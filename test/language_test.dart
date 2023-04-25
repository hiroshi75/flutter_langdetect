import 'package:flutter_test/flutter_test.dart';
import '../lib/language.dart'; // The actual import path of the Language class

void main() {
  group('LanguageTest', () {
    test('test_language', () {
      final lang2 = Language('en', 1.0);
      expect(lang2.lang, 'en');
      expect(lang2.prob, closeTo(1.0, 0.0001));
      expect(lang2.toString(), 'en:1.0');
    });

    test('test_cmp', () {
      final lang1 = Language('a', 0.1);
      final lang2 = Language('b', 0.5);

      expect(lang1 < lang2, isTrue);
      expect(lang1 == lang2, isFalse);
      expect(lang1 > lang1, isFalse);
    });
  });
}
