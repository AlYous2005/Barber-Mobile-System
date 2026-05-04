import 'package:flutter/material.dart';

class ProfileSheetHeader extends StatelessWidget {
  const ProfileSheetHeader({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFFB8774A), Color(0xFF8A4E2E)],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Material(
                color: Colors.white.withValues(alpha: 0.13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: InkWell(
                  onTap: onClose,
                  borderRadius: BorderRadius.circular(15),
                  child: const SizedBox(
                    width: 42,
                    height: 42,
                    child: Icon(Icons.close_rounded, color: Colors.white),
                  ),
                ),
              ),
              const Expanded(
                child: Column(
                  children: [
                    Text(
                      'Barber Profile',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'الملف الشخصي وبيانات التواصل',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFEFE7DE),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 42),
            ],
          ),
        ],
      ),
    );
  }
}