// UI + popups
import 'package:flutter/material.dart';

import '../../controllers/barber/barber_settings_controller.dart';
import '../../widgets/barber/settings/notifications_settings_card.dart';
import '../../widgets/barber/settings/salon_image_settings_card.dart';
import '../../widgets/barber/settings/settings_intro_card.dart';
import '../../widgets/barber/settings/theme_settings_card.dart';
import '../../widgets/barber/shared/barber_feedback_popup.dart';

class BarberSettingsScreen extends StatefulWidget {
  const BarberSettingsScreen({super.key, required this.onLogout});

  final VoidCallback onLogout;

  @override
  State<BarberSettingsScreen> createState() => _BarberSettingsScreenState();
}

class _BarberSettingsScreenState extends State<BarberSettingsScreen> {
  late final BarberSettingsController controller;

  static const Color _accentGreenStart = Color(0xFF16A34A);
  static const Color _accentGreenEnd = Color(0xFF86EFAC);
  static const Color _accentRedStart = Color(0xFFDC2626);
  static const Color _accentRedEnd = Color(0xFFF87171);
  static const Color _accentOrangeStart = Color(0xFFEA580C);
  static const Color _accentOrangeEnd = Color(0xFFFDBA74);

  @override
  void initState() {
    super.initState();

    controller = BarberSettingsController();
    controller.initialize();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _toggleNotifications() async {
    controller.toggleNotifications();

    final bool enabled = controller.notificationsEnabled;

    if (!mounted) return;

    await showBarberFeedbackPopup(
      context: context,
      title: enabled ? 'تم تفعيل الإشعارات' : 'تم إيقاف الإشعارات',
      message: enabled
          ? 'تم تفعيل إشعارات التطبيق'
          : 'تم إيقاف إشعارات التطبيق',
      icon: enabled
          ? Icons.notifications_active_rounded
          : Icons.notifications_off_rounded,
      iconStartColor: enabled ? _accentGreenStart : _accentOrangeStart,
      iconEndColor: enabled ? _accentGreenEnd : _accentOrangeEnd,
    );
  }

  Future<void> _toggleThemeMode(bool value) async {
    await controller.setThemeMode(value);

    if (!mounted) return;

    final bool dark = controller.isDarkMode;

    await showBarberFeedbackPopup(
      context: context,
      title: dark ? 'تم تفعيل الوضع الليلي' : 'تم تفعيل الوضع الصباحي',
      message: dark
          ? 'تم تفعيل الوضع الليلي للتطبيق'
          : 'تم تفعيل الوضع الصباحي للتطبيق',
      icon: dark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
      iconStartColor: dark ? const Color(0xFF6D28D9) : const Color(0xFFD97706),
      iconEndColor: dark ? const Color(0xFFC4B5FD) : const Color(0xFFFCD34D),
    );
  }

  Future<void> _addOrChangeSalonImage() async {
    final bool alreadyHadImage = controller.addOrChangeSalonImage();

    if (!mounted) return;

    if (!alreadyHadImage) {
      await showBarberFeedbackPopup(
        context: context,
        title: 'تمت إضافة صورة الصالون',
        message: 'تمت إضافة صورة الصالون بنجاح',
        icon: Icons.add_photo_alternate_rounded,
        iconStartColor: _accentGreenStart,
        iconEndColor: _accentGreenEnd,
      );
      return;
    }

    await showBarberFeedbackPopup(
      context: context,
      title: 'تم تعديل صورة الصالون',
      message: 'تم تعديل صورة الصالون بنجاح',
      icon: Icons.image_rounded,
      iconStartColor: const Color(0xFFC47A3D),
      iconEndColor: const Color(0xFFEAB07A),
    );
  }

  Future<void> _removeSalonImage() async {
    controller.removeSalonImage();

    if (!mounted) return;

    await showBarberFeedbackPopup(
      context: context,
      title: 'تمت إزالة صورة الصالون',
      message: 'تمت إزالة صورة الصالون بنجاح',
      icon: Icons.delete_outline_rounded,
      iconStartColor: _accentRedStart,
      iconEndColor: _accentRedEnd,
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
                const SettingsIntroCard(),

                const SizedBox(height: 16),

                SalonImageSettingsCard(
                  hasSalonImage: controller.hasSalonImage,
                  onAddOrChangeImage: _addOrChangeSalonImage,
                  onRemoveImage: _removeSalonImage,
                ),

                const SizedBox(height: 16),

                NotificationsSettingsCard(
                  notificationsEnabled: controller.notificationsEnabled,
                  onToggle: _toggleNotifications,
                ),

                const SizedBox(height: 14),

                ThemeSettingsCard(
                  isDarkMode: controller.isDarkMode,
                  onChanged: _toggleThemeMode,
                ),

                const SizedBox(height: 14),
              ],
            ),
          ),
        );
      },
    );
  }
}
