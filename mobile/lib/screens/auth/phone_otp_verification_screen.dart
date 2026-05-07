import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/app_user.dart';
import '../../models/pending_phone_signup.dart';
import '../../services/auth_service.dart';
import '../../services/auth_session.dart';
import '../../widgets/auth/auth_background.dart';
import '../../widgets/auth/auth_card.dart';
import '../../widgets/auth/auth_error_message.dart';
import '../../widgets/auth/auth_text_field.dart';

class PhoneOtpVerificationScreen extends StatefulWidget {
  const PhoneOtpVerificationScreen({super.key, required this.pendingSignUp});

  final PendingPhoneSignUp pendingSignUp;

  @override
  State<PhoneOtpVerificationScreen> createState() =>
      _PhoneOtpVerificationScreenState();
}

class _PhoneOtpVerificationScreenState
    extends State<PhoneOtpVerificationScreen> {
  final TextEditingController otpController = TextEditingController();
  final AuthService authService = const AuthService();

  bool loading = false;
  String? errorMessage;

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  Future<void> verifyOtp() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      final AppUser user = await authService.verifyCustomerPhoneSignUp(
        pendingSignUp: widget.pendingSignUp,
        otpCode: otpController.text,
      );

      AuthSession.start(user);

      if (!mounted) return;

      Navigator.pop(context, user);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = error.toString();
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

                          AuthTextField(
                            controller: otpController,
                            hintText: 'رمز التحقق',
                            icon: Icons.verified_user_outlined,
                            keyboardType: TextInputType.number,
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
