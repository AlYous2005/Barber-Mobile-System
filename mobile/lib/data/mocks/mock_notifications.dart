import '../../models/mock_notification.dart';


const List<MockNotification> mockBarberNotifications = [
  MockNotification(id: 'bn1', message: 'حجز جديد من أحمد خالد'),
  MockNotification(id: 'bn2', message: 'موعد جديد الساعة 6:30 مساءً'),
  MockNotification(
    id: 'bn3',
    message: 'تم إلغاء موعد من محمد علي',
    isRead: true,
  ),
];

const List<MockNotification> mockCustomerNotifications = [
  MockNotification(id: 'cn1', message: 'تم تأكيد موعدك'),
  MockNotification(id: 'cn2', message: 'موعدك اليوم الساعة 7:00 مساءً'),
  MockNotification(
    id: 'cn3',
    message: 'تم اكتمال موعدك، يمكنك تقييم الحلاق الآن',
    isRead: true,
  ),
];