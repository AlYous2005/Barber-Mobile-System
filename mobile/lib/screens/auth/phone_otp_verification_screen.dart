import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../features/auth/auth.dart';
import '../../services/auth_session.dart';
import '../../widgets/auth/auth_background.dart';
import '../../widgets/auth/auth_card.dart';
import '../../widgets/auth/auth_error_message.dart';

class PhoneOtpVerificationScreen extends StatefulWidget {
  const PhoneOtpVerificationScreen({super.key, required this.pendingSignUp});

  final PendingPhoneSignUp pendingSignUp;

  @override
  State<PhoneOtpVerificationScreen> createState() =>
      _PhoneOtpVerificationScreenState();
}

class _PhoneOtpVerificationScreenState
    extends State<PhoneOtpVerificationScreen> {
  final AuthService authService = const AuthService();
  static const int _otpLength = 6;

  late final List<TextEditingController> _otpControllers;
  late final List<FocusNode> _otpFocusNodes;

  Timer? _resendTimer;
  int resendSecondsLeft = 45;

  bool loading = false;
  bool hasOtpError = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _otpControllers = List<TextEditingController>.generate(
      _otpLength,
      (_) => TextEditingController(),
    );
    _otpFocusNodes = List<FocusNode>.generate(_otpLength, (_) => FocusNode());
    _startResendCooldown();
  }

  @override
  void dispose() {
    for (final controller in _otpControllers) {
      controller.dispose();
    }
    for (final focusNode in _otpFocusNodes) {
      focusNode.dispose();
    }
    _resendTimer?.cancel();
    super.dispose();
  }

  String get _otpCode {
    return _otpControllers.map((controller) => controller.text).join();
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

  void _onOtpDigitChanged({required int index, required String value}) {
    if (hasOtpError || errorMessage != null) {
      setState(() {
        hasOtpError = false;
        errorMessage = null;
      });
    }

    if (value.isEmpty) {
      if (index > 0) {
        _otpFocusNodes[index - 1].requestFocus();
      }
      return;
    }

    final String normalized = value.characters.last;
    _otpControllers[index].text = normalized;
    _otpControllers[index].selection = TextSelection.collapsed(
      offset: normalized.length,
    );

    if (index < _otpLength - 1) {
      _otpFocusNodes[index + 1].requestFocus();
      return;
    }

    _otpFocusNodes[index].unfocus();
  }

  void _handleResendCode() {
    if (resendSecondsLeft > 0) return;
    setState(() {
      errorMessage = null;
      hasOtpError = false;
      for (final controller in _otpControllers) {
        controller.clear();
      }
    });
    _otpFocusNodes.first.requestFocus();
    _startResendCooldown();
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
      final AppUser user = await authService.verifyCustomerPhoneSignUp(
        pendingSignUp: widget.pendingSignUp,
        otpCode: _otpCode,
      );

      AuthSession.start(user);

      if (!mounted) return;

      Navigator.pop(context, user);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        hasOtpError = true;
        errorMessage = 'رمز التحقق خطأ';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Theme(
        data: Theme.of(context).copyWith(
          textTheme: GoogleFonts.tajawalTextTheme(Theme.of(context).textTheme),
        ),
        child: Scaffold(
          body: Stack(
            children: [
              const AuthBackground(),

              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: AuthCard(
                      hasError: errorMessage != null,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'تأكيد رقم الهاتف',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            'أدخل رمز التحقق المرسل إلى\n${widget.pendingSignUp.phoneNumber}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFFFFC66D),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              height: 1.5,
                            ),
                          ),

                          const SizedBox(height: 14),

                          AuthErrorMessage(message: errorMessage),

                          const SizedBox(height: 15),

                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List<Widget>.generate(_otpLength, (
                                index,
                              ) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  child: _OtpDigitField(
                                    controller: _otpControllers[index],
                                    focusNode: _otpFocusNodes[index],
                                    isVerifying: loading,
                                    hasError: hasOtpError,
                                    enabled: !loading,
                                    onChanged: (value) => _onOtpDigitChanged(
                                      index: index,
                                      value: value,
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            hasOtpError
                                ? 'رمز التحقق خطأ'
                                : loading
                                ? 'جاري التحقق من الرمز...'
                                : 'رمز التحقق مكوّن من 6 أرقام',
                            style: TextStyle(
                              color: hasOtpError
                                  ? const Color(0xFFEF4444)
                                  : loading
                                  ? const Color(0xFF4ADE80)
                                  : const Color(0xFFE8D9CC),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),

                          const SizedBox(height: 18),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: loading ? null : verifyOtp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                              ),
                              child: loading
                                  ? const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.4,
                                            color: Colors.black,
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          'جاري التأكيد...',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    )
                                  : const Text(
                                      'تأكيد',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          TextButton(
                            onPressed: loading || resendSecondsLeft > 0
                                ? null
                                : _handleResendCode,
                            child: Text(
                              resendSecondsLeft > 0
                                  ? 'إعادة إرسال الرمز خلال ${resendSecondsLeft}s'
                                  : 'إعادة إرسال رمز التحقق',
                              style: TextStyle(
                                color: resendSecondsLeft > 0
                                    ? Colors.white54
                                    : const Color(0xFFFFC66D),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),

                          TextButton(
                            onPressed: loading
                                ? null
                                : () {
                                    Navigator.pop(context);
                                  },
                            child: const Text(
                              'رجوع',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
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
    return const Color(0x66FFFFFF);
  }

  Color get _fillColor {
    if (hasError) return const Color(0xFFEF4444).withValues(alpha: 0.10);
    if (isVerifying) return const Color(0xFF4ADE80).withValues(alpha: 0.10);
    return const Color(0x33000000);
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
      width: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
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
          fontSize: 22,
          fontWeight: FontWeight.w900,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: _fillColor,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: _borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: _borderColor, width: 1.4),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: _borderColor, width: 1.4),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: hasError
                  ? const Color(0xFFEF4444)
                  : isVerifying
                  ? const Color(0xFF4ADE80)
                  : const Color(0xFFFFC66D),
              width: 1.9,
            ),
          ),
        ),
      ),
    );
  }
}
