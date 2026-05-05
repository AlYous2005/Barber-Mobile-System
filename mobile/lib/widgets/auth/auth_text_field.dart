import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
    this.prefixText,
    this.prefixStyle,
    this.prefixIconWidget,
    this.errorText,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final String? prefixText;
  final TextStyle? prefixStyle;

  // هذا للحقول الخاصة مثل رقم الهاتف
  // بنقدر نحط بدل الأيقونة العادية Widget كامل فيه أيقونة + Dropdown
  final Widget? prefixIconWidget;

  /// When non-null and non-empty, shows validation under the field.
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final String? trimmedError = errorText?.trim();
    final bool showFieldError = trimmedError != null && trimmedError.isNotEmpty;

    final OutlineInputBorder baseBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(
        color: Colors.white.withValues(alpha: 0.12),
      ),
    );

    final OutlineInputBorder focusedOutline = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(
        color: Colors.orange,
        width: 1.5,
      ),
    );

    final OutlineInputBorder errorOutline = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(
        color: Color(0xFFFF7043),
        width: 1.5,
      ),
    );

    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
      ),
      cursorColor: Colors.orange,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),

        prefixIcon: prefixIconWidget ?? Icon(icon, color: Colors.orange),

        prefixText: prefixText,
        prefixStyle: prefixStyle,
        suffixIcon: suffixIcon,

        // بدل hint عادي، صرنا نستخدم Floating Label
        // نفس قيمة hintText القديمة ستظهر داخل الحقل ثم تطلع للأعلى عند التركيز أو الكتابة.
        labelText: hintText,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        labelStyle: TextStyle(
          color: showFieldError ? const Color(0xFFFFCCBC) : Colors.white54,
          fontWeight: FontWeight.w600,
        ),
        floatingLabelStyle: TextStyle(
          color: showFieldError ? const Color(0xFFFFCCBC) : Colors.orange,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),

        errorText: showFieldError ? trimmedError : null,
        errorStyle: const TextStyle(
          color: Color(0xFFFFCCBC),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),

        border: baseBorder,
        enabledBorder: baseBorder,
        focusedBorder: focusedOutline,
        errorBorder: errorOutline,
        focusedErrorBorder: errorOutline,
      ),
    );
  }
}