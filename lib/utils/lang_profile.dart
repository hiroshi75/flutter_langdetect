import 'dart:core';
import 'dart:math';

import 'ngram.dart';

class LangProfile {
  static const int minimumFreq = 2;
  static const int lessFreqRatio = 100000;

  static final RegExp romanCharRe = RegExp(r'^[A-Za-z]$');
  static final RegExp romanSubstrRe = RegExp(r'.*[A-Za-z].*');

  String? name;
  Map<String, int> freq = {};
  List<int> nWords;

  LangProfile({this.name, Map<String, int>? freq, List<int>? nWords})
      : freq = Map<String, int>.from(freq ?? {}),
        nWords = nWords ?? List<int>.filled(NGram.nGram, 0) {
    if (freq != null) {
      this.freq.addAll(freq);
    }
  }

  void add(String? gram) {
    if (name == null || gram == null) return;
    int length = gram.length;
    if (length < 1 || length > NGram.nGram) return;
    nWords[length - 1]++;
    freq.update(gram, (value) => value + 1, ifAbsent: () => 1);
  }

  void omitLessFreq() {
    if (name == null) return;
    int threshold = max(nWords[0] ~/ lessFreqRatio, minimumFreq);

    int roman = 0;
    final keys = freq.keys.toList();
    for (final key in keys) {
      final count = freq[key]!;
      if (count <= threshold) {
        nWords[key.length - 1] -= count;
        freq.remove(key);
      } else if (romanCharRe.hasMatch(key)) {
        roman += count;
      }
    }

    if (roman < nWords[0] ~/ 3) {
      final keys = freq.keys.toList();
      for (final key in keys) {
        final count = freq[key]!;
        if (romanSubstrRe.hasMatch(key)) {
          nWords[key.length - 1] -= count;
          freq.remove(key);
        }
      }
    }
  }

  void update(String? text) {
    if (text == null) return;
    text = NGram.normalizeVi(text);
    NGram gram = NGram();
    for (int i = 0; i < text.length; i++) {
      String ch = text[i];
      gram.addChar(ch);
      for (int n = 1; n <= NGram.nGram; n++) {
        add(gram.get(n));
      }
    }
  }
}
