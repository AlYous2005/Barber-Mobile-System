import 'package:flutter/material.dart';

import '../../../models/barber_model.dart';
import '../home/customer_theme.dart';

class BarberCard extends StatelessWidget {
  const BarberCard({
    super.key,
    required this.barber,
    required this.selected,
    required this.onTap,
  });

  final BarberModel barber;
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
              color: selected
                  ? CustomerTheme.accentOrange
                  : CustomerTheme.cardBorder,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: CustomerTheme.coffeeBrown,
                    child: const Icon(
                      Icons.content_cut,
                      color: CustomerTheme.accentOrange,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          barber.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          barber.shopName,
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (selected)
                    const Icon(
                      Icons.check_circle,
                      color: CustomerTheme.accentOrange,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.place_outlined,
                    size: 18,
                    color: Colors.white54,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    barber.distance,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.star_rounded,
                    size: 20,
                    color: CustomerTheme.accentOrange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    barber.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
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
