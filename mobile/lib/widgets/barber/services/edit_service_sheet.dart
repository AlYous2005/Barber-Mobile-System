import 'package:flutter/material.dart';

import '../../../models/ui_service_model.dart';
import '../../../utils/app_theme_colors.dart';
import '../../../utils/validators/service_field_validation.dart';
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

  late final String _originalName;
  late final int _originalDuration;
  late final int _originalPrice;

  late final VoidCallback _onNameChanged;
  late final VoidCallback _onDurationChanged;
  late final VoidCallback _onPriceChanged;

  String? nameError;
  String? durationError;
  String? priceError;

  int nameShakeTrigger = 0;
  int durationShakeTrigger = 0;
  int priceShakeTrigger = 0;

  @override
  void initState() {
    super.initState();

    _originalName = widget.service.name.trim();
    _originalDuration = widget.service.durationMinutes;
    _originalPrice = widget.service.price.round();

    nameController = TextEditingController(text: widget.service.name);
    durationController = TextEditingController(
      text: widget.service.durationMinutes.toString(),
    );
    priceController = TextEditingController(
      text: widget.service.price.toStringAsFixed(0),
    );

    _onNameChanged = () {
      if (!mounted) return;
      setState(() => nameError = null);
    };
    _onDurationChanged = () {
      if (!mounted) return;
      setState(() => durationError = null);
    };
    _onPriceChanged = () {
      if (!mounted) return;
      setState(() => priceError = null);
    };

    nameController.addListener(_onNameChanged);
    durationController.addListener(_onDurationChanged);
    priceController.addListener(_onPriceChanged);
  }

  bool get _hasChanges {
    final String n = nameController.text.trim();
    final int? d = int.tryParse(durationController.text.trim());
    final int? p = int.tryParse(priceController.text.trim());
    return n != _originalName || d != _originalDuration || p != _originalPrice;
  }

  bool _validate() {
    final String n = nameController.text;
    final String d = durationController.text;
    final String p = priceController.text;

    final String? ne = ServiceFieldValidation.nameError(n);
    final String? de = ServiceFieldValidation.durationError(d);
    final String? pe = ServiceFieldValidation.priceError(p);

    final bool ok = ne == null && de == null && pe == null;
    if (!ok) {
      setState(() {
        nameError = ne;
        durationError = de;
        priceError = pe;
        if (ne != null) nameShakeTrigger++;
        if (de != null) durationShakeTrigger++;
        if (pe != null) priceShakeTrigger++;
      });
    } else {
      setState(() {
        nameError = null;
        durationError = null;
        priceError = null;
      });
    }
    return ok;
  }

  void _increaseDuration() {
    ServiceStepperHelper.increaseMultipleOf5(durationController);
    setState(() {});
  }

  void _decreaseDuration() {
    ServiceStepperHelper.decreaseMultipleOf5(durationController);
    setState(() {});
  }

  void _increasePrice() {
    ServiceStepperHelper.increaseMultipleOf5(priceController);
    setState(() {});
  }

  void _decreasePrice() {
    ServiceStepperHelper.decreaseMultipleOf5(priceController);
    setState(() {});
  }

  void _saveChanges() {
    if (!_hasChanges) return;

    if (!_validate()) {
      return;
    }

    final String newName = nameController.text.trim();
    final int newDuration = int.parse(durationController.text.trim());
    final int newPriceInt = int.parse(priceController.text.trim());

    final updatedService = widget.service.copyWith(
      name: newName,
      durationMinutes: newDuration,
      price: newPriceInt.toDouble(),
    );

    widget.onSave(updatedService);
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    nameController.removeListener(_onNameChanged);
    durationController.removeListener(_onDurationChanged);
    priceController.removeListener(_onPriceChanged);
    nameController.dispose();
    durationController.dispose();
    priceController.dispose();
    super.dispose();
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
            color: AppThemeColors.card(context),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppThemeColors.border(context)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: AppThemeColors.isDark(context) ? 0.45 : 0.2,
                ),
                blurRadius: 28,
                offset: const Offset(0, 14),
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
                    color: AppThemeColors.border(context),
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
                          color: const Color(
                            0xFFC47A3D,
                          ).withValues(alpha: 0.18),
                        ),
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        color: Color(0xFFC47A3D),
                        size: 21,
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Text(
                        'تعديل الخدمة',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppThemeColors.textPrimary(context),
                        ),
                      ),
                    ),

                    Material(
                      color: AppThemeColors.softCard(context),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(color: AppThemeColors.border(context)),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => Navigator.of(context).pop(),
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: Icon(
                            Icons.close_rounded,
                            color: AppThemeColors.textSecondary(context),
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
                  errorText: nameError,
                  shakeTrigger: nameShakeTrigger,
                ),

                const SizedBox(height: 14),

                NumberStepperField(
                  label: 'مدة الخدمة بالدقائق',
                  hint: 'مثال: 30',
                  icon: Icons.access_time_rounded,
                  controller: durationController,
                  onIncrease: _increaseDuration,
                  onDecrease: _decreaseDuration,
                  errorText: durationError,
                  shakeTrigger: durationShakeTrigger,
                ),

                const SizedBox(height: 14),

                NumberStepperField(
                  label: 'سعر الخدمة',
                  hint: 'مثال: 30',
                  icon: Icons.payments_rounded,
                  controller: priceController,
                  onIncrease: _increasePrice,
                  onDecrease: _decreasePrice,
                  errorText: priceError,
                  shakeTrigger: priceShakeTrigger,
                ),

                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(
                      child: MainActionButton(
                        label: 'حفظ التعديلات',
                        icon: Icons.edit_rounded,
                        color: const Color(0xFFC47A3D),
                        onTap: _hasChanges ? _saveChanges : null,
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
