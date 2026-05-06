import '../../models/mock_appointment.dart';
import '../../utils/booking_formatters.dart';

final DateTime _mockNow = DateTime.now();

String _formatArabicTime(DateTime dateTime) {
  return formatArabicClockWithPeriod(dateTime);
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
    customerId: 'customer',
    barberId: 'b1',
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
    endDateTime: _mockNow.subtract(
      const Duration(days: 1, hours: 1, minutes: 30),
    ),
    customerId: 'customer',
    barberId: 'b1',
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
    timeLabel: _formatArabicTime(
      _mockNow.subtract(const Duration(minutes: 10)),
    ),
    status: 'جاري',
    startDateTime: _mockNow.subtract(const Duration(minutes: 10)),
    endDateTime: _mockNow.add(const Duration(minutes: 20)),
    customerId: 'customer',
    barberId: 'b1',
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
    customerId: 'customer',
    barberId: 'b1',
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
    customerId: 'customer',
    barberId: 'b1',
  ),
];
