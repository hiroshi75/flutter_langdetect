import 'package:flutter_langdetect/flutter_langdetect.dart' as langdetect;

void main() async {
  // `ensureInitialized` is needed once in your application when you use this library in the actual application.
  // WidgetsFlutterBinding.ensureInitialized();

  // Then, call `initLangDetect` once.
  await langdetect.initLangDetect();

  String text = 'Hello, world!';
  final language = langdetect.detect(text);
  print('Detected language: $language'); // -> "en"

  print('\n');

  final probs = langdetect.detectLangs(text);
  for (final p in probs) {
    print("Language: ${p.lang}");
    print("Probability: ${p.prob}");
  }
}
