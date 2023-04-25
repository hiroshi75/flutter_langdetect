import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_langdetect/flutter_langdetect.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_langdetect/detector_factory.dart';
import 'package:logger/logger.dart';

void main() {
  final logger = Logger();
  group('DetectorTest', () {
    test("detector1", () async {
      WidgetsFlutterBinding.ensureInitialized();
      DetectorFactory.profileBasePath = "assets/profiles/";
      await initLangDetect();
      expect(detect('This is a Pen.'), 'en');

      final probs = detectLangs('This is a Pen.');
      for (final p in probs) {
        logger.d("Language: ${p.lang}");
        logger.d("Probability: ${p.prob}");
      }
    });
  });
}
