import 'package:flutter/material.dart';

import '../../models/mock_service.dart';
import '../../models/ui_service_model.dart';
import '../../utils/app_theme_colors.dart';
import '../../widgets/barber/services/services_intro_card.dart';
import '../../widgets/barber/services/services_form_card.dart';
import '../../widgets/barber/services/service_card.dart';
import '../../widgets/barber/services/service_confirm_dialog.dart';
import '../../widgets/barber/services/services_list_widgets.dart';
import '../../widgets/barber/services/edit_service_sheet.dart';
import '../../widgets/barber/services/service_field_validation.dart';
import '../../widgets/barber/shared/barber_feedback_popup.dart';

class BarberServicesScreen extends StatefulWidget {
  const BarberServicesScreen({super.key});

  @override
  State<BarberServicesScreen> createState() => _BarberServicesScreenState();
}

class _BarberServicesScreenState extends State<BarberServicesScreen> {
  final TextEditingController _serviceNameController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  late final VoidCallback _onAddNameChanged;
  late final VoidCallback _onAddDurationChanged;
  late final VoidCallback _onAddPriceChanged;

  late final List<UiService> _services;

  String? _addNameError;
  String? _addDurationError;
  String? _addPriceError;
  int _addNameShake = 0;
  int _addDurationShake = 0;
  int _addPriceShake = 0;

  @override
  void initState() {
    super.initState();

    _services = mockBarberServices.map((service) {
      return UiService(
        id: service.id,
        name: service.name,
        durationMinutes: service.durationMinutes,
        price: service.price.toDouble(),
        isActive: true,
      );
    }).toList();

    _onAddNameChanged = () {
      if (!mounted) return;
      setState(() => _addNameError = null);
    };
    _onAddDurationChanged = () {
      if (!mounted) return;
      setState(() => _addDurationError = null);
    };
    _onAddPriceChanged = () {
      if (!mounted) return;
      setState(() => _addPriceError = null);
    };

    _serviceNameController.addListener(_onAddNameChanged);
    _durationController.addListener(_onAddDurationChanged);
    _priceController.addListener(_onAddPriceChanged);
  }

