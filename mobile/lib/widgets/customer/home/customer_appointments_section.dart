import 'package:flutter/material.dart';

import '../../../features/bookings/bookings.dart';
import '../appointments/customer_appointment_card.dart';
import 'appointments_tabs_selector.dart';
import 'empty_appointments_box.dart';

class CustomerAppointmentsSection extends StatelessWidget {
  const CustomerAppointmentsSection({
    super.key,
    required this.selectedTab,
    required this.upcomingAppointments,
    required this.previousAppointments,
    required this.onTabChanged,
    required this.onCancelAppointment,
    required this.onRateAppointment,
    required this.onRebookAppointment,
  });

  final String selectedTab;
  final List<MockAppointment> upcomingAppointments;
  final List<MockAppointment> previousAppointments;
  final ValueChanged<String> onTabChanged;
  final ValueChanged<MockAppointment> onCancelAppointment;
  final ValueChanged<MockAppointment> onRateAppointment;
  final ValueChanged<MockAppointment> onRebookAppointment;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppointmentsTabsSelector(
          selectedTab: selectedTab,
          upcomingCount: upcomingAppointments.length,
          previousCount: previousAppointments.length,
          onTabChanged: onTabChanged,
        ),

        const SizedBox(height: 14),

        if (selectedTab == 'upcoming') ...[
          if (upcomingAppointments.isEmpty)
            const EmptyAppointmentsBox(message: 'لا توجد مواعيد قادمة حالياً')
          else
            ...upcomingAppointments.map(
              (item) => CustomerAppointmentCard(
                appointment: item,
                onRate: null,
                onCancel: canCancelAppointment(item)
                    ? () => onCancelAppointment(item)
                    : null,
                onRebook: null,
              ),
            ),
        ] else ...[
          if (previousAppointments.isEmpty)
            const EmptyAppointmentsBox(message: 'لا توجد مواعيد سابقة حالياً')
          else
            ...previousAppointments.map(
              (item) => CustomerAppointmentCard(
                appointment: item,
                onRate: item.isCompleted && item.customerRating == null
                    ? () => onRateAppointment(item)
                    : null,
                onCancel: null,
                onRebook: () => onRebookAppointment(item),
              ),
            ),
        ],
      ],
    );
  }
}
