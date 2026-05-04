import 'package:flutter/material.dart';

void showBarberProfileSheet({
  required BuildContext context,
  required String barberName,
  ValueChanged<String>? onNameSaved,
}) {
  showModalBottomSheet(
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

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('تم حفظ التعديلات مؤقتًا')));
  }

  void _showImageUploadOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 24,
                  offset: Offset(0, 12),
                ),
              ],
            ),
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

                const Text(
                  'تغيير صورة الحلاق',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111827),
                  ),
                ),

                const SizedBox(height: 14),

                _SheetActionButton(
                  label: 'اختيار صورة من الجهاز',
                  icon: Icons.image_rounded,
                  color: const Color(0xFFC47A3D),
                  onTap: () {
                    Navigator.of(context).pop();

                    setState(() {
                      _hasSelectedImage = true;
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('رفع الصورة الحقيقي سنفعّله لاحقًا'),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 10),

                _SheetActionButton(
                  label: 'إزالة الصورة الحالية',
                  icon: Icons.delete_outline_rounded,
                  color: const Color(0xFFEF4444),
                  onTap: () {
                    Navigator.of(context).pop();

                    setState(() {
                      _hasSelectedImage = true;
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'إزالة الصورة ستُربط لاحقًا بالبيانات الحقيقية',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
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
            color: Colors.white,
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
              _FixedHeader(onClose: () => Navigator.of(context).pop()),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                  child: Column(
                    children: [
                      _ProfileSummaryCard(
                        barberName: _nameController.text.trim().isEmpty
                            ? 'اسم الحلاق'
                            : _nameController.text.trim(),
                        hasSelectedImage: _hasSelectedImage,
                        onImageTap: _showImageUploadOptions,
                      ),

                      const SizedBox(height: 14),

                      _ProfileCompletionCard(
                        completedItemsCount: _completedItemsCount,
                      ),

                      const SizedBox(height: 14),

                      _ProfileDataSection(
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
                        _EditActionsBar(
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

class _FixedHeader extends StatelessWidget {
  const _FixedHeader({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFFB8774A), Color(0xFF8A4E2E)],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(999),
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Material(
                color: Colors.white.withValues(alpha: 0.13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: InkWell(
                  onTap: onClose,
                  borderRadius: BorderRadius.circular(15),
                  child: const SizedBox(
                    width: 42,
                    height: 42,
                    child: Icon(Icons.close_rounded, color: Colors.white),
                  ),
                ),
              ),

              const Expanded(
                child: Column(
                  children: [
                    Text(
                      'Barber Profile',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'الملف الشخصي وبيانات التواصل',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFEFE7DE),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 42),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileSummaryCard extends StatelessWidget {
  const _ProfileSummaryCard({
    required this.barberName,
    required this.hasSelectedImage,
    required this.onImageTap,
  });

  final String barberName;
  final bool hasSelectedImage;
  final VoidCallback onImageTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFFFFFBF2), Color(0xFFFFF7E6), Colors.white],
        ),
        border: Border.all(color: const Color(0xFFE8D8B8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12C47A3D),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: onImageTap,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [Color(0xFFC47A3D), Color(0xFFF6D38B)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFC47A3D).withValues(alpha: 0.25),
                        blurRadius: 22,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    backgroundColor: const Color(0xFFF8FAFC),
                    child: Icon(
                      hasSelectedImage
                          ? Icons.image_rounded
                          : Icons.content_cut_rounded,
                      size: 38,
                      color: const Color(0xFFC47A3D),
                    ),
                  ),
                ),

                Positioned(
                  right: -2,
                  bottom: 5,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF111827),
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFC47A3D).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: const Color(0xFFC47A3D).withValues(alpha: 0.20),
              ),
            ),
            child: const Text(
              'الملف الشخصي المهني',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w900,
                color: Color(0xFF8A4E2E),
              ),
            ),
          ),

          const SizedBox(height: 10),

          Text(
            barberName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF2F1F17),
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'اضغط على الصورة لتغيير صورة الحلاق',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCompletionCard extends StatelessWidget {
  const _ProfileCompletionCard({required this.completedItemsCount});

  final int completedItemsCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'حالة اكتمال الملف الشخصي',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFC47A3D).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$completedItemsCount / 4',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF8A4E2E),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _CompletionChip(
                  label: 'الصورة',
                  isDone: completedItemsCount >= 1,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: _CompletionChip(label: 'الواتساب', isDone: true),
              ),
            ],
          ),

          const SizedBox(height: 8),

          const Row(
            children: [
              Expanded(child: _CompletionChip(label: 'النبذة', isDone: true)),
              SizedBox(width: 8),
              Expanded(child: _CompletionChip(label: 'العنوان', isDone: true)),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompletionChip extends StatelessWidget {
  const _CompletionChip({required this.label, required this.isDone});

  final String label;
  final bool isDone;

  @override
  Widget build(BuildContext context) {
    final Color color = isDone
        ? const Color(0xFF16A34A)
        : const Color(0xFF94A3B8);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileDataSection extends StatelessWidget {
  const _ProfileDataSection({
    required this.isEditing,
    required this.onEditTap,
    required this.nameController,
    required this.phoneController,
    required this.whatsappController,
    required this.addressController,
    required this.bioController,
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
  final String whatsappCountryCode;
  final ValueChanged<String?> onWhatsappCountryChanged;
  final String fullWhatsapp;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5E7EB)),
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
              const Expanded(
                child: Text(
                  'البيانات الحالية',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111827),
                  ),
                ),
              ),

              if (!isEditing) _SmallEditButton(onTap: onEditTap),
            ],
          ),

          const SizedBox(height: 12),

          if (!isEditing) ...[
            _ProfileInfoTile(
              icon: Icons.badge_rounded,
              title: 'اسم الحلاق',
              value: nameController.text.trim().isEmpty
                  ? 'لم يتم إدخال اسم الحلاق'
                  : nameController.text.trim(),
            ),
            _ProfileInfoTile(
              icon: Icons.phone_rounded,
              title: 'رقم الهاتف',
              value: phoneController.text.trim().isEmpty
                  ? 'لم يتم إدخال رقم الهاتف'
                  : phoneController.text.trim(),
            ),
            _ProfileInfoTile(
              icon: Icons.chat_rounded,
              title: 'رقم الواتساب',
              value: fullWhatsapp.isEmpty
                  ? 'لم يتم إدخال رقم الواتساب'
                  : fullWhatsapp,
            ),
            _ProfileInfoTile(
              icon: Icons.location_on_rounded,
              title: 'العنوان',
              value: addressController.text.trim().isEmpty
                  ? 'لم يتم إدخال العنوان'
                  : addressController.text.trim(),
            ),
            _ProfileInfoTile(
              icon: Icons.description_rounded,
              title: 'نبذة قصيرة',
              value: bioController.text.trim().isEmpty
                  ? 'لا توجد نبذة بعد'
                  : bioController.text.trim(),
            ),
          ] else ...[
            _ProfileTextField(
              label: 'اسم الحلاق',
              controller: nameController,
              icon: Icons.badge_rounded,
            ),
            const SizedBox(height: 12),
            _ProfileTextField(
              label: 'رقم الهاتف',
              controller: phoneController,
              icon: Icons.phone_rounded,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            _WhatsappField(
              countryCode: whatsappCountryCode,
              onCountryChanged: onWhatsappCountryChanged,
              controller: whatsappController,
            ),
            const SizedBox(height: 12),
            _ProfileTextField(
              label: 'العنوان',
              controller: addressController,
              icon: Icons.location_on_rounded,
            ),
            const SizedBox(height: 12),
            _ProfileTextField(
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

class _SmallEditButton extends StatelessWidget {
  const _SmallEditButton({required this.onTap});

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

class _ProfileInfoTile extends StatelessWidget {
  const _ProfileInfoTile({
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
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
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
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
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

class _ProfileTextField extends StatelessWidget {
  const _ProfileTextField({
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
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFC47A3D), width: 1.4),
        ),
      ),
    );
  }
}

class _WhatsappField extends StatelessWidget {
  const _WhatsappField({
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
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
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
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 13,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
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

class _EditActionsBar extends StatelessWidget {
  const _EditActionsBar({
    required this.canSave,
    required this.onSave,
    required this.onCancel,
  });

  final bool canSave;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: canSave ? onSave : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC47A3D),
              disabledBackgroundColor: const Color(0xFFE5E7EB),
              foregroundColor: Colors.white,
              disabledForegroundColor: const Color(0xFF9CA3AF),
              elevation: canSave ? 2 : 0,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'حفظ التعديلات',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
            ),
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: OutlinedButton(
            onPressed: onCancel,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF111827),
              side: const BorderSide(color: Color(0xFFE5E7EB)),
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'إلغاء',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ],
    );
  }
}

class _SheetActionButton extends StatelessWidget {
  const _SheetActionButton({
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
      color: color.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withValues(alpha: 0.22)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: color,
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
