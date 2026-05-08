import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'password_strength_indicator.dart';

import '../../services/auth_service.dart';
import 'auth_country_code_selector.dart';
import 'auth_error_message.dart';
import 'auth_text_field.dart';

enum _ForgotPasswordStep { phone, otp, newPassword, done }

class AuthForgotPasswordSheet extends StatefulWidget {
  const AuthForgotPasswordSheet({super.key});

  @override
  State<AuthForgotPasswordSheet> createState() =>
      _AuthForgotPasswordSheetState();
}

class _AuthForgotPasswordSheetState extends State<AuthForgotPasswordSheet> {
  final AuthService authService = const AuthService();
  static const int _otpLength = 6;

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  late final List<TextEditingController> otpControllers;
  late final List<FocusNode> otpFocusNodes;

  _ForgotPasswordStep step = _ForgotPasswordStep.phone;

  String selectedCountry = 'فلسطين';
  String? errorMessage;
  bool loading = false;
  bool showNewPassword = false;
  bool hasOtpError = false;
  bool showConfirmPassword = false;
  int resendSecondsLeft = 45;
  Timer? _resendTimer;

  String get selectedCountryCode {
    return selectedCountry == 'فلسطين' ? '+970' : '+972';
  }

  String get internationalPhoneNumber {
    final rawPhone = phoneController.text.trim();

    if (rawPhone.startsWith('+')) {
      return rawPhone.replaceAll(RegExp(r'\s+'), '');
    }

    final digitsOnly = rawPhone.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitsOnly.startsWith('970') || digitsOnly.startsWith('972')) {
      return '+$digitsOnly';
    }

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

  String _friendlyAuthError(Object error) {
    final String raw = error.toString().toLowerCase();

    if (raw.contains('user not found') ||
        raw.contains('invalid login credentials') ||
        raw.contains('no user') ||
        raw.contains('not found')) {
      return 'لا يوجد حساب مرتبط بهذا الرقم';
    }

    if (raw.contains('otp') &&
        (raw.contains('invalid') ||
            raw.contains('expired') ||
            raw.contains('token'))) {
      return 'رمز التحقق غير صحيح أو منتهي الصلاحية';
    }

    if (raw.contains('network') ||
        raw.contains('socket') ||
        raw.contains('timeout')) {
      return 'تعذر الاتصال بالشبكة، تحقق من الإنترنت وحاول مرة أخرى';
    }

    if (raw.contains('phone')) {
      return 'رقم الهاتف غير صحيح، يرجى المراجعة والمحاولة مرة أخرى';
    }

    return 'حدث خطأ غير متوقع، حاول مرة أخرى';
  }

  @override
  void initState() {
    super.initState();
    otpControllers = List<TextEditingController>.generate(
      _otpLength,
      (_) => TextEditingController(),
    );
    otpFocusNodes = List<FocusNode>.generate(_otpLength, (_) => FocusNode());
  }

