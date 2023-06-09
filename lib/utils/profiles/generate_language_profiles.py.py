import glob
import os
import re

"""
Data is stored in the following format in a large number of json files (file name: profiles/*)
{"freq":{"a":230,"h":33,...},"n_words":[1541130,1808182,1328687],"name":"af"}

Convert it to the following dart program and save it as lang_{name}.dart
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
        
        # Replace the last } with );
        data = re.sub(r'}\s*$', ');', data, flags=re.MULTILINE)
        
        # Remove the first {
        data = re.sub(r'^\s*{', '', data, flags=re.MULTILINE)

        with open(f'profiles_data/lang_{name}.dart', 'w', encoding='utf-8') as f:
            f.write("// This is generated by generate_language_profiles.py\n")
            f.write('import \'../language_data.dart\';\n\n')
            f.write(f'const {name}LanguageData = LanguageData(\n')
            f.write(data)
        print(f'Generated {name}.')
        namelist.append(name)
    
    """
    Generate one dart file based on the language name in namelist.

    ```
    import 'language_data.dart';

    import 'profiles_data/lang_af.dart';
    // Import other language data files

    const allLanguageProfiles = const [
        afLanguageData,
        // Add other language data
    ];
    ```
    """
    print('Generating all_language_profiles.dart...')
    with open('all_language_profiles.dart', 'w', encoding='utf-8') as f:
        f.write("// This is generated by generate_language_profiles.py\n")
        for name in namelist:
            f.write(f'import \'profiles_data/lang_{name}.dart\';\n')
        f.write('\n')
        f.write('const allLanguageProfiles = [\n')
        for name in namelist:
            f.write(f'  {name}LanguageData,\n')
        f.write('];\n')

        

if __name__ == '__main__':
    main()

