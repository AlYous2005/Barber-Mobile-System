import 'barber_model.dart';
import 'service_model.dart';

class BookingModel {
  const BookingModel({
    required this.barber,
    required this.service,
    required this.date,
    required this.timeLabel,
    required this.price,
    required this.dateDisplayLabel,
  });

  final BarberModel barber;
  final ServiceModel service;
  final DateTime date;
  final String timeLabel;
  final int price;
  final String dateDisplayLabel;
}
