library flutter_langdetect;

import 'detector_factory.dart' show DetectorFactory;
import 'language.dart';

/// Initialize the language detection library.
Future<void> initLangDetect() async {
  await DetectorFactory.initFactory();
}

/// Detect language of the input text and return Language code.
String detect(String text) {
  return DetectorFactory.detect(text);
}

/// Detect language of the input text and return Language codes and probabilities.
List<Language> detectLangs(String text) {
  return DetectorFactory.detectLangs(text);
}
