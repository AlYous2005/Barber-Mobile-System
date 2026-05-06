// UI + Dialogs + BottomSheet

import 'package:flutter/material.dart';

import '../../controllers/barber/barber_services_controller.dart';
import '../../models/ui_service_model.dart';
import '../../utils/app_theme_colors.dart';
import '../../widgets/barber/services/edit_service_sheet.dart';
import '../../widgets/barber/services/service_card.dart';
import '../../widgets/barber/services/service_confirm_dialog.dart';
import '../../widgets/barber/services/services_form_card.dart';
import '../../widgets/barber/services/services_intro_card.dart';
import '../../widgets/barber/services/services_list_widgets.dart';
import '../../widgets/barber/shared/barber_feedback_popup.dart';

class BarberServicesScreen extends StatefulWidget {
  const BarberServicesScreen({super.key});

  @override
  State<BarberServicesScreen> createState() => _BarberServicesScreenState();
}

class _BarberServicesScreenState extends State<BarberServicesScreen> {
  late final BarberServicesController controller;

  @override
  void initState() {
    super.initState();

    controller = BarberServicesController();
    controller.loadBarberServices();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _showBarberPopup({
    required String title,
    required String message,
    required IconData icon,
    Color iconStartColor = const Color(0xFF16A34A),
    Color iconEndColor = const Color(0xFF86EFAC),
  }) async {
    if (!mounted) return;

    await showBarberFeedbackPopup(
      context: context,
      title: title,
      message: message,
      icon: icon,
      iconStartColor: iconStartColor,
      iconEndColor: iconEndColor,
    );
  }

  void _schedulePopup({
    required String title,
    required String message,
    required IconData icon,
    Color iconStartColor = const Color(0xFF16A34A),
    Color iconEndColor = const Color(0xFF86EFAC),
  }) {
    Future.microtask(() async {
      if (!mounted) return;

      await _showBarberPopup(
        title: title,
        message: message,
        icon: icon,
        iconStartColor: iconStartColor,
        iconEndColor: iconEndColor,
      );
    });
  }

  void _showConfirmDialog({
    required String title,
    required String message,
    required String confirmText,
    required Color confirmColor,
    required VoidCallback onConfirm,
  }) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return ServiceConfirmDialog(
          title: title,
          message: message,
          confirmText: confirmText,
          confirmColor: confirmColor,
          onConfirm: onConfirm,
        );
      },
    );
  }

  void _addService() {
    if (!controller.validateAddForm()) {
      return;
    }

    final String name = controller.serviceNameController.text.trim();

    _showConfirmDialog(
      title: 'تأكيد إضافة الخدمة',
      message: 'هل تريد إضافة الخدمة "$name"؟',
      confirmText: 'إضافة الخدمة',
      confirmColor: const Color(0xFFC47A3D),
      onConfirm: () {
        Future.microtask(() async {
          try {
            await controller.addService();

            if (!mounted) return;

            _schedulePopup(
              title: 'تمت إضافة الخدمة',
              message: 'تمت إضافة الخدمة بنجاح',
              icon: Icons.design_services_rounded,
              iconStartColor: const Color(0xFFC47A3D),
              iconEndColor: const Color(0xFFF6D38B),
            );
          } catch (_) {
            if (!mounted) return;

            _schedulePopup(
              title: 'تعذر إضافة الخدمة',
              message: 'حدث خطأ أثناء إضافة الخدمة، حاول مرة أخرى',
              icon: Icons.error_outline_rounded,
              iconStartColor: const Color(0xFFEF4444),
              iconEndColor: const Color(0xFFFCA5A5),
            );
          }
        });
      },
    );
  }

  void _resetFormWithConfirmation() {
    _showConfirmDialog(
      title: 'إعادة تعيين الحقول',
      message: 'هل تريد مسح جميع بيانات النموذج الحالي؟',
      confirmText: 'إعادة التعيين',
      confirmColor: const Color(0xFFC47A3D),
      onConfirm: () {
        controller.resetForm();

        _schedulePopup(
          title: 'تم إعادة التعيين',
          message: 'تمت إعادة تعيين الحقول',
          icon: Icons.refresh_rounded,
          iconStartColor: const Color(0xFF64748B),
          iconEndColor: const Color(0xFFCBD5E1),
        );
      },
    );
  }

  void _openEditServiceSheet(UiService service) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return EditServiceSheet(
          service: service,
          onMessage: (_) {},
          onSave: (updatedService) {
            Future.microtask(() async {
              try {
                await controller.updateService(updatedService);

                if (!mounted) return;

                _schedulePopup(
                  title: 'تم تعديل الخدمة',
                  message: 'تم حفظ تغييرات الخدمة بنجاح',
                  icon: Icons.edit_rounded,
                  iconStartColor: const Color(0xFFC47A3D),
                  iconEndColor: const Color(0xFFF6D38B),
                );
              } catch (_) {
                if (!mounted) return;

                _schedulePopup(
                  title: 'تعذر تعديل الخدمة',
                  message: 'حدث خطأ أثناء حفظ التعديل، حاول مرة أخرى',
                  icon: Icons.error_outline_rounded,
                  iconStartColor: const Color(0xFFEF4444),
                  iconEndColor: const Color(0xFFFCA5A5),
                );
              }
            });
          },
        );
      },
    );
  }

  void _toggleServiceActive(UiService service) {
    if (service.isActive) {
      _showConfirmDialog(
        title: 'تأكيد تعطيل الخدمة',
        message: 'هل تريد تعطيل الخدمة "${service.name}"؟',
        confirmText: 'تعطيل الخدمة',
        confirmColor: const Color(0xFFEF4444),
        onConfirm: () {
          _setServiceActive(service: service, isActive: false);
        },
      );

      return;
    }

    _setServiceActive(service: service, isActive: true);
  }

  Future<void> _setServiceActive({
    required UiService service,
    required bool isActive,
  }) async {
    try {
      await controller.setServiceActive(service: service, isActive: isActive);

      if (!mounted) return;

      if (isActive) {
        _schedulePopup(
          title: 'تم تفعيل الخدمة',
          message: 'تم تفعيل الخدمة بنجاح',
          icon: Icons.toggle_on_rounded,
          iconStartColor: const Color(0xFF16A34A),
          iconEndColor: const Color(0xFF86EFAC),
        );
      } else {
        _schedulePopup(
          title: 'تم تعطيل الخدمة',
          message: 'تم تعطيل الخدمة بنجاح',
          icon: Icons.toggle_off_rounded,
          iconStartColor: const Color(0xFFEA580C),
          iconEndColor: const Color(0xFFFDBA74),
        );
      }
    } catch (_) {
      if (!mounted) return;

      _schedulePopup(
        title: 'تعذر تحديث الخدمة',
        message: 'حدث خطأ أثناء تحديث حالة الخدمة، حاول مرة أخرى',
        icon: Icons.error_outline_rounded,
        iconStartColor: const Color(0xFFEF4444),
        iconEndColor: const Color(0xFFFCA5A5),
      );
    }
  }

  void _viewLinkedAppointments(UiService service) {
    _showConfirmDialog(
      title: 'عرض المواعيد المرتبطة',
      message: 'هل تريد فتح المواعيد المرتبطة بالخدمة "${service.name}"؟',
      confirmText: 'عرض المواعيد',
      confirmColor: const Color(0xFF0F766E),
      onConfirm: () {
        _schedulePopup(
          title: 'لا توجد مواعيد مرتبطة',
          message: 'لا توجد مواعيد مرتبطة بهذه الخدمة',
          icon: Icons.event_available_rounded,
          iconStartColor: const Color(0xFF0F766E),
          iconEndColor: const Color(0xFF5EEAD4),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              title: Text(
                '',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: AppThemeColors.textPrimary(context),
                ),
              ),
              centerTitle: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
            ),
            body: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              children: [
                const ServicesIntroCard(),

                const SizedBox(height: 18),

                ServicesFormCard(
                  serviceNameController: controller.serviceNameController,
                  durationController: controller.durationController,
                  priceController: controller.priceController,
                  onIncreaseDuration: controller.increaseDuration,
                  onDecreaseDuration: controller.decreaseDuration,
                  onIncreasePrice: controller.increasePrice,
                  onDecreasePrice: controller.decreasePrice,
                  onSubmit: _addService,
                  onReset: _resetFormWithConfirmation,
                  serviceNameError: controller.addNameError,
                  durationError: controller.addDurationError,
                  priceError: controller.addPriceError,
                  serviceNameShakeTrigger: controller.addNameShake,
                  durationShakeTrigger: controller.addDurationShake,
                  priceShakeTrigger: controller.addPriceShake,
                ),

                const SizedBox(height: 18),

                const CurrentServicesBanner(),

                const SizedBox(height: 14),

                if (controller.isLoadingServices)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 28),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (controller.servicesErrorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 28),
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline_rounded, size: 42),
                        const SizedBox(height: 12),
                        Text(
                          controller.servicesErrorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 14),
                        ElevatedButton(
                          onPressed: controller.loadBarberServices,
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  )
                else if (controller.services.isEmpty)
                  const EmptyServicesState()
                else
                  ...controller.services.map(
                    (service) => ServiceCard(
                      service: service,
                      onEdit: () => _openEditServiceSheet(service),
                      onViewAppointments: () =>
                          _viewLinkedAppointments(service),
                      onToggleActive: () => _toggleServiceActive(service),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
