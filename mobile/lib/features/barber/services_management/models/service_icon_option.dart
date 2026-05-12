import 'package:flutter/material.dart';

class ServiceIconOption {
  const ServiceIconOption({
    required this.key,
    required this.arabicName,
    required this.icon,
    this.assetPath,
  });

  final String key;
  final String arabicName;

  /// fallback icon إذا لم يكن عندنا صورة PNG جاهزة.
  final IconData icon;

  /// صورة احترافية من assets.
  final String? assetPath;

  bool get hasAsset {
    final String? path = assetPath?.trim();
    return path != null && path.isNotEmpty;
  }
}

class ServiceIconOptions {
  const ServiceIconOptions._();

  static const String defaultKey = 'haircut';

  static const List<ServiceIconOption> all = <ServiceIconOption>[
    ServiceIconOption(
      key: 'haircut',
      arabicName: 'حلاقة شعر',
      icon: Icons.content_cut_rounded,
      assetPath: 'assets/service_icons/haircut.png',
    ),
    ServiceIconOption(
      key: 'beard',
      arabicName: 'لحية',
      icon: Icons.face_rounded,
      assetPath: 'assets/service_icons/beard-trimming.png',
    ),
    ServiceIconOption(
      key: 'skin_treatment',
      arabicName: 'عناية بالبشرة',
      icon: Icons.spa_rounded,
      assetPath: 'assets/service_icons/skin-treatment.png',
    ),
    ServiceIconOption(
      key: 'elderly_haircut',
      arabicName: 'كبار السن',
      icon: Icons.elderly_rounded,
      assetPath: 'assets/service_icons/old-man-haircut.png',
    ),
    ServiceIconOption(
      key: 'child_haircut',
      arabicName: 'أطفال',
      icon: Icons.child_care_rounded,
      assetPath: 'assets/service_icons/kids-haircut.png',
    ),
    ServiceIconOption(
      key: 'hair_dryer',
      arabicName: 'سشوار',
      icon: Icons.air_rounded,
      assetPath: 'assets/service_icons/hair-dryer.png',
    ),
  ];

  static ServiceIconOption byKey(String? key) {
    if (key == null || key.trim().isEmpty) {
      return all.first;
    }

    final String cleanKey = key.trim();

    final String normalizedKey = cleanKey
        .replaceAll('-', '_')
        .replaceAll(' ', '_')
        .toLowerCase();

    // مفاتيح قديمة أو أسماء ملفات قديمة كانت ممكن تنحفظ في قاعدة البيانات.
    final Map<String, String> aliases = <String, String>{
      'black_mask': 'skin_treatment',
      'facial_care': 'skin_treatment',
      'skin_treatment': 'skin_treatment',
      'skin_treatment_png': 'skin_treatment',

      'styling': 'hair_dryer',
      'hair_wash': 'hair_dryer',
      'hair_dryer': 'hair_dryer',

      'beard_trimming': 'beard',
      'beard_trim': 'beard',

      'old_man_haircut': 'elderly_haircut',
      'elderly': 'elderly_haircut',

      'kids_haircut': 'child_haircut',
      'kid_haircut': 'child_haircut',
      'children_haircut': 'child_haircut',
      'child': 'child_haircut',
    };

    final String resolvedKey = aliases[normalizedKey] ?? normalizedKey;

    for (final option in all) {
      if (option.key == resolvedKey) {
        return option;
      }
    }

    return all.first;
  }
}
