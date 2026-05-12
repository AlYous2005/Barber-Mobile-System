import 'package:flutter/material.dart';

import '../../../general_utils/app_theme_colors.dart';
import '../../../features/locations/locations.dart';

class ProfileDataSection extends StatelessWidget {
  const ProfileDataSection({
    super.key,
    required this.isEditing,
    required this.onEditTap,
    required this.nameController,
    required this.phoneController,
    required this.whatsappController,
    required this.addressController,
    required this.bioController,
    required this.governorates,
    required this.areas,
    required this.selectedGovernorateId,
    required this.selectedAreaId,
    required this.isLoadingGovernorates,
    required this.isLoadingAreas,
    required this.onGovernorateChanged,
    required this.onAreaChanged,
    required this.whatsappCountryCode,
    required this.onWhatsappCountryChanged,
    required this.fullWhatsapp,
  });

  final bool isEditing;
  final VoidCallback onEditTap;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController whatsappController;
  final TextEditingController addressController;
  final TextEditingController bioController;
  final List<GovernorateModel> governorates;
  final List<AreaModel> areas;
  final String? selectedGovernorateId;
  final String? selectedAreaId;
  final bool isLoadingGovernorates;
  final bool isLoadingAreas;
  final ValueChanged<String?> onGovernorateChanged;
  final ValueChanged<String?> onAreaChanged;
  final String whatsappCountryCode;
  final ValueChanged<String?> onWhatsappCountryChanged;
  final String fullWhatsapp;

  String get selectedGovernorateName {
    final id = selectedGovernorateId?.trim();
    if (id == null || id.isEmpty) {
      return '';
    }

    for (final governorate in governorates) {
      if (governorate.id == id) {
        return governorate.nameAr;
      }
    }

    return '';
  }

  String get selectedAreaName {
    final id = selectedAreaId?.trim();
    if (id == null || id.isEmpty) {
      return '';
    }

    for (final area in areas) {
      if (area.id == id) {
        return area.nameAr;
      }
    }

    return '';
  }

