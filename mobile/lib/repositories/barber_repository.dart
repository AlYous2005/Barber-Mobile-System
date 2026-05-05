import '../models/barber_model.dart';

class BarberRepository {
  const BarberRepository();

  Future<List<BarberModel>> getAvailableBarbers() async {
    await Future.delayed(const Duration(milliseconds: 250));

    return List<BarberModel>.from(mockBarbers);
  }
}
