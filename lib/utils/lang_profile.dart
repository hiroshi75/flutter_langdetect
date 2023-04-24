import 'dart:collection';
import 'dart:core';
import 'dart:math';

import 'ngram.dart';

class LangProfile {
  static const int minimumFreq = 2;
  static const int lessFreqRatio = 100000;

  static final RegExp romanCharRe = RegExp(r'^[A-Za-z]$');
  static final RegExp romanSubstrRe = RegExp(r'.*[A-Za-z].*');

  String? name;
  Map<String, int> freq = HashMap<String, int>();
  List<int> nWords;

  LangProfile({String? name, Map<String, int>? freq, List<int>? nWords})
      : name = name,
        freq = freq ?? HashMap<String, int>(),
        nWords = nWords ?? List<int>.filled(NGram.N_GRAM, 0) {
    if (freq != null) {
      this.freq.addAll(freq);
    }
  }

  void add(String? gram) {
    if (name == null || gram == null) return;
    int length = gram.length;
    if (length < 1 || length > NGram.N_GRAM) return;
    nWords[length - 1]++;
    freq.update(gram, (value) => value + 1, ifAbsent: () => 1);
  }

  void omitLessFreq() {
    if (name == null) return;
    int threshold = max(nWords[0] ~/ lessFreqRatio, minimumFreq);

    int roman = 0;
    freq.forEach((key, count) {
      if (count <= threshold) {
        nWords[key.length - 1] -= count;
        freq.remove(key);
      } else if (romanCharRe.hasMatch(key)) {
        roman += count;
      }
    });

    if (roman < nWords[0] ~/ 3) {
      freq.forEach((key, count) {
        if (romanSubstrRe.hasMatch(key)) {
          nWords[key.length - 1] -= count;
          freq.remove(key);
        }
      });
    }
  }

  void update(String? text) {
    if (text == null) return;
    text = NGram.normalizeVi(text);
    NGram gram = NGram();
    for (int i = 0; i < text.length; i++) {
      String ch = text[i];
      gram.addChar(ch);
      for (int n = 1; n <= NGram.N_GRAM; n++) {
        add(gram.get(n));
      }
    }
  }
}
