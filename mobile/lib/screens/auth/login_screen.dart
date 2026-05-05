import 'dart:async';
import 'package:flutter/material.dart';
import 'signup_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/auth/auth_background.dart';
import '../../widgets/auth/auth_text_field.dart';
import '../../widgets/auth/auth_card.dart';
import '../../widgets/auth/auth_error_message.dart';
import '../../widgets/auth/auth_role_selector.dart';
import '../../widgets/auth/auth_forgot_password_sheet.dart';
import 'login_transition_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool showPassword = false;
  bool loading = false;
  String selectedRole = "customer";

  /// Full display name from customer signup ("الاسم الأول اسم العائلة"); used for HomeScreen greeting.
  String? _signedUpCustomerDisplayName;

  String? errorMessage;
  Timer? _errorTimer;

  String? usernameFieldError;
  String? passwordFieldError;

  late final VoidCallback _onUsernameChanged;
  late final VoidCallback _onPasswordChanged;

  late AnimationController _shakeController;
  Animation<double>? _shakeAnimation;

  @override
  void initState() {
    super.initState();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 12,
    ).chain(CurveTween(curve: Curves.elasticIn)).animate(_shakeController);

    _onUsernameChanged = () {
      if (usernameFieldError != null && mounted) {
        setState(() => usernameFieldError = null);
      }
    };

    _onPasswordChanged = () {
      if (passwordFieldError != null && mounted) {
        setState(() => passwordFieldError = null);
      }
    };

    usernameController.addListener(_onUsernameChanged);
    passwordController.addListener(_onPasswordChanged);
  }

  @override
  void dispose() {
    usernameController.removeListener(_onUsernameChanged);
    passwordController.removeListener(_onPasswordChanged);
    usernameController.dispose();
    passwordController.dispose();
    _shakeController.dispose();
    _errorTimer?.cancel();
    super.dispose();
  }

  void showError(String message) {
    setState(() {
      errorMessage = message;
      usernameFieldError = null;
      passwordFieldError = null;
    });

    _shakeController.forward(from: 0);

    _errorTimer?.cancel();
    _errorTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) setState(() => errorMessage = null);
    });
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

  void login() {
    final u = usernameController.text.trim();
    final p = passwordController.text.trim();

    setState(() {
      errorMessage = null;
      usernameFieldError = null;
      passwordFieldError = null;
    });

    final bool allFieldsEmpty = u.isEmpty && p.isEmpty;

    if (allFieldsEmpty) {
      showError("الرجاء إدخال البيانات");
      return;
    }

    String? nextUsernameError;
    String? nextPasswordError;

    if (u.isEmpty) {
      nextUsernameError = "الرجاء إدخال اسم المستخدم";
    }

    if (p.isEmpty) {
      nextPasswordError = "الرجاء إدخال كلمة المرور";
    }

    if (nextUsernameError != null || nextPasswordError != null) {
      setState(() {
        usernameFieldError = nextUsernameError;
        passwordFieldError = nextPasswordError;
      });

      _shakeController.forward(from: 0);
      return;
    }

    if (selectedRole == "barber") {
      if (u != "admin") return showError("هذا الحساب غير موجود");
      if (p != "1234") return showError("كلمة المرور خطأ");
    } else {
      if (u != "customer") return showError("هذا الحساب غير موجود");
      if (p != "1234") return showError("كلمة المرور خطأ");
    }

    setState(() => loading = true);

    Future.delayed(const Duration(milliseconds: 650), () {
      if (!mounted) return;

      setState(() => loading = false);

      final String loginUsername = usernameController.text.trim();
      final String userNameForHome =
          selectedRole == 'customer' &&
              _signedUpCustomerDisplayName != null &&
              _signedUpCustomerDisplayName!.trim().isNotEmpty
          ? _signedUpCustomerDisplayName!.trim()
          : loginUsername;

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 650),
          pageBuilder: (context, animation, secondaryAnimation) {
            return AuthTransitionScreen(
              userName: userNameForHome,
              role: selectedRole,
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
    });
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

              Center(
                child: AnimatedBuilder(
                  animation: _shakeAnimation ?? const AlwaysStoppedAnimation(0),
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(_shakeAnimation?.value ?? 0, 0),
                      child: child,
                    );
                  },
                  child: AuthCard(
                    hasError: errorMessage != null,

                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "تسجيل الدخول",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          "اختر نوع الحساب ثم أدخل بياناتك للمتابعة",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFFFFC66D),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),

                        const SizedBox(height: 15),

                        AuthErrorMessage(message: errorMessage),

                        const SizedBox(height: 15),

                        AuthRoleSelector(
                          selectedRole: selectedRole,
                          onRoleChanged: (role) {
                            setState(() {
                              selectedRole = role;
                            });
                          },
                        ),

                        const SizedBox(height: 15),

                        buildShakingField(
                          shouldShake: usernameFieldError != null,
                          child: AuthTextField(
                            controller: usernameController,
                            hintText: "اسم المستخدم",
                            icon: Icons.person,
                            errorText: usernameFieldError,
                          ),
                        ),

                        const SizedBox(height: 12),
                        buildShakingField(
                          shouldShake: passwordFieldError != null,
                          child: AuthTextField(
                            controller: passwordController,
                            hintText: "كلمة المرور",
                            icon: Icons.lock,
                            obscureText: !showPassword,
                            errorText: passwordFieldError,
                            suffixIcon: IconButton(
                              icon: Icon(
                                showPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.white70,
                              ),
                              onPressed: () {
                                setState(() => showPassword = !showPassword);
                              },
                            ),
                          ),
                        ),

                        TextButton(
                          onPressed: openForgotPasswordSheet,
                          child: const Text(
                            "هل نسيت كلمة المرور؟",
                            style: TextStyle(color: Colors.orangeAccent),
                          ),
                        ),
                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: loading ? null : login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                            ),
                            child: loading
                                ? const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                        "جاري الدخول...",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  )
                                : const Text(
                                    "تسجيل الدخول",
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
                          child: selectedRole == "customer"
                              ? Center(
                                  key: const ValueKey("signup-button-visible"),
                                  child: TextButton(
                                    onPressed: () async {
                                      final String? displayName =
                                          await Navigator.push<String?>(
                                            context,
                                            MaterialPageRoute<String?>(
                                              builder: (_) =>
                                                  const SignUpScreen(),
                                            ),
                                          );

                                      if (!mounted) return;

                                      setState(() {
                                        _signedUpCustomerDisplayName =
                                            displayName != null &&
                                                displayName.trim().isNotEmpty
                                            ? displayName.trim()
                                            : null;
                                      });
                                    },
                                    child: const Text(
                                      "إنشاء حساب جديد",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                  ),
                                )
                              : const Padding(
                                  key: ValueKey("barber-signup-note"),
                                  padding: EdgeInsets.only(top: 4),
                                  child: Text(
                                    "لا يمكنك إنشاء حساب حلاق، يجب التواصل مع مشرفي التطبيق لإنشاء حساب من هذا النوع",
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
  }
}