  @override
  void dispose() {
    phoneController.dispose();
    for (final controller in otpControllers) {
      controller.dispose();
    }
    for (final focusNode in otpFocusNodes) {
      focusNode.dispose();
    }
    _resendTimer?.cancel();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  String get _otpCode {
    return otpControllers.map((controller) => controller.text).join();
  }

  bool get _isOtpComplete {
    return _otpCode.length == _otpLength;
  }

  void _startResendCooldown() {
    _resendTimer?.cancel();
    resendSecondsLeft = 45;
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (resendSecondsLeft <= 1) {
        timer.cancel();
        setState(() {
          resendSecondsLeft = 0;
        });
        return;
      }
      setState(() {
        resendSecondsLeft -= 1;
      });
    });
  }

  void _clearOtpInputs() {
    hasOtpError = false;
    for (final controller in otpControllers) {
      controller.clear();
    }
  }

  void _onOtpDigitChanged({required int index, required String value}) {
    if (hasOtpError || errorMessage != null) {
      setState(() {
        hasOtpError = false;
        errorMessage = null;
      });
    }

    if (value.isEmpty) {
      if (index > 0) {
        otpFocusNodes[index - 1].requestFocus();
      }
      return;
    }

    final normalized = value.characters.last;
    otpControllers[index].text = normalized;
    otpControllers[index].selection = TextSelection.collapsed(
      offset: normalized.length,
    );

    if (index < _otpLength - 1) {
      otpFocusNodes[index + 1].requestFocus();
      return;
    }

    otpFocusNodes[index].unfocus();
  }

  Future<void> sendOtp() async {
    final String? phoneValidationError = _validatePhoneInput();
    if (phoneValidationError != null) {
      setState(() {
        errorMessage = phoneValidationError;
      });
      return;
    }

    setState(() {
      loading = true;
      hasOtpError = false;
      errorMessage = null;
    });

    try {
      debugPrint('FORGOT PASSWORD PHONE = $internationalPhoneNumber');

      await authService.sendPasswordResetOtp(
        phoneNumber: internationalPhoneNumber,
      );

      if (!mounted) return;

      setState(() {
        step = _ForgotPasswordStep.otp;
        loading = false;
        _clearOtpInputs();
        _startResendCooldown();
      });
      otpFocusNodes.first.requestFocus();
    } catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = _friendlyAuthError(error);
        loading = false;
      });
    }
  }

  Future<void> verifyOtp() async {
    if (!_isOtpComplete) {
      setState(() {
        hasOtpError = true;
        errorMessage = 'الرجاء إدخال رمز التحقق كاملاً (6 أرقام)';
      });
      return;
    }

    setState(() {
      loading = true;
      hasOtpError = false;
      errorMessage = null;
    });

    try {
      await authService.verifyPasswordResetOtp(
        phoneNumber: internationalPhoneNumber,
        otpCode: _otpCode,
      );

      if (!mounted) return;

      setState(() {
        step = _ForgotPasswordStep.newPassword;
        loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        hasOtpError = true;
        errorMessage = 'رمز التحقق خطأ';
        loading = false;
      });
    }
  }

  Future<void> updatePassword() async {
    setState(() {
      loading = true;
      errorMessage = null;
      hasOtpError = false;
    });

    try {
      await authService.updateForgottenPassword(
        newPassword: newPasswordController.text,
        confirmPassword: confirmPasswordController.text,
      );

      if (!mounted) return;

      setState(() {
        step = _ForgotPasswordStep.done;
        loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = _friendlyAuthError(error);
        loading = false;
      });
    }
  }

  void goBackOneStep() {
    setState(() {
      errorMessage = null;

      switch (step) {
        case _ForgotPasswordStep.phone:
          Navigator.pop(context);
          break;
        case _ForgotPasswordStep.otp:
          step = _ForgotPasswordStep.phone;
          break;
        case _ForgotPasswordStep.newPassword:
          step = _ForgotPasswordStep.otp;
          break;
        case _ForgotPasswordStep.done:
          Navigator.pop(context);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF151515),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white24),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              final slide = Tween<Offset>(
                begin: const Offset(0, 0.06),
                end: Offset.zero,
              ).animate(animation);

              return FadeTransition(
                opacity: animation,
                child: SlideTransition(position: slide, child: child),
              );
            },
            child: _buildStepContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (step) {
      case _ForgotPasswordStep.phone:
        return _buildPhoneStep();
      case _ForgotPasswordStep.otp:
        return _buildOtpStep();
      case _ForgotPasswordStep.newPassword:
        return _buildNewPasswordStep();
      case _ForgotPasswordStep.done:
        return _buildDoneStep();
    }
  }

  Widget _buildPhoneStep() {
    return Column(
      key: const ValueKey('forgot-phone-step'),
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'استعادة كلمة المرور',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'أدخل رقم الهاتف المرتبط بحسابك لإرسال رمز التحقق',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white60, fontSize: 14, height: 1.5),
        ),

        const SizedBox(height: 18),

        AuthTextField(
          controller: phoneController,
          hintText: 'رقم الهاتف',
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
          prefixIconWidget: AuthCountryCodeSelector(
            selectedCountry: selectedCountry,
            onCountryChanged: (value) {
              setState(() {
                selectedCountry = value;
              });
            },
          ),
        ),

        const SizedBox(height: 12),

        AuthErrorMessage(message: errorMessage),

        const SizedBox(height: 16),

        _PrimaryButton(
          loading: loading,
          loadingText: 'جاري الإرسال...',
          text: 'إرسال رمز التحقق',
          onPressed: sendOtp,
        ),

        const SizedBox(height: 8),

        _SecondaryButton(
          text: 'إغلاق',
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildOtpStep() {
    return Column(
      key: const ValueKey('forgot-otp-step'),
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'تأكيد رقم الهاتف',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'أدخل الرمز المرسل إلى\n$internationalPhoneNumber',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 14,
            height: 1.5,
          ),
        ),

        const SizedBox(height: 18),

        Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List<Widget>.generate(_otpLength, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _OtpDigitField(
                  controller: otpControllers[index],
                  focusNode: otpFocusNodes[index],
                  isVerifying: loading,
                  hasError: hasOtpError,
                  enabled: !loading,
                  onChanged: (value) =>
                      _onOtpDigitChanged(index: index, value: value),
                ),
              );
            }),
          ),
        ),

        const SizedBox(height: 10),

        Text(
          hasOtpError
              ? ''
              : loading
              ? 'جاري التحقق من الرمز...'
              : 'رمز التحقق مكوّن من 6 أرقام',
          style: TextStyle(
            color: hasOtpError
                ? const Color(0xFFEF4444)
                : loading
                ? const Color(0xFF4ADE80)
                : Colors.white60,
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 12),

        AuthErrorMessage(message: errorMessage),

        const SizedBox(height: 16),

        _PrimaryButton(
          loading: loading,
          loadingText: 'جاري التأكيد...',
          text: 'تأكيد الرمز',
          onPressed: verifyOtp,
        ),

        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: _SecondaryButton(text: 'رجوع', onPressed: goBackOneStep),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _SecondaryButton(
                text: resendSecondsLeft > 0
                    ? 'إعادة الإرسال ${resendSecondsLeft}s'
                    : 'إعادة الإرسال',
                onPressed: loading || resendSecondsLeft > 0 ? null : sendOtp,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNewPasswordStep() {
    return Column(
      key: const ValueKey('forgot-new-password-step'),
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'كلمة مرور جديدة',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'ضع كلمة مرور قوية لحسابك',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white60, fontSize: 14),
        ),

        const SizedBox(height: 18),

        AuthTextField(
          controller: newPasswordController,
          hintText: 'كلمة المرور الجديدة',
          icon: Icons.lock,
          obscureText: !showNewPassword,
          suffixIcon: IconButton(
            icon: Icon(
              showNewPassword ? Icons.visibility_off : Icons.visibility,
              color: Colors.white70,
            ),
            onPressed: () {
              setState(() {
                showNewPassword = !showNewPassword;
              });
            },
          ),
        ),

        PasswordStrengthIndicator(controller: newPasswordController),
        const SizedBox(height: 12),

        AuthTextField(
          controller: confirmPasswordController,
          hintText: 'تأكيد كلمة المرور الجديدة',
          icon: Icons.lock_outline,
          obscureText: !showConfirmPassword,
          suffixIcon: IconButton(
            icon: Icon(
              showConfirmPassword ? Icons.visibility_off : Icons.visibility,
              color: Colors.white70,
            ),
            onPressed: () {
              setState(() {
                showConfirmPassword = !showConfirmPassword;
              });
            },
          ),
        ),

        const SizedBox(height: 12),

        AuthErrorMessage(message: errorMessage),

        const SizedBox(height: 16),

        _PrimaryButton(
          loading: loading,
          loadingText: 'جاري التحديث...',
          text: 'تحديث كلمة المرور',
          onPressed: updatePassword,
        ),

        const SizedBox(height: 8),

        _SecondaryButton(text: 'رجوع', onPressed: goBackOneStep),
      ],
    );
  }

  Widget _buildDoneStep() {
    return Column(
      key: const ValueKey('forgot-done-step'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 66,
          height: 66,
          decoration: BoxDecoration(
            color: Colors.greenAccent.withValues(alpha: 0.16),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.greenAccent),
          ),
          child: const Icon(
            Icons.check_rounded,
            color: Colors.greenAccent,
            size: 36,
          ),
        ),

        const SizedBox(height: 14),

        const Text(
          'تم تحديث كلمة المرور',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'يمكنك الآن تسجيل الدخول باستخدام كلمة المرور الجديدة.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white60, fontSize: 14, height: 1.5),
        ),

        const SizedBox(height: 18),

        _PrimaryButton(
          loading: false,
          text: 'العودة لتسجيل الدخول',
          loadingText: '',
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.loading,
    required this.text,
    required this.loadingText,
    required this.onPressed,
  });

  final bool loading;
  final String text;
  final String loadingText;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: Text(
          loading ? loadingText : text,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.text, required this.onPressed});

  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          color: onPressed == null ? Colors.white38 : Colors.white70,
        ),
      ),
    );
  }
}

