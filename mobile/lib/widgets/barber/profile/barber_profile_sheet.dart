import 'package:flutter/material.dart';

import '../../../general_utils/app_theme_colors.dart';
import '../shared/barber_feedback_popup.dart';
import 'profile_action_widgets.dart';
import 'profile_completion_card.dart';
import 'profile_data_section.dart';
import 'profile_image_options_sheet.dart';
import 'profile_sheet_header.dart';
import 'profile_summary_card.dart';
import 'package:image_picker/image_picker.dart';
import '../../../features/locations/locations.dart';

import '../../../features/barber/profile/barber_profile.dart';
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
  late String _initialAreaId;
  late String _initialGovernorateId;

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _whatsappController;
  late final TextEditingController _addressController;
  late final TextEditingController _bioController;

  final ImagePicker _imagePicker = ImagePicker();
  final BarberAvatarRepository _barberAvatarRepository =
      const BarberAvatarRepository();
  final BarberProfileRepository _barberProfileRepository =
      const BarberProfileRepository();

  final LocationRepository _locationRepository = const LocationRepository();

  String? _barberAvatarUrl;
  bool _isUploadingImage = false;
  bool _isLoadingProfile = false;
  bool _isSavingProfile = false;

  bool _isLoadingGovernorates = false;
  bool _isLoadingAreas = false;

  List<GovernorateModel> _governorates = <GovernorateModel>[];
  List<AreaModel> _areas = <AreaModel>[];

  String? _selectedGovernorateId;
  String? _selectedAreaId;

  bool _isEditing = false;
  bool _hasSelectedImage = false;
  String _whatsappCountryCode = '+970';

  @override
  void initState() {
    super.initState();

    _initialName = widget.barberName.trim().isEmpty
        ? 'اسم الحلاق'
        : widget.barberName.trim();

    _initialPhone = '';
    _initialWhatsappCountryCode = '+970';
    _initialWhatsappLocal = '';
    _initialAddress = '';
    _initialBio = '';
    _initialAreaId = '';
    _initialGovernorateId = '';

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
    _loadBarberProfileData();
    _loadGovernorates();
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
        _bioController.text.trim() != _initialBio ||
        (_selectedAreaId ?? '') != _initialAreaId;
  }

  String get _fullWhatsapp {
    final String local = _whatsappController.text.trim();
    if (local.isEmpty) return '';
    return '$_whatsappCountryCode$local';
  }

  bool get _hasCompletedImage {
    return _hasSelectedImage;
  }

  bool get _hasCompletedWhatsapp {
    return _fullWhatsapp.trim().isNotEmpty;
  }

  bool get _hasCompletedLocation {
    return (_selectedAreaId ?? '').trim().isNotEmpty;
  }

  bool get _hasCompletedAddress {
    return _addressController.text.trim().isNotEmpty;
  }

  bool get _hasCompletedBio {
    return _bioController.text.trim().isNotEmpty;
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
      _selectedGovernorateId = _initialGovernorateId.isEmpty
          ? null
          : _initialGovernorateId;
      _selectedAreaId = _initialAreaId.isEmpty ? null : _initialAreaId;
    });

    if (_selectedGovernorateId != null) {
      _loadAreasForGovernorate(_selectedGovernorateId!);
    }
  }

  Future<void> _loadGovernorates() async {
    setState(() {
      _isLoadingGovernorates = true;
    });

    try {
      final loadedGovernorates = await _locationRepository
          .getActiveGovernorates();

      if (!mounted) return;

      setState(() {
        _governorates = loadedGovernorates;
      });
    } catch (error, stackTrace) {
      debugPrint('Load governorates error: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingGovernorates = false;
        });
      }
    }
  }

  Future<void> _loadAreasForGovernorate(String governorateId) async {
    final cleanGovernorateId = governorateId.trim();

    if (cleanGovernorateId.isEmpty) {
      setState(() {
        _areas = <AreaModel>[];
      });
      return;
    }

    setState(() {
      _isLoadingAreas = true;
    });

    try {
      final loadedAreas = await _locationRepository.getActiveAreasByGovernorate(
        governorateId: cleanGovernorateId,
      );

      if (!mounted) return;

      setState(() {
        _areas = loadedAreas;
      });
    } catch (error, stackTrace) {
      debugPrint('Load areas error: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _areas = <AreaModel>[];
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingAreas = false;
        });
      }
    }
  }

  Future<void> _changeGovernorate(String? governorateId) async {
    setState(() {
      _selectedGovernorateId = governorateId;
      _selectedAreaId = null;
      _areas = <AreaModel>[];
    });

    final cleanGovernorateId = governorateId?.trim() ?? '';

    if (cleanGovernorateId.isEmpty) {
      return;
    }

    await _loadAreasForGovernorate(cleanGovernorateId);
  }

  void _changeArea(String? areaId) {
    setState(() {
      _selectedAreaId = areaId;
    });
  }

  Future<void> _saveChanges() async {
    if (!_hasChanges || _isSavingProfile) return;

    final barberId = _currentBarberId;
    if (barberId.isEmpty) {
      if (!mounted) return;
      await showBarberFeedbackPopup(
        context: context,
        title: 'تعذر تحديث البيانات',
        message: 'لا يوجد حساب حلاق مرتبط حاليًا',
        icon: Icons.error_outline_rounded,
        iconStartColor: _accentRedStart,
        iconEndColor: _accentRedEnd,
      );
      return;
    }

    final cleanAreaId = _selectedAreaId?.trim() ?? '';
    if (cleanAreaId.isEmpty) {
      if (!mounted) return;
      await showBarberFeedbackPopup(
        context: context,
        title: 'منطقة الصالون مطلوبة',
        message: 'اختر المحافظة والمنطقة حتى يظهر الصالون للزبائن في منطقتك',
        icon: Icons.location_on_rounded,
        iconStartColor: _accentRedStart,
        iconEndColor: _accentRedEnd,
      );
      return;
    }

    setState(() {
      _isSavingProfile = true;
    });

    try {
      final newName = _nameController.text.trim();
      final newPhone = _phoneController.text.trim();
      final newWhatsappCountry = _whatsappCountryCode;
      final newWhatsappLocal = _whatsappController.text.trim();
      final newWhatsappFull = newWhatsappLocal.isEmpty
          ? ''
          : '$newWhatsappCountry$newWhatsappLocal';
      final newAddress = _addressController.text.trim();
      final newBio = _bioController.text.trim();

      await _barberProfileRepository.updateProfile(
        areaId: cleanAreaId,
        barberId: barberId,
        name: newName,
        phone: newPhone,
        whatsappPhone: newWhatsappFull,
        address: newAddress,
        bio: newBio,
      );

      if (!mounted) return;

      setState(() {
        _initialName = newName;
        _initialPhone = newPhone;
        _initialWhatsappCountryCode = newWhatsappCountry;
        _initialWhatsappLocal = newWhatsappLocal;
        _initialAddress = newAddress;
        _initialBio = newBio;
        _initialAreaId = cleanAreaId;
        _initialGovernorateId = _selectedGovernorateId ?? '';

        _hasSelectedImage = false;
        _isEditing = false;
        _isSavingProfile = false;
      });
      widget.onNameSaved?.call(_initialName);

      await showBarberFeedbackPopup(
        context: context,
        title: 'تم تحديث البيانات',
        message: 'تم تحديث بيانات الحلاق بنجاح',
        icon: Icons.verified_user_rounded,
        iconStartColor: _accentGreenStart,
        iconEndColor: _accentGreenEnd,
      );
    } catch (error, stackTrace) {
      debugPrint('Save barber profile data error: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;
      setState(() {
        _isSavingProfile = false;
      });

      await showBarberFeedbackPopup(
        context: context,
        title: 'فشل تحديث البيانات',
        message: 'حاول مرة أخرى، أو تأكد من اتصال الإنترنت',
        icon: Icons.error_outline_rounded,
        iconStartColor: _accentRedStart,
        iconEndColor: _accentRedEnd,
      );
    }
  }

  String get _currentUserId {
    return AuthSession.currentUser?.username ?? '';
  }

  String get _currentBarberId {
    return AuthSession.currentUser?.barberId ?? '';
  }

  Future<void> _loadBarberProfileData() async {
    final barberId = _currentBarberId;
    if (barberId.isEmpty) {
      return;
    }

    setState(() {
      _isLoadingProfile = true;
    });

    try {
      final profile = await _barberProfileRepository.getProfile(
        barberId: barberId,
      );
      if (!mounted || profile == null) {
        return;
      }

      final whatsappParts = _splitWhatsapp(profile.whatsappPhone);

      setState(() {
        _initialName = profile.name.isEmpty ? _initialName : profile.name;
        _initialPhone = profile.phone;
        _initialWhatsappCountryCode = whatsappParts.countryCode;
        _initialWhatsappLocal = whatsappParts.localNumber;
        _initialAddress = profile.address;
        _initialBio = profile.bio;

        _initialAreaId = profile.areaId;
        _initialGovernorateId = profile.governorateId;

        _selectedAreaId = profile.areaId.isEmpty ? null : profile.areaId;
        _selectedGovernorateId = profile.governorateId.isEmpty
            ? null
            : profile.governorateId;

        _whatsappCountryCode = _initialWhatsappCountryCode;

        _nameController.text = _initialName;
        _phoneController.text = _initialPhone;
        _whatsappController.text = _initialWhatsappLocal;
        _addressController.text = _initialAddress;
        _bioController.text = _initialBio;
      });
      if (profile.governorateId.isNotEmpty) {
        await _loadAreasForGovernorate(profile.governorateId);
      }
    } catch (error, stackTrace) {
      debugPrint('Load barber profile data error: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    }
  }

  ({String countryCode, String localNumber}) _splitWhatsapp(String rawPhone) {
    final cleaned = rawPhone.trim();

    if (cleaned.isEmpty) {
      return (countryCode: '+970', localNumber: '');
    }

    if (cleaned.startsWith('+970')) {
      return (countryCode: '+970', localNumber: cleaned.substring(4));
    }

    if (cleaned.startsWith('970')) {
      return (countryCode: '+970', localNumber: cleaned.substring(3));
    }

    if (cleaned.startsWith('0')) {
      return (countryCode: '+970', localNumber: cleaned.substring(1));
    }

    return (countryCode: '+970', localNumber: cleaned);
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

                      if (_isLoadingProfile) ...[
                        const Padding(
                          padding: EdgeInsets.only(bottom: 14),
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.4),
                          ),
                        ),
                      ],

                      ProfileCompletionCard(
                        hasImage: _hasCompletedImage,
                        hasWhatsapp: _hasCompletedWhatsapp,
                        hasLocation: _hasCompletedLocation,
                        hasAddress: _hasCompletedAddress,
                        hasBio: _hasCompletedBio,
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
                        governorates: _governorates,
                        areas: _areas,
                        selectedGovernorateId: _selectedGovernorateId,
                        selectedAreaId: _selectedAreaId,
                        isLoadingGovernorates: _isLoadingGovernorates,
                        isLoadingAreas: _isLoadingAreas,
                        onGovernorateChanged: _changeGovernorate,
                        onAreaChanged: _changeArea,
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
                          canSave: _hasChanges && !_isSavingProfile,
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
