class Language {
  String lang;
  double prob;

  Language(this.lang, this.prob);

  @override
  String toString() {
    return '$lang:$prob';
  }

  bool operator <(Language other) {
    return prob < other.prob;
  }
}
