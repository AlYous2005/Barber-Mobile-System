import 'package:flutter/material.dart';

import '../../../general_utils/app_theme_colors.dart';
import 'service_form_widgets.dart';
import 'service_icon_selector.dart';
import 'service_image_picker_card.dart';
import '../../../features/barber/services_management/services_management.dart';

class ServicesFormCard extends StatelessWidget {
  const ServicesFormCard({
    super.key,
    required this.serviceNameController,
    required this.durationController,
    required this.priceController,
    required this.onIncreaseDuration,
    required this.onDecreaseDuration,
    required this.onIncreasePrice,
    required this.onDecreasePrice,
    required this.onSubmit,
    required this.onReset,
    required this.selectedTarget,
    required this.onTargetChanged,
    required this.selectedIconKey,
    required this.onIconChanged,
    required this.selectedImageUrl,
    required this.isUploadingImage,
    required this.onPickImage,
    required this.onClearImage,
    this.serviceNameError,
    this.durationError,
    this.priceError,
    this.serviceNameShakeTrigger = 0,
    this.durationShakeTrigger = 0,
    this.priceShakeTrigger = 0,
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
  final ServiceTarget selectedTarget;
  final ValueChanged<ServiceTarget> onTargetChanged;
  final String selectedIconKey;
  final ValueChanged<String> onIconChanged;
  final String? selectedImageUrl;
  final bool isUploadingImage;
  final VoidCallback onPickImage;
  final VoidCallback onClearImage;

  final String? serviceNameError;
  final String? durationError;
  final String? priceError;
  final int serviceNameShakeTrigger;
  final int durationShakeTrigger;
  final int priceShakeTrigger;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppThemeColors.card(context),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppThemeColors.border(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: AppThemeColors.isDark(context) ? 0.35 : 0.08,
            ),
            blurRadius: 28,
            offset: const Offset(0, 12),
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
                    colors: [Color(0xFF9A5A38), Color(0xFFB8774A)],
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

              Text(
                'إضافة خدمة جديدة',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppThemeColors.textPrimary(context),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            'أضف الخدمة مع مدتها وسعرها بطريقة مرتبة وواضحة',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppThemeColors.textSecondary(context),
              fontSize: 13.5,
              height: 1.7,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 18),

          ServiceTextField(
            label: 'اسم الخدمة',
            hint: 'مثال: قص شعر',
            icon: Icons.content_cut_rounded,
            controller: serviceNameController,
            errorText: serviceNameError,
            shakeTrigger: serviceNameShakeTrigger,
          ),

          const SizedBox(height: 14),

          NumberStepperField(
            label: 'مدة الخدمة بالدقائق',
            hint: 'مثال: 30',
            icon: Icons.access_time_rounded,
            controller: durationController,
            onIncrease: onIncreaseDuration,
            onDecrease: onDecreaseDuration,
            errorText: durationError,
            shakeTrigger: durationShakeTrigger,
          ),

          const SizedBox(height: 14),

          NumberStepperField(
            label: 'سعر الخدمة',
            hint: 'مثال: 30',
            icon: Icons.payments_rounded,
            controller: priceController,
            onIncrease: onIncreasePrice,
            onDecrease: onDecreasePrice,
            errorText: priceError,
            shakeTrigger: priceShakeTrigger,
          ),

          const SizedBox(height: 14),

          ServiceTargetSelector(
            selectedTarget: selectedTarget,
            onChanged: onTargetChanged,
          ),

          const SizedBox(height: 14),

          ServiceIconSelector(
            selectedIconKey: selectedIconKey,
            onChanged: onIconChanged,
          ),

          const SizedBox(height: 14),

          ServiceImagePickerCard(
            imageUrl: selectedImageUrl,
            isUploading: isUploadingImage,
            onPickImage: onPickImage,
            onClearImage: onClearImage,
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: MainActionButton(
                  label: 'إضافة الخدمة',
                  icon: Icons.add_rounded,
                  color: const Color(0xFFC47A3D),
                  onTap: onSubmit,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SecondaryActionButton(
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
