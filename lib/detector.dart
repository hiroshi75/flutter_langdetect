import 'dart:math';

import 'utils/ngram.dart';
import 'utils/unicode_block.dart';
import 'language.dart';
import 'lang_detect_exception.dart';
import 'detector_factory.dart';
import 'package:logger/logger.dart';

///   [Detector] class is to detect language from specified text.
///
///   Its instance is able to be constructed via the factory class [DetectorFactory].
///   After appending a target text to the [Detector] instance with [append(string)],
///   the detector provides the language detection results for target text via [detect()] or [getProbabilities()].
///   [detect()] method returns a single language name which has the highest probability.
///   [getProbabilities()] methods returns a list of multiple languages and their probabilities.
///   The detector has some parameters for language detection.
///   See [setAlpha(double)], [setMaxTextLength(int)] [setPriorMap(dict)].
///
///   Example:
///  ```
///  import 'package:flutter_langdetect/flutter_langdetect.dart';
///  import 'package:flutter/widgets.dart';
///  import 'package:logger/logger.dart';
///  void main() async {
///    WidgetsFlutterBinding.ensureInitialized();
///    DetectorFactory.profileBasePath = "assets/profiles/";
///    await initLangDetect();
///    final s = "Hello, world!";
///    final langs = detect(s);
///    logger.d("langs: ${langs}");
///  }
/// ```
///
class Detector {
  final logger = Logger();
  static const double alphaDefault = 0.5;
  static const double alphaWidth = 0.05;
  static const int iterationLimit = 1000;
  static const double probThreshold = 0.1;
  static const double convThreshold = 0.99999;
  static const int baseFreq = 10000;
  static const String unknownLang = 'unknown';
  static final RegExp ureRe =
      RegExp(r'https?://[-_.?&~;+=/#0-9A-Za-z]{1,2076}');
  static final RegExp mailRe =
      RegExp(r'[-_.0-9A-Za-z]{1,64}@[-_0-9A-Za-z]{1,255}[-_.0-9A-Za-z]{1,255}');

  final DetectorFactory factory;
  late Map<String, List<double>> wordLangProbMap;
  late List<String> langList;
  int seed;
  late Random random;
  String text = '';
  List<double>? langProb;

  double alpha = alphaDefault;
  int nTrial = 7;
  int maxTextLength = 10000;
  List<double>? priorMap;
  bool verbose = false;

  /// Construct [Detector] instance.
  Detector(this.factory)
      : seed = factory.seed ?? DateTime.now().millisecondsSinceEpoch {
    wordLangProbMap = factory.wordLangProbMap;
    langList = factory.langList;
    random = Random();
  }

  void setVerbose() {
    verbose = true;
  }

  void setAlpha(double alpha) {
    this.alpha = alpha;
  }

  /// Set prior information about language probabilities.
  void setPriorMap(Map<String, double> priorMap) {
    this.priorMap = List<double>.filled(langList.length, 0.0);
    double sump = 0.0;
    for (int i = 0; i < this.priorMap!.length; i++) {
      String lang = langList[i];
      if (priorMap.containsKey(lang)) {
        double p = priorMap[lang]!;
        if (p < 0) {
          throw LangDetectException(ErrorCode.initParamError,
              'Prior probability must be non-negative.');
        }
        this.priorMap![i] = p;
        sump += p;
      }
    }
    if (sump <= 0.0) {
      throw LangDetectException(ErrorCode.initParamError,
          'More one of prior probability must be non-zero.');
    }
    for (int i = 0; i < this.priorMap!.length; i++) {
      this.priorMap![i] /= sump;
    }
  }

  /// Specify max size of target text to use for language detection.
  ///
  /// The default value is 10000(10KB).
  void setMaxTextLength(int maxTextLength) {
    this.maxTextLength = maxTextLength;
  }

  /// Append the target text for language detection.
  ///
  /// If the total size of target text exceeds the limit size specified by
  /// [Detector.set_max_text_length(int)], the rest is cut down.
  void append(String text) {
    text = text.replaceAll(ureRe, ' ');
    text = text.replaceAll(mailRe, ' ');
    text = NGram.normalizeVi(text);
    String pre = ' ';
    for (int i = 0; i < min(text.length, maxTextLength); i++) {
      String ch = text[i];
      if (ch != ' ' || pre != ' ') {
        this.text += ch;
      }
      pre = ch;
    }
  }

