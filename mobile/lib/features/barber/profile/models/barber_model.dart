class BarberModel {
  const BarberModel({
    required this.id,
    required this.name,
    required this.shopName,
    required this.distance,
    required this.rating,
    this.ratingCount = 0,
    this.satisfactionRate = 0,
    this.ratingBreakdown = const {5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
    this.salonId,
    this.areaId,
    this.areaName,
    this.governorateName,
    this.salonImageUrl,
    this.barberAvatarUrl,
    this.phone,
    this.address,
    this.bio,
    this.bookingWindowEnabled = false,
    this.bookingWindowType = 'month',
  });

  final String id;
  final String name;
  final String shopName;
  final String distance;
  final double rating;
  final int ratingCount;
  final int satisfactionRate;
  final Map<int, int> ratingBreakdown;

  /// يربط الحلاق بالصالون الحقيقي.
  /// إذا كان null معناها الحلاق غير مرتبط بصالون حاليًا.
  final String? salonId;

  /// منطقة الصالون / الحلاق المستخدمة لفلترة الحلاقين للزبون.
  final String? areaId;

  /// اسم المنطقة مثل: زيتا.
  final String? areaName;

  /// اسم المحافظة مثل: طولكرم.
  final String? governorateName;

  final String? salonImageUrl;
  final String? barberAvatarUrl;
  final String? phone;
  final String? address;
  final String? bio;

  /// When true, customer booking dates are limited per [bookingWindowType].
  final bool bookingWindowEnabled;

  /// Supabase `booking_window_type`: today | today_tomorrow | week | month
  final String bookingWindowType;

  String? get locationLabel {
    final String? cleanGovernorate = governorateName?.trim();
    final String? cleanArea = areaName?.trim();

    if (cleanGovernorate != null &&
        cleanGovernorate.isNotEmpty &&
        cleanArea != null &&
        cleanArea.isNotEmpty) {
      return '$cleanGovernorate - $cleanArea';
    }

    if (cleanArea != null && cleanArea.isNotEmpty) {
      return cleanArea;
    }

    if (cleanGovernorate != null && cleanGovernorate.isNotEmpty) {
      return cleanGovernorate;
    }

    return null;
  }
}
