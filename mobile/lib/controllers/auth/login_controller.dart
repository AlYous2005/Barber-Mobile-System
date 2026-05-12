// fields + loading + role + login logic + AuthSession
import 'dart:async';

import 'package:flutter/material.dart';

import '../../features/auth/auth.dart';
import '../../services/auth_session.dart';
import '../../services/biometric_auth_service.dart';
import '../../services/saved_login_credentials_service.dart';

class LoginController extends ChangeNotifier {
  LoginController({
    AuthService authService = const AuthService(),
    SavedLoginCredentialsService credentialsService =
        const SavedLoginCredentialsService(),
    BiometricAuthService? biometricAuthService,
  }) : _authService = authService,
       _credentialsService = credentialsService,
       _biometricAuthService = biometricAuthService ?? BiometricAuthService() {
    _onUsernameChanged = () {
      if (usernameFieldError == null) return;

      usernameFieldError = null;
      notifyListeners();
    };

    _onPasswordChanged = () {
      if (passwordFieldError == null) return;

      passwordFieldError = null;
      notifyListeners();
    };

    usernameController.addListener(_onUsernameChanged);
    passwordController.addListener(_onPasswordChanged);

    loadSavedLoginSettings();
  }

  final AuthService _authService;
  final SavedLoginCredentialsService _credentialsService;
  final BiometricAuthService _biometricAuthService;

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  late final VoidCallback _onUsernameChanged;
  late final VoidCallback _onPasswordChanged;

  bool showPassword = false;
  bool loading = false;
  bool rememberLogin = false;
  bool biometricEnabled = false;
  bool canUseBiometricLogin = false;
  bool isLoadingSavedCredentials = false;
  bool isBiometricActionLoading = false;
  bool showFastLoginOptions = false;

  String selectedRole = 'customer';
  String selectedCountry = 'فلسطين';

  /// Full display name from customer signup.
  String? signedUpCustomerDisplayName;

  String? errorMessage;
  Timer? _errorTimer;

  String? usernameFieldError;
  String? passwordFieldError;

  String get selectedCountryCode {
    return selectedCountry == 'فلسطين' ? '+970' : '+972';
  }

  String get internationalPhoneNumber {
    return _buildInternationalPhoneNumber(
      rawPhone: usernameController.text,
      country: selectedCountry,
    );
  }

  String _countryCodeFor(String country) {
    return country == 'فلسطين' ? '+970' : '+972';
  }

  String _buildInternationalPhoneNumber({
    required String rawPhone,
    required String country,
  }) {
    final String trimmedPhone = rawPhone.trim();

    if (trimmedPhone.isEmpty) {
      return '';
    }

    if (trimmedPhone.startsWith('+')) {
      return trimmedPhone.replaceAll(RegExp(r'\s+'), '');
    }

    final String digitsOnly = trimmedPhone.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitsOnly.isEmpty) {
      return '';
    }

    if (digitsOnly.startsWith('970') || digitsOnly.startsWith('972')) {
      return '+$digitsOnly';
    }

    final String normalizedLocalNumber = digitsOnly.startsWith('0')
        ? digitsOnly.substring(1)
        : digitsOnly;

