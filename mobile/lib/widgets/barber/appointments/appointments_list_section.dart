import 'package:flutter/material.dart';

import '../../../features/bookings/bookings.dart';
import '../../../general_utils/app_theme_colors.dart';

import 'appointment_action_widgets.dart';
import '../../shared/appointment_status_pulse_hint.dart';
import '../shared/user_avatar_box.dart';

class AppointmentsListSection extends StatelessWidget {
  const AppointmentsListSection({
    super.key,
    required this.title,
    required this.emptyText,
    required this.appointments,
    required this.isFinalStatus,
    required this.onConfirm,
    required this.onCheckIn,
    required this.onNoShow,
    required this.onCancel,
  });

  final String title;
  final String emptyText;
  final List<MockAppointment> appointments;
  final bool Function(String status) isFinalStatus;
  final ValueChanged<MockAppointment> onConfirm;
  final ValueChanged<MockAppointment> onCheckIn;
  final ValueChanged<MockAppointment> onNoShow;
  final ValueChanged<MockAppointment> onCancel;

  @override
  Widget build(BuildContext context) {
    final bool dark = AppThemeColors.isDark(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: dark ? AppThemeColors.card(context) : null,
        gradient: dark
            ? null
            : const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFFFFF), Color(0xFFFDFCFA)],
              ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppThemeColors.border(context)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x142C221C),
            blurRadius: 44,
            offset: Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              decoration: BoxDecoration(
                color: dark ? AppThemeColors.softCard(context) : null,
                gradient: dark
                    ? null
                    : const LinearGradient(
                        colors: [Color(0xFFFAF4EE), Color(0xFFF6EEE6)],
                      ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppThemeColors.border(context)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14B8774A),
                    blurRadius: 24,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF8F4E2C),
                          Color(0xFFB86A3D),
                          Color(0xFFA85C34),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(13),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x288F4E2C),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.calendar_month_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppThemeColors.textPrimary(context),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          if (appointments.isEmpty)
            EmptyAppointmentsState(emptyText: emptyText)
          else
            ...appointments.map(
              (appointment) => AppointmentLuxuryCard(
                appointment: appointment,
                isFinal: isFinalStatus(appointment.status),
                onConfirm: () => onConfirm(appointment),
                onCheckIn: () => onCheckIn(appointment),
                onNoShow: () => onNoShow(appointment),
                onCancel: () => onCancel(appointment),
              ),
            ),
        ],
      ),
    );
  }
}

class EmptyAppointmentsState extends StatelessWidget {
  const EmptyAppointmentsState({super.key, required this.emptyText});

  final String emptyText;

