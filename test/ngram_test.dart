import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_langdetect/utils/ngram.dart';

void main() {
  group('NGramTest', () {
    test('test_constants', () {
      expect(NGram.nGram, 3);
    });

    test('test_normalize_with_latin', () {
      expect(NGram.normalize('\u{0000}'), ' ');
      expect(NGram.normalize('\u{0009}'), ' ');
      expect(NGram.normalize('\u{0020}'), ' ');
      expect(NGram.normalize('\u{0030}'), ' ');
      expect(NGram.normalize('\u{0040}'), ' ');
      expect(NGram.normalize('\u{0041}'), '\u{0041}');
      expect(NGram.normalize('\u{005a}'), '\u{005a}');
      expect(NGram.normalize('\u{005b}'), ' ');
      expect(NGram.normalize('\u{0060}'), ' ');
      expect(NGram.normalize('\u{0061}'), '\u{0061}');
      expect(NGram.normalize('\u{007a}'), '\u{007a}');
      expect(NGram.normalize('\u{007b}'), ' ');
      expect(NGram.normalize('\u{007f}'), ' ');
      expect(NGram.normalize('\u{0080}'), '\u{0080}');
      expect(NGram.normalize('\u{00a0}'), ' ');
      expect(NGram.normalize('\u{00a1}'), '\u{00a1}');
    });

    test('test_normalize_with_cjk_kanji', () {
      expect(NGram.normalize('\u{4E00}'), '\u{4E00}');
      expect(NGram.normalize('\u{4E01}'), '\u{4E01}');
      expect(NGram.normalize('\u{4E02}'), '\u{4E02}');
      expect(NGram.normalize('\u{4E03}'), '\u{4E01}');
      expect(NGram.normalize('\u{4E04}'), '\u{4E04}');
      expect(NGram.normalize('\u{4E05}'), '\u{4E05}');
    });
    test('test_normalize_with_cjk_kanji0', () {
      expect(NGram.normalize('\u{4E06}'), '\u{4E06}');
      expect(NGram.normalize('\u{4E07}'), '\u{4E07}');
      expect(NGram.normalize('\u{4E08}'), '\u{4E08}');
      expect(NGram.normalize('\u{4E09}'), '\u{4E09}');
      expect(NGram.normalize('\u{4E10}'), '\u{4E10}');
      expect(NGram.normalize('\u{4E11}'), '\u{4E11}');
      expect(NGram.normalize('\u{4E12}'), '\u{4E12}');
    });
    test('test_normalize_with_cjk_kanji1', () {
      expect(NGram.normalize('\u{4E13}'), '\u{4E13}');
    });
    test('test_normalize_with_cjk_kanji2', () {
      expect(NGram.normalize('\u{4E14}'), '\u{4E14}');
      expect(NGram.normalize('\u{4E15}'), '\u{4E15}');
      expect(NGram.normalize('\u{4E1e}'), '\u{4E1e}');
      expect(NGram.normalize('\u{4E1f}'), '\u{4E1f}');
      expect(NGram.normalize('\u{4E20}'), '\u{4E20}');
      expect(NGram.normalize('\u{4E21}'), '\u{4E21}');
      expect(NGram.normalize('\u{4E22}'), '\u{4E22}');
      expect(NGram.normalize('\u{4E23}'), '\u{4E23}');
      expect(NGram.normalize('\u{4E24}'), '\u{4E13}');
      expect(NGram.normalize('\u{4E25}'), '\u{4E13}');
      expect(NGram.normalize('\u{4E30}'), '\u{4E30}');
    });

    test('test_normalize_for_romanian', () {
      expect(NGram.normalize('\u{015f}'), '\u{015f}');
      expect(NGram.normalize('\u{0163}'), '\u{0163}');
      expect(NGram.normalize('\u{0219}'), '\u{015f}');
      expect(NGram.normalize('\u{021b}'), '\u{0163}');
    });

    test('test_ngram', () {
      final ngram = NGram();
      expect(ngram.get(0), isNull);
      expect(ngram.get(1), isNull);
      expect(ngram.get(2), isNull);
      expect(ngram.get(3), isNull);
      expect(ngram.get(4), isNull);
      ngram.addChar(' ');
      expect(ngram.get(1), isNull);
      expect(ngram.get(2), isNull);
      expect(ngram.get(3), isNull);
      ngram.addChar('A');
      expect(ngram.get(1), 'A');
      expect(ngram.get(2), ' A');
      expect(ngram.get(3), isNull);
      ngram.addChar('\u{06cc}');
      expect(ngram.get(1), '\u{064a}');
      expect(ngram.get(2), 'A\u{064a}');
      expect(ngram.get(3), ' A\u{064a}');
      ngram.addChar('\u{1ea0}');
      expect(ngram.get(1), '\u{1ec3}');
      expect(ngram.get(2), '\u{064a}\u{1ec3}');
      expect(ngram.get(3), 'A\u{064a}\u{1ec3}');
      ngram.addChar('\u{3044}');
      expect(ngram.get(1), '\u{3042}');
      expect(ngram.get(2), '\u{1ec3}\u{3042}');
      expect(ngram.get(3), '\u{064a}\u{1ec3}\u{3042}');
      ngram.addChar('\u{30a4}');
      expect(ngram.get(1), '\u{30a2}');
      expect(ngram.get(2), '\u{3042}\u{30a2}');
      expect(ngram.get(3), '\u{1ec3}\u{3042}\u{30a2}');
      ngram.addChar('\u{3106}');
      expect(ngram.get(1), '\u{3105}');
      expect(ngram.get(2), '\u{30a2}\u{3105}');
      expect(ngram.get(3), '\u{3042}\u{30a2}\u{3105}');
      ngram.addChar('\u{ac01}');
      expect(ngram.get(1), '\u{ac00}');
      expect(ngram.get(2), '\u{3105}\u{ac00}');
      expect(ngram.get(3), '\u{30a2}\u{3105}\u{ac00}');
      ngram.addChar('\u{2010}');
      expect(ngram.get(1), isNull);
      expect(ngram.get(2), '\u{ac00} ');
      expect(ngram.get(3), '\u{3105}\u{ac00} ');

      ngram.addChar('a');
      expect(ngram.get(1), 'a');
      expect(ngram.get(2), ' a');
      expect(ngram.get(3), isNull);
    });

    test('test_ngram3', () {
      final ngram = NGram();

      ngram.addChar('A');
      expect(ngram.get(1), 'A');
      expect(ngram.get(2), ' A');
      expect(ngram.get(3), isNull);

      ngram.addChar('1');
      expect(ngram.get(1), isNull);
      expect(ngram.get(2), 'A ');
      expect(ngram.get(3), ' A ');

      ngram.addChar('B');
      expect(ngram.get(1), 'B');
      expect(ngram.get(2), ' B');
      expect(ngram.get(3), isNull);
    });

    test('test_normalizeVietnamese', () {
      expect(NGram.normalizeVi(''), '');
      expect(NGram.normalizeVi('ABC'), 'ABC');
      expect(NGram.normalizeVi('012'), '012');
      expect(NGram.normalizeVi('\u00c0'), '\u00c0');

      expect(NGram.normalizeVi('\u0041\u0300'), '\u00C0');
      expect(NGram.normalizeVi('\u0045\u0300'), '\u00C8');
      expect(NGram.normalizeVi('\u0049\u0300'), '\u00CC');
      expect(NGram.normalizeVi('\u004F\u0300'), '\u00D2');
      expect(NGram.normalizeVi('\u0055\u0300'), '\u00D9');
      expect(NGram.normalizeVi('\u0059\u0300'), '\u1EF2');
      expect(NGram.normalizeVi('\u0061\u0300'), '\u00E0');
      expect(NGram.normalizeVi('\u0065\u0300'), '\u00E8');
      expect(NGram.normalizeVi('\u0069\u0300'), '\u00EC');
      expect(NGram.normalizeVi('\u006F\u0300'), '\u00F2');
      expect(NGram.normalizeVi('\u0075\u0300'), '\u00F9');
      expect(NGram.normalizeVi('\u0079\u0300'), '\u1EF3');
      expect(NGram.normalizeVi('\u00C2\u0300'), '\u1EA6');
      expect(NGram.normalizeVi('\u00CA\u0300'), '\u1EC0');
      expect(NGram.normalizeVi('\u00D4\u0300'), '\u1ED2');
      expect(NGram.normalizeVi('\u00E2\u0300'), '\u1EA7');
      expect(NGram.normalizeVi('\u00EA\u0300'), '\u1EC1');
      expect(NGram.normalizeVi('\u00F4\u0300'), '\u1ED3');
      expect(NGram.normalizeVi('\u0102\u0300'), '\u1EB0');
      expect(NGram.normalizeVi('\u0103\u0300'), '\u1EB1');
      expect(NGram.normalizeVi('\u01A0\u0300'), '\u1EDC');
      expect(NGram.normalizeVi('\u01A1\u0300'), '\u1EDD');
      expect(NGram.normalizeVi('\u01AF\u0300'), '\u1EEA');
      expect(NGram.normalizeVi('\u01B0\u0300'), '\u1EEB');

      expect(NGram.normalizeVi('\u0041\u0301'), '\u00C1');
      expect(NGram.normalizeVi('\u0045\u0301'), '\u00C9');
      expect(NGram.normalizeVi('\u0049\u0301'), '\u00CD');
      expect(NGram.normalizeVi('\u004F\u0301'), '\u00D3');
      expect(NGram.normalizeVi('\u0055\u0301'), '\u00DA');
      expect(NGram.normalizeVi('\u0059\u0301'), '\u00DD');
      expect(NGram.normalizeVi('\u0061\u0301'), '\u00E1');
      expect(NGram.normalizeVi('\u0065\u0301'), '\u00E9');
      expect(NGram.normalizeVi('\u006F\u0309'), '\u1ECF');
      expect(NGram.normalizeVi('\u0075\u0309'), '\u1EE7');
      expect(NGram.normalizeVi('\u0079\u0309'), '\u1EF7');
      expect(NGram.normalizeVi('\u00C2\u0309'), '\u1EA8');
      expect(NGram.normalizeVi('\u00CA\u0309'), '\u1EC2');
      expect(NGram.normalizeVi('\u00D4\u0309'), '\u1ED4');
      expect(NGram.normalizeVi('\u00E2\u0309'), '\u1EA9');
      expect(NGram.normalizeVi('\u00EA\u0309'), '\u1EC3');
      expect(NGram.normalizeVi('\u00F4\u0309'), '\u1ED5');
      expect(NGram.normalizeVi('\u0102\u0309'), '\u1EB2');
      expect(NGram.normalizeVi('\u0103\u0309'), '\u1EB3');
      expect(NGram.normalizeVi('\u01A0\u0309'), '\u1EDE');
      expect(NGram.normalizeVi('\u01A1\u0309'), '\u1EDF');
      expect(NGram.normalizeVi('\u01AF\u0309'), '\u1EEC');
      expect(NGram.normalizeVi('\u01B0\u0309'), '\u1EED');

      expect(NGram.normalizeVi('\u0041\u0323'), '\u1EA0');
      expect(NGram.normalizeVi('\u0045\u0323'), '\u1EB8');
      expect(NGram.normalizeVi('\u0049\u0323'), '\u1ECA');
      expect(NGram.normalizeVi('\u004F\u0323'), '\u1ECC');
      expect(NGram.normalizeVi('\u0055\u0323'), '\u1EE4');
      expect(NGram.normalizeVi('\u0059\u0323'), '\u1EF4');
      expect(NGram.normalizeVi('\u0061\u0323'), '\u1EA1');
      expect(NGram.normalizeVi('\u0065\u0323'), '\u1EB9');
      expect(NGram.normalizeVi('\u0069\u0323'), '\u1ECB');
      expect(NGram.normalizeVi('\u006F\u0323'), '\u1ECD');
      expect(NGram.normalizeVi('\u0075\u0323'), '\u1EE5');
      expect(NGram.normalizeVi('\u0079\u0323'), '\u1EF5');
      expect(NGram.normalizeVi('\u00C2\u0323'), '\u1EAC');
      expect(NGram.normalizeVi('\u00CA\u0323'), '\u1EC6');
      expect(NGram.normalizeVi('\u00D4\u0323'), '\u1ED8');
      expect(NGram.normalizeVi('\u00E2\u0323'), '\u1EAD');
      expect(NGram.normalizeVi('\u00EA\u0323'), '\u1EC7');
      expect(NGram.normalizeVi('\u00F4\u0323'), '\u1ED9');
      expect(NGram.normalizeVi('\u0102\u0323'), '\u1EB6');
      expect(NGram.normalizeVi('\u0103\u0323'), '\u1EB7');
      expect(NGram.normalizeVi('\u01A0\u0323'), '\u1EE2');
      expect(NGram.normalizeVi('\u01A1\u0323'), '\u1EE3');
      expect(NGram.normalizeVi('\u01AF\u0323'), '\u1EF0');
      expect(NGram.normalizeVi('\u01B0\u0323'), '\u1EF1');
    });
  });
}
