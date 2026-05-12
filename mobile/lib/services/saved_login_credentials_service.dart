import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SavedLoginCredentials {
  const SavedLoginCredentials({
    required this.phoneNumber,
    required this.password,
    required this.role,
    required this.country,
    required this.rememberLogin,
    required this.biometricEnabled,
  });

  final String phoneNumber;
  final String password;
  final String role;
  final String country;
  final bool rememberLogin;
  final bool biometricEnabled;

  bool get hasRequiredLoginData {
    return phoneNumber.trim().isNotEmpty &&
        password.trim().isNotEmpty &&
        role.trim().isNotEmpty;
  }
}

class SavedLoginCredentialsService {
  const SavedLoginCredentialsService({
    FlutterSecureStorage secureStorage = const FlutterSecureStorage(),
  }) : _secureStorage = secureStorage;

  final FlutterSecureStorage _secureStorage;

  static const String _phoneNumberKey = 'saved_login_phone_number';
  static const String _passwordKey = 'saved_login_password';
  static const String _roleKey = 'saved_login_role';
  static const String _countryKey = 'saved_login_country';
  static const String _rememberLoginKey = 'saved_login_remember_login';
  static const String _biometricEnabledKey = 'saved_login_biometric_enabled';

  Future<void> saveCredentials({
    required String phoneNumber,
    required String password,
    required String role,
    required String country,
    required bool biometricEnabled,
  }) async {
    await _secureStorage.write(key: _phoneNumberKey, value: phoneNumber.trim());
    await _secureStorage.write(key: _passwordKey, value: password);
    await _secureStorage.write(key: _roleKey, value: role.trim());
    await _secureStorage.write(key: _countryKey, value: country.trim());
    await _secureStorage.write(key: _rememberLoginKey, value: 'true');
    await _secureStorage.write(
      key: _biometricEnabledKey,
      value: biometricEnabled ? 'true' : 'false',
    );
  }

  Future<SavedLoginCredentials?> readCredentials() async {
    final String? phoneNumber = await _secureStorage.read(key: _phoneNumberKey);
    final String? password = await _secureStorage.read(key: _passwordKey);
    final String? role = await _secureStorage.read(key: _roleKey);
    final String? country = await _secureStorage.read(key: _countryKey);
    final String? rememberLogin = await _secureStorage.read(
      key: _rememberLoginKey,
    );
    final String? biometricEnabled = await _secureStorage.read(
      key: _biometricEnabledKey,
    );

    if (phoneNumber == null &&
        password == null &&
        role == null &&
        country == null) {
      return null;
    }

    return SavedLoginCredentials(
      phoneNumber: phoneNumber ?? '',
      password: password ?? '',
      role: role ?? 'customer',
      country: country == null || country.trim().isEmpty ? 'فلسطين' : country,
      rememberLogin: rememberLogin == 'true',
      biometricEnabled: biometricEnabled == 'true',
    );
  }

  Future<bool> hasSavedCredentials() async {
    final SavedLoginCredentials? credentials = await readCredentials();
    return credentials != null && credentials.hasRequiredLoginData;
  }

  Future<bool> isBiometricLoginEnabled() async {
    final String? value = await _secureStorage.read(key: _biometricEnabledKey);

    return value == 'true';
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    await _secureStorage.write(
      key: _biometricEnabledKey,
      value: enabled ? 'true' : 'false',
    );
  }

  Future<void> clearCredentials() async {
    await _secureStorage.delete(key: _phoneNumberKey);
    await _secureStorage.delete(key: _passwordKey);
    await _secureStorage.delete(key: _roleKey);
    await _secureStorage.delete(key: _countryKey);
    await _secureStorage.delete(key: _rememberLoginKey);
    await _secureStorage.delete(key: _biometricEnabledKey);
  }
}
