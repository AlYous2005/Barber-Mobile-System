import 'package:flutter/material.dart';

class CustomerProfileResult {
  const CustomerProfileResult({
    required this.displayName,
    required this.countryCode,
    required this.phoneNumber,
    this.hasProfileImage = false,
  });

  final String displayName;
  final String countryCode;
  final String phoneNumber;
  final bool hasProfileImage;
}

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({
    super.key,
    required this.initialDisplayName,
    required this.initialCountryCode,
    required this.initialPhoneNumber,
    this.initialHasProfileImage = false,
  });

  final String initialDisplayName;
  final String initialCountryCode;
  final String initialPhoneNumber;
  final bool initialHasProfileImage;

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  late final TextEditingController nameController;
  late final TextEditingController phoneController;
  late final TextEditingController currentPasswordController;
  late final TextEditingController newPasswordController;
  late final TextEditingController confirmPasswordController;

  String selectedCountry = 'فلسطين';
  bool hasProfileImage = false;

  bool showCurrentPassword = false;
  bool showNewPassword = false;
  bool showConfirmPassword = false;

  String get phoneCode => selectedCountry == 'فلسطين' ? '+970' : '+972';

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.initialDisplayName);
    phoneController = TextEditingController(text: widget.initialPhoneNumber);
    currentPasswordController = TextEditingController();
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();

    selectedCountry = widget.initialCountryCode == '+972' ? 'إسرائيل' : 'فلسطين';
    hasProfileImage = widget.initialHasProfileImage;
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _addOrChangeImage() {
    setState(() {
      hasProfileImage = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          hasProfileImage
              ? 'تم تحديث صورة البروفايل مؤقتًا'
              : 'تمت إضافة صورة البروفايل مؤقتًا',
        ),
      ),
    );
  }

  void _removeImage() {
    setState(() {
      hasProfileImage = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تمت إزالة صورة البروفايل مؤقتًا'),
      ),
    );
  }

  bool _passwordSectionHasInput() {
    return currentPasswordController.text.trim().isNotEmpty ||
        newPasswordController.text.trim().isNotEmpty ||
        confirmPasswordController.text.trim().isNotEmpty;
  }

  void save() {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال الاسم الظاهر')),
      );
      return;
    }

    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال رقم الهاتف')),
      );
      return;
    }

    if (_passwordSectionHasInput()) {
      final currentPassword = currentPasswordController.text.trim();
      final newPassword = newPasswordController.text.trim();
      final confirmPassword = confirmPasswordController.text.trim();

      if (currentPassword.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('أدخل كلمة المرور الحالية')),
        );
        return;
      }

      if (newPassword.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('كلمة المرور الجديدة يجب أن تكون 6 أحرف على الأقل')),
        );
        return;
      }

      if (newPassword != confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تأكيد كلمة المرور غير مطابق')),
        );
        return;
      }
    }

    Navigator.of(context).pop(
      CustomerProfileResult(
        displayName: name,
        countryCode: phoneCode,
        phoneNumber: phone,
        hasProfileImage: hasProfileImage,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'الملف الشخصي',
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
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              children: [
                const _ProfileIntroCard(),

                const SizedBox(height: 16),

                _ProfileFormBox(
                  hasProfileImage: hasProfileImage,
                  nameController: nameController,
                  phoneController: phoneController,
                  selectedCountry: selectedCountry,
                  phoneCode: phoneCode,
                  onCountryChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      selectedCountry = value;
                    });
                  },
                  onAddOrChangeImage: _addOrChangeImage,
                  onRemoveImage: _removeImage,
                ),

                const SizedBox(height: 16),

                _PasswordBox(
                  currentPasswordController: currentPasswordController,
                  newPasswordController: newPasswordController,
                  confirmPasswordController: confirmPasswordController,
                  showCurrentPassword: showCurrentPassword,
                  showNewPassword: showNewPassword,
                  showConfirmPassword: showConfirmPassword,
                  onToggleCurrent: () {
                    setState(() {
                      showCurrentPassword = !showCurrentPassword;
                    });
                  },
                  onToggleNew: () {
                    setState(() {
                      showNewPassword = !showNewPassword;
                    });
                  },
                  onToggleConfirm: () {
                    setState(() {
                      showConfirmPassword = !showConfirmPassword;
                    });
                  },
                ),

                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  child: _PrimarySaveButton(
                    label: 'حفظ التغييرات',
                    icon: Icons.save_rounded,
                    onTap: save,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileIntroCard extends StatelessWidget {
  const _ProfileIntroCard();

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
          _ProfileCenterPill(),

          SizedBox(height: 14),

          Text(
            'ملفي الشخصي',
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
            'تحكم بصورتك واسمك ورقم هاتفك ومعلومات حسابك بسهولة',
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

class _ProfileCenterPill extends StatelessWidget {
  const _ProfileCenterPill();

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
              'Customer Profile',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1,
              ),
            ),
            SizedBox(width: 6),
            Icon(
              Icons.person_rounded,
              size: 14,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileFormBox extends StatelessWidget {
  const _ProfileFormBox({
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
    return _ProfileCardShell(
      child: Column(
        children: [
          const _SectionHeader(
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
                child: _MiniActionButton(
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
                  child: _MiniActionButton(
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

          _ProfileTextField(
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
                child: _CountryDropdown(
                  selectedCountry: selectedCountry,
                  onChanged: onCountryChanged,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 3,
                child: _ProfileTextField(
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

class _PasswordBox extends StatelessWidget {
  const _PasswordBox({
    required this.currentPasswordController,
    required this.newPasswordController,
    required this.confirmPasswordController,
    required this.showCurrentPassword,
    required this.showNewPassword,
    required this.showConfirmPassword,
    required this.onToggleCurrent,
    required this.onToggleNew,
    required this.onToggleConfirm,
  });

  final TextEditingController currentPasswordController;
  final TextEditingController newPasswordController;
  final TextEditingController confirmPasswordController;

  final bool showCurrentPassword;
  final bool showNewPassword;
  final bool showConfirmPassword;

  final VoidCallback onToggleCurrent;
  final VoidCallback onToggleNew;
  final VoidCallback onToggleConfirm;

  @override
  Widget build(BuildContext context) {
    return _ProfileCardShell(
      child: Column(
        children: [
          const _SectionHeader(
            icon: Icons.lock_rounded,
            title: 'تغيير كلمة المرور',
            subtitle: 'اترك الحقول فارغة إذا كنت لا تريد تغيير كلمة المرور الآن.',
          ),

          const SizedBox(height: 18),

          _PasswordField(
            label: 'كلمة المرور الحالية',
            controller: currentPasswordController,
            isVisible: showCurrentPassword,
            onToggleVisibility: onToggleCurrent,
          ),

          const SizedBox(height: 14),

          _PasswordField(
            label: 'كلمة المرور الجديدة',
            controller: newPasswordController,
            isVisible: showNewPassword,
            onToggleVisibility: onToggleNew,
          ),

          const SizedBox(height: 14),

          _PasswordField(
            label: 'تأكيد كلمة المرور الجديدة',
            controller: confirmPasswordController,
            isVisible: showConfirmPassword,
            onToggleVisibility: onToggleConfirm,
          ),
        ],
      ),
    );
  }
}

class _ProfileCardShell extends StatelessWidget {
  const _ProfileCardShell({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: const Color(0xFFEDF1F3),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140F172A),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _IconBox(
          icon: icon,
          color: const Color(0xFFC47A3D),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 13,
                  height: 1.6,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({
    required this.icon,
    required this.color,
  });

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.18),
        ),
      ),
      child: Icon(
        icon,
        color: color,
        size: 22,
      ),
    );
  }
}

class _ProfileTextField extends StatelessWidget {
  const _ProfileTextField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.keyboardType,
  });

  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final TextInputType? keyboardType;

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
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(
              icon,
              color: const Color(0xFF5C4030),
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

class _CountryDropdown extends StatelessWidget {
  const _CountryDropdown({
    required this.selectedCountry,
    required this.onChanged,
  });

  final String selectedCountry;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'الدولة',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 9),
        DropdownButtonFormField<String>(
          initialValue: selectedCountry,
          decoration: InputDecoration(
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
          items: const [
            DropdownMenuItem(
              value: 'فلسطين',
              child: Text('🇵🇸 +970'),
            ),
            DropdownMenuItem(
              value: 'إسرائيل',
              child: Text('🇮🇱 +972'),
            ),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.label,
    required this.controller,
    required this.isVisible,
    required this.onToggleVisibility,
  });

  final String label;
  final TextEditingController controller;
  final bool isVisible;
  final VoidCallback onToggleVisibility;

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
          obscureText: !isVisible,
          decoration: InputDecoration(
            hintText: '••••••••',
            prefixIcon: const Icon(
              Icons.lock_outline_rounded,
              color: Color(0xFF5C4030),
            ),
            suffixIcon: IconButton(
              onPressed: onToggleVisibility,
              icon: Icon(
                isVisible
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: const Color(0xFF6B7280),
              ),
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

class _MiniActionButton extends StatelessWidget {
  const _MiniActionButton({
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
          constraints: const BoxConstraints(minHeight: 46),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
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

class _PrimarySaveButton extends StatelessWidget {
  const _PrimarySaveButton({
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
      color: const Color(0xFFC47A3D),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          constraints: const BoxConstraints(minHeight: 52),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33C47A3D),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}