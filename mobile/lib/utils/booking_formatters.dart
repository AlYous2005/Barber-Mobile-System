String formatBookingDuration(int totalMinutes) {
  if (totalMinutes <= 0) {
    return '0';
  }

  if (totalMinutes < 60) {
    return '$totalMinutes دقيقة';
  }

  final hours = totalMinutes ~/ 60;
  final minutes = totalMinutes % 60;

  String hourText;

  if (hours == 1) {
    hourText = 'ساعة';
  } else if (hours == 2) {
    hourText = 'ساعتين';
  } else {
    hourText = '$hours ساعات';
  }

  if (minutes == 0) {
    return hourText;
  }

  if (minutes == 15) {
    return '$hourText وربع';
  }

  if (minutes == 30) {
    return '$hourText ونصف';
  }

  if (minutes == 45) {
    return '$hourText و45 دقيقة';
  }

  return '$hourText و$minutes دقائق';
}