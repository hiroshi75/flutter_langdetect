import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

class Messages {
  static const String messagesFilename = 'assets/messages.properties';
  static final Messages _singleton = Messages._internal();

  factory Messages() {
    return _singleton;
  }

  Messages._internal();

  final Map<String, String> _messages = {};

  Future<void> _loadMessages() async {
    String data = await rootBundle.loadString(messagesFilename);
    data.split('\n').forEach((line) {
      List<String> parts = line.split('=');
      if (parts.length == 2) {
        String key = parts[0].trim();
        String value = parts[1].trim().replaceAllMapped(
            RegExp(r'\\u([\da-fA-F]{4})'),
            (match) =>
                String.fromCharCode(int.parse(match.group(1)!, radix: 16)));

        _messages[key] = value;
      }
    });
  }

  Future<String> getString(String key) async {
    if (_messages.isEmpty) {
      await _loadMessages();
    }
    return _messages[key] ?? '!$key!';
  }
}

Future<String> getString(String key) async {
  return await Messages().getString(key);
}
