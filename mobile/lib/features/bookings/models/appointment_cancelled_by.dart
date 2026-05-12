enum AppointmentCancelledBy {
  barber('barber'),
  customer('customer'),
  system('system');

  const AppointmentCancelledBy(this.storageValue);

  final String storageValue;

  /// Parses DB value; unknown or empty returns null so UI can fall back.
  static AppointmentCancelledBy? tryParse(String? raw) {
    if (raw == null) return null;
    final String v = raw.trim().toLowerCase();
    if (v.isEmpty) return null;
    for (final AppointmentCancelledBy b in AppointmentCancelledBy.values) {
      if (b.storageValue == v) return b;
    }
    return null;
  }
}
