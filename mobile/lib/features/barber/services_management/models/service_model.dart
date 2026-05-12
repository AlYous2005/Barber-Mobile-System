import 'service_target.dart';

class ServiceModel {
  const ServiceModel({
    required this.id,
    required this.name,
    required this.durationMinutes,
    required this.price,
    this.target = ServiceTarget.personal,
    this.serviceImageUrl,
    this.serviceIconKey,
  });

  final String id;
  final String name;
  final int durationMinutes;
  final int price;
  final ServiceTarget target;

  /// رابط صورة الخدمة إذا الحلاق رفع صورة من جهازه.
  final String? serviceImageUrl;

  /// مفتاح الأيقونة الجاهزة إذا الحلاق اختار أيقونة بدل الصورة.
  final String? serviceIconKey;
}
