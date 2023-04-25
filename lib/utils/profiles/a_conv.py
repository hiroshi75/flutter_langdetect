import glob
import os
import re

"""
多数のjsonファイル(ファイル名:profiles/*)に以下の形式でデータが入っている
{"freq":{"a":230,"h":33,...},"n_words":[1541130,1808182,1328687],"name":"af"}

これを以下のdartプログラムに変更して、lang_{name}.dartとして保存する
```
import 'language_data.dart';

const afLanguageData = LanguageData(
  freq: const {
    'a': 230,
    'h': 33,
    // ...
  },
  nWords: const [1541130, 1808182, 1328687],
  name: 'af',
);
```

"""

def main():
    namelist = []
    for path in glob.glob('../../../assets/profiles/*'):
        name = os.path.splitext(os.path.basename(path))[0].replace('-', '')
        print(f'Generating {name}...')
        with open(path, 'r', encoding='utf-8') as f:
            data = f.read()
        data = data.replace('"freq":', 'freq: ')
        data = data.replace('"n_words":', 'nWords: ')
        data = data.replace('"name":', 'name: ')
        # 末尾}を);に置換
        data = re.sub(r'}\s*$', ');', data, flags=re.MULTILINE)
        # 先頭の{を消す
        data = re.sub(r'^\s*{', '', data, flags=re.MULTILINE)

        with open(f'profiles_data/lang_{name}.dart', 'w', encoding='utf-8') as f:
            f.write('import \'../language_data.dart\';\n\n')
            f.write(f'const {name}LanguageData = LanguageData(\n')
            f.write(data)
        print(f'Generated {name}.')
        namelist.append(name)
    
    """
    namelistに入っている言語名をもとに、以下の１つのdartファイルを生成する。

    ```
    import 'language_data.dart';

    import 'profiles_data/lang_af.dart';
    // 他の言語データファイルもインポートする

    const allLanguageProfiles = const [ 
      afLanguageData,
      // 他の言語データも追加する
    ];
    ```
    """
    print('Generating all_language_profiles.dart...')
    with open('all_language_profiles.dart', 'w', encoding='utf-8') as f:
        f.write('import \'language_data.dart\';\n\n')
        for name in namelist:
            f.write(f'import \'profiles_data/lang_{name}.dart\';\n')
        f.write('\n')
        f.write('const allLanguageProfiles = [\n')
        for name in namelist:
            f.write(f'  {name}LanguageData,\n')
        f.write('];\n')

        

if __name__ == '__main__':
    main()

