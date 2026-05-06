import '../models/mock_service.dart';
import '../models/service_model.dart';
import '../models/ui_service_model.dart';
import '../data/mocks/mock_services.dart';
import 'contracts/service_repository_contract.dart';

class ServiceRepository implements ServiceRepositoryContract {
  const ServiceRepository();

  static final Map<String, List<UiService>> _servicesByBarberId = {
    // b1 = أحمد = حساب admin المؤقت.
    'b1': mockBarberServices.map(_uiServiceFromMockService).toList(),

    // b2 = محمد = خدمات افتراضية مؤقتًا.
    'b2': mockServices.map(_uiServiceFromServiceModel).toList(),
  };

  static UiService _uiServiceFromMockService(MockService service) {
    return UiService(
      id: service.id,
      name: service.name,
      durationMinutes: service.durationMinutes,
      price: service.price.toDouble(),
      isActive: true,
    );
  }

  static UiService _uiServiceFromServiceModel(ServiceModel service) {
    return UiService(
      id: service.id,
      name: service.name,
      durationMinutes: service.durationMinutes,
      price: service.price.toDouble(),
      isActive: true,
    );
  }

  List<UiService> _servicesForBarber(String barberId) {
    if (_servicesByBarberId.containsKey(barberId)) {
      return _servicesByBarberId[barberId]!;
    }

    _servicesByBarberId[barberId] = mockServices
        .map(_uiServiceFromServiceModel)
        .toList();

    return _servicesByBarberId[barberId]!;
  }
  @override
  Future<List<UiService>> getBarberServices({required String barberId}) async {
    await Future.delayed(const Duration(milliseconds: 250));

    return List<UiService>.from(_servicesForBarber(barberId));
  }
  @override
  Future<List<ServiceModel>> getAvailableServices({
    required String barberId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));

    return _servicesForBarber(barberId)
        .where((service) => service.isActive)
        .map(
          (service) => ServiceModel(
            id: service.id,
            name: service.name,
            durationMinutes: service.durationMinutes,
            price: service.price.round(),
          ),
        )
        .toList();
  }
  @override
  Future<UiService> addBarberService({
    required String barberId,
    required UiService service,
  }) async {
    await Future.delayed(const Duration(milliseconds: 350));

    final services = _servicesForBarber(barberId);
    services.insert(0, service);

    return service;
  }
  @override
  Future<UiService> updateBarberService({
    required String barberId,
    required UiService service,
  }) async {
    await Future.delayed(const Duration(milliseconds: 350));

    final services = _servicesForBarber(barberId);
    final int index = services.indexWhere((item) => item.id == service.id);

    if (index != -1) {
      services[index] = service;
    }

    return service;
  }
  @override
  Future<UiService> setServiceActive({
    required String barberId,
    required String serviceId,
    required bool isActive,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));

    final services = _servicesForBarber(barberId);
    final int index = services.indexWhere((item) => item.id == serviceId);

    if (index == -1) {
      throw Exception('Service not found');
    }

    final updatedService = services[index].copyWith(isActive: isActive);
    services[index] = updatedService;

    return updatedService;
  }
}
