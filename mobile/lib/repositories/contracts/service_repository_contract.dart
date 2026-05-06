import '../../models/service_model.dart';
import '../../models/ui_service_model.dart';

abstract class ServiceRepositoryContract {
  Future<List<ServiceModel>> getAvailableServices({
    required String barberId,
  });

  Future<List<UiService>> getBarberServices({
    required String barberId,
  });

  Future<UiService> addBarberService({
    required String barberId,
    required UiService service,
  });

  Future<UiService> updateBarberService({
    required String barberId,
    required UiService service,
  });

  Future<UiService> setServiceActive({
    required String barberId,
    required String serviceId,
    required bool isActive,
  });
}