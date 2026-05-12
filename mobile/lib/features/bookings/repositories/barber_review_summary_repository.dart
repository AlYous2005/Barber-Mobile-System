import '../../../services/supabase_config.dart';
import '../constants/booking_constants.dart';
import '../models/barber_rating_summary.dart';

class BarberReviewSummaryRepository {
  const BarberReviewSummaryRepository();

  Future<BarberRatingSummary> getSummaryForBarber({
    required String barberId,
  }) async {
    final cleanedBarberId = barberId.trim();

    if (cleanedBarberId.isEmpty) {
      return BarberRatingSummary.empty;
    }

    final rows = await SupabaseConfig.client
        .from(BookingTableNames.barberReviews)
        .select(BarberReviewColumnNames.rating)
        .eq(BarberReviewColumnNames.barberId, cleanedBarberId);

    return _buildSummaryFromRows(rows);
  }

  Future<Map<String, BarberRatingSummary>> getSummariesByBarberIds({
    required List<String> barberIds,
  }) async {
    final cleanedIds = barberIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();

    if (cleanedIds.isEmpty) {
      return <String, BarberRatingSummary>{};
    }

    final rows = await SupabaseConfig.client
        .from(BookingTableNames.barberReviews)
        .select(
          '${BarberReviewColumnNames.barberId}, '
          '${BarberReviewColumnNames.rating}',
        )
        .inFilter(BarberReviewColumnNames.barberId, cleanedIds);

    final Map<String, List<int>> ratingsByBarberId = {};

    for (final row in rows) {
      final barberId = row[BarberReviewColumnNames.barberId]?.toString();
      final rating = _parseRating(row[BarberReviewColumnNames.rating]);

      if (barberId == null || barberId.trim().isEmpty || rating == null) {
        continue;
      }

      ratingsByBarberId.putIfAbsent(barberId, () => <int>[]).add(rating);
    }

    final Map<String, BarberRatingSummary> summaries = {};

    for (final barberId in cleanedIds) {
      summaries[barberId] = _buildSummaryFromRatings(
        ratingsByBarberId[barberId] ?? <int>[],
      );
    }

    return summaries;
  }

  BarberRatingSummary _buildSummaryFromRows(List<dynamic> rows) {
    final ratings = rows
        .map((row) => _parseRating(row[BarberReviewColumnNames.rating]))
        .whereType<int>()
        .toList();

    return _buildSummaryFromRatings(ratings);
  }

  BarberRatingSummary _buildSummaryFromRatings(List<int> ratings) {
    final Map<int, int> breakdown = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};

    for (final rating in ratings) {
      if (rating < 1 || rating > 5) {
        continue;
      }

      breakdown[rating] = (breakdown[rating] ?? 0) + 1;
    }

    final int ratingCount = breakdown.values.fold<int>(
      0,
      (sum, count) => sum + count,
    );

    if (ratingCount == 0) {
      return BarberRatingSummary.empty;
    }

    final int totalScore = breakdown.entries.fold<int>(
      0,
      (sum, entry) => sum + (entry.key * entry.value),
    );

    final double averageRating = double.parse(
      (totalScore / ratingCount).toStringAsFixed(1),
    );

    final int satisfiedCount = (breakdown[5] ?? 0) + (breakdown[4] ?? 0);
    final int satisfactionRate = ((satisfiedCount / ratingCount) * 100).round();

    return BarberRatingSummary(
      averageRating: averageRating,
      ratingCount: ratingCount,
      satisfactionRate: satisfactionRate,
      ratingBreakdown: breakdown,
    );
  }

  int? _parseRating(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value.toString());
  }
}
