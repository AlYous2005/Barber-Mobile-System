class UiService {
  const UiService({
    required this.id,
    required this.name,
    required this.durationMinutes,
    required this.price,
    this.isActive = true,
  });

  final String id;
  final String name;
  final int durationMinutes;
  final double price;
  final bool isActive;

  UiService copyWith({
    String? name,
    int? durationMinutes,
    double? price,
    bool? isActive,
  }) {
    return UiService(
      id: id,
      name: name ?? this.name,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      price: price ?? this.price,
      isActive: isActive ?? this.isActive,
    );
  }
}