  String get selectedLocationLabel {
    if (selectedGovernorateName.isNotEmpty && selectedAreaName.isNotEmpty) {
      return '$selectedGovernorateName - $selectedAreaName';
    }

    if (selectedAreaName.isNotEmpty) {
      return selectedAreaName;
    }

    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppThemeColors.card(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppThemeColors.border(context)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'البيانات الحالية',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: AppThemeColors.textPrimary(context),
                  ),
                ),
              ),

              if (!isEditing) SmallEditButton(onTap: onEditTap),
            ],
          ),

          const SizedBox(height: 12),

          if (!isEditing) ...[
            ProfileInfoTile(
              icon: Icons.badge_rounded,
              title: 'اسم الحلاق',
              value: nameController.text.trim().isEmpty
                  ? 'لم يتم إدخال اسم الحلاق'
                  : nameController.text.trim(),
            ),
            ProfileInfoTile(
              icon: Icons.map_rounded,
              title: 'الموقع الرسمي',
              value: selectedLocationLabel.isEmpty
                  ? 'لم يتم تحديد المحافظة والمنطقة'
                  : selectedLocationLabel,
            ),
            ProfileInfoTile(
              icon: Icons.phone_rounded,
              title: 'رقم الهاتف',
              value: phoneController.text.trim().isEmpty
                  ? 'لم يتم إدخال رقم الهاتف'
                  : phoneController.text.trim(),
            ),
            ProfileInfoTile(
              icon: Icons.chat_rounded,
              title: 'رقم الواتساب',
              value: fullWhatsapp.isEmpty
                  ? 'لم يتم إدخال رقم الواتساب'
                  : fullWhatsapp,
            ),
            ProfileInfoTile(
              icon: Icons.location_on_rounded,
              title: 'العنوان التفصيلي',
              value: addressController.text.trim().isEmpty
                  ? 'لم يتم إدخال العنوان'
                  : addressController.text.trim(),
            ),
            ProfileInfoTile(
              icon: Icons.description_rounded,
              title: 'نبذة قصيرة',
              value: bioController.text.trim().isEmpty
                  ? 'لا توجد نبذة بعد'
                  : bioController.text.trim(),
            ),
          ] else ...[
            ProfileTextField(
              label: 'اسم الحلاق',
              controller: nameController,
              icon: Icons.badge_rounded,
            ),
            const SizedBox(height: 12),
            ProfileTextField(
              label: 'رقم الهاتف',
              controller: phoneController,
              icon: Icons.phone_rounded,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            WhatsappField(
              countryCode: whatsappCountryCode,
              onCountryChanged: onWhatsappCountryChanged,
              controller: whatsappController,
            ),
            const SizedBox(height: 20),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                'موقع الصالون',
                style: TextStyle(
                  color: AppThemeColors.textPrimary(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 10),

            ProfileDropdownField(
              label: 'المحافظة',
              icon: Icons.location_city_rounded,
              value: selectedGovernorateId,
              isLoading: isLoadingGovernorates,
              hintText: 'اختر المحافظة',
              items: governorates.map((governorate) {
                return DropdownMenuItem<String>(
                  value: governorate.id,
                  child: Text(
                    governorate.nameAr,
                    style: TextStyle(
                      color: AppThemeColors.textPrimary(context),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                );
              }).toList(),
              onChanged: onGovernorateChanged,
            ),
            const SizedBox(height: 12),
            ProfileDropdownField(
              label: 'المنطقة',
              icon: Icons.place_rounded,
              value: selectedAreaId,
              isLoading: isLoadingAreas,
              isEnabled: selectedGovernorateId != null,
              hintText: selectedGovernorateId == null
                  ? 'اختر المحافظة أولًا'
                  : 'اختر المنطقة',
              items: areas.map((area) {
                return DropdownMenuItem<String>(
                  value: area.id,
                  child: Text(
                    area.nameAr,
                    style: TextStyle(
                      color: AppThemeColors.textPrimary(context),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                );
              }).toList(),
              onChanged: onAreaChanged,
            ),
            const SizedBox(height: 12),
            ProfileTextField(
              label: 'العنوان التفصيلي',
              controller: addressController,
              icon: Icons.location_on_rounded,
            ),
            const SizedBox(height: 12),
            ProfileTextField(
              label: 'نبذة قصيرة',
              controller: bioController,
              icon: Icons.description_rounded,
              maxLines: 3,
            ),
          ],
        ],
      ),
    );
  }
}

class ProfileDropdownField extends StatelessWidget {
  const ProfileDropdownField({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.hintText,
    this.isLoading = false,
    this.isEnabled = true,
  });

  final String label;
  final IconData icon;
  final String? value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;
  final String hintText;
  final bool isLoading;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final bool canChange = isEnabled && !isLoading;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppThemeColors.softCard(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppThemeColors.border(context)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFC47A3D), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                dropdownColor: AppThemeColors.card(context),
                iconEnabledColor: AppThemeColors.textSecondary(context),
                hint: Text(
                  isLoading ? 'جاري التحميل...' : hintText,
                  style: TextStyle(
                    color: AppThemeColors.textSecondary(context),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                items: items,
                onChanged: canChange ? onChanged : null,
              ),
            ),
          ),
          if (isLoading)
            const SizedBox(
              width: 17,
              height: 17,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }
}

class SmallEditButton extends StatelessWidget {
  const SmallEditButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFC47A3D).withValues(alpha: 0.11),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: const Color(0xFFC47A3D).withValues(alpha: 0.22),
            ),
          ),
          child: const Row(
            children: [
              Icon(Icons.edit_rounded, size: 15, color: Color(0xFFC47A3D)),
              SizedBox(width: 6),
              Text(
                'تعديل البيانات',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFC47A3D),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileInfoTile extends StatelessWidget {
  const ProfileInfoTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppThemeColors.softCard(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppThemeColors.border(context)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFC47A3D).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFFC47A3D), size: 20),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF8A4E2E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    fontWeight: FontWeight.w700,
                    color: AppThemeColors.textPrimary(context),
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

class ProfileTextField extends StatelessWidget {
  const ProfileTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    this.keyboardType,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFFC47A3D)),
        filled: true,
        fillColor: AppThemeColors.softCard(context),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppThemeColors.border(context)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppThemeColors.border(context)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFC47A3D), width: 1.4),
        ),
      ),
    );
  }
}

class WhatsappField extends StatelessWidget {
  const WhatsappField({
    super.key,
    required this.countryCode,
    required this.onCountryChanged,
    required this.controller,
  });

  final String countryCode;
  final ValueChanged<String?> onCountryChanged;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 58,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: AppThemeColors.softCard(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppThemeColors.border(context)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: countryCode,
              items: const [
                DropdownMenuItem(value: '+970', child: Text('فلسطين +970')),
                DropdownMenuItem(value: '+972', child: Text('إسرائيل +972')),
              ],
              onChanged: onCountryChanged,
            ),
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.phone,
            textDirection: TextDirection.ltr,
            decoration: InputDecoration(
              labelText: 'رقم الواتساب',
              filled: true,
              fillColor: AppThemeColors.softCard(context),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 13,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppThemeColors.border(context)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppThemeColors.border(context)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFFC47A3D),
                  width: 1.4,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
