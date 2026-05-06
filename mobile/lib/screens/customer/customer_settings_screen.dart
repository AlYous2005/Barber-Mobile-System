// UI + popups
import 'package:flutter/material.dart';

import '../../controllers/customer/customer_settings_controller.dart';
import '../../widgets/customer/settings/customer_appearance_settings_card.dart';
import '../../widgets/customer/settings/customer_notifications_settings_card.dart';
import '../../widgets/customer/settings/customer_settings_intro_card.dart';
import '../../widgets/customer/shared/customer_feedback_popup.dart';

class CustomerSettingsScreen extends StatefulWidget {
  const CustomerSettingsScreen({super.key});

  @override
  State<CustomerSettingsScreen> createState() => _CustomerSettingsScreenState();
}

class _CustomerSettingsScreenState extends State<CustomerSettingsScreen> {
  late final CustomerSettingsController controller;

  @override
  void initState() {
    super.initState();

    controller = CustomerSettingsController();
    controller.initialize();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _toggleNotifications(bool value) async {
    controller.setNotificationsEnabled(value);

    await showCustomerFeedbackPopup(
      context: context,
      title: controller.notificationsEnabled
          ? 'تم تفعيل الإشعارات'
          : 'تم إيقاف الإشعارات',
      message: controller.notificationsEnabled
          ? 'تم تفعيل الإشعارات للتطبيق'
          : 'تم إيقاف إشعارات التطبيق مؤقتًا',
      icon: controller.notificationsEnabled
          ? Icons.notifications_active_rounded
          : Icons.notifications_off_rounded,
      iconStartColor: controller.notificationsEnabled
          ? const Color(0xFF22C55E)
          : const Color(0xFFEF4444),
      iconEndColor: controller.notificationsEnabled
          ? const Color(0xFF86EFAC)
          : const Color(0xFFFCA5A5),
    );
  }

  Future<void> _setThemeMode(bool dark) async {
    await controller.setThemeMode(dark);

    if (!mounted) return;

    await showCustomerFeedbackPopup(
      context: context,
      title: 'تم تغيير ألوان التطبيق',
      message: dark
          ? 'Dark Mode - تم إلى الوضع الداكن'
          : 'Light Mode - إلى الوضع الفاتح',
      icon: dark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
      iconStartColor: dark ? const Color(0xFFC47A3D) : const Color(0xFFF59E0B),
      iconEndColor: dark ? const Color(0xFFF6D38B) : const Color(0xFFFDE68A),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final Color pageBackground = Theme.of(context).scaffoldBackgroundColor;
        final Color textColor =
            Theme.of(context).appBarTheme.iconTheme?.color ??
            Theme.of(context).colorScheme.onSurface;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: pageBackground,
            appBar: AppBar(
              title: Text(
                '',
                style: TextStyle(fontWeight: FontWeight.w900, color: textColor),
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
                  notificationsEnabled: controller.notificationsEnabled,
                  onChanged: _toggleNotifications,
                ),

                const SizedBox(height: 14),

                CustomerAppearanceSettingsCard(
                  isDarkMode: controller.isDarkMode,
                  onSelectLight: () => _setThemeMode(false),
                  onSelectDark: () => _setThemeMode(true),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
