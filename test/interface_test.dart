import 'package:flutter_test/flutter_test.dart';
import '../lib/langdetect.dart';
import 'package:flutter/widgets.dart';
import '../lib/detector_factory.dart';

void main() {
  group('DetectorTest', () {
    test("detector1", () async {
      WidgetsFlutterBinding.ensureInitialized();
      DetectorFactory.profileBasePath = "assets/profiles/";
      await initLangDetect();
      expect(detect('This is a Pen.'), 'en');
    });
  });
}
