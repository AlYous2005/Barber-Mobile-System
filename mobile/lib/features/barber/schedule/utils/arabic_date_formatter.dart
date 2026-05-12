String formatArabicDateLabel(
  DateTime? date, {
  String emptyLabel = 'اختر التاريخ',
}) {
  if (date == null) {
    return emptyLabel;
  }

  return '${date.day}/${date.month}/${date.year}';
}
