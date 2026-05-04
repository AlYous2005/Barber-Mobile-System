import 'package:flutter/material.dart';


import '../../widgets/customer/settings/customer_settings_intro_card.dart';
import '../../widgets/customer/settings/customer_appearance_settings_card.dart';
import '../../widgets/customer/settings/customer_notifications_settings_card.dart';

class CustomerSettingsScreen extends StatefulWidget {
  const CustomerSettingsScreen({super.key});

  @override
  State<CustomerSettingsScreen> createState() => _CustomerSettingsScreenState();
}

class _CustomerSettingsScreenState extends State<CustomerSettingsScreen> {
  bool notificationsEnabled = true;
  bool isDarkMode = false;

  void _toggleNotifications(bool value) {
    setState(() {
      notificationsEnabled = value;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          notificationsEnabled
              ? 'تم تفعيل إشعارات المواعيد'
              : 'تم إيقاف إشعارات المواعيد',
        ),
      ),
    );
  }

  void _setThemeMode(bool dark) {
    setState(() {
      isDarkMode = dark;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isDarkMode
              ? 'تم اختيار النمط الداكن مؤقتًا'
              : 'تم اختيار النمط الفاتح مؤقتًا',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color pageBackground =
        isDarkMode ? const Color(0xFF111827) : Colors.white;

    final Color textColor =
        isDarkMode ? Colors.white : const Color(0xFF111827);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: pageBackground,
        appBar: AppBar(
          title: Text(
            '',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: textColor,
            ),
          ),
          centerTitle: true,
          backgroundColor: pageBackground,
          surfaceTintColor: pageBackground,
          elevation: 0,
          iconTheme: IconThemeData(color: textColor),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            const CustomerSettingsIntroCard(),

            const SizedBox(height: 16),

            CustomerNotificationsSettingsCard(
              notificationsEnabled: notificationsEnabled,
              onChanged: _toggleNotifications,
            ),

            const SizedBox(height: 14),

            CustomerAppearanceSettingsCard(
              isDarkMode: isDarkMode,
              onSelectLight: () => _setThemeMode(false),
              onSelectDark: () => _setThemeMode(true),
            ),
          ],
        ),
      ),
    );
  }
}









