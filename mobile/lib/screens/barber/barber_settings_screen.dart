// UI + popups
import 'package:flutter/material.dart';

import '../../controllers/barber/barber_settings_controller.dart';
import 'package:image_picker/image_picker.dart';
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
  final ImagePicker _imagePicker = ImagePicker();

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
    await controller.toggleNotifications();

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

  Future<ImageSource?> _showSalonImageSourceSheet() {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        final Color textColor = Theme.of(context).colorScheme.onSurface;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Text(
                    'صورة الصالون',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: textColor,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'اختر طريقة إضافة الصورة',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textColor.withValues(alpha: 0.65),
                    ),
                  ),

                  const SizedBox(height: 18),

                  _ImageSourceOption(
                    icon: Icons.photo_library_rounded,
                    title: 'اختيار صورة من الجهاز',
                    subtitle: 'اختر صورة جاهزة من الملفات أو المعرض',
                    color: const Color(0xFFC47A3D),
                    onTap: () {
                      Navigator.of(bottomSheetContext).pop(ImageSource.gallery);
                    },
                  ),

                  const SizedBox(height: 10),

                  _ImageSourceOption(
                    icon: Icons.photo_camera_rounded,
                    title: 'التقاط صورة بالكاميرا',
                    subtitle: 'افتح الكاميرا والتقط صورة جديدة',
                    color: const Color(0xFF16A34A),
                    onTap: () {
                      Navigator.of(bottomSheetContext).pop(ImageSource.camera);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _addOrChangeSalonImage() async {
    try {
      final imageSource = await _showSalonImageSourceSheet();

      if (imageSource == null) {
        return;
      }

      final selectedImage = await _imagePicker.pickImage(
        source: imageSource,
        imageQuality: 95,
      );

      if (selectedImage == null) {
        return;
      }

      final imageBytes = await selectedImage.readAsBytes();

      final bool alreadyHadImage = await controller.addOrChangeSalonImage(
        imageBytes: imageBytes,
        originalFileName: selectedImage.name,
      );

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
    } catch (error) {
      if (!mounted) return;

      await showBarberFeedbackPopup(
        context: context,
        title: 'فشل اختيار أو رفع صورة الصالون',
        message:
            'إذا كنت تستخدم Windows، جرّب اختيار صورة من الجهاز بدل الكاميرا',
        icon: Icons.error_outline_rounded,
        iconStartColor: _accentRedStart,
        iconEndColor: _accentRedEnd,
      );
    }
  }

  Future<void> _removeSalonImage() async {
    try {
      await controller.removeSalonImage();

      if (!mounted) return;

      await showBarberFeedbackPopup(
        context: context,
        title: 'تمت إزالة صورة الصالون',
        message: 'تمت إزالة صورة الصالون بنجاح',
        icon: Icons.delete_outline_rounded,
        iconStartColor: _accentRedStart,
        iconEndColor: _accentRedEnd,
      );
    } catch (error) {
      if (!mounted) return;

      await showBarberFeedbackPopup(
        context: context,
        title: 'فشل حذف صورة الصالون',
        message: 'حاول مرة أخرى، أو تأكد من اتصال الإنترنت',
        icon: Icons.error_outline_rounded,
        iconStartColor: _accentRedStart,
        iconEndColor: _accentRedEnd,
      );
    }
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
                  salonImageUrl: controller.salonImageUrl,
                  isUploadingSalonImage: controller.isUploadingSalonImage,
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

class _ImageSourceOption extends StatelessWidget {
  const _ImageSourceOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color textColor = Theme.of(context).colorScheme.onSurface;

    return Material(
      color: color.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                        color: textColor.withValues(alpha: 0.62),
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.chevron_left_rounded,
                color: textColor.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
