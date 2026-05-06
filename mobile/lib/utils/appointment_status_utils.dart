class AppointmentStatusUtils {
  const AppointmentStatusUtils._();

  static bool isPending(String status) {
    return status == 'معلق' || status == 'معلقة';
  }

  static bool isConfirmed(String status) {
    return status == 'مؤكد' ||
        status == 'مؤكدة' ||
        status == 'قادم' ||
        status == 'تم التأكيد';
  }

  static bool isCompleted(String status) {
    return status == 'مكتمل' || status == 'مكتملة';
  }

  static bool isCancelled(String status) {
    return status == 'ملغي' || status == 'ملغية';
  }

  static bool isNoShow(String status) {
    return status == 'لم يحضر';
  }

  static bool isCurrent(String status) {
    return status == 'جاري';
  }

  static bool isFinal(String status) {
    return isCompleted(status) || isCancelled(status) || isNoShow(status);
  }

  static bool isUpcoming(String status) {
    return status == 'قادم' || isPending(status);
  }

  static String displayLabel(String status) {
    switch (status) {
      case 'قادم':
        return 'محجوز';
      case 'معلق':
      case 'معلقة':
        return 'معلق';
      case 'تم التأكيد':
      case 'مؤكد':
      case 'مؤكدة':
        return 'مؤكد';
      case 'مكتمل':
      case 'مكتملة':
        return 'منجز';
      case 'ملغي':
      case 'ملغية':
        return 'ملغي';
      case 'لم يحضر':
        return 'لم يحضر';
      case 'جاري':
        return 'جاري';
      default:
        return status;
    }
  }
}