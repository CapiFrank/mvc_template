import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'session_token', value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'session_token');
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: 'session_token');
  }

  static Future<String> generateSecureKey() async {
    final key = List<int>.generate(32, (_) => Random.secure().nextInt(256));
    final base64Key = base64UrlEncode(key);
    await _storage.write(key: 'encryption_key', value: base64Key);
    return base64Key;
  }

  static Future<String> getOrCreateKey() async {
    String? key = await _storage.read(key: 'encryption_key');
    key ??= await generateSecureKey();
    return key;
  }
}
