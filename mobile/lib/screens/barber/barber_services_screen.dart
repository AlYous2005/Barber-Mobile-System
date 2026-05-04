import 'package:flutter/material.dart';

import '../../models/mock_service.dart';

class BarberServicesScreen extends StatefulWidget {
  const BarberServicesScreen({super.key});

  @override
  State<BarberServicesScreen> createState() => _BarberServicesScreenState();
}

class _BarberServicesScreenState extends State<BarberServicesScreen> {
  final TextEditingController _serviceNameController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  late final List<_UiService> _services;

  @override
  void initState() {
    super.initState();

    _services = mockBarberServices.map((service) {
      return _UiService(
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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تمت إعادة تعيين الحقول'),
      ),
    );
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
            _UiService(
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

  void _openEditServiceSheet(_UiService service) {
    final TextEditingController nameController = TextEditingController(
      text: service.name,
    );
    final TextEditingController durationController = TextEditingController(
      text: service.durationMinutes.toString(),
    );
    final TextEditingController priceController = TextEditingController(
      text: service.price.toStringAsFixed(0),
    );

    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: EdgeInsets.only(
              left: 12,
              right: 12,
              top: 12,
              bottom: MediaQuery.of(context).viewInsets.bottom + 12,
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 28,
                    offset: Offset(0, 14),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFFC47A3D).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFFC47A3D)
                                  .withValues(alpha: 0.18),
                            ),
                          ),
                          child: const Icon(
                            Icons.edit_rounded,
                            color: Color(0xFFC47A3D),
                            size: 21,
                          ),
                        ),

                        const SizedBox(width: 10),

