class BarberRatingSummary {
  const BarberRatingSummary({
    required this.averageRating,
    required this.ratingCount,
    required this.satisfactionRate,
    required this.ratingBreakdown,
  });

  final double averageRating;
  final int ratingCount;
  final int satisfactionRate;
  final Map<int, int> ratingBreakdown;

  static const empty = BarberRatingSummary(
    averageRating: 0,
    ratingCount: 0,
    satisfactionRate: 0,
    ratingBreakdown: {5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
  );
}