  /// Cleaning text to detect
  ///
  /// (eliminate URL, e-mail address and Latin sentence if it is not written in Latin alphabet).
  void cleaningText() {
    int latinCount = 0;
    int nonLatinCount = 0;
    for (int codeUnit in text.codeUnits) {
      String ch = String.fromCharCode(codeUnit);
      if ('A'.compareTo(ch) <= 0 && ch.compareTo('z') <= 0) {
        latinCount++;
      } else if (ch.compareTo('\u0300') >= 0 &&
          unicodeBlock(ch) != UnicodeBlock.unicodeLatinExtendedAdditional) {
        nonLatinCount++;
      }
    }

    if (latinCount * 2 < nonLatinCount) {
      String textWithoutLatin = '';
      for (int codeUnit in text.codeUnits) {
        String ch = String.fromCharCode(codeUnit);
        if (ch.compareTo('A') < 0 || ch.compareTo('z') > 0) {
          textWithoutLatin += ch;
        }
      }
      text = textWithoutLatin;
    }
  }

  /// Detect language of the target text and return the language name which has the highest probability.
  String detect() {
    List<Language> probabilities = getProbabilities();
    if (probabilities.isNotEmpty) {
      return probabilities[0].lang;
    }
    return unknownLang;
  }

  List<Language> getProbabilities() {
    if (langProb == null) {
      _detectBlock();
    }
    return _sortProbability(langProb!);
  }

  void _detectBlock() {
    cleaningText();
    List<String> ngrams = _extractNgrams();
    if (ngrams.isEmpty) {
      throw LangDetectException(
          ErrorCode.cantDetectError, 'No features in text.');
    }

    langProb = List<double>.filled(langList.length, 0.0);

    random = Random(seed);
    for (int t = 0; t < nTrial; t++) {
      List<double> prob = _initProbability();
      double alpha = this.alpha + random.nextDouble() * alphaWidth;

      int i = 0;
      while (true) {
        _updateLangProb(prob, getRandomElement(random, ngrams), alpha);
        if (i % 5 == 0) {
          if (_normalizeProb(prob) > convThreshold || i >= iterationLimit) {
            break;
          }
        }
        i++;
      }
      for (int j = 0; j < langProb!.length; j++) {
        langProb![j] += prob[j] / nTrial;
      }
    }
  }

  String getRandomElement(Random random, List<String> list) {
    if (list.isEmpty) {
      return "";
    }
    int randomIndex = random.nextInt(list.length);
    return list[randomIndex];
  }

  List<double> _initProbability() {
    if (priorMap != null) {
      return List.from(priorMap!);
    } else {
      return List<double>.filled(langList.length, 1.0 / langList.length);
    }
  }

  List<String> _extractNgrams() {
    List<String> result = [];
    NGram ngram = NGram();
    for (String ch in text.split('')) {
      ngram.addChar(ch);
      if (ngram.capitalword) {
        continue;
      }
      for (int n = 1; n <= NGram.nGram; n++) {
        String? w = ngram.get(n);
        if (w != null &&
            w != "" &&
            w != ' ' &&
            wordLangProbMap.containsKey(w)) {
          result.add(w);
        }
      }
    }
    return result;
  }

  void _updateLangProb(List<double> prob, String word, double alpha) {
    if (word.isEmpty || !wordLangProbMap.containsKey(word)) {
      return;
    }

    List<double> langProbMap = wordLangProbMap[word]!;
    if (verbose) {
      logger.d('$word($word): ${_wordProbToString(langProbMap)}');
    }

    double weight = alpha / baseFreq;
    for (int i = 0; i < prob.length; i++) {
      prob[i] *= weight + langProbMap[i];
    }
  }

  String _wordProbToString(List<double> prob) {
    String result = '';
    for (int j = 0; j < prob.length; j++) {
      double p = prob[j];
      if (p >= 0.00001) {
        result += ' ${langList[j]}:${p.toStringAsFixed(5)}';
      }
    }
    return result;
  }

  /// Normalize probabilities and check convergence by the maximun probability.
  double _normalizeProb(List<double> prob) {
    double maxp = 0.0;
    double sump = prob.reduce((a, b) => a + b);
    for (int i = 0; i < prob.length; i++) {
      double p = prob[i] / sump;
      if (maxp < p) {
        maxp = p;
      }
      prob[i] = p;
    }
    return maxp;
  }

  List<Language> _sortProbability(List<double> prob) {
    List<Language> result = [];
    for (int i = 0; i < langList.length; i++) {
      double p = prob[i];
      if (p > probThreshold) {
        result.add(Language(langList[i], p));
      }
    }
    result.sort((a, b) => -a.prob.compareTo(b.prob));
    return result;
  }
}
