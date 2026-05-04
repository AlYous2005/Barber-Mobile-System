import 'package:flutter/material.dart';

class ProfileSummaryCard extends StatelessWidget {
  const ProfileSummaryCard({
    super.key,
    required this.barberName,
    required this.hasSelectedImage,
    required this.onImageTap,
  });

  final String barberName;
  final bool hasSelectedImage;
  final VoidCallback onImageTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFFFFFBF2), Color(0xFFFFF7E6), Colors.white],
        ),
        border: Border.all(color: const Color(0xFFE8D8B8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12C47A3D),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: onImageTap,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [Color(0xFFC47A3D), Color(0xFFF6D38B)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFC47A3D).withValues(alpha: 0.25),
                        blurRadius: 22,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    backgroundColor: const Color(0xFFF8FAFC),
                    child: Icon(
                      hasSelectedImage
                          ? Icons.image_rounded
                          : Icons.content_cut_rounded,
                      size: 38,
                      color: const Color(0xFFC47A3D),
                    ),
                  ),
                ),
                Positioned(
                  right: -2,
                  bottom: 5,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF111827),
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFC47A3D).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: const Color(0xFFC47A3D).withValues(alpha: 0.20),
              ),
            ),
            child: const Text(
              'الملف الشخصي المهني',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w900,
                color: Color(0xFF8A4E2E),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            barberName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF2F1F17),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'اضغط على الصورة لتغيير صورة الحلاق',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}