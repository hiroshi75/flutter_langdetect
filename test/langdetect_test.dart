import 'package:flutter_test/flutter_test.dart';
import '../lib/detector_factory.dart'; // DetectorFactory を含むファイルへの適切なインポートを指定してください
import '../lib/utils/lang_profile.dart'; // LangProfile を含むファイルへの適切なインポートを指定してください

void main() {
  group('DetectorTest', () {
    final trainingEn = 'a a a b b c c d e';
    final trainingFr = 'a b b c c c d d d';
    final trainingJa = '\u3042 \u3042 \u3042 \u3044 \u3046 \u3048 \u3048';

    DetectorFactory? factory;

    setUp(() async {
      //await DetectorFactory.initFactory();
      DetectorFactory.profileBasePath = "assets/profiles/";
      factory = DetectorFactory();
      factory!.clear();

      final profileEn = LangProfile(name: 'en');
      for (final w in trainingEn.split(' ')) {
        profileEn.add(w);
      }
      factory!.addProfile(profileEn, 0, 3);

      final profileFr = LangProfile(name: 'fr');
      for (final w in trainingFr.split(' ')) {
        profileFr.add(w);
      }
      factory!.addProfile(profileFr, 1, 3);

      final profileJa = LangProfile(name: 'ja');
      for (final w in trainingJa.split(' ')) {
        profileJa.add(w);
      }
      factory!.addProfile(profileJa, 2, 3);
    });

    test('detector1', () {
      final detect = factory!.create();
      detect.append('a');
      expect(detect.detect(), 'en');
    });

    test('detector2', () {
      final detect = factory!.create();
      detect.append('b d');
      expect(detect.detect(), 'fr');
    });

    test('detector3', () {
      final detect = factory!.create();
      detect.append('d e');
      expect(detect.detect(), 'en');
    });

    test('detector4', () {
      final detect = factory!.create();
      detect.append('\u3042\u3042\u3042\u3042a');
      expect(detect.detect(), 'ja');
    });

    test('lang_list', () {
      final langList = factory!.getLangList();
      expect(langList.length, 3);
      expect(langList[0], 'en');
      expect(langList[1], 'fr');
      expect(langList[2], 'ja');
    });

    test('factory_from_json_string', () {
      factory!.clear();
      final profiles = [
        '{"freq":{"A":3,"B":6,"C":3,"AB":2,"BC":1,"ABC":2,"BBC":1,"CBA":1},"n_words":[12,3,4],"name":"lang1"}',
        '{"freq":{"A":6,"B":3,"C":3,"AA":3,"AB":2,"ABC":1,"ABA":1,"CAA":1},"n_words":[12,5,3],"name":"lang2"}',
      ];
      factory!.loadJsonProfile(profiles);
      final langList = factory!.getLangList();
      expect(langList.length, 2);
      expect(langList[0], 'lang1');
      expect(langList[1], 'lang2');
    });
  });
}
