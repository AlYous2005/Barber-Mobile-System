import 'dart:async';
import 'package:flutter/material.dart';
import 'signup_screen.dart';
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

  String? errorMessage;
  Timer? _errorTimer;

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
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    _shakeController.dispose();
    _errorTimer?.cancel();
    super.dispose();
  }

  void showError(String message) {
    setState(() => errorMessage = message);

    _shakeController.forward(from: 0);

    _errorTimer?.cancel();
    _errorTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) setState(() => errorMessage = null);
    });
  }

  void login() {
    final u = usernameController.text.trim();
    final p = passwordController.text.trim();

    if (u.isEmpty && p.isEmpty) {
      showError("الرجاء إدخال اسم المستخدم وكلمة المرور");
      return;
    }

    if (u.isEmpty) return showError("الرجاء إدخال اسم المستخدم");
    if (p.isEmpty) return showError("الرجاء إدخال كلمة المرور");

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

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 650),
          pageBuilder: (context, animation, secondaryAnimation) {
            return AuthTransitionScreen(
              userName: usernameController.text.trim(),
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
    return Scaffold(
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

                    AuthTextField(
                      controller: usernameController,
                      hintText: "اسم المستخدم",
                      icon: Icons.person,
                    ),

                    const SizedBox(height: 12),

                    AuthTextField(
                      controller: passwordController,
                      hintText: "كلمة المرور",
                      icon: Icons.lock,
                      obscureText: !showPassword,
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
                        child: Text(
                          loading ? "جاري الدخول..." : "تسجيل الدخول",
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
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const SignUpScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "إنشاء حساب جديد",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ),
                            )
                          : const SizedBox(
                              key: ValueKey("signup-button-hidden"),
                              height: 0,
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
