library flutter_langdetect;

import 'detector_factory.dart' show DetectorFactory, detectLangs, detect;
import 'lang_detect_exception.dart' show LangDetectException;
import 'language.dart';

Future<void> initLangDetect() async {
  await DetectorFactory.initFactory();
}

String detect(String text) {
  return DetectorFactory.detect(text);
}

List<Language> detectLangs(String text) {
  return DetectorFactory.detectLangs(text);
}
