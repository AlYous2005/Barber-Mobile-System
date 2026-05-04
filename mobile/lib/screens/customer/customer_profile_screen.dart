import 'package:flutter/material.dart';

import '../../models/customer_profile_result.dart';
import '../../utils/app_theme_colors.dart';
import '../../widgets/customer/profile/customer_profile_intro_card.dart';
import '../../widgets/customer/profile/customer_profile_shared_widgets.dart';
import '../../widgets/customer/profile/customer_password_box.dart';
import '../../widgets/customer/profile/customer_profile_form_box.dart';

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

    selectedCountry = widget.initialCountryCode == '+972'
        ? 'إسرائيل'
        : 'فلسطين';
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
    final bool alreadyHadImage = hasProfileImage;

    setState(() {
      hasProfileImage = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          alreadyHadImage
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
      const SnackBar(content: Text('تمت إزالة صورة البروفايل مؤقتًا')),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('الرجاء إدخال رقم الهاتف')));
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
          const SnackBar(
            content: Text('كلمة المرور الجديدة يجب أن تكون 6 أحرف على الأقل'),
          ),
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
    final Color pageBg = Theme.of(context).scaffoldBackgroundColor;
    final Color titleColor = AppThemeColors.textPrimary(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: pageBg,
        appBar: AppBar(
          title: const SizedBox.shrink(),
          centerTitle: true,
          backgroundColor: pageBg,
          surfaceTintColor: pageBg,
          elevation: 0,
          iconTheme: IconThemeData(color: titleColor),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              children: [
                const CustomerProfileIntroCard(),

                const SizedBox(height: 16),

                CustomerProfileFormBox(
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

                CustomerPasswordBox(
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
                  child: CustomerProfilePrimarySaveButton(
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
