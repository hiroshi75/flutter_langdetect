import 'package:flutter_test/flutter_test.dart';
import '../lib/utils/lang_profile.dart'; // The actual import path of the LangProfile class

void main() {
  group('LangProfileTest', () {
    test('test_lang_profile', () {
      final profile = LangProfile();
      expect(profile.name, isNull);
    });

    test('test_lang_profile_string_int', () {
      final profile = LangProfile(name: 'en');
      expect(profile.name, 'en');
    });

    test('test_add', () {
      final profile = LangProfile(name: 'en');
      profile.add('a');
      expect(profile.freq['a'], 1);
      profile.add('a');
      expect(profile.freq['a'], 2);
      profile.omitLessFreq();
    });

    test('test_add_illegally1', () {
      final profile = LangProfile();
      profile.add('a'); // ignore
      expect(profile.freq['a'], isNull); // ignored
    });

    test('test_add_illegally2', () {
      final profile = LangProfile(name: 'en');
      profile.add('a');
      profile.add(
          ''); // Illegal (string's length of parameter must be between 1 and 3) but ignore
      profile.add('abcd'); // as well
      expect(profile.freq['a'], 1);
      expect(profile.freq[''], isNull); // ignored
      expect(profile.freq['abcd'], isNull); // ignored
    });

    test('test_omit_less_freq', () {
      final profile = LangProfile(name: 'en');
      final grams = 'a b c あ い う え お か が き ぎ く'.split(' ');
      for (var i = 0; i < 5; i++) {
        for (final g in grams) {
          profile.add(g);
        }
      }
      profile.add('ぐ');

      expect(profile.freq['a'], 5);
      expect(profile.freq['あ'], 5);
      expect(profile.freq['ぐ'], 1);
      profile.omitLessFreq();
      expect(profile.freq['a'], isNull); // omitted
      expect(profile.freq['あ'], 5);
      expect(profile.freq['ぐ'], isNull); // omitted
    });

    test('test_omit_less_freq_illegally', () {
      final profile = LangProfile();
      profile.omitLessFreq(); // ignore
    });
  });
}
