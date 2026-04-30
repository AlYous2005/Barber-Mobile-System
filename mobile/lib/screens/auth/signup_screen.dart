import 'dart:async';
import 'package:flutter/material.dart';
import '../../widgets/auth/auth_background.dart';
import '../../widgets/auth/auth_text_field.dart';
import '../../widgets/auth/auth_card.dart';
import '../../widgets/auth/auth_error_message.dart';


class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  final usernameController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool showPassword = false;
  bool showConfirmPassword = false;
  bool loading = false;

  String selectedCountry = "فلسطين";
  String? errorMessage;
  DateTime? selectedBirthDate;

  Timer? _errorTimer;

  late AnimationController _shakeController;
  Animation<double>? _shakeAnimation;

  String get phoneCode => selectedCountry == "فلسطين" ? "+970" : "+972";

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
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
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

  String get formattedBirthDate {
    if (selectedBirthDate == null) {
      return "تاريخ الميلاد";
    }

    final day = selectedBirthDate!.day.toString().padLeft(2, '0');
    final month = selectedBirthDate!.month.toString().padLeft(2, '0');
    final year = selectedBirthDate!.year.toString();

    return "$day/$month/$year";
  }

  Future<void> pickBirthDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.orange,
              surface: Colors.black,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        selectedBirthDate = pickedDate;
      });
    }
  }

  void register() {
    final u = usernameController.text.trim();
    final p = phoneController.text.trim();
    final pass = passwordController.text.trim();
    final conf = confirmPasswordController.text.trim();

    if (u.isEmpty &&
        p.isEmpty &&
        selectedBirthDate == null &&
        pass.isEmpty &&
        conf.isEmpty) {
      return showError("الرجاء إدخال البيانات");
    }

    if (u.isEmpty) return showError("الرجاء إدخال اسم المستخدم");
    if (p.isEmpty) return showError("الرجاء إدخال رقم الهاتف");
    if (selectedBirthDate == null) {
      return showError("الرجاء إدخال تاريخ الميلاد");
    }
    if (pass.isEmpty) return showError("الرجاء إدخال كلمة المرور");
    if (conf.isEmpty) return showError("الرجاء إدخال تأكيد كلمة المرور");

    if (pass != conf) return showError("كلمة المرور غير متطابقة");

    setState(() => loading = true);

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => loading = false);
      Navigator.pop(context);
    });
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
                      "إنشاء حساب",
                      style: TextStyle(color: Colors.white, fontSize: 26),
                    ),

                    const SizedBox(height: 10),

                    AuthErrorMessage(message: errorMessage),

                    const SizedBox(height: 15),

                    AuthTextField(
                      controller: usernameController,
                      hintText: "اسم المستخدم",
                      icon: Icons.person,
                    ),

                    
                    const SizedBox(height: 12),

                    AuthTextField(
                      controller: phoneController,
                      hintText: "رقم الهاتف",
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      prefixIconWidget: SizedBox(
                        width: 132,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.phone,
                              color: Colors.orange,
                              size: 20,
                            ),

                            const SizedBox(width: 6),

                            DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedCountry,
                                dropdownColor: Colors.black87,
                                iconEnabledColor: Colors.orange,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: "فلسطين",
                                    child: Text("🇵🇸 +970"),
                                  ),
                                  DropdownMenuItem(
                                    value: "إسرائيل",
                                    child: Text("🇮🇱 +972"),
                                  ),
                                ],
                                onChanged: (value) {
                                  if (value == null) return;

                                  setState(() {
                                    selectedCountry = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    GestureDetector(
                      onTap: pickBirthDate,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.transparent),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month, color: Colors.orange),
                            const SizedBox(width: 12),
                            Text(
                              formattedBirthDate,
                              style: TextStyle(
                                color: selectedBirthDate == null
                                    ? Colors.white38
                                    : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
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

                    const SizedBox(height: 12),
                    AuthTextField(
                      controller: confirmPasswordController,
                      hintText: "تأكيد كلمة المرور",
                      icon: Icons.lock_outline,
                      obscureText: !showConfirmPassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          showConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.white70,
                        ),
                        onPressed: () {
                          setState(
                            () => showConfirmPassword = !showConfirmPassword,
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: loading ? null : register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                        child: Text(loading ? "جاري الإنشاء..." : "إنشاء حساب"),
                      ),
                    ),
                    const SizedBox(height: 10),

                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "هل لديك حساب؟ تسجيل الدخول",
                        style: TextStyle(color: Colors.white70),
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
