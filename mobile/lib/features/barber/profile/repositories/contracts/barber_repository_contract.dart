import '../../models/barber_model.dart';

abstract class BarberRepositoryContract {
  Future<List<BarberModel>> getAvailableBarbers();

  Future<List<BarberModel>> getAvailableBarbersByArea({required String areaId});

  Future<BarberModel?> findBarberByName(String barberName);
}
