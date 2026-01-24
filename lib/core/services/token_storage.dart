import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _accessTokenKey = 'aidlink_access_token';

  final FlutterSecureStorage? _storage =
      kIsWeb ? null : const FlutterSecureStorage();
  String? _memoryToken;

  Future<void> writeToken(String token) async {
    if (_storage == null) {
      _memoryToken = token;
      return;
    }
    await _storage.write(key: _accessTokenKey, value: token);
  }

  Future<String?> readToken() async {
    if (_storage == null) {
      return _memoryToken;
    }
    return _storage.read(key: _accessTokenKey);
  }

  Future<void> clearToken() async {
    if (_storage == null) {
      _memoryToken = null;
      return;
    }
    await _storage.delete(key: _accessTokenKey);
  }
}