  @override
  Widget build(BuildContext context) {
    final bool dark = AppThemeColors.isDark(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: dark ? AppThemeColors.softCard(context) : null,
        gradient: dark
            ? null
            : const LinearGradient(
                colors: [Color(0xFFFAF6F1), Color(0xFFF6F0E9)],
              ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppThemeColors.border(context)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: dark ? AppThemeColors.elevatedCard(context) : null,
              gradient: dark
                  ? null
                  : const LinearGradient(
                      colors: [Color(0xFFFAECE0), Color(0xFFF4E2D2)],
                    ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.calendar_month_rounded,
              color: dark
                  ? AppThemeColors.brandBrown(context)
                  : const Color(0xFF8A4A2A),
              size: 23,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'لا توجد مواعيد هنا الآن',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppThemeColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  emptyText,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.6,
                    fontWeight: FontWeight.w600,
                    color: AppThemeColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AppointmentLuxuryCard extends StatefulWidget {
  const AppointmentLuxuryCard({
    super.key,
    required this.appointment,
    required this.isFinal,
    required this.onConfirm,
    required this.onCheckIn,
    required this.onNoShow,
    required this.onCancel,
  });

  final MockAppointment appointment;
  final bool isFinal;
  final VoidCallback onConfirm;
  final VoidCallback onCheckIn;
  final VoidCallback onNoShow;
  final VoidCallback onCancel;

  @override
  State<AppointmentLuxuryCard> createState() => _AppointmentLuxuryCardState();
}

class _AppointmentLuxuryCardState extends State<AppointmentLuxuryCard> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    final MockAppointment appointment = widget.appointment;

    return AnimatedScale(
      scale: isPressed ? 0.985 : 1,
      duration: const Duration(milliseconds: 120),
      child: GestureDetector(
        onTapDown: (_) {
          setState(() {
            isPressed = true;
          });
        },
        onTapCancel: () {
          setState(() {
            isPressed = false;
          });
        },
        onTapUp: (_) {
          setState(() {
            isPressed = false;
          });
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppThemeColors.elevatedCard(context),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppThemeColors.border(context)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                textDirection: TextDirection.ltr,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: appointment.createdAt != null
                          ? Text(
                              formatAppointmentBookedAtLine(
                                appointment.createdAt!,
                              ),
                              textDirection: TextDirection.rtl,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppThemeColors.textMuted(context),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                  AppointmentStatusPulseHint(
                    arabicStatus: appointment.status,
                    audience: AppointmentStatusAudience.barber,
                    cancelledBy: appointment.cancelledBy,
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  UserAvatarBox(
                    displayName: appointment.displayCustomerName,
                    imageUrl: appointment.customerAvatarUrl,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      appointment.displayCustomerName,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        color: AppThemeColors.textPrimary(context),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              AppointmentDetailLine(
                icon: Icons.content_cut_rounded,
                text: appointment.serviceName,
              ),

              const SizedBox(height: 10),

              AppointmentDetailLine(
                icon: Icons.access_time_rounded,
                text: appointment.displayTimeRange,
              ),

              const SizedBox(height: 10),

              AppointmentDetailLine(
                icon: Icons.calendar_month_rounded,
                text: appointment.dateLabel,
              ),

              if (!widget.isFinal) ...[
                const SizedBox(height: 16),
                ActionsGrid(
                  status: appointment.status,
                  onConfirm: widget.onConfirm,
                  onCheckIn: widget.onCheckIn,
                  onNoShow: widget.onNoShow,
                  onCancel: widget.onCancel,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class AppointmentDetailLine extends StatelessWidget {
  const AppointmentDetailLine({
    super.key,
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppThemeColors.softCard(context),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: AppThemeColors.border(context)),
          ),
          child: Icon(
            icon,
            color: AppThemeColors.textSecondary(context),
            size: 17,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14.5,
              height: 1.5,
              fontWeight: FontWeight.w700,
              color: AppThemeColors.textSecondary(context),
            ),
          ),
        ),
      ],
    );
  }
}

class ActionsGrid extends StatelessWidget {
  const ActionsGrid({
    super.key,
    required this.status,
    required this.onConfirm,
    required this.onCheckIn,
    required this.onNoShow,
    required this.onCancel,
  });

  final String status;
  final VoidCallback onConfirm;
  final VoidCallback onCheckIn;
  final VoidCallback onNoShow;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    if (AppointmentStatusUtils.isFinal(status)) {
      return const SizedBox.shrink();
    }

    if (AppointmentStatusUtils.isPending(status)) {
      return Row(
        children: [
          Expanded(
            child: AppointmentActionButton(
              label: 'تأكيد',
              icon: Icons.verified_rounded,
              color: const Color(0xFF3D7A5C),
              onTap: onConfirm,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: AppointmentActionButton(
              label: 'إلغاء',
              icon: Icons.close_rounded,
              color: const Color(0xFFC9544A),
              onTap: onCancel,
            ),
          ),
        ],
      );
    }

    if (AppointmentStatusUtils.isConfirmed(status)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: AppointmentActionButton(
                  label: 'تسجيل حضور',
                  icon: Icons.done_all_rounded,
                  color: const Color(0xFF4A6FA8),
                  onTap: onCheckIn,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppointmentActionButton(
                  label: 'عدم حضور',
                  icon: Icons.person_off_rounded,
                  color: const Color(0xFFC2783A),
                  onTap: onNoShow,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          AppointmentActionButton(
            label: 'إلغاء',
            icon: Icons.close_rounded,
            color: const Color(0xFFC9544A),
            onTap: onCancel,
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: AppointmentActionButton(
            label: 'إلغاء',
            icon: Icons.close_rounded,
            color: const Color(0xFFC9544A),
            onTap: onCancel,
          ),
        ),
      ],
    );
  }
}
