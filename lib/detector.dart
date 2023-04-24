import 'dart:math';
import 'utils/ngram.dart';
import 'utils/unicode_block.dart';
import 'language.dart';
import 'lang_detect_exception.dart';
import 'detector_factory.dart';
import 'package:logger/logger.dart';

class Detector {
  final logger = Logger();
  static const double ALPHA_DEFAULT = 0.5;
  static const double ALPHA_WIDTH = 0.05;
  static const int ITERATION_LIMIT = 1000;
  static const double PROB_THRESHOLD = 0.1;
  static const double CONV_THRESHOLD = 0.99999;
  static const int BASE_FREQ = 10000;
  static const String UNKNOWN_LANG = 'unknown';
  static final RegExp URL_RE =
      RegExp(r'https?://[-_.?&~;+=/#0-9A-Za-z]{1,2076}');
  static final RegExp MAIL_RE =
      RegExp(r'[-_.0-9A-Za-z]{1,64}@[-_0-9A-Za-z]{1,255}[-_.0-9A-Za-z]{1,255}');

  final DetectorFactory factory;
  late Map<String, List<double>> wordLangProbMap;
  late List<String> langList;
  int seed;
  late Random random;
  String text = '';
  List<double>? langProb;

  double alpha = ALPHA_DEFAULT;
  int nTrial = 7;
  int maxTextLength = 10000;
  List<double>? priorMap;
  bool verbose = false;

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

  void setPriorMap(Map<String, double> priorMap) {
    this.priorMap = List<double>.filled(langList.length, 0.0);
    double sump = 0.0;
    for (int i = 0; i < this.priorMap!.length; i++) {
      String lang = langList[i];
      if (priorMap.containsKey(lang)) {
        double p = priorMap[lang]!;
        if (p < 0) {
          throw LangDetectException(ErrorCode.InitParamError,
              'Prior probability must be non-negative.');
        }
        this.priorMap![i] = p;
        sump += p;
      }
    }
    if (sump <= 0.0) {
      throw LangDetectException(ErrorCode.InitParamError,
          'More one of prior probability must be non-zero.');
    }
    for (int i = 0; i < this.priorMap!.length; i++) {
      this.priorMap![i] /= sump;
    }
  }

  void setMaxTextLength(int maxTextLength) {
    this.maxTextLength = maxTextLength;
  }

  void append(String text) {
    text = text.replaceAll(URL_RE, ' ');
    text = text.replaceAll(MAIL_RE, ' ');
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

  void cleaningText() {
    int latinCount = 0;
    int nonLatinCount = 0;
    for (int codeUnit in text.codeUnits) {
      String ch = String.fromCharCode(codeUnit);
      if ('A'.compareTo(ch) <= 0 && ch.compareTo('z') <= 0) {
        latinCount++;
      } else if (ch.compareTo('\u0300') >= 0 &&
          unicodeBlock(ch) != 'Latin Extended Additional') {
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

  String detect() {
    List<Language> probabilities = getProbabilities();
    if (probabilities.isNotEmpty) {
      return probabilities[0].lang;
    }
    return UNKNOWN_LANG;
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
          ErrorCode.CantDetectError, 'No features in text.');
    }

    langProb = List<double>.filled(langList.length, 0.0);

    random = Random(seed);
    for (int t = 0; t < nTrial; t++) {
      List<double> prob = _initProbability();
      double alpha = this.alpha + random.nextDouble() * ALPHA_WIDTH;

      int i = 0;
      while (true) {
        _updateLangProb(prob, getRandomElement(random, ngrams), alpha);
        if (i % 5 == 0) {
          if (_normalizeProb(prob) > CONV_THRESHOLD || i >= ITERATION_LIMIT) {
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
      for (int n = 1; n <= NGram.N_GRAM; n++) {
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

    double weight = alpha / BASE_FREQ;
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
      if (p > PROB_THRESHOLD) {
        result.add(Language(langList[i], p));
      }
    }
    result.sort((a, b) => -a.prob.compareTo(b.prob));
    return result;
  }
}
