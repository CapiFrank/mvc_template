import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart' as crypto;
import 'package:bcrypt/bcrypt.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/services.dart';
import 'package:mvc_template/utils/secure_storage.dart';

class Hash {
  /// Genera un hash usando bcrypt (igual que Laravel)
  static String make(String value, {int rounds = 10}) {
    return BCrypt.hashpw(value, BCrypt.gensalt(logRounds: rounds));
  }

  static String token() {
    final random = Random.secure();
    final sessionIdBytes = List<int>.generate(16, (_) => random.nextInt(256));
    String sessionId = String.fromCharCodes(sessionIdBytes);
    return BCrypt.hashpw(sessionId, BCrypt.gensalt());
  }

  /// Verifica si una contraseña coincide con un hash
  static bool check(String value, String hash) {
    return BCrypt.checkpw(value, hash);
  }

  /// Genera un hash SHA-256
  static String sha256(String value) {
    return crypto.sha256.convert(utf8.encode(value)).toString();
  }

  /// Genera un hash SHA-512
  static String sha512(String value) {
    return crypto.sha512.convert(utf8.encode(value)).toString();
  }

  /// Verifica si un hash bcrypt necesita ser actualizado
  static bool needsRehash(String hash, {int rounds = 10}) {
    return BCrypt.gensalt(logRounds: rounds) != hash.substring(0, 29);
  }

  static Future<String> secureToken(String deviceId) async {
    final header = base64Url
        .encode(utf8.encode(jsonEncode({'alg': 'HS256', 'typ': 'JWT'})));
    final payload = base64Url.encode(utf8.encode(jsonEncode({
      'iat': DateTime.now().millisecondsSinceEpoch,
      'exp': DateTime.now().add(Duration(hours: 24)).millisecondsSinceEpoch,
      'device_id': deviceId,
    })));
    final key = await _getSecretKey();
    final signature = hmacSha256('$header.$payload', key);
    return '$header.$payload.${base64Url.encode(signature)}';
  }

  static List<int> hmacSha256(String data, List<int> key) {
    final hmac = crypto.Hmac(crypto.sha256, key);
    return hmac.convert(utf8.encode(data)).bytes;
  }

  static Future<List<int>> _getSecretKey() async {
    final secureKey = await SecureStorage.getOrCreateKey();
    return utf8.encode(secureKey);
  }

  static Future<String> get getDecryptedToken async {
    final encryptedToken = await rootBundle.loadString('assets/746f6b656e.txt');
    final secureKey = await rootBundle.loadString('assets/6b6579.txt');
    final secureIv = await rootBundle.loadString('assets/6976.txt');
    final key = Key.fromBase64(secureKey); // Debe tener 32 caracteres
    final iv = IV.fromBase64(secureIv);

    final encrypter = Encrypter(AES(key));
    final decrypted = encrypter.decrypt64(encryptedToken, iv: iv);

    return decrypted;
  }
}