  @override
  void dispose() {
    _serviceNameController.removeListener(_onAddNameChanged);
    _durationController.removeListener(_onAddDurationChanged);
    _priceController.removeListener(_onAddPriceChanged);
    _serviceNameController.dispose();
    _durationController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _increaseDuration() {
    ServiceStepperHelper.increaseMultipleOf5(_durationController);
    setState(() {});
  }

  void _decreaseDuration() {
    ServiceStepperHelper.decreaseMultipleOf5(_durationController);
    setState(() {});
  }

  void _increasePrice() {
    ServiceStepperHelper.increaseMultipleOf5(_priceController);
    setState(() {});
  }

  void _decreasePrice() {
    ServiceStepperHelper.decreaseMultipleOf5(_priceController);
    setState(() {});
  }

  bool _validateAddForm() {
    final String? ne = ServiceFieldValidation.nameError(
      _serviceNameController.text,
    );
    final String? de = ServiceFieldValidation.durationError(
      _durationController.text,
    );
    final String? pe = ServiceFieldValidation.priceError(_priceController.text);

    final bool ok = ne == null && de == null && pe == null;
    if (!ok) {
      setState(() {
        _addNameError = ne;
        _addDurationError = de;
        _addPriceError = pe;
        if (ne != null) _addNameShake++;
        if (de != null) _addDurationShake++;
        if (pe != null) _addPriceShake++;
      });
    } else {
      setState(() {
        _addNameError = null;
        _addDurationError = null;
        _addPriceError = null;
      });
    }
    return ok;
  }

  void _resetForm() {
    setState(() {
      _addNameError = null;
      _addDurationError = null;
      _addPriceError = null;
      _serviceNameController.clear();
      _durationController.clear();
      _priceController.clear();
    });
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

  void _addService() {
    if (!_validateAddForm()) {
      return;
    }

    final String name = _serviceNameController.text.trim();
    final int duration = int.parse(_durationController.text.trim());
    final int priceInt = int.parse(_priceController.text.trim());

    _showConfirmDialog(
      title: 'تأكيد إضافة الخدمة',
      message: 'هل تريد إضافة الخدمة "$name"؟',
      confirmText: 'إضافة الخدمة',
      confirmColor: const Color(0xFFC47A3D),
      onConfirm: () {
        setState(() {
          _services.insert(
            0,
            UiService(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              name: name,
              durationMinutes: duration,
              price: priceInt.toDouble(),
              isActive: true,
            ),
          );
        });

        _serviceNameController.clear();
        _durationController.clear();
        _priceController.clear();

        _schedulePopup(
          title: 'تمت إضافة الخدمة',
          message: 'تمت إضافة الخدمة بنجاح',
          icon: Icons.design_services_rounded,
          iconStartColor: const Color(0xFFC47A3D),
          iconEndColor: const Color(0xFFF6D38B),
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
            setState(() {
              final int index = _services.indexWhere(
                (item) => item.id == updatedService.id,
              );

              if (index != -1) {
                _services[index] = updatedService;
              }
            });

            _schedulePopup(
              title: 'تم تعديل الخدمة',
              message: 'تم حفظ تغييرات الخدمة بنجاح',
              icon: Icons.edit_rounded,
              iconStartColor: const Color(0xFFC47A3D),
              iconEndColor: const Color(0xFFF6D38B),
            );
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
          setState(() {
            final int index = _services.indexWhere((s) => s.id == service.id);
            if (index != -1) {
              _services[index] = service.copyWith(isActive: false);
            }
          });

          _schedulePopup(
            title: 'تم تعطيل الخدمة',
            message: 'تم تعطيل الخدمة بنجاح',
            icon: Icons.toggle_off_rounded,
            iconStartColor: const Color(0xFFEA580C),
            iconEndColor: const Color(0xFFFDBA74),
          );
        },
      );
    } else {
      setState(() {
        final int index = _services.indexWhere((s) => s.id == service.id);
        if (index != -1) {
          _services[index] = service.copyWith(isActive: true);
        }
      });

      _schedulePopup(
        title: 'تم تفعيل الخدمة',
        message: 'تم تفعيل الخدمة بنجاح',
        icon: Icons.toggle_on_rounded,
        iconStartColor: const Color(0xFF16A34A),
        iconEndColor: const Color(0xFF86EFAC),
      );
    }
  }

  void viewLinkedAppointments(UiService service) {
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

  @override
  Widget build(BuildContext context) {
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
              serviceNameController: _serviceNameController,
              durationController: _durationController,
              priceController: _priceController,
              onIncreaseDuration: _increaseDuration,
              onDecreaseDuration: _decreaseDuration,
              onIncreasePrice: _increasePrice,
              onDecreasePrice: _decreasePrice,
              onSubmit: _addService,
              onReset: () {
                _showConfirmDialog(
                  title: 'إعادة تعيين الحقول',
                  message: 'هل تريد مسح جميع بيانات النموذج الحالي؟',
                  confirmText: 'إعادة التعيين',
                  confirmColor: const Color(0xFFC47A3D),
                  onConfirm: () {
                    _resetForm();
                    _schedulePopup(
                      title: 'تم إعادة التعيين',
                      message: 'تمت إعادة تعيين الحقول',
                      icon: Icons.refresh_rounded,
                      iconStartColor: const Color(0xFF64748B),
                      iconEndColor: const Color(0xFFCBD5E1),
                    );
                  },
                );
              },
              serviceNameError: _addNameError,
              durationError: _addDurationError,
              priceError: _addPriceError,
              serviceNameShakeTrigger: _addNameShake,
              durationShakeTrigger: _addDurationShake,
              priceShakeTrigger: _addPriceShake,
            ),

            const SizedBox(height: 18),

            const CurrentServicesBanner(),

            const SizedBox(height: 14),

            if (_services.isEmpty)
              const EmptyServicesState()
            else
              ..._services.map(
                (service) => ServiceCard(
                  service: service,
                  onEdit: () => _openEditServiceSheet(service),
                  onViewAppointments: () => viewLinkedAppointments(service),
                  onToggleActive: () => _toggleServiceActive(service),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
