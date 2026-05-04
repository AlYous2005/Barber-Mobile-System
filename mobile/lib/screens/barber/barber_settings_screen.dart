import 'package:flutter/material.dart';

import '../../widgets/barber/settings/settings_intro_card.dart';
import '../../widgets/barber/settings/theme_settings_card.dart';
import '../../widgets/barber/settings/notifications_settings_card.dart';
import '../../widgets/barber/settings/salon_image_settings_card.dart';

class BarberSettingsScreen extends StatefulWidget {
  const BarberSettingsScreen({super.key, required this.onLogout});

  final VoidCallback onLogout;

  @override
  State<BarberSettingsScreen> createState() => _BarberSettingsScreenState();
}

class _BarberSettingsScreenState extends State<BarberSettingsScreen> {
  bool notificationsEnabled = true;
  bool isDarkMode = false;
  bool hasSalonImage = false;

  void _toggleNotifications() {
    setState(() {
      notificationsEnabled = !notificationsEnabled;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          notificationsEnabled
              ? 'تم تفعيل إشعارات التطبيق'
              : 'تم إيقاف إشعارات التطبيق',
        ),
      ),
    );
  }

  void _toggleThemeMode(bool value) {
    setState(() {
      isDarkMode = value;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isDarkMode
              ? 'تم اختيار الوضع الداكن مؤقتًا'
              : 'تم اختيار الوضع الفاتح مؤقتًا',
        ),
      ),
    );
  }

  void _addOrChangeSalonImage() {
    final bool alreadyHadImage = hasSalonImage;

    setState(() {
      hasSalonImage = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          alreadyHadImage
              ? 'تم تحديث صورة الصالون مؤقتًا'
              : 'تمت إضافة صورة الصالون مؤقتًا',
        ),
      ),
    );
  }

  void _removeSalonImage() {
    setState(() {
      hasSalonImage = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تمت إزالة صورة الصالون مؤقتًا')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color pageBackground = isDarkMode
        ? const Color(0xFF111827)
        : Colors.white;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: pageBackground,
        appBar: AppBar(
          title: Text(
            '',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: isDarkMode ? Colors.white : const Color(0xFF111827),
            ),
          ),
          centerTitle: true,
          backgroundColor: pageBackground,
          surfaceTintColor: pageBackground,
          elevation: 0,
          iconTheme: IconThemeData(
            color: isDarkMode ? Colors.white : const Color(0xFF111827),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            const SettingsIntroCard(),
            const SizedBox(height: 16),

            SalonImageSettingsCard(
              hasSalonImage: hasSalonImage,
              onAddOrChangeImage: _addOrChangeSalonImage,
              onRemoveImage: _removeSalonImage,
            ),
            const SizedBox(height: 16),

            NotificationsSettingsCard(
              notificationsEnabled: notificationsEnabled,
              onToggle: _toggleNotifications,
            ),

            const SizedBox(height: 14),

            ThemeSettingsCard(
              isDarkMode: isDarkMode,
              onChanged: _toggleThemeMode,
            ),

            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }
}
