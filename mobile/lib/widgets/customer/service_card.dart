import 'package:flutter/material.dart';

import '../../models/service_model.dart';
import 'customer_theme.dart';

class ServiceCard extends StatelessWidget {
  const ServiceCard({
    super.key,
    required this.service,
    required this.selected,
    required this.onTap,
  });

  final ServiceModel service;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected
                ? CustomerTheme.accentOrange.withValues(alpha: 0.18)
                : CustomerTheme.cardFill,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? CustomerTheme.accentOrange : CustomerTheme.cardBorder,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${service.durationMinutes} دقيقة',
                      style: const TextStyle(color: Colors.white60, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${service.price} شيكل',
                    style: const TextStyle(
                      color: CustomerTheme.accentOrange,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (selected)
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Icon(Icons.check_circle, color: CustomerTheme.accentOrange, size: 22),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
