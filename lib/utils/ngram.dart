import 'unicode_block.dart' show UnicodeBlock, unicodeBlock;
import 'ngram_data.dart';

class NGram {
  static const latin1Excluded = "\u00A0\u00AB\u00B0\u00BB";
  static const nGram = 3;
  static Map<String, String> cjkMap = {};

  String grams = ' ';
  bool capitalword = false;
  NGram() {
    initCjkMap();
  }

  static void initCjkMap() {
    if (cjkMap.isEmpty) {
      for (final cjkList in NGramData.cjkList) {
        final representative = cjkList[0];
        for (int i = 0; i < cjkList.length; i++) {
          cjkMap[cjkList[i]] = representative;
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
    } else if (grams.length >= nGram) {
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
    if (n < 1 || n > nGram || grams.length < n) {
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
    initCjkMap();
    final block = unicodeBlock(ch);
    if (block == UnicodeBlock.unicodeBasicLatin) {
      if (ch.compareTo('A') < 0 ||
          (ch.compareTo('Z') > 0 && ch.compareTo('a') < 0) ||
          ch.compareTo('z') > 0) {
        ch = ' ';
      }
    } else if (block == UnicodeBlock.unicodeLatin1Supplement) {
      if (latin1Excluded.contains(ch)) {
        ch = ' ';
      }
    } else if (block == UnicodeBlock.unicodeLatinExtendedB) {
      // normalization for Romanian
      if (ch == '\u0219') {
        // Small S with comma below => with cedilla
        ch = '\u015f';
      }
      if (ch == '\u021b') {
        // Small T with comma below => with cedilla
        ch = '\u0163';
      }
    } else if (block == UnicodeBlock.unicodeGeneralPunctuation) {
      ch = ' ';
    } else if (block == UnicodeBlock.unicodeArabic) {
      if (ch == '\u06cc') {
        ch = '\u064a'; // Farsi yeh => Arabic yeh
      }
    } else if (block == UnicodeBlock.unicodeLatinExtendedAdditional) {
      if (ch.compareTo('\u1ea0') >= 0) {
        ch = '\u1ec3';
      }
    } else if (block == UnicodeBlock.unicodeHiragana) {
      ch = '\u3042';
    } else if (block == UnicodeBlock.unicodeKatakana) {
      ch = '\u30a2';
    } else if (block == UnicodeBlock.unicodeBopomofo ||
        block == UnicodeBlock.unicodeBopomofoExtended) {
      ch = '\u3105';
    } else if (block == UnicodeBlock.unicodeCjkUnifiedIdeographs) {
      ch = cjkMap[ch] ?? ch;
    } else if (block == UnicodeBlock.unicodeHangulSyllables) {
      ch = '\uac00';
    }
    return ch;
  }

  static List<String> normalizedViChars = [
    normalizedViChars0300,
    normalizedViChars0301,
    normalizedViChars0303,
    normalizedViChars0309,
    normalizedViChars0323
  ];
  static String toNormalizeViChars = toNormalizeViCharsNorm;
  static String dmarkClass = dmarkClassChars;
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
