import 'unicode_block.dart' show UnicodeBlock, unicodeBlock;
import 'ngram_data.dart';

class NGram {
  static const LATIN1_EXCLUDED = "\u00A0\u00AB\u00B0\u00BB";
  static const N_GRAM = 3;
  static Map<String, String> CJK_MAP = {};

  String grams = ' ';
  bool capitalword = false;

  static void init_cjk_map() {
    if (CJK_MAP.isEmpty) {
      for (final cjk_list in NGramData.CJK_LIST) {
        final representative = cjk_list[0];
        for (int i = 0; i < cjk_list.length; i++) {
          CJK_MAP[cjk_list[i]] = representative;
        }
      }
    }
  }

  void addChar(String ch) {
    ch = normalize(ch);
    String lastChar = grams[grams.length - 1];
    if (lastChar == ' ') {
      grams = ' ';
      capitalword = false;
      if (ch == ' ') {
        return;
      }
    } else if (grams.length >= N_GRAM) {
      grams = grams.substring(1);
    }
    grams += ch;

    if (isUpperCase(ch)) {
      if (isUpperCase(lastChar)) {
        capitalword = true;
      }
    } else {
      capitalword = false;
    }
  }

  String? get(int n) {
    if (capitalword) {
      return null;
    }
    if (n < 1 || n > N_GRAM || grams.length < n) {
      return null;
    }
    if (n == 1) {
      String ch = grams[grams.length - 1];
      if (ch == ' ') {
        return null;
      }
      return ch;
    } else {
      return grams.substring(grams.length - n);
    }
  }

  bool isUpperCase(String ch) {
    return ch.codeUnitAt(0) >= 'A'.codeUnitAt(0) &&
        ch.codeUnitAt(0) <= 'Z'.codeUnitAt(0);
  }

  static String normalize(String ch) {
    final block = unicodeBlock(ch);
    if (block == UnicodeBlock.UNICODE_BASIC_LATIN) {
      if (ch.compareTo('A') < 0 ||
          (ch.compareTo('Z') > 0 && ch.compareTo('a') < 0) ||
          ch.compareTo('z') > 0) {
        ch = ' ';
      }
    } else if (block == UnicodeBlock.UNICODE_LATIN_1_SUPPLEMENT) {
      if (LATIN1_EXCLUDED.contains(ch)) {
        ch = ' ';
      }
    } else if (block == UnicodeBlock.UNICODE_LATIN_EXTENDED_B) {
      // normalization for Romanian
      if (ch == '\u0219') {
        // Small S with comma below => with cedilla
        ch = '\u015f';
      }
      if (ch == '\u021b') {
        // Small T with comma below => with cedilla
        ch = '\u0163';
      }
    } else if (block == UnicodeBlock.UNICODE_GENERAL_PUNCTUATION) {
      ch = ' ';
    } else if (block == UnicodeBlock.UNICODE_ARABIC) {
      if (ch == '\u06cc') {
        ch = '\u064a'; // Farsi yeh => Arabic yeh
      }
    } else if (block == UnicodeBlock.UNICODE_LATIN_EXTENDED_ADDITIONAL) {
      if (ch.compareTo('\u1ea0') >= 0) {
        ch = '\u1ec3';
      }
    } else if (block == UnicodeBlock.UNICODE_HIRAGANA) {
      ch = '\u3042';
    } else if (block == UnicodeBlock.UNICODE_KATAKANA) {
      ch = '\u30a2';
    } else if (block == UnicodeBlock.UNICODE_BOPOMOFO ||
        block == UnicodeBlock.UNICODE_BOPOMOFO_EXTENDED) {
      ch = '\u3105';
    } else if (block == UnicodeBlock.UNICODE_CJK_UNIFIED_IDEOGRAPHS) {
      ch = CJK_MAP[ch] ?? ch;
    } else if (block == UnicodeBlock.UNICODE_HANGUL_SYLLABLES) {
      ch = '\uac00';
    }
    return ch;
  }

  static List<String> normalizedViChars = [
    NORMALIZED_VI_CHARS_0300,
    NORMALIZED_VI_CHARS_0301,
    NORMALIZED_VI_CHARS_0303,
    NORMALIZED_VI_CHARS_0309,
    NORMALIZED_VI_CHARS_0323
  ];
  static String toNormalizeViChars = TO_NORMALIZE_VI_CHARS;
  static String dmarkClass = DMARK_CLASS;
  static RegExp alphabetWithDmark = RegExp(
    '([$toNormalizeViChars])([$dmarkClass])',
    unicode: true,
  );

  static String normalizeVi(String text) {
    String repl(Match m) {
      int alphabet = toNormalizeViChars.indexOf(m.group(1)!);
      int dmark = dmarkClass.indexOf(m.group(2)!); // Diacritical Mark
      return normalizedViChars[dmark][alphabet];
    }

    return text.replaceAllMapped(alphabetWithDmark, repl);
  }
}