                        const Expanded(
                          child: Text(
                            'تعديل الخدمة',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF111827),
                            ),
                          ),
                        ),

                        Material(
                          color: const Color(0xFFF5F5F4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () => Navigator.of(context).pop(),
                            child: const SizedBox(
                              width: 40,
                              height: 40,
                              child: Icon(
                                Icons.close_rounded,
                                color: Color(0xFF374151),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    _ServiceTextField(
                      label: 'اسم الخدمة',
                      hint: 'مثال: قص شعر',
                      icon: Icons.content_cut_rounded,
                      controller: nameController,
                    ),

                    const SizedBox(height: 14),

                    _NumberStepperField(
                      label: 'مدة الخدمة بالدقائق',
                      hint: 'مثال: 30',
                      icon: Icons.access_time_rounded,
                      controller: durationController,
                      onIncrease: () {
                        final int current =
                            int.tryParse(durationController.text) ?? 0;
                        durationController.text = (current + 1).toString();
                      },
                      onDecrease: () {
                        final int current =
                            int.tryParse(durationController.text) ?? 1;
                        durationController.text =
                            (current <= 1 ? 1 : current - 1).toString();
                      },
                    ),

                    const SizedBox(height: 14),

                    _NumberStepperField(
                      label: 'سعر الخدمة',
                      hint: 'مثال: 30',
                      icon: Icons.payments_rounded,
                      controller: priceController,
                      onIncrease: () {
                        final double current =
                            double.tryParse(priceController.text) ?? 0;
                        priceController.text =
                            (current + 1).toStringAsFixed(0);
                      },
                      onDecrease: () {
                        final double current =
                            double.tryParse(priceController.text) ?? 0;
                        final double next = current <= 0 ? 0 : current - 1;
                        priceController.text = next.toStringAsFixed(0);
                      },
                    ),

                    const SizedBox(height: 18),

                    Row(
                      children: [
                        Expanded(
                          child: _MainActionButton(
                            label: 'حفظ التعديلات',
                            icon: Icons.edit_rounded,
                            color: const Color(0xFFC47A3D),
                            onTap: () {
                              final String newName =
                                  nameController.text.trim();
                              final int? newDuration =
                                  int.tryParse(durationController.text.trim());
                              final double? newPrice =
                                  double.tryParse(priceController.text.trim());

                              if (newName.isEmpty) {
                                _showMessage('يرجى إدخال اسم الخدمة');
                                return;
                              }

                              if (newDuration == null || newDuration <= 0) {
                                _showMessage('يرجى إدخال مدة صحيحة');
                                return;
                              }

                              if (newPrice == null || newPrice < 0) {
                                _showMessage('يرجى إدخال سعر صحيح');
                                return;
                              }

                              setState(() {
                                final int index = _services.indexWhere(
                                  (item) => item.id == service.id,
                                );

                                if (index != -1) {
                                  _services[index] = service.copyWith(
                                    name: newName,
                                    durationMinutes: newDuration,
                                    price: newPrice,
                                  );
                                }
                              });

                              Navigator.of(context).pop();
                              _showMessage('تم تعديل الخدمة بنجاح');
                            },
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: _SecondaryActionButton(
                            label: 'إغلاق',
                            icon: Icons.close_rounded,
                            onTap: () => Navigator.of(context).pop(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ).whenComplete(() {
      nameController.dispose();
      durationController.dispose();
      priceController.dispose();
    });
  }

  void _deleteService(_UiService service) {
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

  void _viewLinkedAppointments(_UiService service) {
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
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF111827),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.7,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4B5563),
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: _MainActionButton(
                      label: confirmText,
                      icon: Icons.check_rounded,
                      color: confirmColor,
                      onTap: () {
                        Navigator.of(context).pop();
                        onConfirm();
                      },
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: _SecondaryActionButton(
                      label: 'إلغاء',
                      icon: Icons.close_rounded,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
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
            const _ServicesIntroCard(),

            const SizedBox(height: 18),

            _ServicesFormCard(
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

            const _CurrentServicesBanner(),

            const SizedBox(height: 14),

            if (_services.isEmpty)
              const _EmptyServicesState()
            else
              ..._services.map(
                (service) => _ServiceCard(
                  service: service,
                  onEdit: () => _openEditServiceSheet(service),
                  onViewAppointments: () => _viewLinkedAppointments(service),
                  onDelete: () => _deleteService(service),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ServicesIntroCard extends StatelessWidget {
  const _ServicesIntroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6E3F2F),
            Color(0xFF9B5A3D),
            Color(0xFFC37A49),
          ],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ServiceCenterPill(),

          SizedBox(height: 14),

          Text(
            'الخدمات',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w900,
              color: Color(0xFF111111),
              height: 1.1,
            ),
          ),

          SizedBox(height: 10),

          Text(
            'إدارة خدمات الحلاق ومددها وأسعارها بسهولة',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceCenterPill extends StatelessWidget {
  const _ServiceCenterPill();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.18),
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Service Center',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1,
              ),
            ),
            SizedBox(width: 6),
            Icon(
              Icons.close_rounded,
              size: 14,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

class _ServicesFormCard extends StatelessWidget {
  const _ServicesFormCard({
    required this.serviceNameController,
    required this.durationController,
    required this.priceController,
    required this.onIncreaseDuration,
    required this.onDecreaseDuration,
    required this.onIncreasePrice,
    required this.onDecreasePrice,
    required this.onSubmit,
    required this.onReset,
  });

  final TextEditingController serviceNameController;
  final TextEditingController durationController;
  final TextEditingController priceController;

  final VoidCallback onIncreaseDuration;
  final VoidCallback onDecreaseDuration;
  final VoidCallback onIncreasePrice;
  final VoidCallback onDecreasePrice;
  final VoidCallback onSubmit;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFFEDF1F3),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140F172A),
            blurRadius: 28,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF9A5A38),
                      Color(0xFFB8774A),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x3320532D),
                      blurRadius: 18,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),

              const SizedBox(width: 10),

              const Text(
                'إضافة خدمة جديدة',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          const Text(
            'أضف الخدمة مع مدتها وسعرها بطريقة مرتبة وواضحة',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 13.5,
              height: 1.7,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 18),

          _ServiceTextField(
            label: 'اسم الخدمة',
            hint: 'مثال: قص شعر',
            icon: Icons.content_cut_rounded,
            controller: serviceNameController,
          ),

          const SizedBox(height: 14),

          _NumberStepperField(
            label: 'مدة الخدمة بالدقائق',
            hint: 'مثال: 30',
            icon: Icons.access_time_rounded,
            controller: durationController,
            onIncrease: onIncreaseDuration,
            onDecrease: onDecreaseDuration,
          ),

          const SizedBox(height: 14),

          _NumberStepperField(
            label: 'سعر الخدمة',
            hint: 'مثال: 30',
            icon: Icons.payments_rounded,
            controller: priceController,
            onIncrease: onIncreasePrice,
            onDecrease: onDecreasePrice,
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _MainActionButton(
                  label: 'إضافة الخدمة',
                  icon: Icons.add_rounded,
                  color: const Color(0xFFC47A3D),
                  onTap: onSubmit,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SecondaryActionButton(
                  label: 'إعادة تعيين',
                  icon: Icons.close_rounded,
                  onTap: onReset,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CurrentServicesBanner extends StatelessWidget {
  const _CurrentServicesBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFEFFCF3),
            Color(0xFFDCFCE7),
          ],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: const Color(0xFFB7EFC5),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1422C55E),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF16A34A),
                  Color(0xFF15803D),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x3316A34A),
                  blurRadius: 18,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.inventory_2_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الخدمات الحالية',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF5C4030),
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'جميع الخدمات المتوفرة حالياً للحلاق مع المدة والسعر وخيارات الإدارة',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF166534),
                    height: 1.6,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.service,
    required this.onEdit,
    required this.onViewAppointments,
    required this.onDelete,
  });

  final _UiService service;
  final VoidCallback onEdit;
  final VoidCallback onViewAppointments;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFFE9EFF0),
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D0F172A),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF7F1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFDCEFE2),
                  ),
                ),
                child: const Icon(
                  Icons.content_cut_rounded,
                  color: Color(0xFF5C4030),
                  size: 20,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  service.name,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _MetaBadge(
                  icon: Icons.access_time_rounded,
                  label: '${service.durationMinutes} دقيقة',
                  color: const Color(0xFF5C4030),
                  backgroundColor: const Color(0xFFF4F8F5),
                  borderColor: const Color(0xFFDCEFE2),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _MetaBadge(
                  icon: Icons.payments_rounded,
                  label: '₪${service.price.toStringAsFixed(0)}',
                  color: const Color(0xFF15803D),
                  backgroundColor: const Color(0xFFEEFBF2),
                  borderColor: const Color(0xFFBBF7D0),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          _CardButton(
            label: 'تعديل',
            icon: Icons.edit_rounded,
            color: const Color(0xFF2563EB),
            onTap: onEdit,
          ),

          const SizedBox(height: 10),

          _CardButton(
            label: 'المواعيد المرتبطة',
            icon: Icons.visibility_rounded,
            color: const Color(0xFF0F766E),
            onTap: onViewAppointments,
          ),

          const SizedBox(height: 10),

          _CardButton(
            label: 'تعطيل',
            icon: Icons.delete_rounded,
            color: const Color(0xFFEF4444),
            onTap: onDelete,
          ),
        ],
      ),
    );
  }
}

