import 'service_target.dart';

class UiService {
  const UiService({
    required this.id,
    required this.name,
    required this.durationMinutes,
    required this.price,
    this.target = ServiceTarget.personal,
    this.isActive = true,
    this.serviceImageUrl,
    this.serviceIconKey,
  });

  final String id;
  final String name;
  final int durationMinutes;
  final double price;
  final ServiceTarget target;
  final bool isActive;

  /// رابط صورة الخدمة إذا الحلاق رفع صورة من جهازه.
  final String? serviceImageUrl;

  /// مفتاح الأيقونة الجاهزة إذا الحلاق اختار أيقونة بدل الصورة.
  final String? serviceIconKey;

  UiService copyWith({
    String? name,
    int? durationMinutes,
    double? price,
    ServiceTarget? target,
    bool? isActive,
    String? serviceImageUrl,
    String? serviceIconKey,
    bool clearServiceImageUrl = false,
  }) {
    return UiService(
      id: id,
      name: name ?? this.name,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      price: price ?? this.price,
      target: target ?? this.target,
      isActive: isActive ?? this.isActive,
      serviceImageUrl: clearServiceImageUrl
          ? null
          : serviceImageUrl ?? this.serviceImageUrl,
      serviceIconKey: serviceIconKey ?? this.serviceIconKey,
    );
  }
}
