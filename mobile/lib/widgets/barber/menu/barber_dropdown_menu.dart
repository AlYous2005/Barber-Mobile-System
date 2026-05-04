import 'dart:ui';

import 'package:flutter/material.dart';
import 'barber_logout_item.dart';
import 'barber_menu_item.dart';

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
                child: Container(color: Colors.black.withValues(alpha: 0.42)),
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
                                  color: const Color(
                                    0xFFC47A3D,
                                  ).withValues(alpha: 0.18),
                                  border: Border.all(
                                    color: const Color(
                                      0xFFC47A3D,
                                    ).withValues(alpha: 0.35),
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

                          BarberMenuItem(
                            label: 'الخدمات',
                            icon: Icons.content_cut_outlined,
                            onTap: onServicesTap,
                            isSelected: true,
                          ),

                          BarberMenuItem(
                            label: 'المواعيد',
                            icon: Icons.calendar_month_outlined,
                            onTap: onAppointmentsTap,
                          ),

                          BarberMenuItem(
                            label: 'التوفر والإغلاقات',
                            icon: Icons.event_busy_rounded,
                            onTap: onAvailabilityTap,
                          ),

                          BarberMenuItem(
                            label: 'ساعات العمل',
                            icon: Icons.schedule_rounded,
                            onTap: onWorkingHoursTap,
                          ),

                          BarberMenuItem(
                            label: 'الملخصات والإنجازات',
                            icon: Icons.bar_chart_rounded,
                            onTap: onSummaryTap,
                          ),

                          BarberMenuItem(
                            label: 'الإعدادات',
                            icon: Icons.settings_outlined,
                            onTap: onSettingsTap,
                          ),

                          const SizedBox(height: 8),

                         BarberLogoutItem(onTap: onLogoutTap),
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



