import 'package:flutter/material.dart';

import '../../widgets/barber/settings/settings_intro_card.dart';
import '../../widgets/barber/settings/theme_settings_card.dart';
import '../../widgets/barber/settings/notifications_settings_card.dart';
import '../../widgets/barber/settings/salon_image_settings_card.dart';
import '../../widgets/barber/shared/barber_feedback_popup.dart';
import '../../main.dart';

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

  static const Color _accentGreenStart = Color(0xFF16A34A);
  static const Color _accentGreenEnd = Color(0xFF86EFAC);
  static const Color _accentRedStart = Color(0xFFDC2626);
  static const Color _accentRedEnd = Color(0xFFF87171);
  static const Color _accentOrangeStart = Color(0xFFEA580C);
  static const Color _accentOrangeEnd = Color(0xFFFDBA74);

  @override
  void initState() {
    super.initState();
    isDarkMode = appThemeMode.value == ThemeMode.dark;
  }

  void _toggleNotifications() {
    setState(() {
      notificationsEnabled = !notificationsEnabled;
    });

    final bool enabled = notificationsEnabled;
    if (!mounted) return;
    showBarberFeedbackPopup(
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

  void _toggleThemeMode(bool value) {
    _applyThemeModeChange(value);
  }

  Future<void> _applyThemeModeChange(bool value) async {
    setState(() {
      isDarkMode = value;
    });

    appThemeMode.value = value ? ThemeMode.dark : ThemeMode.light;
    await saveAppThemeMode(appThemeMode.value);

    if (!mounted) return;

    final bool dark = isDarkMode;
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

  void _addOrChangeSalonImage() {
    final bool alreadyHadImage = hasSalonImage;

    setState(() {
      hasSalonImage = true;
    });

    if (!mounted) return;

    if (!alreadyHadImage) {
      showBarberFeedbackPopup(
        context: context,
        title: 'تمت إضافة صورة الصالون',
        message: 'تمت إضافة صورة الصالون بنجاح',
        icon: Icons.add_photo_alternate_rounded,
        iconStartColor: _accentGreenStart,
        iconEndColor: _accentGreenEnd,
      );
    } else {
      showBarberFeedbackPopup(
        context: context,
        title: 'تم تعديل صورة الصالون',
        message: 'تم تعديل صورة الصالون بنجاح',
        icon: Icons.image_rounded,
        iconStartColor: const Color(0xFFC47A3D),
        iconEndColor: const Color(0xFFEAB07A),
      );
    }
  }

  void _removeSalonImage() {
    setState(() {
      hasSalonImage = false;
    });

    if (!mounted) return;
    showBarberFeedbackPopup(
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
