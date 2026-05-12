// UI + animation + navigation + legal sheets

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../features/locations/locations.dart';

import '../../controllers/auth/signup_controller.dart';

import '../../widgets/auth/auth_background.dart';
import '../../widgets/auth/auth_birth_date_selector.dart';
import '../../widgets/auth/auth_card.dart';
import '../../widgets/auth/auth_country_code_selector.dart';
import '../../widgets/auth/auth_error_message.dart';
import '../../widgets/auth/auth_legal_agreement_text.dart';
import '../../widgets/auth/auth_text_field.dart';
import '../../features/auth/auth.dart';
import 'phone_otp_verification_screen.dart';
import '../../widgets/auth/password_strength_indicator.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  late final SignUpController controller;

  late AnimationController _shakeController;
  Animation<double>? _shakeAnimation;

  @override
  void initState() {
    super.initState();

    controller = SignUpController();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 12,
    ).chain(CurveTween(curve: Curves.elasticIn)).animate(_shakeController);
  }

  @override
  void dispose() {
    controller.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  Widget buildShakingField({required bool shouldShake, required Widget child}) {
    return AnimatedBuilder(
      animation: _shakeAnimation ?? const AlwaysStoppedAnimation(0),
      builder: (context, animatedChild) {
        return Transform.translate(
          offset: shouldShake
              ? Offset(_shakeAnimation?.value ?? 0, 0)
              : Offset.zero,
          child: animatedChild,
        );
      },
      child: child,
    );
  }

  Widget buildLocationDropdown({
    required String hintText,
    required IconData icon,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
    String? errorText,
    bool isLoading = false,
    bool isEnabled = true,
  }) {
    final bool canChange = isEnabled && !isLoading;
    final bool hasError = errorText != null && errorText.trim().isNotEmpty;

    String? selectedLabel;

    for (final item in items) {
      if (item.value == value && item.child is Text) {
        selectedLabel = (item.child as Text).data;
        break;
      }
    }

    Future<void> openOptionsSheet() async {
      if (!canChange) return;

      final String? selectedValue = await showModalBottomSheet<String>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF151515),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white24),
              ),
              child: items.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(18),
                      child: Text(
                        'لا توجد خيارات متاحة حاليًا',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: items.length,
                      separatorBuilder: (_, _) {
                        return const Divider(color: Colors.white10, height: 1);
                      },
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final bool selected = item.value == value;

                        String label = '';
                        if (item.child is Text) {
                          label = (item.child as Text).data ?? '';
                        }

                        return ListTile(
                          onTap: () => Navigator.pop(context, item.value),
                          leading: Icon(
                            selected
                                ? Icons.check_circle_rounded
                                : Icons.circle_outlined,
                            color: selected ? Colors.orange : Colors.white38,
                          ),
                          title: Text(
                            label,
                            style: TextStyle(
                              color: selected ? Colors.orange : Colors.white,
                              fontSize: 15,
                              fontWeight: selected
                                  ? FontWeight.w900
                                  : FontWeight.w700,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          );
        },
      );

      if (selectedValue != null) {
        onChanged(selectedValue);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: canChange ? openOptionsSheet : null,
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 56,
              padding: const EdgeInsetsDirectional.only(start: 14, end: 12),
              decoration: BoxDecoration(
                color: const Color(
                  0xFF202020,
                ).withValues(alpha: canChange ? 1 : 0.70),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: hasError ? Colors.redAccent : Colors.white12,
                  width: hasError ? 1.3 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: hasError
                        ? Colors.redAccent
                        : canChange
                        ? Colors.orange
                        : Colors.white38,
                    size: 22,
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      selectedLabel ??
                          (isLoading ? 'جاري التحميل...' : hintText),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selectedLabel == null
                            ? Colors.white54
                            : Colors.white,
                        fontSize: 14.5,
                        fontWeight: selectedLabel == null
                            ? FontWeight.w700
                            : FontWeight.w800,
                      ),
                    ),
                  ),

                  if (isLoading)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.orange,
                      ),
                    )
                  else
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: canChange ? Colors.orange : Colors.white38,
                      size: 25,
                    ),
                ],
              ),
            ),
          ),
        ),

        if (hasError) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 4),
            child: Text(
              errorText,
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> signUp() async {
    try {
      final PendingPhoneSignUp pendingSignUp = await controller.signUp();

      if (!mounted) return;

      final AppUser? verifiedUser = await Navigator.push<AppUser>(
        context,
        MaterialPageRoute(
          builder: (_) {
            return PhoneOtpVerificationScreen(pendingSignUp: pendingSignUp);
          },
        ),
      );

      if (verifiedUser == null) {
        return;
      }

      if (!mounted) return;

      Navigator.pop(context, verifiedUser.displayName);
    } catch (_) {
      _shakeController.forward(from: 0);
    }
  }

  void showLegalSheet({
    required String title,
    required String intro,
    required String body,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final double sheetHeight = MediaQuery.of(context).size.height * 0.84;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: SizedBox(
            height: sheetHeight,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF151515),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white24),
              ),
              child: Column(
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    intro,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Container(
                    width: 74,
                    height: 74,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.orange.withValues(alpha: 0.40),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withValues(alpha: 0.18),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.asset(
                        'assets/images/barb_icon.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        body,
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.75,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'آخر تحديث: 12 مايو 2026',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFFFC66D),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                      child: const Text(
                        'فهمت',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

  void openTermsOfUse() {
    showLegalSheet(
      title: 'شروط الاستخدام',
      intro: 'مرحبًا بك في تطبيق Barb.',
      body:
          'باستخدامك للتطبيق أو إنشاء حساب داخله، فإنك توافق على هذه الشروط.\n\n'
          '1. الغرض من التطبيق\n'
          'يوفر تطبيق Barb وسيلة لتنظيم حجوزات الحلاقة بين الزبائن والحلاقين، ومساعدة الحلاق على إدارة مواعيده وخدماته وساعات عمله.\n\n'
          '2. صحة البيانات\n'
          'يجب عليك إدخال بيانات صحيحة عند إنشاء الحساب، مثل الاسم ورقم الهاتف والمنطقة. أنت مسؤول عن دقة البيانات التي تدخلها داخل التطبيق.\n\n'
          '3. الحساب وكلمة المرور\n'
          'أنت مسؤول عن الحفاظ على سرية حسابك وكلمة المرور الخاصة بك. لا يجوز استخدام حساب شخص آخر أو مشاركة الحساب بطريقة قد تسبب ضررًا للآخرين.\n\n'
          '4. الحجوزات\n'
          'يجب استخدام نظام الحجز بشكل جدي ومنظم. يمنع إنشاء حجوزات وهمية أو متكررة بقصد الإزعاج أو تعطيل عمل الحلاق.\n\n'
          '5. صلاحيات الحجز والمنع\n'
          'يحق للحلاق إدارة وصول الزبائن إلى خدماته، بما في ذلك قبول أو رفض طلبات الحجز، أو منع زبون من الحجز عند وجود سبب مناسب متعلق بسوء الاستخدام أو التنظيم.\n\n'
          '6. سلوك المستخدم\n'
          'يمنع استخدام التطبيق بطريقة مسيئة، أو إدخال بيانات مضللة، أو محاولة تعطيل الخدمة، أو استخدام التطبيق لأي غرض غير مشروع.\n\n'
          '7. توفر الخدمة\n'
          'نسعى لتوفير التطبيق بشكل مستقر، لكن قد تحدث انقطاعات أو أخطاء تقنية أو أعمال صيانة. لا نضمن أن الخدمة ستكون متاحة دائمًا بدون توقف.\n\n'
          '8. حدود المسؤولية\n'
          'التطبيق يساعد على تنظيم الحجز، لكنه لا يتحمل مسؤولية جودة الخدمة المقدمة داخل الصالون، أو أي خلاف مباشر بين الزبون والحلاق خارج نطاق النظام التقني للتطبيق.\n\n'
          '9. تعديل الشروط\n'
          'قد يتم تحديث هذه الشروط مستقبلًا عند إضافة ميزات جديدة أو تحسين النظام. استمرارك في استخدام التطبيق بعد التحديث يعني موافقتك على الشروط المعدلة.',
    );
  }

  void openPrivacyPolicy() {
    showLegalSheet(
      title: 'سياسة الخصوصية',
      intro: 'مرحبًا بك في تطبيق Barb.',
      body:
          'نحن نحترم خصوصيتك ونوضح لك هنا كيف يتم التعامل مع بياناتك داخل تطبيق Barb.\n\n'
          '1. البيانات التي نجمعها\n'
          'عند إنشاء حساب أو استخدام التطبيق، قد نجمع بيانات مثل الاسم الأول، اسم العائلة، رقم الهاتف، تاريخ الميلاد، المنطقة، صورة الحساب إن وجدت، وبيانات الحجوزات والخدمات المختارة.\n\n'
          '2. لماذا نستخدم البيانات؟\n'
          'نستخدم هذه البيانات لتشغيل التطبيق، إنشاء الحساب، تأكيد رقم الهاتف، عرض الحلاقين المناسبين حسب المنطقة، إدارة الحجوزات، إرسال الإشعارات، وتمكين الحلاق من تنظيم مواعيده وخدماته.\n\n'
          '3. بيانات الحجز\n'
          'عند إنشاء حجز، يتم حفظ معلومات الموعد مثل الحلاق، الزبون، التاريخ، الوقت، الخدمات المختارة، السعر، والمدة. بعض بيانات الخدمة تحفظ كنسخة ثابتة حتى يبقى الموعد واضحًا حتى لو تغيرت الخدمة لاحقًا.\n\n'
          '4. مشاركة البيانات\n'
          'لا نبيع بياناتك لأي طرف خارجي. يتم عرض البيانات الضرورية فقط بين أطراف الحجز، مثل ظهور اسم الزبون ورقم الهاتف للحلاق عند الحاجة لإدارة الموعد، وظهور بيانات الحلاق للزبون حتى يستطيع الحجز لديه.\n\n'
          '5. تخزين وحماية البيانات\n'
          'يتم تخزين البيانات باستخدام خدمات Supabase. كلمة المرور لا يتم حفظها داخل جداول التطبيق العامة، بل تتم إدارتها من خلال نظام المصادقة الآمن الخاص بالخدمة.\n\n'
          '6. الإشعارات\n'
          'قد يرسل التطبيق إشعارات متعلقة بالحجوزات، طلبات صلاحية الحجز، قبول أو رفض الطلبات، أو تغييرات مهمة داخل النظام.\n\n'
          '7. صلاحيات الوصول\n'
          'قد يستخدم التطبيق بيانات المنطقة لتحديد الحلاقين المتاحين للزبون. كما يمكن للحلاق إدارة صلاحية الحجز لبعض الزبائن حسب نظام التطبيق.\n\n'
          '8. الاحتفاظ بالبيانات\n'
          'نحتفظ بالبيانات ما دامت ضرورية لتشغيل الحساب والحجوزات وتحسين تجربة الاستخدام. قد تبقى بعض سجلات الحجوزات محفوظة للحفاظ على سجل واضح للعمليات السابقة.\n\n'
          '9. حقوق المستخدم\n'
          'يمكنك طلب تعديل بياناتك أو حذف حسابك أو الاستفسار عن بياناتك من خلال إدارة التطبيق عند توفر قناة تواصل رسمية.\n\n'
          '10. تحديث سياسة الخصوصية\n'
          'قد نقوم بتحديث هذه السياسة عند إضافة ميزات جديدة أو تغيير طريقة معالجة البيانات. استمرارك في استخدام التطبيق يعني موافقتك على السياسة المحدثة.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Theme(
            data: Theme.of(context).copyWith(
              textTheme: GoogleFonts.tajawalTextTheme(
                Theme.of(context).textTheme,
              ),
            ),
            child: Scaffold(
              body: Stack(
                children: [
                  const AuthBackground(),
                  SafeArea(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: AnimatedBuilder(
                          animation:
                              _shakeAnimation ??
                              const AlwaysStoppedAnimation(0),
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(_shakeAnimation?.value ?? 0, 0),
                              child: child,
                            );
                          },
                          child: AuthCard(
                            hasError: controller.errorMessage != null,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'إنشاء حساب',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'أدخل بياناتك وأنشئ حسابًا جديدًا',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFFFFC66D),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                AuthErrorMessage(
                                  message: controller.errorMessage,
                                ),
                                const SizedBox(height: 15),

                                buildShakingField(
                                  shouldShake:
                                      controller.firstNameFieldError != null,
                                  child: AuthTextField(
                                    controller: controller.firstNameController,
                                    hintText: 'الاسم الأول',
                                    icon: Icons.person_outline,
                                    errorText: controller.firstNameFieldError,
                                  ),
                                ),

                                const SizedBox(height: 12),

                                buildShakingField(
                                  shouldShake:
                                      controller.lastNameFieldError != null,
                                  child: AuthTextField(
                                    controller: controller.lastNameController,
                                    hintText: 'اسم العائلة',
                                    icon: Icons.badge_outlined,
                                    errorText: controller.lastNameFieldError,
                                  ),
                                ),

                                const SizedBox(height: 12),

                                buildShakingField(
                                  shouldShake:
                                      controller.phoneFieldError != null,
                                  child: AuthTextField(
                                    controller: controller.phoneController,
                                    hintText: 'رقم الهاتف',
                                    icon: Icons.phone,
                                    keyboardType: TextInputType.phone,
                                    errorText: controller.phoneFieldError,
                                    prefixIconWidget: AuthCountryCodeSelector(
                                      selectedCountry:
                                          controller.selectedCountry,
                                      onCountryChanged:
                                          controller.changeCountry,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 14),

                                buildShakingField(
                                  shouldShake:
                                      controller.birthDateFieldError != null,
                                  child: AuthBirthDateSelector(
                                    selectedDate: controller.selectedBirthDate,
                                    errorText: controller.birthDateFieldError,
                                    onDateChanged: controller.changeBirthDate,
                                  ),
                                ),

                                const SizedBox(height: 12),

                                buildShakingField(
                                  shouldShake:
                                      controller.areaFieldError != null,
                                  child: buildLocationDropdown(
                                    hintText: 'اختر المحافظة',
                                    icon: Icons.location_city_rounded,
                                    value: controller.selectedGovernorateId,
                                    isLoading: controller.isLoadingGovernorates,
                                    items: controller.governorates.map((
                                      GovernorateModel governorate,
                                    ) {
                                      return DropdownMenuItem<String>(
                                        value: governorate.id,
                                        child: Text(
                                          governorate.nameAr,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: controller.changeGovernorate,
                                  ),
                                ),

                                const SizedBox(height: 12),

                                buildShakingField(
                                  shouldShake:
                                      controller.areaFieldError != null,
                                  child: buildLocationDropdown(
                                    hintText:
                                        controller.selectedGovernorateId == null
                                        ? 'اختر المحافظة أولًا'
                                        : 'اختر المنطقة',
                                    icon: Icons.place_rounded,
                                    value: controller.selectedAreaId,
                                    errorText: controller.areaFieldError,
                                    isLoading: controller.isLoadingAreas,
                                    isEnabled:
                                        controller.selectedGovernorateId !=
                                        null,
                                    items: controller.areas.map((
                                      AreaModel area,
                                    ) {
                                      return DropdownMenuItem<String>(
                                        value: area.id,
                                        child: Text(
                                          area.nameAr,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: controller.changeArea,
                                  ),
                                ),

                                const SizedBox(height: 12),

                                buildShakingField(
                                  shouldShake:
                                      controller.passwordFieldError != null,
                                  child: AuthTextField(
                                    controller: controller.passwordController,
                                    hintText: 'كلمة المرور',
                                    icon: Icons.lock,
                                    obscureText: !controller.showPassword,
                                    errorText: controller.passwordFieldError,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        controller.showPassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: Colors.white70,
                                      ),
                                      onPressed:
                                          controller.togglePasswordVisibility,
                                    ),
                                  ),
                                ),

                                PasswordStrengthIndicator(
                                  controller: controller.passwordController,
                                ),

                                const SizedBox(height: 12),

                                buildShakingField(
                                  shouldShake:
                                      controller.confirmPasswordFieldError !=
                                      null,
                                  child: AuthTextField(
                                    controller:
                                        controller.confirmPasswordController,
                                    hintText: 'تأكيد كلمة المرور',
                                    icon: Icons.lock_outline,
                                    obscureText:
                                        !controller.showConfirmPassword,
                                    errorText:
                                        controller.confirmPasswordFieldError,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        controller.showConfirmPassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: Colors.white70,
                                      ),
                                      onPressed: controller
                                          .toggleConfirmPasswordVisibility,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 10),

                                AuthLegalAgreementText(
                                  onTermsTap: openTermsOfUse,
                                  onPrivacyTap: openPrivacyPolicy,
                                ),

                                const SizedBox(height: 18),

                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: controller.loading
                                        ? null
                                        : signUp,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                    ),
                                    child: controller.loading
                                        ? const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                width: 18,
                                                height: 18,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2.4,
                                                      color: Colors.black,
                                                    ),
                                              ),
                                              SizedBox(width: 10),
                                              Text(
                                                'جاري الإنشاء...',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          )
                                        : const Text(
                                            'إنشاء حساب',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ),

                                const SizedBox(height: 10),

                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    'هل لديك حساب؟ تسجيل الدخول',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
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
}
