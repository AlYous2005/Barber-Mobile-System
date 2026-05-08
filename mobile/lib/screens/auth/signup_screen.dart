// UI + animation + navigation + legal sheets

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/auth/signup_controller.dart';
import '../../models/app_user.dart';

import '../../widgets/auth/auth_background.dart';
import '../../widgets/auth/auth_birth_date_selector.dart';
import '../../widgets/auth/auth_card.dart';
import '../../widgets/auth/auth_country_code_selector.dart';
import '../../widgets/auth/auth_error_message.dart';
import '../../widgets/auth/auth_legal_agreement_text.dart';
import '../../widgets/auth/auth_text_field.dart';
import '../../models/pending_phone_signup.dart';
import 'phone_otp_verification_screen.dart';
import '../../widgets/auth/password_strength_indicator.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  late final SignUpController controller;

  late AnimationController _shakeController;
  Animation<double>? _shakeAnimation;

  @override
  void initState() {
    super.initState();

    controller = SignUpController();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 12,
    ).chain(CurveTween(curve: Curves.elasticIn)).animate(_shakeController);
  }

  @override
  void dispose() {
    controller.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  Widget buildShakingField({required bool shouldShake, required Widget child}) {
    return AnimatedBuilder(
      animation: _shakeAnimation ?? const AlwaysStoppedAnimation(0),
      builder: (context, animatedChild) {
        return Transform.translate(
          offset: shouldShake
              ? Offset(_shakeAnimation?.value ?? 0, 0)
              : Offset.zero,
          child: animatedChild,
        );
      },
      child: child,
    );
  }

  Future<void> signUp() async {
    try {
      final PendingPhoneSignUp pendingSignUp = await controller.signUp();

      if (!mounted) return;

      final AppUser? verifiedUser = await Navigator.push<AppUser>(
        context,
        MaterialPageRoute(
          builder: (_) {
            return PhoneOtpVerificationScreen(pendingSignUp: pendingSignUp);
          },
        ),
      );

      if (verifiedUser == null) {
        return;
      }

      if (!mounted) return;

      Navigator.pop(context, verifiedUser.displayName);
    } catch (_) {
      _shakeController.forward(from: 0);
    }
  }

  void showLegalSheet({required String title, required String body}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF151515),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  body,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: const Text(
                      'فهمت',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void openTermsOfUse() {
    showLegalSheet(
      title: 'شروط الاستخدام',
      body:
          'باستخدامك للتطبيق، أنت توافق على استخدامه بطريقة صحيحة وعدم إنشاء حجوزات وهمية أو إساءة استخدام الخدمات. هذه نسخة مبدئية وسيتم تحديثها لاحقًا.',
    );
  }

  void openPrivacyPolicy() {
    showLegalSheet(
      title: 'سياسة الخصوصية',
      body:
          'نستخدم بياناتك مثل الاسم ورقم الهاتف ومعلومات الحجز فقط لتشغيل التطبيق وتحسين تجربة الحجز. هذه نسخة مبدئية وسيتم تحديثها لاحقًا.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Theme(
            data: Theme.of(context).copyWith(
              textTheme: GoogleFonts.tajawalTextTheme(
                Theme.of(context).textTheme,
              ),
            ),
            child: Scaffold(
              body: Stack(
                children: [
                  const AuthBackground(),
                  SafeArea(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: AnimatedBuilder(
                          animation:
                              _shakeAnimation ??
                              const AlwaysStoppedAnimation(0),
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(_shakeAnimation?.value ?? 0, 0),
                              child: child,
                            );
                          },
                          child: AuthCard(
                            hasError: controller.errorMessage != null,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'إنشاء حساب',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'أدخل بياناتك وأنشئ حسابًا جديدًا',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFFFFC66D),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                AuthErrorMessage(
                                  message: controller.errorMessage,
                                ),
                                const SizedBox(height: 15),

                                buildShakingField(
                                  shouldShake:
                                      controller.firstNameFieldError != null,
                                  child: AuthTextField(
                                    controller: controller.firstNameController,
                                    hintText: 'الاسم الأول',
                                    icon: Icons.person_outline,
                                    errorText: controller.firstNameFieldError,
                                  ),
                                ),

                                const SizedBox(height: 12),

                                buildShakingField(
                                  shouldShake:
                                      controller.lastNameFieldError != null,
                                  child: AuthTextField(
                                    controller: controller.lastNameController,
                                    hintText: 'اسم العائلة',
                                    icon: Icons.badge_outlined,
                                    errorText: controller.lastNameFieldError,
                                  ),
                                ),

                                const SizedBox(height: 12),

                                buildShakingField(
                                  shouldShake:
                                      controller.phoneFieldError != null,
                                  child: AuthTextField(
                                    controller: controller.phoneController,
                                    hintText: 'رقم الهاتف',
                                    icon: Icons.phone,
                                    keyboardType: TextInputType.phone,
                                    errorText: controller.phoneFieldError,
                                    prefixIconWidget: AuthCountryCodeSelector(
                                      selectedCountry:
                                          controller.selectedCountry,
                                      onCountryChanged:
                                          controller.changeCountry,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 14),

                                buildShakingField(
                                  shouldShake:
                                      controller.birthDateFieldError != null,
                                  child: AuthBirthDateSelector(
                                    selectedDate: controller.selectedBirthDate,
                                    errorText: controller.birthDateFieldError,
                                    onDateChanged: controller.changeBirthDate,
                                  ),
                                ),

                                const SizedBox(height: 12),

                                buildShakingField(
                                  shouldShake:
                                      controller.passwordFieldError != null,
                                  child: AuthTextField(
                                    controller: controller.passwordController,
                                    hintText: 'كلمة المرور',
                                    icon: Icons.lock,
                                    obscureText: !controller.showPassword,
                                    errorText: controller.passwordFieldError,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        controller.showPassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: Colors.white70,
                                      ),
                                      onPressed:
                                          controller.togglePasswordVisibility,
                                    ),
                                  ),
                                ),

                                PasswordStrengthIndicator(
                                  controller: controller.passwordController,
                                ),

                                const SizedBox(height: 12),

                                buildShakingField(
                                  shouldShake:
                                      controller.confirmPasswordFieldError !=
                                      null,
                                  child: AuthTextField(
                                    controller:
                                        controller.confirmPasswordController,
                                    hintText: 'تأكيد كلمة المرور',
                                    icon: Icons.lock_outline,
                                    obscureText:
                                        !controller.showConfirmPassword,
                                    errorText:
                                        controller.confirmPasswordFieldError,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        controller.showConfirmPassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: Colors.white70,
                                      ),
                                      onPressed: controller
                                          .toggleConfirmPasswordVisibility,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 10),

                                AuthLegalAgreementText(
                                  onTermsTap: openTermsOfUse,
                                  onPrivacyTap: openPrivacyPolicy,
                                ),

                                const SizedBox(height: 18),

                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: controller.loading
                                        ? null
                                        : signUp,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                    ),
                                    child: controller.loading
                                        ? const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                width: 18,
                                                height: 18,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2.4,
                                                      color: Colors.black,
                                                    ),
                                              ),
                                              SizedBox(width: 10),
                                              Text(
                                                'جاري الإنشاء...',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          )
                                        : const Text(
                                            'إنشاء حساب',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ),

                                const SizedBox(height: 10),

                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    'هل لديك حساب؟ تسجيل الدخول',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ),
                              ],
                            ),
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
      },
    );
  }
}
