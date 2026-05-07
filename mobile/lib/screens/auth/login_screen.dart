import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/auth/login_controller.dart';
import '../../models/app_user.dart';
import '../../services/auth_service.dart';
import '../../widgets/auth/auth_background.dart';
import '../../widgets/auth/auth_card.dart';
import '../../widgets/auth/auth_error_message.dart';
import '../../widgets/auth/auth_forgot_password_sheet.dart';
import '../../widgets/auth/auth_role_selector.dart';
import '../../widgets/auth/auth_text_field.dart';
import 'login_transition_screen.dart';
import '../../widgets/auth/auth_country_code_selector.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late final LoginController controller;

  late final AnimationController _shakeController;
  Animation<double>? _shakeAnimation;

  @override
  void initState() {
    super.initState();

    controller = LoginController();

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

  Future<void> login() async {
    try {
      final AppUser user = await controller.login();

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 650),
          pageBuilder: (context, animation, secondaryAnimation) {
            return AuthTransitionScreen(
              userName: user.displayName,
              role: user.role,
            );
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final offsetAnimation =
                Tween<Offset>(
                  begin: const Offset(0, 0.08),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                );

            return FadeTransition(
              opacity: animation,
              child: SlideTransition(position: offsetAnimation, child: child),
            );
          },
        ),
      );
    } on AuthException {
      _shakeController.forward(from: 0);
    } on LoginControllerException {
      _shakeController.forward(from: 0);
    }
  }

  void openForgotPasswordSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const AuthForgotPasswordSheet();
      },
    );
  }

  Future<void> openSignUpScreen() async {
    final String? displayName = await Navigator.push<String?>(
      context,
      MaterialPageRoute<String?>(builder: (_) => const SignUpScreen()),
    );

    if (!mounted) return;

    controller.setSignedUpCustomerDisplayName(displayName);
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

                  Center(
                    child: AnimatedBuilder(
                      animation:
                          _shakeAnimation ?? const AlwaysStoppedAnimation(0),
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
                              'تسجيل الدخول',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 8),

                            const Text(
                              'اختر نوع الحساب ثم أدخل بياناتك للمتابعة',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFFFFC66D),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                height: 1.4,
                              ),
                            ),

                            const SizedBox(height: 15),

                            AuthErrorMessage(message: controller.errorMessage),

                            const SizedBox(height: 15),

                            AuthRoleSelector(
                              selectedRole: controller.selectedRole,
                              onRoleChanged: controller.changeRole,
                            ),

                            const SizedBox(height: 15),

                            buildShakingField(
                              shouldShake:
                                  controller.usernameFieldError != null,
                              child: AuthTextField(
                                controller: controller.usernameController,
                                hintText: 'رقم الهاتف',
                                icon: Icons.phone,
                                keyboardType: TextInputType.phone,
                                errorText: controller.usernameFieldError,
                                prefixIconWidget: AuthCountryCodeSelector(
                                  selectedCountry: controller.selectedCountry,
                                  onCountryChanged: controller.changeCountry,
                                ),
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

                            TextButton(
                              onPressed: openForgotPasswordSheet,
                              child: const Text(
                                'هل نسيت كلمة المرور؟',
                                style: TextStyle(color: Colors.orangeAccent),
                              ),
                            ),

                            const SizedBox(height: 20),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: controller.loading ? null : login,
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
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.4,
                                              color: Colors.black,
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            'جاري الدخول...',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      )
                                    : const Text(
                                        'تسجيل الدخول',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 280),
                              switchInCurve: Curves.easeOutCubic,
                              switchOutCurve: Curves.easeInCubic,
                              transitionBuilder: (child, animation) {
                                final slideAnimation = Tween<Offset>(
                                  begin: const Offset(0, 0.25),
                                  end: Offset.zero,
                                ).animate(animation);

                                return FadeTransition(
                                  opacity: animation,
                                  child: SizeTransition(
                                    sizeFactor: animation,
                                    axisAlignment: -1,
                                    child: SlideTransition(
                                      position: slideAnimation,
                                      child: child,
                                    ),
                                  ),
                                );
                              },
                              child: controller.selectedRole == 'customer'
                                  ? Center(
                                      key: const ValueKey(
                                        'signup-button-visible',
                                      ),
                                      child: TextButton(
                                        onPressed: openSignUpScreen,
                                        child: const Text(
                                          'إنشاء حساب جديد',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ),
                                    )
                                  : const Padding(
                                      key: ValueKey('barber-signup-note'),
                                      padding: EdgeInsets.only(top: 4),
                                      child: Text(
                                        'لا يمكنك إنشاء حساب حلاق، يجب التواصل مع مشرفي التطبيق لإنشاء حساب من هذا النوع',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Color(0xFFFFC66D),
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w700,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                            ),
                          ],
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
