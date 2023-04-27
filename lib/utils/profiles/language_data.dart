// A class that holds data on the characteristics of each language.
class LanguageData {
  final Map<String, int> freq;
  final List<int> nWords;
  final String name;

  const LanguageData(
      {required this.freq, required this.nWords, required this.name});
}
