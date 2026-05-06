import '../../models/barber_model.dart';

abstract class BarberRepositoryContract {
  Future<List<BarberModel>> getAvailableBarbers();

  Future<BarberModel?> findBarberByName(String barberName);
}