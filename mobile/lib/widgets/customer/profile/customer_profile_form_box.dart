import 'package:flutter/material.dart';

import 'customer_profile_fields.dart';
import 'customer_profile_shared_widgets.dart';

class CustomerProfileFormBox extends StatelessWidget {
  const CustomerProfileFormBox({
    super.key,
    required this.hasProfileImage,
    required this.nameController,
    required this.phoneController,
    required this.selectedCountry,
    required this.phoneCode,
    required this.onCountryChanged,
    required this.onAddOrChangeImage,
    required this.onRemoveImage,
  });

  final bool hasProfileImage;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final String selectedCountry;
  final String phoneCode;
  final ValueChanged<String?> onCountryChanged;
  final VoidCallback onAddOrChangeImage;
  final VoidCallback onRemoveImage;

  @override
  Widget build(BuildContext context) {
    return CustomerProfileCardShell(
      child: Column(
        children: [
          const CustomerProfileSectionHeader(
            icon: Icons.badge_rounded,
            title: 'بيانات الحساب',
            subtitle: 'هذه البيانات تساعد الحلاق على التعرف عليك عند الحجز.',
          ),
          const SizedBox(height: 18),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 102,
                height: 102,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: hasProfileImage
                      ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF2A2018),
                            Color(0xFF6E3F2F),
                            Color(0xFFC37A49),
                          ],
                        )
                      : const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF6E3F2F),
                            Color(0xFFC47A3D),
                          ],
                        ),
                  border: Border.all(
                    color: const Color(0xFFE7B679),
                    width: 3,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x22C47A3D),
                      blurRadius: 18,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  hasProfileImage ? Icons.image_rounded : Icons.person_rounded,
                  size: 46,
                  color: Colors.white,
                ),
              ),
              Positioned(
                left: 4,
                bottom: 4,
                child: Container(
                  width: 19,
                  height: 19,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF22C55E),
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x7722C55E),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            hasProfileImage
                ? 'تمت إضافة صورة بروفايل مؤقتة'
                : 'لم تتم إضافة صورة بروفايل بعد',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: CustomerProfileMiniActionButton(
                  label: hasProfileImage ? 'تعديل الصورة' : 'إضافة صورة',
                  icon: hasProfileImage
                      ? Icons.edit_rounded
                      : Icons.add_photo_alternate_rounded,
                  color: const Color(0xFFC47A3D),
                  onTap: onAddOrChangeImage,
                ),
              ),
              if (hasProfileImage) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: CustomerProfileMiniActionButton(
                    label: 'إزالة الصورة',
                    icon: Icons.delete_outline_rounded,
                    color: const Color(0xFFEF4444),
                    onTap: onRemoveImage,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 18),
          CustomerProfileTextField(
            label: 'الاسم الظاهر',
            hint: 'مثال: يوسف',
            icon: Icons.person_outline_rounded,
            controller: nameController,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: CustomerCountryDropdown(
                  selectedCountry: selectedCountry,
                  onChanged: onCountryChanged,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 3,
                child: CustomerProfileTextField(
                  label: 'رقم الهاتف',
                  hint: '599999999',
                  icon: Icons.phone_rounded,
                  keyboardType: TextInputType.phone,
                  controller: phoneController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBF2),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFFE8D8B8),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_rounded,
                  color: Color(0xFFC47A3D),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'سيظهر رقمك للحلاق بصيغة: $phoneCode ${phoneController.text}',
                    style: const TextStyle(
                      fontSize: 12.5,
                      height: 1.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF6B4F3E),
                    ),
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