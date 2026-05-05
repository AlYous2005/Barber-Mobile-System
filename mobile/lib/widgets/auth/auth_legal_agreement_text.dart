import 'package:flutter/material.dart';

class AuthLegalAgreementText extends StatelessWidget {
  const AuthLegalAgreementText({
    super.key,
    required this.onTermsTap,
    required this.onPrivacyTap,
  });

  final VoidCallback onTermsTap;
  final VoidCallback onPrivacyTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Text(
          "بإنشاء الحساب، أنت توافق على ",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white60,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
        ),
        _LegalLink(
          text: "شروط الاستخدام",
          onTap: onTermsTap,
        ),
        const Text(
          " و ",
          style: TextStyle(
            color: Colors.white60,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        _LegalLink(
          text: "سياسة الخصوصية",
          onTap: onPrivacyTap,
        ),
      ],
    );
  }
}

class _LegalLink extends StatelessWidget {
  const _LegalLink({
    required this.text,
    required this.onTap,
  });

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFFFFC66D),
            fontSize: 12,
            fontWeight: FontWeight.w900,
            decoration: TextDecoration.underline,
            decorationColor: Color(0xFFFFC66D),
          ),
        ),
      ),
    );
  }
}