import '../models/service_model.dart';

class ServiceRepository {
  const ServiceRepository();

  Future<List<ServiceModel>> getAvailableServices({
    required String barberId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));

    return List<ServiceModel>.from(mockServices);
  }
}
