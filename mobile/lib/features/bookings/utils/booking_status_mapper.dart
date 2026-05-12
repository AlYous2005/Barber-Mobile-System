import '../constants/booking_constants.dart';

class BookingStatusMapper {
  const BookingStatusMapper._();

  static String arabicToDatabase(String status) {
    switch (status) {
      case 'معلق':
      case 'معلقة':
        return AppointmentStatuses.pending;
      case 'مؤكد':
      case 'مؤكدة':
      case 'تم التأكيد':
      case 'قادم':
        return AppointmentStatuses.confirmed;
      case 'مكتمل':
      case 'مكتملة':
        return AppointmentStatuses.completed;
      case 'ملغي':
      case 'ملغية':
        return AppointmentStatuses.cancelled;
      case 'لم يحضر':
        return AppointmentStatuses.noShow;
      default:
        return status;
    }
  }

  static String databaseToArabic(String status) {
    switch (status) {
      case AppointmentStatuses.pending:
        return 'معلق';
      case AppointmentStatuses.confirmed:
        return 'مؤكد';
      case AppointmentStatuses.completed:
        return 'مكتمل';
      case AppointmentStatuses.cancelled:
        return 'ملغي';
      case AppointmentStatuses.noShow:
        return 'لم يحضر';
      default:
        return status;
    }
  }
}