class _MetaBadge extends StatelessWidget {
  const _MetaBadge({
    required this.icon,
    required this.label,
    required this.color,
    required this.backgroundColor,
    required this.borderColor,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color backgroundColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 12.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceTextField extends StatelessWidget {
  const _ServiceTextField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
  });

  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: Color(0xFF374151),
          ),
        ),

        const SizedBox(height: 9),

        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(
              icon,
              color: const Color(0xFF5C4030),
              size: 20,
            ),
            filled: true,
            fillColor: const Color(0xFFF9FBFA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: Color(0xFFE4ECE7),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: Color(0xFFE4ECE7),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: Color(0xFFC47A3D),
                width: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NumberStepperField extends StatelessWidget {
  const _NumberStepperField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    required this.onIncrease,
    required this.onDecrease,
  });

  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: Color(0xFF374151),
          ),
        ),

        const SizedBox(height: 9),

        Row(
          children: [
            _AdjustButton(
              icon: Icons.remove_rounded,
              onTap: onDecrease,
            ),

            const SizedBox(width: 10),

            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: hint,
                  prefixIcon: Icon(
                    icon,
                    color: const Color(0xFF5C4030),
                    size: 20,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF9FBFA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(
                      color: Color(0xFFE4ECE7),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(
                      color: Color(0xFFE4ECE7),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(
                      color: Color(0xFFC47A3D),
                      width: 1.4,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 10),

            _AdjustButton(
              icon: Icons.add_rounded,
              onTap: onIncrease,
            ),
          ],
        ),
      ],
    );
  }
}

class _AdjustButton extends StatelessWidget {
  const _AdjustButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          width: 50,
          height: 54,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF9A5A38),
                Color(0xFFB8774A),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x3020532D),
                blurRadius: 18,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 22,
          ),
        ),
      ),
    );
  }
}

class _MainActionButton extends StatelessWidget {
  const _MainActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.18),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  const _SecondaryActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE5EBE7),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D0F172A),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: const Color(0xFF1F2937),
                size: 18,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF1F2937),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardButton extends StatelessWidget {
  const _CardButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _MainActionButton(
      label: label,
      icon: icon,
      color: color,
      onTap: onTap,
    );
  }
}

class _EmptyServicesState extends StatelessWidget {
  const _EmptyServicesState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFDBE3EA),
          style: BorderStyle.solid,
        ),
      ),
      child: const Text(
        'لا توجد خدمات مضافة حاليًا',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Color(0xFF6B7280),
        ),
      ),
    );
  }
}

class _UiService {
  const _UiService({
    required this.id,
    required this.name,
    required this.durationMinutes,
    required this.price,
  });

  final String id;
  final String name;
  final int durationMinutes;
  final double price;

  _UiService copyWith({
    String? name,
    int? durationMinutes,
    double? price,
  }) {
    return _UiService(
      id: id,
      name: name ?? this.name,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      price: price ?? this.price,
    );
  }
}