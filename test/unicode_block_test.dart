import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_langdetect/utils/unicode_block.dart'; // The actual import path of the UnicodeBlock enum and unicodeBlock function

void main() {
  group('UnicodeBlockTest', () {
    test('test_unicode_block', () {
      expect(unicodeBlock('\u0065'), UnicodeBlock.unicodeBasicLatin);
      expect(unicodeBlock('\u007F'), UnicodeBlock.unicodeBasicLatin);
      expect(unicodeBlock('\u0080'), UnicodeBlock.unicodeLatin1Supplement);
      expect(unicodeBlock('\u21FF'), UnicodeBlock.unicodeArrows);
      expect(unicodeBlock('\u2200'), UnicodeBlock.unicodeMathematicalOperators);
      expect(unicodeBlock('\u2201'), UnicodeBlock.unicodeMathematicalOperators);
      expect(unicodeBlock('\u22FF'), UnicodeBlock.unicodeMathematicalOperators);
      expect(
          unicodeBlock('\u2300'), UnicodeBlock.unicodeMiscellaneousTechnical);
    });
  });
}
