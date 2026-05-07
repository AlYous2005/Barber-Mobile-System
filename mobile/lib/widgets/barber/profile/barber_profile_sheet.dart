import 'package:flutter/material.dart';

import '../../../utils/app_theme_colors.dart';
import '../shared/barber_feedback_popup.dart';
import 'profile_action_widgets.dart';
import 'profile_completion_card.dart';
import 'profile_data_section.dart';
import 'profile_image_options_sheet.dart';
import 'profile_sheet_header.dart';
import 'profile_summary_card.dart';
import 'package:image_picker/image_picker.dart';

import '../../../repositories/barber_avatar_repository.dart';
import '../../../services/auth_session.dart';

Future<void> showBarberProfileSheet({
  required BuildContext context,
  required String barberName,
  ValueChanged<String>? onNameSaved,
}) {
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) {
      return BarberProfileSheet(
        barberName: barberName,
        onNameSaved: onNameSaved,
      );
    },
  );
}

class BarberProfileSheet extends StatefulWidget {
  const BarberProfileSheet({
    super.key,
    required this.barberName,
    this.onNameSaved,
  });

  final String barberName;
  final ValueChanged<String>? onNameSaved;

  @override
  State<BarberProfileSheet> createState() => _BarberProfileSheetState();
}

class _BarberProfileSheetState extends State<BarberProfileSheet> {
  static const Color _accentGreenStart = Color(0xFF16A34A);
  static const Color _accentGreenEnd = Color(0xFF86EFAC);
  static const Color _accentRedStart = Color(0xFFDC2626);
  static const Color _accentRedEnd = Color(0xFFF87171);

  late String _initialName;
  late String _initialPhone;
  late String _initialWhatsappCountryCode;
  late String _initialWhatsappLocal;
  late String _initialAddress;
  late String _initialBio;

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _whatsappController;
  late final TextEditingController _addressController;
  late final TextEditingController _bioController;

  final ImagePicker _imagePicker = ImagePicker();
  final BarberAvatarRepository _barberAvatarRepository =
      const BarberAvatarRepository();

  String? _barberAvatarUrl;
  bool _isUploadingImage = false;

  bool _isEditing = false;
  bool _hasSelectedImage = false;
  String _whatsappCountryCode = '+970';

  @override
  void initState() {
    super.initState();

    _initialName = widget.barberName.trim().isEmpty
        ? 'اسم الحلاق'
        : widget.barberName.trim();

    _initialPhone = '0590000000';
    _initialWhatsappCountryCode = '+970';
    _initialWhatsappLocal = '590000000';
    _initialAddress = 'نابلس - فلسطين';
    _initialBio =
        'حلاق متخصص في القصات العصرية واللحية والعناية الكاملة بالمظهر.';

    _whatsappCountryCode = _initialWhatsappCountryCode;

    _nameController = TextEditingController(text: _initialName);
    _phoneController = TextEditingController(text: _initialPhone);
    _whatsappController = TextEditingController(text: _initialWhatsappLocal);
    _addressController = TextEditingController(text: _initialAddress);
    _bioController = TextEditingController(text: _initialBio);

    _nameController.addListener(_refresh);
    _phoneController.addListener(_refresh);
    _whatsappController.addListener(_refresh);
    _addressController.addListener(_refresh);
    _bioController.addListener(_refresh);
    _loadBarberAvatar();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _addressController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  bool get _hasChanges {
    return _hasSelectedImage ||
        _nameController.text.trim() != _initialName ||
        _phoneController.text.trim() != _initialPhone ||
        _whatsappCountryCode != _initialWhatsappCountryCode ||
        _whatsappController.text.trim() != _initialWhatsappLocal ||
        _addressController.text.trim() != _initialAddress ||
        _bioController.text.trim() != _initialBio;
  }

  String get _fullWhatsapp {
    final String local = _whatsappController.text.trim();
    if (local.isEmpty) return '';
    return '$_whatsappCountryCode$local';
  }

  int get _completedItemsCount {
    int count = 0;

    if (_hasSelectedImage) count++;
    if (_fullWhatsapp.isNotEmpty) count++;
    if (_bioController.text.trim().isNotEmpty) count++;
    if (_addressController.text.trim().isNotEmpty) count++;

    return count;
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
    });
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _hasSelectedImage = false;

