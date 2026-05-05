import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/auth/auth_background.dart';
import '../../widgets/auth/auth_text_field.dart';
import '../../widgets/auth/auth_card.dart';
import '../../widgets/auth/auth_error_message.dart';
import '../../widgets/auth/auth_legal_agreement_text.dart';
import '../../widgets/auth/auth_country_code_selector.dart';
import '../../widgets/auth/auth_birth_date_selector.dart';
import '../../models/app_user.dart';
import '../../services/auth_service.dart';
import '../../services/auth_session.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = const AuthService();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool showPassword = false;
  bool showConfirmPassword = false;
  bool loading = false;

  String selectedCountry = "فلسطين";
  String? errorMessage;
  DateTime? selectedBirthDate;

  String? firstNameFieldError;
  String? lastNameFieldError;
  String? phoneFieldError;
  String? birthDateFieldError;
  String? passwordFieldError;
  String? confirmPasswordFieldError;

  Timer? _errorTimer;

  late AnimationController _shakeController;
  Animation<double>? _shakeAnimation;

  late final VoidCallback _onFirstNameChanged;
  late final VoidCallback _onLastNameChanged;
  late final VoidCallback _onPhoneChanged;
  late final VoidCallback _onPasswordChanged;
  late final VoidCallback _onConfirmPasswordChanged;

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

    _onFirstNameChanged = () {
      if (firstNameFieldError != null && mounted) {
        setState(() => firstNameFieldError = null);
      }
    };

    _onLastNameChanged = () {
      if (lastNameFieldError != null && mounted) {
        setState(() => lastNameFieldError = null);
      }
    };

    _onPhoneChanged = () {
      if (phoneFieldError != null && mounted) {
        setState(() => phoneFieldError = null);
      }
    };

    _onPasswordChanged = () {
      if (passwordFieldError != null && mounted) {
        setState(() => passwordFieldError = null);
      }
    };

    _onConfirmPasswordChanged = () {
      if (confirmPasswordFieldError != null && mounted) {
        setState(() => confirmPasswordFieldError = null);
      }
    };

    firstNameController.addListener(_onFirstNameChanged);
    lastNameController.addListener(_onLastNameChanged);
    phoneController.addListener(_onPhoneChanged);
    passwordController.addListener(_onPasswordChanged);
    confirmPasswordController.addListener(_onConfirmPasswordChanged);
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

    _shakeController.dispose();
    _errorTimer?.cancel();

    super.dispose();
  }

  void showError(String message) {
    setState(() {
      errorMessage = message;
      firstNameFieldError = null;
      lastNameFieldError = null;
      phoneFieldError = null;
      birthDateFieldError = null;
      passwordFieldError = null;
      confirmPasswordFieldError = null;
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

  Future<void> signUp() async {
    setState(() => loading = true);

    try {
      final AppUser user = await _authService.signUpCustomer(
        firstName: firstNameController.text,
        lastName: lastNameController.text,
        phoneNumber: phoneController.text,
        password: passwordController.text,
        confirmPassword: confirmPasswordController.text,
        birthDate: selectedBirthDate,
      );
      AuthSession.start(user);
      if (!mounted) return;

      setState(() => loading = false);

      Navigator.pop(context, user.displayName);
    } on AuthException catch (error) {
      if (!mounted) return;

      setState(() => loading = false);
      showError(error.message);
    } catch (_) {
      if (!mounted) return;

      setState(() => loading = false);
      showError('حدث خطأ غير متوقع، حاول مرة أخرى');
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
                      "فهمت",
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
      title: "شروط الاستخدام",
      body:
          "باستخدامك للتطبيق، أنت توافق على استخدامه بطريقة صحيحة وعدم إنشاء حجوزات وهمية أو إساءة استخدام الخدمات. هذه نسخة مبدئية وسيتم تحديثها لاحقًا.",
    );
  }

  void openPrivacyPolicy() {
    showLegalSheet(
      title: "سياسة الخصوصية",
      body:
          "نستخدم بياناتك مثل الاسم ورقم الهاتف ومعلومات الحجز فقط لتشغيل التطبيق وتحسين تجربة الحجز. هذه نسخة مبدئية وسيتم تحديثها لاحقًا.",
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
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
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
                        hasError: errorMessage != null,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "إنشاء حساب",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "أدخل بياناتك وأنشئ حسابًا جديدًا",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFFFFC66D),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 14),
                            AuthErrorMessage(message: errorMessage),
                            const SizedBox(height: 15),
                            buildShakingField(
                              shouldShake: firstNameFieldError != null,
                              child: AuthTextField(
                                controller: firstNameController,
                                hintText: "الاسم الأول",
                                icon: Icons.person_outline,
                                errorText: firstNameFieldError,
                              ),
                            ),
                            const SizedBox(height: 12),
                            buildShakingField(
                              shouldShake: lastNameFieldError != null,
                              child: AuthTextField(
                                controller: lastNameController,
                                hintText: "اسم العائلة",
                                icon: Icons.badge_outlined,
                                errorText: lastNameFieldError,
                              ),
                            ),
                            const SizedBox(height: 12),
                            buildShakingField(
                              shouldShake: phoneFieldError != null,
                              child: AuthTextField(
                                controller: phoneController,
                                hintText: "رقم الهاتف",
                                icon: Icons.phone,
                                keyboardType: TextInputType.phone,
                                errorText: phoneFieldError,
                                prefixIconWidget: AuthCountryCodeSelector(
                                  selectedCountry: selectedCountry,
                                  onCountryChanged: (value) {
                                    setState(() {
                                      selectedCountry = value;
                                    });
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            buildShakingField(
                              shouldShake: birthDateFieldError != null,
                              child: AuthBirthDateSelector(
                                selectedDate: selectedBirthDate,
                                errorText: birthDateFieldError,
                                onDateChanged: (date) {
                                  setState(() {
                                    selectedBirthDate = date;
                                    birthDateFieldError = null;
                                  });
                                },
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
                                    setState(
                                      () => showPassword = !showPassword,
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            buildShakingField(
                              shouldShake: confirmPasswordFieldError != null,
                              child: AuthTextField(
                                controller: confirmPasswordController,
                                hintText: "تأكيد كلمة المرور",
                                icon: Icons.lock_outline,
                                obscureText: !showConfirmPassword,
                                errorText: confirmPasswordFieldError,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    showConfirmPassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.white70,
                                  ),
                                  onPressed: () {
                                    setState(
                                      () => showConfirmPassword =
                                          !showConfirmPassword,
                                    );
                                  },
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
                                onPressed: loading ? null : signUp,
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
                                            "جاري الإنشاء...",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      )
                                    : const Text(
                                        "إنشاء حساب",
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
                                "هل لديك حساب؟ تسجيل الدخول",
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
  }
}
