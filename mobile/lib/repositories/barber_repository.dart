import '../models/barber_model.dart';
import '../data/mocks/mock_barbers.dart';
import 'contracts/barber_repository_contract.dart';


class BarberRepository implements BarberRepositoryContract {
  const BarberRepository();
   
  @override
  Future<List<BarberModel>> getAvailableBarbers() async {
    await Future.delayed(const Duration(milliseconds: 250));

    return List<BarberModel>.from(mockBarbers);
  }
  
  @override
  Future<BarberModel?> findBarberByName(String barberName) async {
  await Future.delayed(const Duration(milliseconds: 100));

  final normalizedName = barberName.trim();

  for (final barber in mockBarbers) {
    if (barber.name.trim() == normalizedName) {
      return barber;
    }
  }

  return null;
}

}
