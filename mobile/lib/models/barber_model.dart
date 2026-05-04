class BarberModel {
  const BarberModel({
    required this.id,
    required this.name,
    required this.shopName,
    required this.distance,
    required this.rating,
  });

  final String id;
  final String name;
  final String shopName;
  final String distance;
  final double rating;
}

const List<BarberModel> mockBarbers = [
  BarberModel(
    id: 'b1',
    name: 'أحمد',
    shopName: 'صالون أحمد',
    distance: '1.2 كم',
    rating: 4.8,
  ),
  BarberModel(
    id: 'b2',
    name: 'محمد',
    shopName: 'صالون الشباب',
    distance: '2.5 كم',
    rating: 4.6,
  ),
];
