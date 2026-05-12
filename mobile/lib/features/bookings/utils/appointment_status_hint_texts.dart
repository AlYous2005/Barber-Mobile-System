import '../models/appointment_cancelled_by.dart';
import '../models/appointment_status_audience.dart';
import 'appointment_status_utils.dart';

/// Tooltip / hint strings for interactive status badges.
class AppointmentStatusHintTexts {
  const AppointmentStatusHintTexts._();

  /// Returns null when the UI should not show a tooltip (e.g. barber + no-show).
  static String? resolve({
    required AppointmentStatusAudience audience,
    required String arabicStatus,
    AppointmentCancelledBy? cancelledBy,
  }) {
    if (audience == AppointmentStatusAudience.barber &&
        AppointmentStatusUtils.isNoShow(arabicStatus)) {
      return null;
    }

    if (AppointmentStatusUtils.isCompleted(arabicStatus)) {
      return audience == AppointmentStatusAudience.customer
          ? 'هذا الموعد مكتمل - نعيماً'
          : 'هذا الموعد مكتمل، يعطيك العافية';
    }

    if (AppointmentStatusUtils.isConfirmed(arabicStatus) ||
        AppointmentStatusUtils.isCurrent(arabicStatus)) {
      return audience == AppointmentStatusAudience.customer
          ? 'لقد وافق الحلاق على هذا الموعد'
          : 'لقد وافقت على هذا الموعد';
    }

    if (AppointmentStatusUtils.isCancelled(arabicStatus)) {
      return _cancelledHint(audience: audience, cancelledBy: cancelledBy);
    }

    if (AppointmentStatusUtils.isNoShow(arabicStatus)) {
      return 'لم تحضر هذا الموعد - نرجو الالتزام في المرات القادمة';
    }

    if (AppointmentStatusUtils.isPending(arabicStatus)) {
      return audience == AppointmentStatusAudience.customer
          ? 'موعدك قيد انتظار موافقة الحلاق'
          : 'هذا الموعد بانتظار موافقتك';
    }

    return null;
  }

  static String _cancelledHint({
    required AppointmentStatusAudience audience,
    AppointmentCancelledBy? cancelledBy,
  }) {
    if (cancelledBy == AppointmentCancelledBy.barber) {
      return audience == AppointmentStatusAudience.customer
          ? 'تم إلغاء الموعد من قبل الحلاق، يمكنك مراجعته إن أردت'
          : 'لقد قمت بإلغاء هذا الموعد';
    }
    if (cancelledBy == AppointmentCancelledBy.customer) {
      return audience == AppointmentStatusAudience.customer
          ? 'لقد قمت بإلغاء هذا الموعد'
          : 'لقد قام الزبون بإلغاء هذا الموعد';
    }
    return audience == AppointmentStatusAudience.customer
        ? 'تم إلغاء هذا الموعد'
        : 'تم إلغاء هذا الموعد';
  }
}
