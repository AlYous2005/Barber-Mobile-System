import 'package:flutter/material.dart';

import '../../../models/barber_model.dart';
import '../../../utils/app_theme_colors.dart';
import '../../shared/star_rating_display.dart';
import 'salon_barbers_picker_dialog.dart';

class BarberPublicProfileDialog extends StatelessWidget {
  const BarberPublicProfileDialog({super.key, required this.barber});

  final BarberModel barber;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = barber.barberAvatarUrl?.trim();
    final salonImageUrl = barber.salonImageUrl?.trim();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 430),
            color: AppThemeColors.card(context),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 190,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned.fill(
                          child: salonImageUrl == null || salonImageUrl.isEmpty
                              ? _SalonFallback()
                              : Image.network(
                                  salonImageUrl,
                                  fit: BoxFit.cover,
                                  filterQuality: FilterQuality.high,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _SalonFallback();
                                  },
                                ),
                        ),

                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.18),
                                  Colors.black.withValues(alpha: 0.74),
                                ],
                              ),
                            ),
                          ),
                        ),

                        Positioned(
                          top: 12,
                          left: 12,
                          child: IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.black.withValues(
                                alpha: 0.34,
                              ),
                            ),
                          ),
                        ),

                        // صورة الحلاق + الاسم + اسم الصالون فوق عاليمين
                        Positioned(
                          top: 4,
                          right: 16,
                          left: 76,
                          child: Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.26),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.10),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _LargeAvatar(
                                    avatarUrl: avatarUrl,
                                    barberName: barber.name,
                                  ),

                                  const SizedBox(width: 10),

                                  Flexible(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          barber.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 21,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          barber.shopName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.white.withValues(
                                              alpha: 0.84,
                                            ),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // الشريط الجديد مكان الصورة والاسم القديم
                        if (barber.salonId != null &&
                            barber.salonId!.trim().isNotEmpty)
                          Positioned(
                            right: 65,
                            left: 65,
                            bottom: 16,
                            child: _SalonBarbersStripButton(
                              onTap: () async {
                                final selectedBarber =
                                    await showDialog<BarberModel>(
                                      context: context,
                                      builder: (_) {
                                        return SalonBarbersPickerDialog(
                                          currentBarber: barber,
                                        );
                                      },
                                    );

                                if (selectedBarber == null) {
                                  return;
                                }

                                if (!context.mounted) return;

                                Navigator.of(context).pop(selectedBarber);
                              },
                            ),
                          ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: StarRatingDisplay(
                            rating: barber.rating,
                            ratingCount: 27,
                            satisfactionRate: 96,
                            starSize: 20,
                            enableDetailsPopup: false,
                          ),
                        ),

                        const SizedBox(height: 18),

                        _SectionTitle(
                          icon: Icons.info_outline_rounded,
                          title: 'نبذة قصيرة',
                        ),

                        const SizedBox(height: 8),

                        Text(
                          _displayOrFallback(
                            barber.bio,
                            'لم يضف الحلاق نبذة تعريفية بعد.',
                          ),
                          style: TextStyle(
                            color: AppThemeColors.textSecondary(context),
                            fontSize: 13.5,
                            height: 1.7,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 18),

                        _InfoTile(
                          icon: Icons.storefront_rounded,
                          label: 'اسم الصالون',
                          value: barber.shopName,
                        ),

                        const SizedBox(height: 10),

                        _InfoTile(
                          icon: Icons.location_on_outlined,
                          label: 'العنوان',
                          value: _displayOrFallback(
                            barber.address,
                            'العنوان غير محدد',
                          ),
                        ),

                        const SizedBox(height: 10),

                        _InfoTile(
                          icon: Icons.phone_rounded,
                          label: 'رقم الهاتف',
                          value: _displayOrFallback(
                            barber.phone,
                            'رقم الهاتف غير متوفر',
                          ),
                        ),

                        const SizedBox(height: 18),

                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFC47A3D),
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text(
                              'إغلاق',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _displayOrFallback(String? value, String fallback) {
    final cleaned = value?.trim();

    if (cleaned == null || cleaned.isEmpty) {
      return fallback;
    }

    return cleaned;
  }
}

class _SalonBarbersStripButton extends StatelessWidget {
  const _SalonBarbersStripButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
          ),
          child: const Text(
            'عرض الحلاقين الآخرين في هذا الصالون',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _LargeAvatar extends StatelessWidget {
  const _LargeAvatar({required this.avatarUrl, required this.barberName});

  final String? avatarUrl;
  final String barberName;

  @override
  Widget build(BuildContext context) {
    final imageUrl = avatarUrl?.trim();

    return Container(
      width: 72,
      height: 72,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipOval(
        child: imageUrl == null || imageUrl.isEmpty
            ? _AvatarFallback(barberName: barberName)
            : Image.network(
                imageUrl,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
                errorBuilder: (context, error, stackTrace) {
                  return _AvatarFallback(barberName: barberName);
                },
              ),
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback({required this.barberName});

  final String barberName;

  @override
  Widget build(BuildContext context) {
    final firstLetter = barberName.trim().isEmpty
        ? 'ح'
        : barberName.trim().characters.first;

    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF6E3F2F), Color(0xFFC47A3D)],
        ),
      ),
      child: Center(
        child: Text(
          firstLetter,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _SalonFallback extends StatelessWidget {
  const _SalonFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1D120D),
      child: const Center(
        child: Icon(
          Icons.storefront_rounded,
          color: Color(0x55FFFFFF),
          size: 72,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFC47A3D), size: 19),
        const SizedBox(width: 7),
        Text(
          title,
          style: TextStyle(
            color: AppThemeColors.textPrimary(context),
            fontSize: 15.5,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppThemeColors.softCard(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppThemeColors.border(context)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFC47A3D).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: const Color(0xFFC47A3D), size: 20),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppThemeColors.textMuted(context),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppThemeColors.textPrimary(context),
                    fontSize: 13.5,
                    height: 1.4,
                    fontWeight: FontWeight.w900,
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
