import 'package:flutter/material.dart';

import '../../models/service_model.dart';

class BookingSummaryCard extends StatelessWidget {
  const BookingSummaryCard({
    super.key,
    required this.barberName,
    required this.barberLocation,
    required this.selectedServices,
    required this.dateLabel,
    required this.timeLabel,
    required this.totalPrice,
    required this.totalDurationLabel,
  });

  final String barberName;
  final String barberLocation;
  final List<ServiceModel> selectedServices;
  final String dateLabel;
  final String timeLabel;
  final int totalPrice;
  final String totalDurationLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Color(0xFFFFFFFF),
                Color(0xFFFFFBF7),
                Color(0xFFFFF1E3),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: const Color(0xFFEADBCD),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF6E3F2F),
                          Color(0xFFC47A3D),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.assignment_turned_in_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'راجع تفاصيل حجزك',
                          style: TextStyle(
                            color: Color(0xFF111827),
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'تأكد من البيانات التالية قبل الضغط على تأكيد الحجز.',
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 12.8,
                            height: 1.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              _SummaryInfoCard(
                title: 'الحلاق',
                value: barberName,
                secondaryValue: barberLocation,
                icon: Icons.content_cut_rounded,
                color: const Color(0xFFC47A3D),
              ),

              const SizedBox(height: 12),

              _ServicesSummaryCard(
                services: selectedServices,
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _MiniSummaryBox(
                      title: 'التاريخ',
                      value: dateLabel,
                      icon: Icons.calendar_month_rounded,
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MiniSummaryBox(
                      title: 'الوقت',
                      value: timeLabel,
                      icon: Icons.access_time_rounded,
                      color: const Color(0xFF16A34A),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _MiniSummaryBox(
                      title: 'حسابك بالشيكل',
                      value: '$totalPrice ₪',
                      icon: Icons.payments_rounded,
                      color: const Color(0xFF16A34A),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MiniSummaryBox(
                      title: 'المدة',
                      value: totalDurationLabel,
                      icon: Icons.timelapse_rounded,
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        




        
      ],
    );
  }
}

class _SummaryInfoCard extends StatelessWidget {
  const _SummaryInfoCard({
    required this.title,
    required this.value,
    required this.secondaryValue,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final String secondaryValue;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFEADBCD),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: color,
              size: 21,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 15.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  secondaryValue,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
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

class _ServicesSummaryCard extends StatelessWidget {
  const _ServicesSummaryCard({
    required this.services,
  });

  final List<ServiceModel> services;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFEADBCD),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.design_services_rounded,
                color: Color(0xFFC47A3D),
                size: 18,
              ),
              SizedBox(width: 7),
              Text(
                'الخدمات المختارة',
                style: TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: services
                .map(
                  (service) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: const Color(0xFFEADBCD),
                      ),
                    ),
                    child: Text(
                      service.name,
                      style: const TextStyle(
                        color: Color(0xFF6B4F3E),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _MiniSummaryBox extends StatelessWidget {
  const _MiniSummaryBox({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.16),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 17,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF4B5563),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 15.5,
              height: 1.25,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}