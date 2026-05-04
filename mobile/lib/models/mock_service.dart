class MockService {
  const MockService({
    required this.id,
    required this.name,
    required this.price,
    required this.durationMinutes,
  });

  final String id;
  final String name;
  final int price;
  final int durationMinutes;
}

const List<MockService> mockBarberServices = [
  MockService(
    id: 'bs1',
    name: 'حلاقة شعر + لحية',
    price: 40,
    durationMinutes: 30,
  ),
  MockService(
    id: 'bs2',
    name: 'حلاقة شعر',
    price: 25,
    durationMinutes: 20,
  ),
  MockService(
    id: 'bs3',
    name: 'حلاقة أطفال',
    price: 20,
    durationMinutes: 20,
  ),
];
