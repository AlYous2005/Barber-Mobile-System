import 'package:flutter/material.dart';

import 'customer_theme.dart';

class CustomerHeader extends StatelessWidget {
  const CustomerHeader({
    super.key,
    required this.onLogout,
    this.title = 'Barb',
  });

  final VoidCallback onLogout;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: title.substring(0, 1),
                style: const TextStyle(
                  color: CustomerTheme.beige,
                  fontWeight: FontWeight.w900,
                  fontSize: 26,
                ),
              ),
              TextSpan(
                text: title.length > 1 ? title.substring(1) : '',
                style: const TextStyle(
                  color: Color(0xFF111827),
                  fontWeight: FontWeight.w600,
                  fontSize: 26,
                ),
              ),
            ],
          ),
          textDirection: TextDirection.ltr,
        ),
        const Spacer(),
        IconButton(
          onPressed: onLogout,
          tooltip: 'تسجيل خروج',
          icon: const Icon(
            Icons.logout_rounded,
            color: CustomerTheme.accentOrange,
          ),
        ),
      ],
    );
  }
}
