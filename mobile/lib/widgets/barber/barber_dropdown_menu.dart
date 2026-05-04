import 'dart:ui';

import 'package:flutter/material.dart';

class BarberDropdownMenu extends StatelessWidget {
  const BarberDropdownMenu({
    super.key,
    required this.isOpen,
    required this.onClose,
    required this.onServicesTap,
    required this.onAppointmentsTap,
    required this.onAvailabilityTap,
    required this.onWorkingHoursTap,
    required this.onSummaryTap,
    required this.onSettingsTap,
    required this.onLogoutTap,
  });

  final bool isOpen;
  final VoidCallback onClose;
  final VoidCallback onServicesTap;
  final VoidCallback onAppointmentsTap;
  final VoidCallback onAvailabilityTap;
  final VoidCallback onWorkingHoursTap;
  final VoidCallback onSummaryTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onLogoutTap;

  @override
  Widget build(BuildContext context) {
    if (!isOpen) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: Stack(
        children: [
          GestureDetector(
            onTap: onClose,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 9, sigmaY: 9),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.42),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                offset: isOpen ? Offset.zero : const Offset(0, -0.12),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 220),
                  opacity: isOpen ? 1 : 0,
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(18, 14, 18, 0),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1D1511),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x66000000),
                          blurRadius: 34,
                          offset: Offset(0, 18),
                        ),
                      ],
                    ),
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFFC47A3D)
                                      .withValues(alpha: 0.18),
                                  border: Border.all(
                                    color: const Color(0xFFC47A3D)
                                        .withValues(alpha: 0.35),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.content_cut_rounded,
                                  color: Color(0xFFE7B679),
                                  size: 20,
                                ),
                              ),

                              const SizedBox(width: 10),

                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'قائمة الحلاق',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'اختر القسم الذي تريد الانتقال إليه',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFFA8A29E),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Material(
                                color: Colors.white.withValues(alpha: 0.08),
                                shape: const CircleBorder(),
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  onTap: onClose,
                                  child: const SizedBox(
                                    width: 38,
                                    height: 38,
                                    child: Icon(
                                      Icons.close_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          _MenuItem(
                            label: 'الخدمات',
                            icon: Icons.content_cut_outlined,
                            onTap: onServicesTap,
                            isSelected: true,
                          ),

                          _MenuItem(
                            label: 'المواعيد',
                            icon: Icons.calendar_month_outlined,
                            onTap: onAppointmentsTap,
                          ),

                          _MenuItem(
                            label: 'التوفر والإغلاقات',
                            icon: Icons.event_busy_rounded,
                            onTap: onAvailabilityTap,
                          ),

                          _MenuItem(
                            label: 'ساعات العمل',
                            icon: Icons.schedule_rounded,
                            onTap: onWorkingHoursTap,
                          ),

                          _MenuItem(
                            label: 'الملخصات والإنجازات',
                            icon: Icons.bar_chart_rounded,
                            onTap: onSummaryTap,
                          ),

                          _MenuItem(
                            label: 'الإعدادات',
                            icon: Icons.settings_outlined,
                            onTap: onSettingsTap,
                          ),

                          const SizedBox(height: 8),

                          _LogoutItem(
                            onTap: onLogoutTap,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isSelected = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final Color accentColor =
        isSelected ? const Color(0xFFC47A3D) : const Color(0xFF8B6B55);

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Material(
        color: isSelected
            ? const Color(0xFFC47A3D).withValues(alpha: 0.24)
            : Colors.white.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFC47A3D).withValues(alpha: 0.32)
                    : Colors.white.withValues(alpha: 0.06),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected
                        ? const Color(0xFFF2C99A)
                        : const Color(0xFFBFA898),
                    size: 19,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),

                Icon(
                  Icons.chevron_left_rounded,
                  color: Colors.white.withValues(alpha: 0.45),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoutItem extends StatelessWidget {
  const _LogoutItem({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF7F1D1D).withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFEF4444).withValues(alpha: 0.28),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.logout_rounded,
                color: Color(0xFFFCA5A5),
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                'تسجيل الخروج',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFFCA5A5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}