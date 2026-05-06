// fields + loading + role + login logic + AuthSession
import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../services/auth_service.dart';
import '../../services/auth_session.dart';

class LoginController extends ChangeNotifier {
  LoginController({AuthService authService = const AuthService()})
    : _authService = authService {
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
  }

  final AuthService _authService;

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  late final VoidCallback _onUsernameChanged;
  late final VoidCallback _onPasswordChanged;

  bool showPassword = false;
  bool loading = false;
  String selectedRole = 'customer';

  /// Full display name from customer signup.
  String? signedUpCustomerDisplayName;

  String? errorMessage;
  Timer? _errorTimer;

  String? usernameFieldError;
  String? passwordFieldError;

  void togglePasswordVisibility() {
    showPassword = !showPassword;
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

  Future<AppUser> login() async {
    loading = true;
    notifyListeners();

    try {
      final AppUser user = await _authService.login(
        username: usernameController.text,
        password: passwordController.text,
        role: selectedRole,
        signedUpCustomerDisplayName: signedUpCustomerDisplayName,
      );

      AuthSession.start(user);

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
