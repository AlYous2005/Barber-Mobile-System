class UiService {
  const UiService({
    required this.id,
    required this.name,
    required this.durationMinutes,
    required this.price,
  });

  final String id;
  final String name;
  final int durationMinutes;
  final double price;

  UiService copyWith({
    String? name,
    int? durationMinutes,
    double? price,
  }) {
    return UiService(
      id: id,
      name: name ?? this.name,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      price: price ?? this.price,
    );
  }
}