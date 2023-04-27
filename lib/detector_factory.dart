import 'dart:convert';

import 'detector.dart';
import 'lang_detect_exception.dart';
import 'utils/lang_profile.dart';
import 'language.dart';
import 'package:logger/logger.dart';
import 'utils/profiles/all_language_profiles.dart';

/// Language Detector Factory Class.
/// This class manages an initialization and constructions of Detector.
/// Before using language detection library,
/// initialize just once with initFactory() method after
/// WidgetsFlutterBinding.ensureInitialized();
///
/// When the language detection,
/// construct Detector instance via DetectorFactory.create().
/// See also Detector's sample code.
class DetectorFactory {
  final logger = Logger();
  static final DetectorFactory _singleton = DetectorFactory._internal();
  static String profileBasePath =
      "packages/flutter_langdetect/assets/profiles/";

  factory DetectorFactory() {
    return _singleton;
  }

  DetectorFactory._internal();
  static bool _initialized = false;

  static Future<void> initFactory() async {
    if (_initialized == false) {
      await DetectorFactory().loadProfile();
      _initialized = true;
    }
  }

  /// Detect language of the input text and return Language code.
  static String detect(String text) {
    Detector detector = DetectorFactory().create();
    detector.append(text);
    return detector.detect();
  }

  /// Detect language of the input text and return Language codes and probabilities.
  static List<Language> detectLangs(String text) {
    Detector detector = DetectorFactory().create();
    detector.append(text);
    return detector.getProbabilities();
  }

  int? seed;

  Map<String, List<double>> wordLangProbMap = {};
  List<String> langList = [];

  Future<void> loadProfile() async {
    logger.d("loadProfile");
    int langSize = allLanguageProfiles.length;
    int index = 0;
    for (final languageProfile in allLanguageProfiles) {
      LangProfile profile = LangProfile(
          name: languageProfile.name,
          freq: languageProfile.freq,
          nWords: languageProfile.nWords);
      addProfile(profile, index, langSize);
      index += 1;
    }
  }

  void loadJsonProfile(List<String> jsonProfiles) {
    int langSize = jsonProfiles.length;
    int index = 0;
    if (langSize < 2) {
      throw LangDetectException(
          ErrorCode.needLoadProfileError, 'Need more than 2 profiles.');
    }

    for (String jsonProfile in jsonProfiles) {
      try {
        final jsonData = jsonDecode(jsonProfile);
        LangProfile profile = LangProfile(
            name: jsonData['name'],
            freq: (jsonData['freq'] as Map<String, dynamic>)
                .map((key, value) => MapEntry(key, value.toInt())),
            nWords: (jsonData['n_words'].cast<int>() as List<int>));
        addProfile(profile, index, langSize);
        index += 1;
      } catch (e) {
        throw LangDetectException(
            ErrorCode.formatError, 'Profile format error.$jsonProfile');
      }
    }
  }

  void addProfile(LangProfile profile, int index, int langSize) {
    String lang = profile.name!;
    if (langList.contains(lang)) {
      final s = langList.toString();
      throw LangDetectException(ErrorCode.duplicateLangError,
          'Duplicate the same language profile. $s');
    }
    langList.add(lang);

    profile.freq.forEach((String word, int count) {
      if (!wordLangProbMap.containsKey(word)) {
        wordLangProbMap[word] = List<double>.filled(langSize, 0.0);
      }
      int length = word.length;
      if (1 <= length && length <= 3) {
        double prob = 1.0 * count / profile.nWords[length - 1];
        wordLangProbMap[word]![index] = prob;
      }
    });
  }

  void clear() {
    langList = [];
    wordLangProbMap = {};
  }

  Detector create({double? alpha}) {
    Detector detector = _createDetector();
    if (alpha != null) {
      detector.setAlpha(alpha);
    }
    return detector;
  }

  Detector _createDetector() {
    if (langList.isEmpty) {
      throw LangDetectException(
          ErrorCode.needLoadProfileError, 'Need to load profiles.');
    }
    return Detector(this);
  }

  void setSeed(int seed) {
    this.seed = seed;
  }

  List<String> getLangList() {
    return List<String>.from(langList);
  }
}
