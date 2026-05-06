// fields + loading + signup logic + AuthSession + state
import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../services/auth_service.dart';
import '../../services/auth_session.dart';

class SignUpController extends ChangeNotifier {
  SignUpController({AuthService authService = const AuthService()})
    : _authService = authService {
    _onFirstNameChanged = () {
      if (firstNameFieldError == null) return;

      firstNameFieldError = null;
      notifyListeners();
    };

    _onLastNameChanged = () {
      if (lastNameFieldError == null) return;

      lastNameFieldError = null;
      notifyListeners();
    };

    _onPhoneChanged = () {
      if (phoneFieldError == null) return;

      phoneFieldError = null;
      notifyListeners();
    };

    _onPasswordChanged = () {
      if (passwordFieldError == null) return;

      passwordFieldError = null;
      notifyListeners();
    };

    _onConfirmPasswordChanged = () {
      if (confirmPasswordFieldError == null) return;

      confirmPasswordFieldError = null;
      notifyListeners();
    };

    firstNameController.addListener(_onFirstNameChanged);
    lastNameController.addListener(_onLastNameChanged);
    phoneController.addListener(_onPhoneChanged);
    passwordController.addListener(_onPasswordChanged);
    confirmPasswordController.addListener(_onConfirmPasswordChanged);
  }

  final AuthService _authService;

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  late final VoidCallback _onFirstNameChanged;
  late final VoidCallback _onLastNameChanged;
  late final VoidCallback _onPhoneChanged;
  late final VoidCallback _onPasswordChanged;
  late final VoidCallback _onConfirmPasswordChanged;

  bool showPassword = false;
  bool showConfirmPassword = false;
  bool loading = false;

  String selectedCountry = 'فلسطين';
  String? errorMessage;
  DateTime? selectedBirthDate;

  String? firstNameFieldError;
  String? lastNameFieldError;
  String? phoneFieldError;
  String? birthDateFieldError;
  String? passwordFieldError;
  String? confirmPasswordFieldError;

  Timer? _errorTimer;

  void togglePasswordVisibility() {
    showPassword = !showPassword;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    showConfirmPassword = !showConfirmPassword;
    notifyListeners();
  }

  void changeCountry(String value) {
    selectedCountry = value;
    notifyListeners();
  }

  void changeBirthDate(DateTime date) {
    selectedBirthDate = date;
    birthDateFieldError = null;
    notifyListeners();
  }

  void showError(String message) {
    errorMessage = message;
    firstNameFieldError = null;
    lastNameFieldError = null;
    phoneFieldError = null;
    birthDateFieldError = null;
    passwordFieldError = null;
    confirmPasswordFieldError = null;
    notifyListeners();

    _errorTimer?.cancel();
    _errorTimer = Timer(const Duration(seconds: 5), () {
      errorMessage = null;
      notifyListeners();
    });
  }

  Future<AppUser> signUp() async {
    loading = true;
    notifyListeners();

    try {
      final AppUser user = await _authService.signUpCustomer(
        firstName: firstNameController.text,
        lastName: lastNameController.text,
        phoneNumber: phoneController.text,
        password: passwordController.text,
        confirmPassword: confirmPasswordController.text,
        birthDate: selectedBirthDate,
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
      throw const SignUpControllerException('حدث خطأ غير متوقع، حاول مرة أخرى');
    }
  }

  @override
  void dispose() {
    firstNameController.removeListener(_onFirstNameChanged);
    lastNameController.removeListener(_onLastNameChanged);
    phoneController.removeListener(_onPhoneChanged);
    passwordController.removeListener(_onPasswordChanged);
    confirmPasswordController.removeListener(_onConfirmPasswordChanged);

    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    _errorTimer?.cancel();

    super.dispose();
  }
}

class SignUpControllerException implements Exception {
  const SignUpControllerException(this.message);

  final String message;

  @override
  String toString() => message;
}
