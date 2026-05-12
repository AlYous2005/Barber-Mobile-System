import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/auth/login_controller.dart';
import '../../features/auth/auth.dart';
import '../../widgets/auth/auth_background.dart';
import '../../widgets/auth/auth_card.dart';
import '../../widgets/auth/auth_error_message.dart';
import '../../widgets/auth/auth_forgot_password_sheet.dart';
import '../../widgets/auth/auth_role_selector.dart';
import '../../widgets/auth/auth_text_field.dart';
import '../home/home_screen.dart';
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

  void navigateToHome(AppUser user) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 650),
        pageBuilder: (context, animation, secondaryAnimation) {
          return HomeScreen(userName: user.displayName, role: user.role);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final offsetAnimation =
              Tween<Offset>(
                begin: const Offset(0, 0.08),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              );

          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: offsetAnimation, child: child),
          );
        },
      ),
    );
  }

  Future<void> login() async {
    try {
      final AppUser user = await controller.login();

      if (!mounted) return;

      navigateToHome(user);
    } on AuthException {
      _shakeController.forward(from: 0);
    } on LoginControllerException {
      _shakeController.forward(from: 0);
    }
  }

  Future<void> loginWithBiometrics() async {
    try {
      final AppUser user = await controller.loginWithBiometrics();

      if (!mounted) return;

      navigateToHome(user);
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

    if (displayName == null || displayName.trim().isEmpty) {
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: const Color(0xFF151515),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
              side: const BorderSide(color: Colors.white24),
            ),
            title: const Text(
              'تم إنشاء الحساب بنجاح',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            content: const Text(
              'تم إنشاء حسابك بنجاح، يمكنك الآن تسجيل الدخول.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                height: 1.6,
              ),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'حسنًا',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 0,
                        vertical: 24,
                      ),
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

                                AuthErrorMessage(
                                  message: controller.errorMessage,
                                ),

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
                                      selectedCountry:
                                          controller.selectedCountry,
                                      onCountryChanged:
                                          controller.changeCountry,
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
                                const SizedBox(height: 10),

                                TextButton.icon(
                                  onPressed:
                                      controller.loading ||
                                          controller
                                              .isLoadingSavedCredentials ||
                                          controller.isBiometricActionLoading
                                      ? null
                                      : controller.toggleFastLoginOptions,
                                  icon: Icon(
                                    controller.showFastLoginOptions
                                        ? Icons.keyboard_arrow_up_rounded
                                        : Icons.keyboard_arrow_down_rounded,
                                    color: Colors.orangeAccent,
                                  ),
                                  label: const Text(
                                    'خيارات تسجيل الدخول السريع',
                                    style: TextStyle(
                                      color: Colors.orangeAccent,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),

                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 240),
                                  switchInCurve: Curves.easeOutCubic,
                                  switchOutCurve: Curves.easeInCubic,
                                  transitionBuilder: (child, animation) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: SizeTransition(
                                        sizeFactor: animation,
                                        axisAlignment: -1,
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: controller.showFastLoginOptions
                                      ? Column(
                                          key: const ValueKey(
                                            'fast-login-options-open',
                                          ),
                                          children: [
                                            _LoginOptionTile(
                                              icon: Icons.save_alt_rounded,
                                              title: 'حفظ بيانات الدخول',
                                              subtitle:
                                                  'احفظ رقم الهاتف وكلمة المرور لتسجيل دخول أسرع',
                                              value: controller.rememberLogin,
                                              enabled:
                                                  !controller.loading &&
                                                  !controller
                                                      .isLoadingSavedCredentials &&
                                                  !controller
                                                      .isBiometricActionLoading,
                                              onChanged: (value) {
                                                controller.changeRememberLogin(
                                                  value,
                                                );
                                              },
                                            ),

                                            const SizedBox(height: 8),

                                            _LoginOptionTile(
                                              icon: Icons.fingerprint_rounded,
                                              title: 'تفعيل الدخول بالبصمة',
                                              subtitle: controller.rememberLogin
                                                  ? 'يتم تفعيلها بعد تسجيل دخول ناجح'
                                                  : 'فعّل حفظ بيانات الدخول أولًا',
                                              value:
                                                  controller.biometricEnabled,
                                              enabled:
                                                  controller.rememberLogin &&
                                                  !controller.loading &&
                                                  !controller
                                                      .isLoadingSavedCredentials &&
                                                  !controller
                                                      .isBiometricActionLoading,
                                              onChanged: (value) {
                                                controller
                                                    .changeBiometricEnabled(
                                                      value,
                                                    );
                                              },
                                            ),
                                          ],
                                        )
                                      : const SizedBox.shrink(
                                          key: ValueKey(
                                            'fast-login-options-closed',
                                          ),
                                        ),
                                ),

                                const SizedBox(height: 8),

                                if (controller.canUseBiometricLogin) ...[
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed:
                                          controller.loading ||
                                              controller
                                                  .isBiometricActionLoading
                                          ? null
                                          : loginWithBiometrics,
                                      icon: controller.isBiometricActionLoading
                                          ? const SizedBox(
                                              width: 17,
                                              height: 17,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.2,
                                                color: Colors.orange,
                                              ),
                                            )
                                          : const Icon(
                                              Icons.fingerprint_rounded,
                                              color: Colors.orange,
                                            ),
                                      label: Text(
                                        controller.isBiometricActionLoading
                                            ? 'جاري التحقق...'
                                            : 'الدخول بالبصمة',
                                        style: const TextStyle(
                                          color: Colors.orange,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                          color: Colors.orange,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],

                                TextButton(
                                  onPressed: openForgotPasswordSheet,
                                  child: const Text(
                                    'هل نسيت كلمة المرور؟',
                                    style: TextStyle(
                                      color: Colors.orangeAccent,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: controller.loading
                                        ? null
                                        : login,
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

class _LoginOptionTile extends StatelessWidget {
  const _LoginOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final Color activeColor = Colors.orange;
    final Color borderColor = value
        ? activeColor.withValues(alpha: 0.60)
        : Colors.white12;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: double.infinity,
      padding: const EdgeInsetsDirectional.only(
        start: 12,
        end: 8,
        top: 9,
        bottom: 9,
      ),
      decoration: BoxDecoration(
        color: value
            ? activeColor.withValues(alpha: 0.10)
            : const Color(0xFF202020),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: enabled
                ? value
                      ? activeColor
                      : Colors.white70
                : Colors.white30,
            size: 23,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: enabled ? Colors.white : Colors.white38,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: enabled ? Colors.white54 : Colors.white30,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),

          Switch(
            value: value,
            onChanged: enabled ? onChanged : null,
            activeThumbColor: activeColor,
            activeTrackColor: activeColor.withValues(alpha: 0.35),
            inactiveThumbColor: Colors.white70,
            inactiveTrackColor: Colors.white24,
          ),
        ],
      ),
    );
  }
}
