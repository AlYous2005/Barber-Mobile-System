import 'package:flutter/material.dart';

import '../../../models/ui_service_model.dart';
import 'service_form_widgets.dart';

class ServiceCard extends StatelessWidget {
  const ServiceCard({
    super.key,
    required this.service,
    required this.onEdit,
    required this.onViewAppointments,
    required this.onDelete,
  });

  final UiService service;
  final VoidCallback onEdit;
  final VoidCallback onViewAppointments;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFFE9EFF0),
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D0F172A),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF7F1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFDCEFE2),
                  ),
                ),
                child: const Icon(
                  Icons.content_cut_rounded,
                  color: Color(0xFF5C4030),
                  size: 20,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  service.name,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111827),
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
                  backgroundColor: const Color(0xFFF4F8F5),
                  borderColor: const Color(0xFFDCEFE2),
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

          const SizedBox(height: 16),

          CardButton(
            label: 'تعديل',
            icon: Icons.edit_rounded,
            color: const Color(0xFF2563EB),
            onTap: onEdit,
          ),

          const SizedBox(height: 10),

          CardButton(
            label: 'المواعيد المرتبطة',
            icon: Icons.visibility_rounded,
            color: const Color(0xFF0F766E),
            onTap: onViewAppointments,
          ),

          const SizedBox(height: 10),

          CardButton(
            label: 'تعطيل',
            icon: Icons.delete_rounded,
            color: const Color(0xFFEF4444),
            onTap: onDelete,
          ),
        ],
      ),
    );
  }
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
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 16,
          ),
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