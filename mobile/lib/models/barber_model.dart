class BarberModel {
  const BarberModel({
    required this.id,
    required this.name,
    required this.shopName,
    required this.distance,
    required this.rating,
    this.salonId,
    this.salonImageUrl,
    this.barberAvatarUrl,
    this.phone,
    this.address,
    this.bio,
  });

  final String id;
  final String name;
  final String shopName;
  final String distance;
  final double rating;

  /// يربط الحلاق بالصالون الحقيقي.
  /// إذا كان null معناها الحلاق غير مرتبط بصالون حاليًا.
  final String? salonId;

  final String? salonImageUrl;
  final String? barberAvatarUrl;
  final String? phone;
  final String? address;
  final String? bio;
}
