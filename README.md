# flutter_langdetect

A Flutter package for language detection, ported from the Python [`langdetect`](https://github.com/Mimino666/langdetect) library.

## Features
- Detects 55 languages
- Lightweight and fast

## Languages
`flutter_langdetect` supports 55 languages out of the box ([ISO 639-1 codes](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes)):

    af, ar, bg, bn, ca, cs, cy, da, de, el, en, es, et, fa, fi, fr, gu, he,
    hi, hr, hu, id, it, ja, kn, ko, lt, lv, mk, ml, mr, ne, nl, no, pa, pl,
    pt, ro, ru, sk, sl, so, sq, sv, sw, ta, te, th, tl, tr, uk, ur, vi, zh-cn, zh-tw

## Installation

Add `flutter_langdetect` to your `pubspec.yaml` dependencies:

```yaml
dependencies:
  flutter_langdetect: ^0.0.1
```
Then, run flutter pub get to download and install the package.

## Usage
```dart
import 'package:flutter/widgets.dart';

// recommend to import 'as langdetect' because this package shows a simple function name 'detect'
import 'package:flutter_langdetect/flutter_langdetect.dart' as langdetect;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await langdetect.initLangDetect();  // This is needed once in your application after ensureInitialized()

  String text = 'Hello, world!';
  final language = langdetect.detect(text);
  print('Detected language: $language'); // -> "en"

  final probs = detectLangs(text);
  for (final p in probs) {
    print("Language: ${p.lang}");  // -> "en"
    print("Probability: ${p.prob}");  // -> 0.9999964132193504
  }
}
```

## History

The `flutter_langdetect` package is inspired by the Python library [`langdetect`](https://github.com/Mimino666/langdetect) created by [Mimino666](https://github.com/Mimino666). 

In turn, the Python `langdetect` library is a port of Nakatani Shuyo's [language-detection](https://github.com/shuyo/language-detection) library, which is written in Java. 

Both of these projects have contributed significantly to the field of natural language processing and have enabled developers to easily integrate language detection capabilities into their applications.

## Contributing
Contributions are welcome! Feel free to open issues or submit pull requests to improve the package.

## License
This package is licensed under the [Apache 2.0 License](https://www.apache.org/licenses/LICENSE-2.0.html).