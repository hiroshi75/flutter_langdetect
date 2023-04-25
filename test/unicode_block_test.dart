import 'package:flutter_test/flutter_test.dart';
import '../lib/utils/unicode_block.dart'; // The actual import path of the UnicodeBlock enum and unicodeBlock function

void main() {
  group('UnicodeBlockTest', () {
    test('test_unicode_block', () {
      expect(unicodeBlock('\u0065'), UnicodeBlock.UNICODE_BASIC_LATIN);
      expect(unicodeBlock('\u007F'), UnicodeBlock.UNICODE_BASIC_LATIN);
      expect(unicodeBlock('\u0080'), UnicodeBlock.UNICODE_LATIN_1_SUPPLEMENT);
      expect(unicodeBlock('\u21FF'), UnicodeBlock.UNICODE_ARROWS);
      expect(
          unicodeBlock('\u2200'), UnicodeBlock.UNICODE_MATHEMATICAL_OPERATORS);
      expect(
          unicodeBlock('\u2201'), UnicodeBlock.UNICODE_MATHEMATICAL_OPERATORS);
      expect(
          unicodeBlock('\u22FF'), UnicodeBlock.UNICODE_MATHEMATICAL_OPERATORS);
      expect(
          unicodeBlock('\u2300'), UnicodeBlock.UNICODE_MISCELLANEOUS_TECHNICAL);
    });
  });
}
