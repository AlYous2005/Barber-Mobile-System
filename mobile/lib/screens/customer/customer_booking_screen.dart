import 'package:flutter/material.dart';

import '../../models/barber_model.dart';
import '../../models/booking_model.dart';
import '../../models/service_model.dart';

import '../../widgets/customer/booking_date_selector.dart';
import '../../widgets/customer/booking_summary_card.dart';

import 'booking_success_screen.dart';

const List<String> mockAvailableTimes = [
  '10:00 صباحاً',
  '10:30 صباحاً',
  '11:00 صباحاً',
  '12:00 ظهراً',
  '04:00 مساءً',
  '05:30 مساءً',
];

DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

DateTime _resolveBookingDate(BookingDateChoice choice, DateTime? custom) {
  final today = _startOfDay(DateTime.now());
  switch (choice) {
    case BookingDateChoice.today:
      return today;
    case BookingDateChoice.tomorrow:
      return today.add(const Duration(days: 1));
    case BookingDateChoice.custom:
      return custom != null ? _startOfDay(custom) : today;
  }
}

String _resolveDateDisplayLabel(BookingDateChoice choice, DateTime resolved) {
  switch (choice) {
    case BookingDateChoice.today:
      return 'اليوم';
    case BookingDateChoice.tomorrow:
      return 'غداً';
    case BookingDateChoice.custom:
      return '${resolved.day}/${resolved.month}/${resolved.year}';
  }
}

String _arabicDayName(DateTime date) {
  switch (date.weekday) {
    case DateTime.saturday:
      return 'السبت';
    case DateTime.sunday:
      return 'الأحد';
    case DateTime.monday:
      return 'الإثنين';
    case DateTime.tuesday:
      return 'الثلاثاء';
    case DateTime.wednesday:
      return 'الأربعاء';
    case DateTime.thursday:
      return 'الخميس';
    case DateTime.friday:
      return 'الجمعة';
    default:
      return '';
  }
}

String _dateWithDayLabel(DateTime date) {
  final String day = date.day.toString().padLeft(2, '0');
  final String month = date.month.toString().padLeft(2, '0');
  final String year = date.year.toString();

  return '$day/$month/$year - ${_arabicDayName(date)}';
}

String _formatBookingDuration(int totalMinutes) {
  if (totalMinutes <= 0) {
    return '0';
  }

  if (totalMinutes < 60) {
    return '$totalMinutes دقيقة';
  }

  final int hours = totalMinutes ~/ 60;
  final int minutes = totalMinutes % 60;

  String hourText;
  if (hours == 1) {
    hourText = 'ساعة';
  } else if (hours == 2) {
    hourText = 'ساعتين';
  } else {
    hourText = '$hours ساعات';
  }

  if (minutes == 0) {
    return hourText;
  }

  if (minutes == 15) {
    return '$hourText وربع';
  }

  if (minutes == 30) {
    return '$hourText ونصف';
  }

  if (minutes == 45) {
    return '$hourText و45 دقيقة';
  }

  return '$hourText و$minutes دقائق';
}

class CustomerBookingScreen extends StatefulWidget {
  const CustomerBookingScreen({
    super.key,
    this.preselectedBarber,
  });

  final BarberModel? preselectedBarber;

  @override
  State<CustomerBookingScreen> createState() => _CustomerBookingScreenState();
}

class _CustomerBookingScreenState extends State<CustomerBookingScreen> {
  int step = 0;

  BarberModel? selectedBarber;
  List<ServiceModel> selectedServices = [];
  BookingDateChoice dateChoice = BookingDateChoice.today;
  DateTime? customDate;
  String? selectedTime;

  @override
void initState() {
  super.initState();

  if (widget.preselectedBarber != null) {
    selectedBarber = widget.preselectedBarber;
    step = 1;
  }
}

  int get selectedTotalPrice {
    return selectedServices.fold(0, (sum, service) => sum + service.price);
  }

  int get selectedTotalDuration {
    return selectedServices.fold(
      0,
      (sum, service) => sum + service.durationMinutes,
    );
  }

  ServiceModel get combinedSelectedService {
    return ServiceModel(
      id: selectedServices.map((service) => service.id).join('+'),
      name: selectedServices.map((service) => service.name).join(' + '),
      durationMinutes: selectedTotalDuration,
      price: selectedTotalPrice,
    );
  }

