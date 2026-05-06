import 'package:flutter/material.dart';
import 'auth_text_field.dart';

class AuthForgotPasswordSheet extends StatefulWidget {
  const AuthForgotPasswordSheet({super.key});

  @override
  State<AuthForgotPasswordSheet> createState() =>
      _AuthForgotPasswordSheetState();
}

class _AuthForgotPasswordSheetState extends State<AuthForgotPasswordSheet> {
  final TextEditingController phoneController = TextEditingController();

  String selectedCountry = "فلسطين";
  String? errorMessage;
  String? successMessage;
  bool loading = false;

  String get phoneCode => selectedCountry == "فلسطين" ? "+970" : "+972";

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  void submitForgotPassword() {
    final phone = phoneController.text.trim();

    setState(() {
      errorMessage = null;
      successMessage = null;
    });

    if (phone.isEmpty) {
      setState(() {
        errorMessage = "الرجاء إدخال رقم الهاتف";
      });
      return;
    }

    setState(() {
      loading = true;
    });

    // Mock check مؤقت لحين ربط قاعدة البيانات
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      // رقم تجريبي مؤقت
      // جرّب تدخل هذا الرقم: 0599999999
      const mockExistingPhone = "0599999999";

      if (phone == mockExistingPhone) {
        setState(() {
          successMessage =
              "تم العثور على الحساب. سيتم إرسال رمز التحقق لاحقاً.";
        });
      } else {
        setState(() {
          errorMessage = "هذا الرقم غير مرتبط بأي حساب";
        });
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "استعادة كلمة المرور",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "أدخل رقم الهاتف المرتبط بحسابك",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white60, fontSize: 14),
              ),

              const SizedBox(height: 18),

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
                      const Icon(Icons.phone, color: Colors.orange, size: 20),

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

              const SizedBox(height: 12),

              if (errorMessage != null)
                Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),

              if (successMessage != null)
                Text(
                  successMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loading ? null : submitForgotPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    loading ? "جاري التحقق..." : "إرسال",
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "إغلاق",
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
