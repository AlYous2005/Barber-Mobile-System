String formatDateForDatabase(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');

  return '$year-$month-$day';
} 

DateTime? parseDateFromDatabase(dynamic value) {
  if (value == null) return null;

  return DateTime.tryParse(value.toString());
} 
