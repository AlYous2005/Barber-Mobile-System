// fields + loading + signup logic + AuthSession + state
// fields + loading + signup logic + state
import 'dart:async';

import 'package:flutter/material.dart';

import '../../features/auth/auth.dart';
import '../../features/locations/locations.dart';

class SignUpController extends ChangeNotifier {
  SignUpController({
    AuthService authService = const AuthService(),
    LocationRepository locationRepository = const LocationRepository(),
  }) : _authService = authService,
       _locationRepository = locationRepository {
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
    loadGovernorates();
  }

  final AuthService _authService;
  final LocationRepository _locationRepository;

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
  List<GovernorateModel> governorates = <GovernorateModel>[];
  List<AreaModel> areas = <AreaModel>[];

  String? selectedGovernorateId;
  String? selectedAreaId;

  bool isLoadingGovernorates = false;
  bool isLoadingAreas = false;
  String? firstNameFieldError;
  String? lastNameFieldError;
  String? phoneFieldError;
  String? birthDateFieldError;
  String? areaFieldError;
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
    areaFieldError = null;
    notifyListeners();
  }

  Future<void> loadGovernorates() async {
    isLoadingGovernorates = true;
    notifyListeners();

    try {
      governorates = await _locationRepository.getActiveGovernorates();
    } catch (_) {
      governorates = <GovernorateModel>[];
      showError('تعذر تحميل المحافظات، حاول مرة أخرى');
    } finally {
      isLoadingGovernorates = false;
      notifyListeners();
    }
  }

  Future<void> changeGovernorate(String? governorateId) async {
    selectedGovernorateId = governorateId;
    selectedAreaId = null;
    areas = <AreaModel>[];
    areaFieldError = null;

    final String cleanGovernorateId = governorateId?.trim() ?? '';

    if (cleanGovernorateId.isEmpty) {
      notifyListeners();
      return;
    }

    isLoadingAreas = true;
    notifyListeners();

    try {
      areas = await _locationRepository.getActiveAreasByGovernorate(
        governorateId: cleanGovernorateId,
      );
    } catch (_) {
      areas = <AreaModel>[];
      showError('تعذر تحميل المناطق، حاول مرة أخرى');
    } finally {
      isLoadingAreas = false;
      notifyListeners();
    }
  }

  void changeArea(String? areaId) {
    selectedAreaId = areaId;
    areaFieldError = null;
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

  String get selectedCountryCode {
    return selectedCountry == 'فلسطين' ? '+970' : '+972';
  }

  String get internationalPhoneNumber {
    final rawPhone = phoneController.text.trim();

    // نحذف أي مسافات أو شرطات كتبها المستخدم
    final digitsOnly = rawPhone.replaceAll(RegExp(r'[^0-9]'), '');

    // إذا الرقم يبدأ بصفر، نحذفه بعد رمز الدولة
    // مثال: 0599350166 -> +970599350166
    final normalizedLocalNumber = digitsOnly.startsWith('0')
        ? digitsOnly.substring(1)
        : digitsOnly;

    return '$selectedCountryCode$normalizedLocalNumber';
  }

  String? _validatePhoneInput() {
    final String rawPhone = phoneController.text.trim();
    final String digitsOnly = rawPhone.replaceAll(RegExp(r'[^0-9]'), '');

    if (rawPhone.isEmpty) {
      return 'الرجاء إدخال رقم الهاتف';
    }

    if (RegExp(r'[A-Za-z\u0621-\u064A]').hasMatch(rawPhone)) {
      return 'يجب أن يتكون الرقم من أرقام وليس أحرف';
    }

    if (digitsOnly.length < 9 || digitsOnly.length > 10) {
      return 'يجب أن يتكون الرقم من 10 أو 9 أرقام فقط';
    }

    return null;
  }

  String _friendlySignUpError(String message) {
    final String raw = message.toLowerCase();

    if (raw.contains('already registered') ||
        raw.contains('user already registered') ||
        raw.contains('duplicate key') ||
        raw.contains('phone_number_key') ||
        raw.contains('already exists') ||
        raw.contains('exists')) {
      return 'لا يمكنك انشاء حساب باستخدام هذا الرقم';
    }

    if (raw.contains('phone')) {
      return 'رقم الهاتف غير صحيح، يرجى إدخال رقم صالح';
    }

    return message;
  }

  Future<PendingPhoneSignUp> signUp() async {
    final String? phoneValidationError = _validatePhoneInput();
    if (phoneValidationError != null) {
      phoneFieldError = phoneValidationError;
      errorMessage = phoneValidationError;
      notifyListeners();
      throw SignUpControllerException(phoneValidationError);
    }

    if (selectedAreaId == null || selectedAreaId!.trim().isEmpty) {
      const String message = 'الرجاء اختيار منطقتك';
      areaFieldError = message;
      errorMessage = message;
      notifyListeners();
      throw const SignUpControllerException(message);
    }

    loading = true;
    notifyListeners();

    try {
      final PendingPhoneSignUp pendingSignUp = await _authService
          .signUpCustomer(
            firstName: firstNameController.text,
            lastName: lastNameController.text,
            phoneNumber: internationalPhoneNumber,
            password: passwordController.text,
            confirmPassword: confirmPasswordController.text,
            birthDate: selectedBirthDate,
            areaId: selectedAreaId,
          );

      loading = false;
      notifyListeners();

      return pendingSignUp;
    } on AuthException catch (error) {
      loading = false;
      notifyListeners();

      showError(_friendlySignUpError(error.message));
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