  bool _isServiceSelected(ServiceModel service) {
    return selectedServices.any((item) => item.id == service.id);
  }

  void _toggleService(ServiceModel service) {
    setState(() {
      final bool alreadySelected = _isServiceSelected(service);

      if (alreadySelected) {
        selectedServices = selectedServices
            .where((item) => item.id != service.id)
            .toList();
      } else {
        selectedServices = [...selectedServices, service];
      }

      selectedTime = null;
    });
  }

  bool get _canGoNext {
    switch (step) {
      case 0:
        return selectedBarber != null;
      case 1:
        return selectedServices.isNotEmpty;
      case 2:
        if (dateChoice == BookingDateChoice.custom && customDate == null) {
          return false;
        }
        return true;
      case 3:
        return selectedTime != null;
      case 4:
        return true;
      default:
        return false;
    }
  }

  void _next() {
    if (!_canGoNext) return;
    if (step < 4) {
      setState(() => step += 1);
    }
  }

  void _back() {
    if (step == 0) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => step -= 1);
  }

  void _confirm() {
    final barber = selectedBarber!;
    final service = combinedSelectedService;
    final resolved = _resolveBookingDate(dateChoice, customDate);
    final dateLabel = _resolveDateDisplayLabel(dateChoice, resolved);
    final time = selectedTime!;

    final booking = BookingModel(
      barber: barber,
      service: service,
      date: resolved,
      timeLabel: time,
      price: service.price,
      dateDisplayLabel: dateLabel,
    );

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BookingSuccessScreen(booking: booking),
      ),
    );
  }

  String get _stepTitle {
    switch (step) {
      case 0:
        return 'اختر الحلاق';
      case 1:
        return 'اختر الخدمة';
      case 2:
        return 'اختر التاريخ';
      case 3:
        return 'الأوقات المتاحة';
      case 4:
        return 'تأكيد الحجز';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF7ED),
        appBar: AppBar(
          title: const Text(
            'حجز موعد',
            style: TextStyle(
              color: Color(0xFF111827),
              fontWeight: FontWeight.w900,
            ),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFFFFF7ED),
          surfaceTintColor: const Color(0xFFFFF7ED),
          leading: IconButton(
            onPressed: _back,
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 10),
              child: _BookingStepHeader(step: step, title: _stepTitle),
            ),

            if (step == 1)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: _ServicesLiveCounter(
                  totalPrice: selectedTotalPrice,
                  totalDuration: selectedTotalDuration,
                  selectedCount: selectedServices.length,
                ),
              ),

            if (step == 4)
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: _BookingConfirmWarningCard(),
              ),

            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (step == 0 && selectedBarber != null) {
                    setState(() {
                      selectedBarber = null;
                      selectedServices = [];
                      selectedTime = null;
                    });
                  }
                },
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                  child: _buildStepBody(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: step == 4
                      ? _confirm
                      : _canGoNext
                      ? _next
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC47A3D),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    disabledBackgroundColor: const Color(0xFFE5E7EB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    step == 4 ? 'تأكيد الحجز' : 'التالي',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepBody() {
    switch (step) {
      case 0:
        return _ChooseBarberStep(
          selectedBarber: selectedBarber,
          onSelectBarber: (barber) {
            setState(() {
              selectedBarber = barber;
              selectedServices = [];
              selectedTime = null;
            });
          },
        );
      case 1:
        return _ChooseServicesStep(
          selectedServices: selectedServices,
          onToggleService: _toggleService,
        );
      case 2:
        return BookingDateSelector(
          choice: dateChoice,
          customDate: customDate,
          onChoiceChanged: (c) {
            setState(() {
              dateChoice = c;
              selectedTime = null;

              if (c != BookingDateChoice.custom) {
                customDate = null;
              }
            });
          },
          onCustomDateChanged: (date) {
            setState(() {
              customDate = date;
              dateChoice = BookingDateChoice.custom;
              selectedTime = null;
            });
          },
        );
      case 3:
        final DateTime resolvedDate = _resolveBookingDate(
          dateChoice,
          customDate,
        );

        return _AvailableTimesStep(
          selectedTime: selectedTime,
          selectedDateLabel: _dateWithDayLabel(resolvedDate),
          requiredDurationLabel: _formatBookingDuration(selectedTotalDuration),
          onSelectTime: (time) {
            setState(() {
              selectedTime = time;
            });
          },
        );
      case 4:
        final barber = selectedBarber!;
        final resolvedDate = _resolveBookingDate(dateChoice, customDate);

        return BookingSummaryCard(
          barberName: barber.name,
          barberLocation: 'زيتا، زيتا',
          selectedServices: selectedServices,
          dateLabel: _dateWithDayLabel(resolvedDate),
          timeLabel: selectedTime!,
          totalPrice: selectedTotalPrice,
          totalDurationLabel: _formatBookingDuration(selectedTotalDuration),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _ChooseBarberStep extends StatelessWidget {
  const _ChooseBarberStep({
    required this.selectedBarber,
    required this.onSelectBarber,
  });

  final BarberModel? selectedBarber;
  final ValueChanged<BarberModel> onSelectBarber;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...mockBarbers.map(
          (barber) => _WarmBarberChoiceCard(
            barber: barber,
            selected: selectedBarber?.id == barber.id,
            onTap: () => onSelectBarber(barber),
          ),
        ),
      ],
    );
  }
}

class _WarmBarberChoiceCard extends StatelessWidget {
  const _WarmBarberChoiceCard({
    required this.barber,
    required this.selected,
    required this.onTap,
  });

  final BarberModel barber;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color borderColor = selected
        ? const Color(0xFFC47A3D)
        : const Color(0xFFEADBCD);

    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: borderColor, width: selected ? 1.7 : 1),
              boxShadow: [
                BoxShadow(
                  color: selected
                      ? const Color(0x22C47A3D)
                      : const Color(0x10000000),
                  blurRadius: selected ? 22 : 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF6E3F2F), Color(0xFFC47A3D)],
                        ),
                        border: Border.all(
                          color: const Color(0xFFE7B679),
                          width: 2.4,
                        ),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 31,
                      ),
                    ),
                    if (selected)
                      Positioned(
                        left: -2,
                        bottom: -2,
                        child: Container(
                          width: 23,
                          height: 23,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF16A34A),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 15,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(width: 13),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        barber.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF111827),
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        barber.shopName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 17,
                            color: Color(0xFF9CA3AF),
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            'زيتا، زيتا',
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 12),
                          _FiveStarsMiniRating(rating: barber.rating),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFFC47A3D)
                        : const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFFC47A3D)
                          : const Color(0xFFEADBCD),
                    ),
                  ),
                  child: Icon(
                    selected
                        ? Icons.check_rounded
                        : Icons.arrow_back_ios_new_rounded,
                    color: selected ? Colors.white : const Color(0xFFC47A3D),
                    size: selected ? 20 : 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FiveStarsMiniRating extends StatelessWidget {
  const _FiveStarsMiniRating({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    final int fullStars = rating.floor();
    final bool hasHalfStar = rating - fullStars >= 0.5;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        IconData icon;

        if (index < fullStars) {
          icon = Icons.star_rounded;
        } else if (index == fullStars && hasHalfStar) {
          icon = Icons.star_half_rounded;
        } else {
          icon = Icons.star_border_rounded;
        }

        return Icon(icon, size: 15, color: const Color(0xFFF59E0B));
      }),
    );
  }
}

