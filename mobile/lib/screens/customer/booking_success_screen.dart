import 'dart:ui';

import 'package:flutter/material.dart';

import '../../models/booking_model.dart';
import '../../widgets/customer/booking_summary_card.dart';

class BookingSuccessScreen extends StatefulWidget {
  const BookingSuccessScreen({
    super.key,
    required this.booking,
  });

  final BookingModel booking;

  @override
  State<BookingSuccessScreen> createState() => _BookingSuccessScreenState();
}

class _BookingSuccessScreenState extends State<BookingSuccessScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _showImportantReminderPopup();
    });
  }

  void _goHome() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  String _formatSuccessDuration(int totalMinutes) {
    if (totalMinutes <= 0) {
      return 'لا يزيد مدة الحجز';
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

  void _showImportantReminderPopup() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Stack(
            children: [
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 8,
                    sigmaY: 8,
                  ),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.22),
                  ),
                ),
              ),
              Dialog(
                insetPadding: const EdgeInsets.symmetric(horizontal: 22),
                backgroundColor: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: const Color(0xFFFCA5A5),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 30,
                        offset: Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 62,
                        height: 62,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF1F2),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: const Color(0xFFFCA5A5),
                          ),
                        ),
                        child: const Icon(
                          Icons.notifications_active_rounded,
                          color: Color(0xFFDC2626),
                          size: 31,
                        ),
                      ),

                      const SizedBox(height: 16),

                      const Text(
                        'تنبيه مهم قبل الموعد',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF111827),
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        'يرجى الانتباه إلى هاتفك قبل الموعد بـ 15 دقيقة.\n'
                        'سيتم إرسال إشعار لك لتأكيد حضورك على الموعد.\n'
                        'في حال عدم الرد قد يتم إلغاء الموعد تلقائيًا.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF7F1D1D),
                          fontSize: 14,
                          height: 1.7,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 18),

                      SizedBox(
                        width: double.infinity,
                        child: Material(
                          color: const Color(0xFFDC2626),
                          borderRadius: BorderRadius.circular(18),
                          child: InkWell(
                            onTap: () => Navigator.of(context).pop(),
                            borderRadius: BorderRadius.circular(18),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'حسناً',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;

    return PopScope(
      canPop: false,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color(0xFFFFF7ED),
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text(
              'نجاح الحجز',
              style: TextStyle(
                color: Color(0xFF111827),
                fontWeight: FontWeight.w900,
              ),
            ),
            centerTitle: true,
            backgroundColor: const Color(0xFFFFF7ED),
            surfaceTintColor: const Color(0xFFFFF7ED),
            elevation: 0,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          Color(0xFFFFFFFF),
                          Color(0xFFF0FDF4),
                          Color(0xFFDCFCE7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: const Color(0xFFBBF7D0),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1A16A34A),
                          blurRadius: 26,
                          offset: Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 82,
                          height: 82,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF16A34A),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF16A34A)
                                    .withValues(alpha: 0.35),
                                blurRadius: 24,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 46,
                          ),
                        ),

                        const SizedBox(height: 18),

                        const Text(
                          'تم تأكيد حجزك بنجاح',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF111827),
                            fontSize: 25,
                            fontWeight: FontWeight.w900,
                          ),
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          'تم تسجيل الموعد بنجاح. يمكنك الآن العودة للصفحة الرئيسية ومتابعة حالة موعدك من قسم مواعيدي.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF4B5563),
                            fontSize: 14,
                            height: 1.65,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  BookingSummaryCard(
                    barberName: booking.barber.name,
                    barberLocation: 'زيتا، زيتا',
                    selectedServices: [booking.service],
                    dateLabel: booking.dateDisplayLabel,
                    timeLabel: booking.timeLabel,
                    totalPrice: booking.price,
                    totalDurationLabel: _formatSuccessDuration(
                      booking.service.durationMinutes,
                    ),
                  ),

                  const SizedBox(height: 22),

                  SizedBox(
                    width: double.infinity,
                    child: Material(
                      color: const Color(0xFFC47A3D),
                      borderRadius: BorderRadius.circular(18),
                      child: InkWell(
                        onTap: _goHome,
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x33C47A3D),
                                blurRadius: 18,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.home_rounded,
                                color: Colors.white,
                                size: 21,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'العودة للصفحة الرئيسية',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}