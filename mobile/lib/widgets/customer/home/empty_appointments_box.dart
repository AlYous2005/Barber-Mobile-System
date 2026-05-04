import 'package:flutter/material.dart';

import '../../../utils/app_theme_colors.dart';

class EmptyAppointmentsBox extends StatelessWidget {
  const EmptyAppointmentsBox({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppThemeColors.softCard(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppThemeColors.border(context)),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppThemeColors.textSecondary(context),
          fontSize: 13.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
