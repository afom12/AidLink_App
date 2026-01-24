import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecurePreferences {
  static const _biometricEnabledKey = 'aidlink_biometric_enabled';

  final FlutterSecureStorage? _storage =
      kIsWeb ? null : const FlutterSecureStorage();
  bool? _memoryBiometricEnabled;

  Future<bool> isBiometricEnabled() async {
    if (_storage == null) {
      return _memoryBiometricEnabled ?? false;
    }
    final value = await _storage.read(key: _biometricEnabledKey);
    return value == 'true';
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    if (_storage == null) {
      _memoryBiometricEnabled = enabled;
      return;
    }
    await _storage.write(key: _biometricEnabledKey, value: '$enabled');
  }
}

