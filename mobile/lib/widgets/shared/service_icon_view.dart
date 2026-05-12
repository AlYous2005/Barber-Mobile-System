import 'package:flutter/material.dart';

import '../../features/barber/services_management/services_management.dart';

class ServiceIconView extends StatelessWidget {
  const ServiceIconView({
    super.key,
    required this.option,
    required this.size,
    required this.fallbackColor,
    this.assetPadding = 3,
  });

  final ServiceIconOption option;
  final double size;
  final Color fallbackColor;
  final double assetPadding;

  @override
  Widget build(BuildContext context) {
    final String? assetPath = option.assetPath?.trim();

    if (assetPath != null && assetPath.isNotEmpty) {
      return Padding(
        padding: EdgeInsets.all(assetPadding),
        child: Image.asset(
          assetPath,
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Icon(option.icon, color: fallbackColor, size: size);
          },
        ),
      );
    }

    return Icon(option.icon, color: fallbackColor, size: size);
  }
}