    return '${_countryCodeFor(country)}$normalizedLocalNumber';
  }

  Future<void> loadSavedLoginSettings() async {
    isLoadingSavedCredentials = true;
    notifyListeners();

    try {
      final SavedLoginCredentials? credentials = await _credentialsService
          .readCredentials();

      if (credentials == null || !credentials.rememberLogin) {
        rememberLogin = false;
        biometricEnabled = false;
        canUseBiometricLogin = false;
        return;
      }

      rememberLogin = true;
      biometricEnabled = credentials.biometricEnabled;
      canUseBiometricLogin =
          credentials.biometricEnabled && credentials.hasRequiredLoginData;

      selectedRole = credentials.role.trim().isEmpty
          ? 'customer'
          : credentials.role;

      selectedCountry = credentials.country.trim().isEmpty
          ? 'فلسطين'
          : credentials.country;

      usernameController.text = credentials.phoneNumber;
      passwordController.text = credentials.password;
    } catch (_) {
      rememberLogin = false;
      biometricEnabled = false;
      canUseBiometricLogin = false;
    } finally {
      isLoadingSavedCredentials = false;
      notifyListeners();
    }
  }

  Future<void> changeRememberLogin(bool value) async {
    rememberLogin = value;

    if (!rememberLogin) {
      biometricEnabled = false;
      canUseBiometricLogin = false;
      await _credentialsService.clearCredentials();
    }

    notifyListeners();
  }

  Future<void> changeBiometricEnabled(bool value) async {
    if (value && !rememberLogin) {
      showError('فعّل حفظ بيانات الدخول أولًا حتى تتمكن من استخدام البصمة');
      return;
    }

    biometricEnabled = value;

    if (!value) {
      canUseBiometricLogin = false;
      await _credentialsService.setBiometricEnabled(false);
    }

    notifyListeners();
  }

  void changeCountry(String value) {
    selectedCountry = value;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    showPassword = !showPassword;
    notifyListeners();
  }

  void toggleFastLoginOptions() {
    showFastLoginOptions = !showFastLoginOptions;
    notifyListeners();
  }

  void changeRole(String role) {
    selectedRole = role;
    notifyListeners();
  }

  void setSignedUpCustomerDisplayName(String? displayName) {
    signedUpCustomerDisplayName =
        displayName != null && displayName.trim().isNotEmpty
        ? displayName.trim()
        : null;

    notifyListeners();
  }

  void showError(String message) {
    errorMessage = message;
    usernameFieldError = null;
    passwordFieldError = null;
    notifyListeners();

    _errorTimer?.cancel();
    _errorTimer = Timer(const Duration(seconds: 5), () {
      errorMessage = null;
      notifyListeners();
    });
  }

  Future<void> _saveOrClearCredentialsAfterSuccessfulLogin() async {
    if (!rememberLogin) {
      biometricEnabled = false;
      canUseBiometricLogin = false;
      await _credentialsService.clearCredentials();
      return;
    }

    await _credentialsService.saveCredentials(
      phoneNumber: usernameController.text.trim(),
      password: passwordController.text,
      role: selectedRole,
      country: selectedCountry,
      biometricEnabled: biometricEnabled,
    );

    canUseBiometricLogin = biometricEnabled;
  }

  Future<AppUser> login() async {
    loading = true;
    notifyListeners();

    try {
      final AppUser user = await _authService.login(
        username: internationalPhoneNumber,
        password: passwordController.text,
        role: selectedRole,
        signedUpCustomerDisplayName: signedUpCustomerDisplayName,
      );

      AuthSession.start(user);

      await _saveOrClearCredentialsAfterSuccessfulLogin();

      loading = false;
      notifyListeners();

      return user;
    } on AuthException catch (error) {
      loading = false;
      notifyListeners();

      showError(error.message);
      rethrow;
    } catch (_) {
      loading = false;
      notifyListeners();

      showError('حدث خطأ غير متوقع، حاول مرة أخرى');
      throw const LoginControllerException('حدث خطأ غير متوقع، حاول مرة أخرى');
    }
  }

  Future<AppUser> loginWithBiometrics() async {
    isBiometricActionLoading = true;
    notifyListeners();

    try {
      final SavedLoginCredentials? credentials = await _credentialsService
          .readCredentials();

      if (credentials == null || !credentials.hasRequiredLoginData) {
        throw const LoginControllerException(
          'لا توجد بيانات دخول محفوظة لاستخدام البصمة',
        );
      }

      if (!credentials.biometricEnabled) {
        throw const LoginControllerException('الدخول بالبصمة غير مفعّل');
      }

      final bool authenticated = await _biometricAuthService.authenticate(
        reason: 'أكد هويتك لتسجيل الدخول إلى Barb',
      );

      if (!authenticated) {
        throw const LoginControllerException('تعذر التحقق من البصمة');
      }

      final String savedPhoneNumber = _buildInternationalPhoneNumber(
        rawPhone: credentials.phoneNumber,
        country: credentials.country,
      );

      final AppUser user = await _authService.login(
        username: savedPhoneNumber,
        password: credentials.password,
        role: credentials.role,
        signedUpCustomerDisplayName: signedUpCustomerDisplayName,
      );

      AuthSession.start(user);

      selectedRole = credentials.role;
      selectedCountry = credentials.country;
      usernameController.text = credentials.phoneNumber;
      passwordController.text = credentials.password;
      rememberLogin = true;
      biometricEnabled = true;
      canUseBiometricLogin = true;

      isBiometricActionLoading = false;
      notifyListeners();

      return user;
    } on AuthException catch (error) {
      isBiometricActionLoading = false;
      notifyListeners();

      showError(error.message);
      rethrow;
    } on LoginControllerException catch (error) {
      isBiometricActionLoading = false;
      notifyListeners();

      showError(error.message);
      rethrow;
    } catch (_) {
      isBiometricActionLoading = false;
      notifyListeners();

      showError('تعذر تسجيل الدخول بالبصمة، حاول مرة أخرى');
      throw const LoginControllerException(
        'تعذر تسجيل الدخول بالبصمة، حاول مرة أخرى',
      );
    }
  }

  @override
  void dispose() {
    usernameController.removeListener(_onUsernameChanged);
    passwordController.removeListener(_onPasswordChanged);

    usernameController.dispose();
    passwordController.dispose();

    _errorTimer?.cancel();

    super.dispose();
  }
}

class LoginControllerException implements Exception {
  const LoginControllerException(this.message);

  final String message;

  @override
  String toString() => message;
}
