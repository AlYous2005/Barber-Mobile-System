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

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),

        prefixIcon: prefixIconWidget ?? Icon(icon, color: Colors.orange),

        prefixText: prefixText,
        prefixStyle: prefixStyle,
        suffixIcon: suffixIcon,

        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white38),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}