class _OtpDigitField extends StatelessWidget {
  const _OtpDigitField({
    required this.controller,
    required this.focusNode,
    required this.isVerifying,
    required this.hasError,
    required this.enabled,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isVerifying;
  final bool hasError;
  final bool enabled;
  final ValueChanged<String> onChanged;

  Color get _borderColor {
    if (hasError) return const Color(0xFFEF4444);
    if (isVerifying) return const Color(0xFF4ADE80);
    return Colors.white38;
  }

  Color get _fillColor {
    if (hasError) return const Color(0xFFEF4444).withValues(alpha: 0.10);
    if (isVerifying) return const Color(0xFF4ADE80).withValues(alpha: 0.10);
    return const Color(0x30000000);
  }

  List<BoxShadow> get _boxShadow {
    if (hasError) {
      return [
        BoxShadow(
          color: const Color(0xFFEF4444).withValues(alpha: 0.32),
          blurRadius: 14,
        ),
      ];
    }

    if (isVerifying) {
      return [
        BoxShadow(
          color: const Color(0xFF4ADE80).withValues(alpha: 0.30),
          blurRadius: 14,
        ),
      ];
    }

    return const [];
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: 42,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: _boxShadow,
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        enabled: enabled,
        onChanged: onChanged,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        maxLength: 1,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 21,
          fontWeight: FontWeight.w900,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: _fillColor,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _borderColor, width: 1.35),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _borderColor, width: 1.35),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: hasError
                  ? const Color(0xFFEF4444)
                  : isVerifying
                  ? const Color(0xFF4ADE80)
                  : const Color(0xFFFFC66D),
              width: 1.8,
            ),
          ),
        ),
      ),
    );
  }
}
