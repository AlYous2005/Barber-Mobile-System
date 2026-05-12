import 'package:flutter/material.dart';

import '../../../features/barber/services_management/services_management.dart';
import '../../../general_utils/app_theme_colors.dart';
import 'service_form_widgets.dart';
import '../../shared/service_icon_view.dart';

class ServiceCard extends StatelessWidget {
  const ServiceCard({
    super.key,
    required this.service,
    required this.onEdit,
    required this.onArchive,
    required this.onToggleActive,
  });

  final UiService service;
  final VoidCallback onEdit;
  final VoidCallback onArchive;
  final VoidCallback onToggleActive;

  @override
  Widget build(BuildContext context) {
    final bool active = service.isActive;
    final ServiceIconOption iconOption = ServiceIconOptions.byKey(
      service.serviceIconKey,
    );
    final String? serviceImageUrl = _cleanText(service.serviceImageUrl);
    return Opacity(
      opacity: active ? 1 : 0.72,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppThemeColors.card(context),
          border: Border.all(color: AppThemeColors.border(context)),
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: AppThemeColors.isDark(context) ? 0.28 : 0.06,
              ),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: active
                        ? const Color(0xFFEEF7F1)
                        : AppThemeColors.softCard(context),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: active
                          ? const Color(0xFFDCEFE2)
                          : AppThemeColors.border(context),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: serviceImageUrl == null
                        ? ServiceIconView(
                            option: iconOption,
                            size: 21,
                            fallbackColor: const Color(0xFF5C4030),
                            assetPadding: 2,
                          )
                        : Image.network(
                            serviceImageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                iconOption.icon,
                                color: const Color(0xFF5C4030),
                                size: 21,
                              );
                            },
                          ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    service.name,
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: AppThemeColors.textPrimary(context),
                    ),
                  ),
                ),

                if (!active)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppThemeColors.softCard(context),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppThemeColors.border(context)),
                    ),
                    child: Text(
                      'معطّلة',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: AppThemeColors.textMuted(context),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: MetaBadge(
                    icon: Icons.access_time_rounded,
                    label: '${service.durationMinutes} دقيقة',
                    color: const Color(0xFF5C4030),
                    backgroundColor: AppThemeColors.softCard(context),
                    borderColor: AppThemeColors.border(context),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: MetaBadge(
                    icon: Icons.payments_rounded,
                    label: '₪${service.price.toStringAsFixed(0)}',
                    color: const Color(0xFF15803D),
                    backgroundColor: const Color(0xFFEEFBF2),
                    borderColor: const Color(0xFFBBF7D0),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            MetaBadge(
              icon: Icons.people_alt_rounded,
              label: service.target.arabicLabel,
              color: const Color(0xFF9A5A38),
              backgroundColor: const Color(0xFFFFF7ED),
              borderColor: const Color(0xFFFED7AA),
            ),

            const SizedBox(height: 16),

            CardButton(
              label: 'تعديل',
              icon: Icons.edit_rounded,
              color: const Color(0xFF2563EB),
              onTap: onEdit,
            ),

            const SizedBox(height: 10),

            CardButton(
              label: active ? 'تعطيل' : 'تفعيل',
              icon: active ? Icons.toggle_off_rounded : Icons.toggle_on_rounded,
              color: active ? const Color(0xFFEF4444) : const Color(0xFF16A34A),
              onTap: onToggleActive,
            ),

            const SizedBox(height: 10),

            CardButton(
              label: 'حذف من قائمة الخدمات',
              icon: Icons.delete_outline_rounded,
              color: const Color(0xFF92400E),
              onTap: onArchive,
            ),
          ],
        ),
      ),
    );
  }
}

String? _cleanText(String? value) {
  if (value == null) {
    return null;
  }

  final String trimmed = value.trim();
  if (trimmed.isEmpty) {
    return null;
  }

  return trimmed;
}

class MetaBadge extends StatelessWidget {
  const MetaBadge({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.backgroundColor,
    required this.borderColor,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color backgroundColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 12.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
