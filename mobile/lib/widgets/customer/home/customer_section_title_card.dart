import 'package:flutter/material.dart';

import '../../../general_utils/app_theme_colors.dart';

class CustomerSectionTitleCard extends StatelessWidget {
  const CustomerSectionTitleCard({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: AppThemeColors.softCard(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppThemeColors.border(context)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppThemeColors.textPrimary(context),
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
