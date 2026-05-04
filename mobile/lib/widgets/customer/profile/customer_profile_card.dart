import 'package:flutter/material.dart';

import '../customer_theme.dart';

class CustomerProfileCard extends StatelessWidget {
  const CustomerProfileCard({
    super.key,
    required this.displayName,
    required this.countryCode,
    required this.phoneNumber,
    required this.onEdit,
  });

  final String displayName;
  final String countryCode;
  final String phoneNumber;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_outline_rounded, color: CustomerTheme.accentOrange),
              const SizedBox(width: 8),
              const Text(
                'بياناتك',
                style: TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 18, color: CustomerTheme.accentOrange),
                label: const Text(
                  'تعديل',
                  style: TextStyle(color: CustomerTheme.accentOrange, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _row('الاسم الظاهر:', displayName),
          const SizedBox(height: 8),
          _row('رقم الهاتف:', '$countryCode $phoneNumber'),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
