class Language {
  String lang;
  double prob;

  Language(this.lang, this.prob);

  @override
  String toString() {
    if (lang == null) {
      return '';
    }
    return '$lang:$prob';
  }

  bool operator <(Language other) {
    return this.prob < other.prob;
  }
}
