import 'package:flutter/material.dart';

import '../../models/mock_service.dart';
import '../../models/ui_service_model.dart';
import '../../widgets/barber/services/services_intro_card.dart';
import '../../widgets/barber/services/services_form_card.dart';
import '../../widgets/barber/services/service_card.dart';
import '../../widgets/barber/services/service_confirm_dialog.dart';
import '../../widgets/barber/services/services_list_widgets.dart';
import '../../widgets/barber/services/edit_service_sheet.dart';

class BarberServicesScreen extends StatefulWidget {
  const BarberServicesScreen({super.key});

  @override
  State<BarberServicesScreen> createState() => _BarberServicesScreenState();
}

class _BarberServicesScreenState extends State<BarberServicesScreen> {
  final TextEditingController _serviceNameController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  late final List<UiService> _services;

  @override
  void initState() {
    super.initState();

    _services = mockBarberServices.map((service) {
      return UiService(
        id: service.name,
        name: service.name,
        durationMinutes: int.tryParse(service.durationMinutes.toString()) ?? 0,
        price: double.tryParse(service.price.toString()) ?? 0,
      );
    }).toList();
  }

  @override
  void dispose() {
    _serviceNameController.dispose();
    _durationController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _increaseDuration() {
    final int current = int.tryParse(_durationController.text) ?? 0;
    _durationController.text = (current + 1).toString();
  }

  void _decreaseDuration() {
    final int current = int.tryParse(_durationController.text) ?? 1;
    _durationController.text = (current <= 1 ? 1 : current - 1).toString();
  }

  void _increasePrice() {
    final double current = double.tryParse(_priceController.text) ?? 0;
    _priceController.text = (current + 1).toStringAsFixed(0);
  }

  void _decreasePrice() {
    final double current = double.tryParse(_priceController.text) ?? 0;
    final double next = current <= 0 ? 0 : current - 1;
    _priceController.text = next.toStringAsFixed(0);
  }

  void _resetForm() {
    _serviceNameController.clear();
    _durationController.clear();
    _priceController.clear();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('تمت إعادة تعيين الحقول')));
  }

  void _addService() {
    final String name = _serviceNameController.text.trim();
    final int? duration = int.tryParse(_durationController.text.trim());
    final double? price = double.tryParse(_priceController.text.trim());

    if (name.isEmpty) {
      _showMessage('يرجى إدخال اسم الخدمة');
      return;
    }

    if (duration == null || duration <= 0) {
      _showMessage('يرجى إدخال مدة صحيحة للخدمة');
      return;
    }

    if (price == null || price < 0) {
      _showMessage('يرجى إدخال سعر صحيح للخدمة');
      return;
    }

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
              price: price,
            ),
          );
        });

        _serviceNameController.clear();
        _durationController.clear();
        _priceController.clear();

        _showMessage('تمت إضافة الخدمة بنجاح');
      },
    );
  }

  void _openEditServiceSheet(UiService service) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return EditServiceSheet(
          service: service,
          onMessage: _showMessage,
          onSave: (updatedService) {
            setState(() {
              final int index = _services.indexWhere(
                (item) => item.id == updatedService.id,
              );

              if (index != -1) {
                _services[index] = updatedService;
              }
            });

            _showMessage('تم تعديل الخدمة بنجاح');
          },
        );
      },
    );
  }

  void deleteService(UiService service) {
    _showConfirmDialog(
      title: 'تأكيد تعطيل الخدمة',
      message: 'هل تريد تعطيل الخدمة "${service.name}"؟',
      confirmText: 'تعطيل الخدمة',
      confirmColor: const Color(0xFFEF4444),
      onConfirm: () {
        setState(() {
          _services.removeWhere((item) => item.id == service.id);
        });

        _showMessage('تم تعطيل الخدمة بنجاح');
      },
    );
  }

  void viewLinkedAppointments(UiService service) {
    _showConfirmDialog(
      title: 'عرض المواعيد المرتبطة',
      message: 'هل تريد فتح المواعيد المرتبطة بالخدمة "${service.name}"؟',
      confirmText: 'عرض المواعيد',
      confirmColor: const Color(0xFF0F766E),
      onConfirm: () {
        _showMessage('صفحة المواعيد المرتبطة ستُربط لاحقًا');
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

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFFFF),
        appBar: AppBar(
          title: const Text(
            '',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: Color(0xFF111827),
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
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
                  onConfirm: _resetForm,
                );
              },
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
                  onDelete: () => deleteService(service),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
