import 'package:flutter/material.dart';

import '../../../models/ui_service_model.dart';
import 'service_form_widgets.dart';

class EditServiceSheet extends StatefulWidget {
  const EditServiceSheet({
    super.key,
    required this.service,
    required this.onSave,
    required this.onMessage,
  });

  final UiService service;
  final ValueChanged<UiService> onSave;
  final ValueChanged<String> onMessage;

  @override
  State<EditServiceSheet> createState() => _EditServiceSheetState();
}

class _EditServiceSheetState extends State<EditServiceSheet> {
  late final TextEditingController nameController;
  late final TextEditingController durationController;
  late final TextEditingController priceController;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.service.name);
    durationController = TextEditingController(
      text: widget.service.durationMinutes.toString(),
    );
    priceController = TextEditingController(
      text: widget.service.price.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    durationController.dispose();
    priceController.dispose();
    super.dispose();
  }

  void _increaseDuration() {
    final int current = int.tryParse(durationController.text) ?? 0;
    durationController.text = (current + 1).toString();
  }

  void _decreaseDuration() {
    final int current = int.tryParse(durationController.text) ?? 1;
    durationController.text = (current <= 1 ? 1 : current - 1).toString();
  }

  void _increasePrice() {
    final double current = double.tryParse(priceController.text) ?? 0;
    priceController.text = (current + 1).toStringAsFixed(0);
  }

  void _decreasePrice() {
    final double current = double.tryParse(priceController.text) ?? 0;
    final double next = current <= 0 ? 0 : current - 1;
    priceController.text = next.toStringAsFixed(0);
  }

  void _saveChanges() {
    final String newName = nameController.text.trim();
    final int? newDuration = int.tryParse(durationController.text.trim());
    final double? newPrice = double.tryParse(priceController.text.trim());

    if (newName.isEmpty) {
      widget.onMessage('يرجى إدخال اسم الخدمة');
      return;
    }

    if (newDuration == null || newDuration <= 0) {
      widget.onMessage('يرجى إدخال مدة صحيحة');
      return;
    }

    if (newPrice == null || newPrice < 0) {
      widget.onMessage('يرجى إدخال سعر صحيح');
      return;
    }

    final updatedService = widget.service.copyWith(
      name: newName,
      durationMinutes: newDuration,
      price: newPrice,
    );

    widget.onSave(updatedService);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
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
                        color: const Color(0xFFC47A3D).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color:
                              const Color(0xFFC47A3D).withValues(alpha: 0.18),
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

                ServiceTextField(
                  label: 'اسم الخدمة',
                  hint: 'مثال: قص شعر',
                  icon: Icons.content_cut_rounded,
                  controller: nameController,
                ),

                const SizedBox(height: 14),

                NumberStepperField(
                  label: 'مدة الخدمة بالدقائق',
                  hint: 'مثال: 30',
                  icon: Icons.access_time_rounded,
                  controller: durationController,
                  onIncrease: _increaseDuration,
                  onDecrease: _decreaseDuration,
                ),

                const SizedBox(height: 14),

                NumberStepperField(
                  label: 'سعر الخدمة',
                  hint: 'مثال: 30',
                  icon: Icons.payments_rounded,
                  controller: priceController,
                  onIncrease: _increasePrice,
                  onDecrease: _decreasePrice,
                ),

                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(
                      child: MainActionButton(
                        label: 'حفظ التعديلات',
                        icon: Icons.edit_rounded,
                        color: const Color(0xFFC47A3D),
                        onTap: _saveChanges,
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: SecondaryActionButton(
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
  }
}