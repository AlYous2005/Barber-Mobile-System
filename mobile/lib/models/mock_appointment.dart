class MockAppointment {
  const MockAppointment({
    required this.id,
    required this.customerName,
    required this.barberName,
    required this.barberRating,
    required this.serviceName,
    required this.dateLabel,
    required this.timeLabel,
    required this.status,
    required this.startDateTime,
    required this.endDateTime,
  });

  final String id;
  final String customerName;
  final String barberName;
  final double barberRating;
  final String serviceName;
  final String dateLabel;
  final String timeLabel;
  final String status;
  final DateTime startDateTime;
  final DateTime endDateTime;

  bool get isCompleted => status == 'مكتمل';
  bool get isCurrent => status == 'جاري';
  bool get isUpcoming => status == 'قادم';
}

final DateTime _mockNow = DateTime.now();

String _formatArabicTime(DateTime dateTime) {
  final int hour = dateTime.hour;
  final int minute = dateTime.minute;

  final String period = hour >= 12 ? 'مساءً' : 'صباحًا';
  final int displayHour = hour % 12 == 0 ? 12 : hour % 12;
  final String displayMinute = minute.toString().padLeft(2, '0');

  return '$displayHour:$displayMinute $period';
}

final List<MockAppointment> mockCustomerAppointments = [
  MockAppointment(
    id: 'ca1',
    customerName: 'يوسف',
    barberName: 'أحمد',
    barberRating: 4.8,
    serviceName: 'حلاقة شعر + لحية',
    dateLabel: 'اليوم',
    timeLabel: _formatArabicTime(_mockNow.add(const Duration(hours: 2))),
    status: 'قادم',
    startDateTime: _mockNow.add(const Duration(hours: 2)),
    endDateTime: _mockNow.add(const Duration(hours: 2, minutes: 30)),
  ),
  MockAppointment(
    id: 'ca2',
    customerName: 'يوسف',
    barberName: 'محمد',
    barberRating: 4.6,
    serviceName: 'حلاقة شعر',
    dateLabel: 'أمس',
    timeLabel: _formatArabicTime(_mockNow.subtract(const Duration(days: 1))),
    status: 'مكتمل',
    startDateTime: _mockNow.subtract(const Duration(days: 1, hours: 2)),
    endDateTime: _mockNow.subtract(const Duration(days: 1, hours: 1, minutes: 30)),
  ),
];

final List<MockAppointment> mockBarberAppointments = [
  MockAppointment(
    id: 'ba1',
    customerName: 'محمد علي',
    barberName: 'أنت',
    barberRating: 0,
    serviceName: 'حلاقة شعر',
    dateLabel: 'اليوم',
    timeLabel: _formatArabicTime(_mockNow.subtract(const Duration(minutes: 10))),
    status: 'جاري',
    startDateTime: _mockNow.subtract(const Duration(minutes: 10)),
    endDateTime: _mockNow.add(const Duration(minutes: 20)),
  ),
  MockAppointment(
    id: 'ba2',
    customerName: 'أحمد خالد',
    barberName: 'أنت',
    barberRating: 0,
    serviceName: 'حلاقة شعر + لحية',
    dateLabel: 'اليوم',
    timeLabel: _formatArabicTime(_mockNow.add(const Duration(minutes: 45))),
    status: 'قادم',
    startDateTime: _mockNow.add(const Duration(minutes: 45)),
    endDateTime: _mockNow.add(const Duration(minutes: 75)),
  ),
  MockAppointment(
    id: 'ba3',
    customerName: 'سامي عيسى',
    barberName: 'أنت',
    barberRating: 0,
    serviceName: 'حلاقة أطفال',
    dateLabel: 'اليوم',
    timeLabel: _formatArabicTime(_mockNow.subtract(const Duration(hours: 2))),
    status: 'مكتمل',
    startDateTime: _mockNow.subtract(const Duration(hours: 2)),
    endDateTime: _mockNow.subtract(const Duration(hours: 1, minutes: 30)),
  ),
];