// UI + Dialogs + BottomSheet

import 'package:flutter/material.dart';

import '../../controllers/barber/barber_services_controller.dart';
import '../../features/barber/services_management/services_management.dart';
import '../../general_utils/app_theme_colors.dart';
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
  ServiceTarget _listCategory = ServiceTarget.personal;

  @override
  void initState() {
    super.initState();

    controller = BarberServicesController();
    controller.loadBarberServices();
  }

  List<UiService> _servicesForCategory(ServiceTarget target) {
    return controller.services
        .where((UiService s) => s.target == target)
        .toList();
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
    if (controller.isUploadingAddImage) {
      _schedulePopup(
        title: 'جاري رفع الصورة',
        message: 'انتظر حتى يكتمل رفع صورة الخدمة ثم حاول الإضافة',
        icon: Icons.cloud_upload_rounded,
        iconStartColor: const Color(0xFFC47A3D),
        iconEndColor: const Color(0xFFF6D38B),
      );
      return;
    }
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
          } catch (error, stackTrace) {
            debugPrint('ADD_SERVICE_ERROR: $error');
            debugPrintStack(stackTrace: stackTrace);

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
        Future.microtask(() async {
          try {
            await controller.resetForm();

            if (!mounted) return;

            _schedulePopup(
              title: 'تم إعادة التعيين',
              message: 'تمت إعادة تعيين الحقول',
              icon: Icons.refresh_rounded,
              iconStartColor: const Color(0xFF64748B),
              iconEndColor: const Color(0xFFCBD5E1),
            );
          } catch (_) {
            if (!mounted) return;

            _schedulePopup(
              title: 'تعذر إعادة التعيين',
              message: 'حدث خطأ أثناء حذف صورة الخدمة أو إعادة تعيين الحقول',
              icon: Icons.error_outline_rounded,
              iconStartColor: const Color(0xFFEF4444),
              iconEndColor: const Color(0xFFFCA5A5),
            );
          }
        });
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
          onMessage: (message) {
            _schedulePopup(
              title: 'تنبيه',
              message: message,
              icon: Icons.info_outline_rounded,
              iconStartColor: const Color(0xFFC47A3D),
              iconEndColor: const Color(0xFFF6D38B),
            );
          },
          onPickImage: controller.pickAndUploadServiceImageUrl,
          onDeleteImage: controller.deleteServiceImageByUrl,
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

  Future<void> _onToggleServiceActive(UiService service) async {
    if (!service.isActive) {
      await _setServiceActive(service: service, isActive: true);
      return;
    }

    try {
      final int activeCount = await controller
          .countActiveAppointmentsForService(service.id);
      if (!mounted) return;

      if (activeCount == 0) {
        await _setServiceActive(service: service, isActive: false);
        return;
      }

      _showConfirmDialog(
        title: 'تعطيل الخدمة',
        message:
            'يوجد مواعيد سارية مرتبطة بهذه الخدمة، هل تريد إلغاء هذه المواعيد وتعطيل الخدمة؟',
        confirmText: 'نعم، إلغاء المواعيد وتعطيل الخدمة',
        confirmColor: const Color(0xFFDC2626),
        onConfirm: () {
          Future.microtask(() async {
            try {
              await controller.cancelActiveAppointmentsForService(service.id);
              await controller.setServiceActive(
                service: service,
                isActive: false,
              );

              if (!mounted) return;
              _schedulePopup(
                title: 'تم تعطيل الخدمة',
                message: 'تم إلغاء المواعيد السارية وتعطيل الخدمة',
                icon: Icons.toggle_off_rounded,
                iconStartColor: const Color(0xFFEA580C),
                iconEndColor: const Color(0xFFFDBA74),
              );
            } catch (_) {
              if (!mounted) return;
              _schedulePopup(
                title: 'تعذر إكمال العملية',
                message:
                    'حدث خطأ أثناء إلغاء المواعيد أو تعطيل الخدمة، حاول مرة أخرى',
                icon: Icons.error_outline_rounded,
                iconStartColor: const Color(0xFFEF4444),
                iconEndColor: const Color(0xFFFCA5A5),
              );
            }
          });
        },
      );
    } catch (_) {
      if (!mounted) return;

      _schedulePopup(
        title: 'تعذر التحقق',
        message: 'حدث خطأ أثناء التحقق من المواعيد المرتبطة',
        icon: Icons.error_outline_rounded,
        iconStartColor: const Color(0xFFEF4444),
        iconEndColor: const Color(0xFFFCA5A5),
      );
    }
  }

  Future<void> _onArchiveService(UiService service) async {
    try {
      final int activeCount = await controller
          .countActiveAppointmentsForService(service.id);
      if (!mounted) return;

      if (activeCount == 0) {
        _showConfirmDialog(
          title: 'حذف الخدمة من القائمة',
          message: 'هل تريد حذف هذه الخدمة من قائمة خدماتك؟',
          confirmText: 'نعم، حذفها من قائمتي',
          confirmColor: const Color(0xFF92400E),
          onConfirm: () {
            Future.microtask(() async {
              try {
                await controller.archiveServiceById(service.id);

                if (!mounted) return;
                _schedulePopup(
                  title: 'تم الحذف من القائمة',
                  message:
                      'تم إخفاء الخدمة؛ المواعيد السابقة لا تزال تعرض اسم الخدمة المحفوظ',
                  icon: Icons.inventory_2_outlined,
                  iconStartColor: const Color(0xFFC47A3D),
                  iconEndColor: const Color(0xFFF6D38B),
                );
              } catch (_) {
                if (!mounted) return;
                _schedulePopup(
                  title: 'تعذر الحذف',
                  message:
                      'حدث خطأ أثناء إخفاء الخدمة؛ تحقق من الاتصال وحاول مجددًا',
                  icon: Icons.error_outline_rounded,
                  iconStartColor: const Color(0xFFEF4444),
                  iconEndColor: const Color(0xFFFCA5A5),
                );
              }
            });
          },
        );
        return;
      }

      _showConfirmDialog(
        title: 'حذف الخدمة من القائمة',
        message:
            'يوجد مواعيد سارية مرتبطة بهذه الخدمة، هل تريد حذفها؟\n\n'
            'سيتم إلغاء المواعيد القادمة المرتبطة بهذه الخدمة فقط. '
            'المواعيد القديمة والمكتملة تبقى كما هي مع أسماء الخدمات المحفوظة.',
        confirmText: 'نعم، إلغاء المواعيد السارية والحذف من القائمة',
        confirmColor: const Color(0xFFDC2626),
        onConfirm: () {
          Future.microtask(() async {
            try {
              await controller.cancelActiveAppointmentsForService(service.id);
              await controller.archiveServiceById(service.id);

              if (!mounted) return;
              _schedulePopup(
                title: 'تم الحذف من القائمة',
                message:
                    'تم إلغاء المواعيد السارية وإخفاء الخدمة؛ السجلات القديمة محفوظة',
                icon: Icons.inventory_2_outlined,
                iconStartColor: const Color(0xFFC47A3D),
                iconEndColor: const Color(0xFFF6D38B),
              );
            } catch (_) {
              if (!mounted) return;
              _schedulePopup(
                title: 'تعذر إكمال العملية',
                message: 'حدث خطأ أثناء إلغاء المواعيد أو إخفاء الخدمة',
                icon: Icons.error_outline_rounded,
                iconStartColor: const Color(0xFFEF4444),
                iconEndColor: const Color(0xFFFCA5A5),
              );
            }
          });
        },
      );
    } catch (_) {
      if (!mounted) return;

      _schedulePopup(
        title: 'تعذر التحقق',
        message: 'حدث خطأ أثناء التحقق من المواعيد المرتبطة',
        icon: Icons.error_outline_rounded,
        iconStartColor: const Color(0xFFEF4444),
        iconEndColor: const Color(0xFFFCA5A5),
      );
    }
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
                  selectedTarget: controller.selectedAddTarget,
                  onTargetChanged: controller.changeAddTarget,
                  selectedIconKey: controller.selectedAddIconKey,
                  onIconChanged: controller.changeAddIconKey,
                  selectedImageUrl: controller.selectedAddImageUrl,
                  isUploadingImage: controller.isUploadingAddImage,
                  onPickImage: controller.pickAndUploadAddServiceImage,
                  onClearImage: () {
                    Future.microtask(controller.clearAddServiceImage);
                  },
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
                else ...[
                  ServicesTargetTabs(
                    selected: _listCategory,
                    onChanged: (ServiceTarget t) {
                      setState(() {
                        _listCategory = t;
                      });
                    },
                  ),
                  const SizedBox(height: 14),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 320),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.04, 0),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                    child: Builder(
                      key: ValueKey<ServiceTarget>(_listCategory),
                      builder: (BuildContext context) {
                        final List<UiService> filtered = _servicesForCategory(
                          _listCategory,
                        );
                        if (filtered.isEmpty) {
                          return const EmptyCategoryServicesState();
                        }
                        return Column(
                          children: filtered
                              .map(
                                (UiService service) => ServiceCard(
                                  service: service,
                                  onEdit: () => _openEditServiceSheet(service),
                                  onArchive: () => _onArchiveService(service),
                                  onToggleActive: () =>
                                      _onToggleServiceActive(service),
                                ),
                              )
                              .toList(),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
