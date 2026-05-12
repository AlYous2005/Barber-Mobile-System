import 'package:flutter/material.dart';

import '../../../general_utils/app_theme_colors.dart';

class ProfileCompletionCard extends StatelessWidget {
  const ProfileCompletionCard({
    super.key,
    required this.hasImage,
    required this.hasWhatsapp,
    required this.hasLocation,
    required this.hasAddress,
    required this.hasBio,
  });

  final bool hasImage;
  final bool hasWhatsapp;
  final bool hasLocation;
  final bool hasAddress;
  final bool hasBio;

  static const int _totalItems = 5;

  int get completedItemsCount {
    int count = 0;

    if (hasImage) count++;
    if (hasWhatsapp) count++;
    if (hasLocation) count++;
    if (hasAddress) count++;
    if (hasBio) count++;

    return count;
  }

  @override
  Widget build(BuildContext context) {
    final int completed = completedItemsCount;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppThemeColors.softCard(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppThemeColors.border(context)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'حالة اكتمال الملف الشخصي',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppThemeColors.textPrimary(context),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFC47A3D).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$completed / $_totalItems',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF8A4E2E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CompletionChip(label: 'الصورة', isDone: hasImage),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CompletionChip(label: 'الواتساب', isDone: hasWhatsapp),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: CompletionChip(label: 'الموقع', isDone: hasLocation),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CompletionChip(label: 'العنوان', isDone: hasAddress),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: CompletionChip(label: 'النبذة', isDone: hasBio),
              ),
              const SizedBox(width: 8),
              const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }
}

class CompletionChip extends StatelessWidget {
  const CompletionChip({super.key, required this.label, required this.isDone});

  final String label;
  final bool isDone;

  @override
  Widget build(BuildContext context) {
    final Color color = isDone
        ? const Color(0xFF16A34A)
        : const Color(0xFF94A3B8);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
