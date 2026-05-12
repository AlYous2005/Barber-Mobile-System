import '../../barber/services_management/services_management.dart';

class SelectedBookingService {
  const SelectedBookingService({required this.service, required this.target});

  final ServiceModel service;
  final ServiceTarget target;

  String get uniqueKey {
    return '${service.id}-${target.databaseValue}';
  }

  String get displayName {
    return '${service.name} — ${target.arabicLabel}';
  }

  int get price {
    return service.price;
  }

  int get durationMinutes {
    return service.durationMinutes;
  }
}
