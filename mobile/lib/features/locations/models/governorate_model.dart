class GovernorateModel {
  const GovernorateModel({required this.id, required this.nameAr});

  final String id;
  final String nameAr;

  factory GovernorateModel.fromMap(Map<String, dynamic> map) {
    return GovernorateModel(
      id: (map['id'] ?? '').toString(),
      nameAr: (map['name_ar'] ?? '').toString(),
    );
  }
}