      _nameController.text = _initialName;
      _phoneController.text = _initialPhone;
      _whatsappCountryCode = _initialWhatsappCountryCode;
      _whatsappController.text = _initialWhatsappLocal;
      _addressController.text = _initialAddress;
      _bioController.text = _initialBio;
    });
  }

  void _saveChanges() {
    if (!_hasChanges) return;

    setState(() {
      _initialName = _nameController.text.trim();
      widget.onNameSaved?.call(_initialName);
      _initialPhone = _phoneController.text.trim();
      _initialWhatsappCountryCode = _whatsappCountryCode;
      _initialWhatsappLocal = _whatsappController.text.trim();
      _initialAddress = _addressController.text.trim();
      _initialBio = _bioController.text.trim();

      _hasSelectedImage = false;
      _isEditing = false;
    });

    if (!mounted) return;
    showBarberFeedbackPopup(
      context: context,
      title: 'تم تحديث البيانات',
      message: 'تم تحديث بيانات الحلاق بنجاح',
      icon: Icons.verified_user_rounded,
      iconStartColor: _accentGreenStart,
      iconEndColor: _accentGreenEnd,
    );
  }

  String get _currentUserId {
    return AuthSession.currentUser?.username ?? '';
  }

  Future<void> _loadBarberAvatar() async {
    final userId = _currentUserId;

    if (userId.isEmpty) {
      return;
    }

    try {
      final avatarUrl = await _barberAvatarRepository.getBarberAvatarUrl(
        userId: userId,
      );

      if (!mounted) return;

      setState(() {
        _barberAvatarUrl = avatarUrl;
        _hasSelectedImage = avatarUrl != null && avatarUrl.trim().isNotEmpty;
      });
    } catch (error) {
      debugPrint('Load barber avatar error: $error');
    }
  }

  Future<void> _pickBarberAvatarImage() async {
    Navigator.of(context).pop();

    final userId = _currentUserId;

    if (userId.isEmpty) {
      if (!mounted) return;

      showBarberFeedbackPopup(
        context: context,
        title: 'تعذر تحديث الصورة',
        message: 'لا يوجد مستخدم مسجل حاليًا',
        icon: Icons.error_outline_rounded,
        iconStartColor: _accentRedStart,
        iconEndColor: _accentRedEnd,
      );
      return;
    }

    try {
      await Future<void>.delayed(const Duration(milliseconds: 250));

      final selectedImage = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 95,
      );

      if (selectedImage == null) {
        return;
      }

      final imageBytes = await selectedImage.readAsBytes();

      if (!mounted) return;

      setState(() {
        _isUploadingImage = true;
      });

      final avatarUrl = await _barberAvatarRepository.uploadBarberAvatar(
        userId: userId,
        imageBytes: imageBytes,
        originalFileName: selectedImage.name,
      );

      if (!mounted) return;

      setState(() {
        _barberAvatarUrl = avatarUrl;
        _hasSelectedImage = true;
        _isUploadingImage = false;
      });

      showBarberFeedbackPopup(
        context: context,
        title: 'تم تحديث الصورة',
        message: 'تم تحديث صورة الحلاق الشخصية بنجاح',
        icon: Icons.add_a_photo_rounded,
        iconStartColor: _accentGreenStart,
        iconEndColor: _accentGreenEnd,
      );
    } catch (error) {
      debugPrint('Pick/upload barber avatar error: $error');

      if (!mounted) return;

      setState(() {
        _isUploadingImage = false;
      });

      showBarberFeedbackPopup(
        context: context,
        title: 'فشل تحديث الصورة',
        message: 'حاول مرة أخرى، أو تأكد من اتصال الإنترنت',
        icon: Icons.error_outline_rounded,
        iconStartColor: _accentRedStart,
        iconEndColor: _accentRedEnd,
      );
    }
  }

  Future<void> _removeBarberAvatarImage() async {
    Navigator.of(context).pop();

    final userId = _currentUserId;
    final bool hadImage =
        _barberAvatarUrl != null && _barberAvatarUrl!.trim().isNotEmpty;

    if (userId.isEmpty || !hadImage) {
      return;
    }

    try {
      setState(() {
        _isUploadingImage = true;
      });

      await _barberAvatarRepository.removeBarberAvatar(userId: userId);

      if (!mounted) return;

      setState(() {
        _barberAvatarUrl = null;
        _hasSelectedImage = false;
        _isUploadingImage = false;
      });

      showBarberFeedbackPopup(
        context: context,
        title: 'تمت إزالة الصورة',
        message: 'تمت إزالة الصورة الشخصية بنجاح',
        icon: Icons.delete_outline_rounded,
        iconStartColor: _accentRedStart,
        iconEndColor: _accentRedEnd,
      );
    } catch (error) {
      debugPrint('Remove barber avatar error: $error');

      if (!mounted) return;

      setState(() {
        _isUploadingImage = false;
      });

      showBarberFeedbackPopup(
        context: context,
        title: 'فشل حذف الصورة',
        message: 'حاول مرة أخرى، أو تأكد من اتصال الإنترنت',
        icon: Icons.error_outline_rounded,
        iconStartColor: _accentRedStart,
        iconEndColor: _accentRedEnd,
      );
    }
  }

  void _showImageUploadOptions() {
    if (_isUploadingImage) {
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return ProfileImageOptionsSheet(
          onPickImage: _pickBarberAvatarImage,
          onRemoveImage: _removeBarberAvatarImage,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: FractionallySizedBox(
        heightFactor: 0.92,
        child: Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppThemeColors.card(context),
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 30,
                offset: Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            children: [
              ProfileSheetHeader(onClose: () => Navigator.of(context).pop()),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                  child: Column(
                    children: [
                      ProfileSummaryCard(
                        barberName: _nameController.text.trim().isEmpty
                            ? 'اسم الحلاق'
                            : _nameController.text.trim(),
                        hasSelectedImage: _hasSelectedImage,
                        avatarUrl: _barberAvatarUrl,
                        isUploadingImage: _isUploadingImage,
                        onImageTap: _showImageUploadOptions,
                      ),

                      const SizedBox(height: 14),

                      ProfileCompletionCard(
                        completedItemsCount: _completedItemsCount,
                      ),

                      const SizedBox(height: 14),

                      ProfileDataSection(
                        isEditing: _isEditing,
                        onEditTap: _startEditing,
                        nameController: _nameController,
                        phoneController: _phoneController,
                        whatsappController: _whatsappController,
                        addressController: _addressController,
                        bioController: _bioController,
                        whatsappCountryCode: _whatsappCountryCode,
                        onWhatsappCountryChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            _whatsappCountryCode = value;
                          });
                        },
                        fullWhatsapp: _fullWhatsapp,
                      ),

                      if (_isEditing) ...[
                        const SizedBox(height: 14),
                        EditActionsBar(
                          canSave: _hasChanges,
                          onSave: _saveChanges,
                          onCancel: _cancelEditing,
                        ),
                      ],
                    ],
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
