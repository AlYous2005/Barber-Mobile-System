class ServiceModel {
  const ServiceModel({
    required this.id,
    required this.name,
    required this.durationMinutes,
    required this.price,
  });

  final String id;
  final String name;
  final int durationMinutes;
  final int price;
}

const List<ServiceModel> mockServices = [
  ServiceModel(id: 's1', name: 'حلاقة شعر', durationMinutes: 30, price: 25),
  ServiceModel(id: 's2', name: 'حلاقة ذقن', durationMinutes: 15, price: 10),
  ServiceModel(id: 's3', name: 'ماسك أسود', durationMinutes: 0, price: 10),
  ServiceModel(id: 's4', name: 'ماسك أبيض', durationMinutes: 0, price: 10),
  ServiceModel(id: 's5', name: 'شمع', durationMinutes: 0, price: 8),
  ServiceModel(
    id: 'child_haircut',
    name: 'حلاقة أطفال',
    durationMinutes: 25,
    price: 20,
  ),
];
