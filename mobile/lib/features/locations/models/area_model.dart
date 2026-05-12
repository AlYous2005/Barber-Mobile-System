class AreaModel {
  const AreaModel({
    required this.id,
    required this.governorateId,
    required this.nameAr,
  });

  final String id;
  final String governorateId;
  final String nameAr;

  factory AreaModel.fromMap(Map<String, dynamic> map) {
    return AreaModel(
      id: (map['id'] ?? '').toString(),
      governorateId: (map['governorate_id'] ?? '').toString(),
      nameAr: (map['name_ar'] ?? '').toString(),
    );
  }
}