class _BookingStepHeader extends StatelessWidget {
  const _BookingStepHeader({required this.step, required this.title});

  final int step;
  final String title;

  @override
  Widget build(BuildContext context) {
    final int currentStep = step + 1;
    final double progress = currentStep / 5;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEADBCD)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6E3F2F), Color(0xFFC47A3D)],
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.content_cut_rounded,
                  color: Colors.white,
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
                        color: Color(0xFF111827),
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'الخطوة $currentStep من 5',
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFFEADBCD)),
                ),
                child: Text(
                  '$currentStep/5',
                  style: const TextStyle(
                    color: Color(0xFFC47A3D),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Container(
              height: 8,
              width: double.infinity,
              color: const Color(0xFFF3E5D8),
              child: Align(
                alignment: Alignment.centerRight,
                child: FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFC47A3D), Color(0xFFFFB45C)],
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

class _ChooseServicesStep extends StatelessWidget {
  const _ChooseServicesStep({
    required this.selectedServices,
    required this.onToggleService,
  });

  final List<ServiceModel> selectedServices;
  final ValueChanged<ServiceModel> onToggleService;

  bool _isSelected(ServiceModel service) {
    return selectedServices.any((item) => item.id == service.id);
  }

  @override
  Widget build(BuildContext context) {
    final regularServices = mockServices
        .where((service) => service.id != 'child_haircut')
        .toList();

    final childServices = mockServices
        .where((service) => service.id == 'child_haircut')
        .toList();

    return Column(
      children: [
        _ServicesSectionTitle(
          title: 'الخدمات المتوفرة',
          subtitle: 'اختر خدمة واحدة أو أكثر حسب ما تحتاجه.',
          icon: Icons.content_cut_rounded,
        ),

        const SizedBox(height: 12),

        ...regularServices.map(
          (service) => _SelectableServiceCard(
            service: service,
            selected: _isSelected(service),
            onTap: () => onToggleService(service),
          ),
        ),

        if (childServices.isNotEmpty) ...[
          const SizedBox(height: 10),

          _ChildServiceInfoCard(),

          const SizedBox(height: 12),

          ...childServices.map(
            (service) => _SelectableServiceCard(
              service: service,
              selected: _isSelected(service),
              onTap: () => onToggleService(service),
            ),
          ),
        ],
      ],
    );
  }
}

class _ServicesLiveCounter extends StatelessWidget {
  const _ServicesLiveCounter({
    required this.totalPrice,
    required this.totalDuration,
    required this.selectedCount,
  });

  final int totalPrice;
  final int totalDuration;
  final int selectedCount;

  @override
  Widget build(BuildContext context) {
    final bool hasSelection = selectedCount > 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: hasSelection
              ? const [Color(0xFFFFFFFF), Color(0xFFFFFBF7), Color(0xFFFFEDD5)]
              : const [Color(0xFFFFFFFF), Color(0xFFFFFBF7)],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: hasSelection
              ? const Color(0xFFC47A3D)
              : const Color(0xFFEADBCD),
          width: hasSelection ? 1.6 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: hasSelection
                ? const Color(0x24C47A3D)
                : const Color(0x10000000),
            blurRadius: hasSelection ? 22 : 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6E3F2F), Color(0xFFC47A3D)],
                  ),
                  borderRadius: BorderRadius.circular(17),
                  boxShadow: hasSelection
                      ? const [
                          BoxShadow(
                            color: Color(0x33C47A3D),
                            blurRadius: 16,
                            offset: Offset(0, 7),
                          ),
                        ]
                      : [],
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: Colors.white,
                  size: 23,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.25),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: Text(
                        hasSelection
                            ? 'تم اختيار $selectedCount خدمات'
                            : 'اختر خدماتك وسيظهر الحساب هنا',
                        key: ValueKey('selected-count-$selectedCount'),
                        style: const TextStyle(
                          color: Color(0xFF111827),
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'يتم تحديث السعر والمدة تلقائيًا',
                      style: TextStyle(
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

          const SizedBox(height: 15),

          Row(
            children: [
              Expanded(
                child: _AnimatedSummaryBox(
                  label: 'حسابك بالشيكل',
                  value: '$totalPrice ₪',
                  icon: Icons.payments_rounded,
                  color: const Color(0xFF16A34A),
                  valueKeyText: 'price-$totalPrice',
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _AnimatedSummaryBox(
                  label: 'المدة',
                  value: _formatBookingDuration(totalDuration),
                  icon: Icons.access_time_rounded,
                  color: const Color(0xFF2563EB),
                  valueKeyText: 'duration-$totalDuration',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnimatedSummaryBox extends StatelessWidget {
  const _AnimatedSummaryBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.valueKeyText,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String valueKeyText;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 31,
                height: 31,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: color, size: 17),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  '$label:',
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

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            transitionBuilder: (child, animation) {
              final curvedAnimation = CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutBack,
              );

              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(scale: curvedAnimation, child: child),
              );
            },
            child: Text(
              value,
              key: ValueKey(valueKeyText),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 18,
                height: 1.15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServicesSectionTitle extends StatelessWidget {
  const _ServicesSectionTitle({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFFFEDD5),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: const Color(0xFFC47A3D), size: 20),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
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
    );
  }
}

class _SelectableServiceCard extends StatelessWidget {
  const _SelectableServiceCard({
    required this.service,
    required this.selected,
    required this.onTap,
  });

  final ServiceModel service;
  final bool selected;
  final VoidCallback onTap;

  bool get isZeroDuration => service.durationMinutes == 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: selected
                    ? const Color(0xFFC47A3D)
                    : const Color(0xFFEADBCD),
                width: selected ? 1.7 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: selected
                      ? const Color(0x22C47A3D)
                      : const Color(0x0D000000),
                  blurRadius: selected ? 20 : 12,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFFC47A3D)
                        : const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFFC47A3D)
                          : const Color(0xFFEADBCD),
                    ),
                  ),
                  child: Icon(
                    selected ? Icons.check_rounded : Icons.add_rounded,
                    color: selected ? Colors.white : const Color(0xFFC47A3D),
                    size: 22,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name,
                        style: const TextStyle(
                          color: Color(0xFF111827),
                          fontSize: 16.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                      const SizedBox(height: 7),

                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _ServiceMiniBadge(
                            icon: Icons.payments_rounded,
                            text: '${service.price} شيكل',
                            color: const Color(0xFF16A34A),
                          ),
                          _ServiceMiniBadge(
                            icon: Icons.access_time_rounded,
                            text: isZeroDuration
                                ? 'لا يزيد مدة الحجز'
                                : '${service.durationMinutes} دقيقة',
                            color: isZeroDuration
                                ? const Color(0xFF6366F1)
                                : const Color(0xFF2563EB),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ServiceMiniBadge extends StatelessWidget {
  const _ServiceMiniBadge({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChildServiceInfoCard extends StatelessWidget {
  const _ChildServiceInfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8D8B8)),
      ),
      child: const Row(
        children: [
          Icon(Icons.child_care_rounded, color: Color(0xFFC47A3D), size: 24),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'يمكنك حجز موعد لحلاقة طفلك أيضًا عن طريق هذه الخدمة.',
              style: TextStyle(
                color: Color(0xFF6B4F3E),
                fontSize: 13,
                height: 1.55,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvailableTimesStep extends StatelessWidget {
  const _AvailableTimesStep({
    required this.selectedTime,
    required this.selectedDateLabel,
    required this.requiredDurationLabel,
    required this.onSelectTime,
  });

  final String? selectedTime;
  final String selectedDateLabel;
  final String requiredDurationLabel;
  final ValueChanged<String> onSelectTime;

  static const List<String> morningTimes = [
    '10:00 صباحاً',
    '10:30 صباحاً',
    '11:00 صباحاً',
    '12:00 ظهراً',
  ];

  static const List<String> eveningTimes = [
    '04:00 مساءً',
    '05:30 مساءً',
    '06:00 مساءً',
    '07:00 مساءً',
  ];

  // Mock حاليًا: لاحقًا الباك إند هو الذي يحدد الأوقات غير المتاحة.
  static const Set<String> unavailableTimes = {'10:30 صباحاً', '06:00 مساءً'};

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _AvailableTimesInfoCard(
          selectedDateLabel: selectedDateLabel,
          requiredDurationLabel: requiredDurationLabel,
          selectedTime: selectedTime,
        ),

        const SizedBox(height: 16),

        _TimesGroup(
          title: 'أوقات الصباح',
          subtitle: 'اختر وقتًا مناسبًا قبل الظهيرة.',
          icon: Icons.wb_sunny_rounded,
          times: morningTimes,
          unavailableTimes: unavailableTimes,
          selectedTime: selectedTime,
          onSelectTime: onSelectTime,
        ),

        const SizedBox(height: 16),

        _TimesGroup(
          title: 'أوقات المساء',
          subtitle: 'أوقات مناسبة بعد الظهر والمساء.',
          icon: Icons.nightlight_round_rounded,
          times: eveningTimes,
          unavailableTimes: unavailableTimes,
          selectedTime: selectedTime,
          onSelectTime: onSelectTime,
        ),

        const SizedBox(height: 8),

        const _TimeSelectionHint(),
      ],
    );
  }
}

class _AvailableTimesInfoCard extends StatelessWidget {
  const _AvailableTimesInfoCard({
    required this.selectedDateLabel,
    required this.requiredDurationLabel,
    required this.selectedTime,
  });

  final String selectedDateLabel;
  final String requiredDurationLabel;
  final String? selectedTime;

  @override
  Widget build(BuildContext context) {
    final bool hasSelectedTime = selectedTime != null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFFFFFFFF), Color(0xFFFFFBF7), Color(0xFFFFEDD5)],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: hasSelectedTime
              ? const Color(0xFFC47A3D)
              : const Color(0xFFEADBCD),
          width: hasSelectedTime ? 1.6 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: hasSelectedTime
                ? const Color(0x24C47A3D)
                : const Color(0x10000000),
            blurRadius: hasSelectedTime ? 22 : 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6E3F2F), Color(0xFFC47A3D)],
                  ),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Icon(
                  Icons.schedule_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'الأوقات المتاحة لهذا اليوم',
                      style: TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      selectedDateLabel,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _TimeInfoMiniBox(
                  label: 'مدة الحجز',
                  value: requiredDurationLabel,
                  icon: Icons.timelapse_rounded,
                  color: const Color(0xFF2563EB),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _TimeInfoMiniBox(
                  label: 'الوقت المختار',
                  value: selectedTime ?? 'لم يتم الاختيار',
                  icon: Icons.check_circle_rounded,
                  color: hasSelectedTime
                      ? const Color(0xFF16A34A)
                      : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimeInfoMiniBox extends StatelessWidget {
  const _TimeInfoMiniBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
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
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
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

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutBack,
                  ),
                  child: child,
                ),
              );
            },
            child: Text(
              value,
              key: ValueKey(value),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 15.5,
                height: 1.2,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimesGroup extends StatelessWidget {
  const _TimesGroup({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.times,
    required this.unavailableTimes,
    required this.selectedTime,
    required this.onSelectTime,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<String> times;
  final Set<String> unavailableTimes;
  final String? selectedTime;
  final ValueChanged<String> onSelectTime;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFEADBCD)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 14,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEDD5),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: const Color(0xFFC47A3D), size: 21),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
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

          const SizedBox(height: 14),

          GridView.builder(
            itemCount: times.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.45,
            ),
            itemBuilder: (context, index) {
              final String time = times[index];
              final bool isUnavailable = unavailableTimes.contains(time);

              return _AvailableTimeCard(
                label: time,
                selected: selectedTime == time,
                unavailable: isUnavailable,
                onTap: isUnavailable ? null : () => onSelectTime(time),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AvailableTimeCard extends StatelessWidget {
  const _AvailableTimeCard({
    required this.label,
    required this.selected,
    required this.unavailable,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool unavailable;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Colors.white;
    Color borderColor = const Color(0xFFEADBCD);
    Color textColor = const Color(0xFF111827);
    Color iconColor = const Color(0xFFC47A3D);

    if (selected) {
      backgroundColor = const Color(0xFFC47A3D);
      borderColor = const Color(0xFFC47A3D);
      textColor = Colors.white;
      iconColor = Colors.white;
    }

    if (unavailable) {
      backgroundColor = const Color(0xFFF3F4F6);
      borderColor = const Color(0xFFE5E7EB);
      textColor = const Color(0xFF9CA3AF);
      iconColor = const Color(0xFF9CA3AF);
    }

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 190),
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor, width: selected ? 1.6 : 1),
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: Color(0x30C47A3D),
                      blurRadius: 16,
                      offset: Offset(0, 7),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                unavailable
                    ? Icons.block_rounded
                    : selected
                    ? Icons.check_circle_rounded
                    : Icons.access_time_rounded,
                color: iconColor,
                size: 17,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  unavailable ? 'محجوز' : label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeSelectionHint extends StatelessWidget {
  const _TimeSelectionHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8D8B8)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_rounded, color: Color(0xFFC47A3D), size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'الأوقات المحجوزة أو غير المتاحة تظهر باللون الرمادي. لاحقًا سيتم حسابها تلقائيًا حسب جدول الحلاق.',
              style: TextStyle(
                color: Color(0xFF6B4F3E),
                fontSize: 12.5,
                height: 1.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _BookingConfirmWarningCard extends StatelessWidget {
  const _BookingConfirmWarningCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFCA5A5),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14EF4444),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFDC2626),
            size: 23,
          ),
          SizedBox(width: 9),
          Expanded(
            child: Text(
              'راجع تفاصيل الحجز جيدًا. يمكنك الرجوع وتعديل أي خطوة قبل تأكيد الحجز النهائي.',
              style: TextStyle(
                color: Color(0xFF991B1B),
                fontSize: 13,
                height: 1.55,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
