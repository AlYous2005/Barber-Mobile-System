import 'package:flutter/material.dart';

import '../../../models/barber_model.dart';
import '../../../repositories/barber_repository.dart';
import '../../../utils/app_theme_colors.dart';
import '../../shared/star_rating_display.dart';

class SalonBarbersPickerDialog extends StatefulWidget {
  const SalonBarbersPickerDialog({
    super.key,
    required this.currentBarber,
    BarberRepository? barberRepository,
  }) : _barberRepository = barberRepository ?? const BarberRepository();

  final BarberModel currentBarber;
  final BarberRepository _barberRepository;

  @override
  State<SalonBarbersPickerDialog> createState() =>
      _SalonBarbersPickerDialogState();
}

class _SalonBarbersPickerDialogState extends State<SalonBarbersPickerDialog> {
  bool isLoading = true;
  String? errorMessage;

  List<BarberModel> salonBarbers = [];
  BarberModel? selectedBarber;

  @override
  void initState() {
    super.initState();
    selectedBarber = widget.currentBarber;
    _loadSalonBarbers();
  }

  Future<void> _loadSalonBarbers() async {
    final salonId = widget.currentBarber.salonId?.trim();

    if (salonId == null || salonId.isEmpty) {
      setState(() {
        salonBarbers = [widget.currentBarber];
        isLoading = false;
      });
      return;
    }

    try {
      final loaded = await widget._barberRepository.getBarbersBySalonId(
        salonId: salonId,
      );

      if (!mounted) return;

      setState(() {
        salonBarbers = loaded.isEmpty ? [widget.currentBarber] : loaded;
        selectedBarber = salonBarbers.firstWhere(
          (barber) => barber.id == widget.currentBarber.id,
          orElse: () => widget.currentBarber,
        );
        isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'تعذر تحميل حلاقين الصالون';
        salonBarbers = [widget.currentBarber];
        isLoading = false;
      });
    }
  }

  void _confirmSelection() {
    final barber = selectedBarber;

    if (barber == null) {
      return;
    }

    Navigator.of(context).pop(barber);
  }

  @override
  Widget build(BuildContext context) {
    final salonImageUrl = widget.currentBarber.salonImageUrl?.trim();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 440, maxHeight: 680),
            color: AppThemeColors.card(context),
            child: Column(
              children: [
                SizedBox(
                  height: 145,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: salonImageUrl == null || salonImageUrl.isEmpty
                            ? const _SalonFallbackHeader()
                            : Image.network(
                                salonImageUrl,
                                fit: BoxFit.cover,
                                filterQuality: FilterQuality.high,
                                errorBuilder: (context, error, stackTrace) {
                                  return const _SalonFallbackHeader();
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
                                Colors.black.withValues(alpha: 0.20),
                                Colors.black.withValues(alpha: 0.72),
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

                      Positioned(
                        right: 18,
                        left: 18,
                        bottom: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'حلاقو الصالون',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.currentBarber.shopName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.86),
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: _buildBody(context),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(17),
                            ),
                          ),
                          child: const Text(
                            'إلغاء',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: FilledButton(
                          onPressed: selectedBarber == null
                              ? null
                              : _confirmSelection,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFC47A3D),
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(17),
                            ),
                          ),
                          child: const Text(
                            'تأكيد الاختيار',
                            style: TextStyle(fontWeight: FontWeight.w900),
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
    );
  }

  Widget _buildBody(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Text(
          errorMessage!,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.error,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }

    if (salonBarbers.isEmpty) {
      return const Center(
        child: Text(
          'لا يوجد حلاقون متاحون في هذا الصالون حاليًا',
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.separated(
      itemCount: salonBarbers.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final barber = salonBarbers[index];

        return _SalonBarberCard(
          barber: barber,
          isCurrentBarber: barber.id == widget.currentBarber.id,
          isSelected: barber.id == selectedBarber?.id,
          onTap: () {
            setState(() {
              selectedBarber = barber;
            });
          },
        );
      },
    );
  }
}

class _SalonBarberCard extends StatelessWidget {
  const _SalonBarberCard({
    required this.barber,
    required this.isCurrentBarber,
    required this.isSelected,
    required this.onTap,
  });

  final BarberModel barber;
  final bool isCurrentBarber;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = barber.barberAvatarUrl?.trim();

    return Material(
      color: isSelected
          ? const Color(0xFFC47A3D).withValues(alpha: 0.12)
          : AppThemeColors.softCard(context),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFC47A3D)
                  : AppThemeColors.border(context),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: const Color(0xFFC47A3D).withValues(alpha: 0.35),
                  ),
                ),
                child: ClipOval(
                  child: avatarUrl == null || avatarUrl.isEmpty
                      ? _AvatarFallback(barberName: barber.name)
                      : Image.network(
                          avatarUrl,
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.high,
                          errorBuilder: (context, error, stackTrace) {
                            return _AvatarFallback(barberName: barber.name);
                          },
                        ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            barber.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppThemeColors.textPrimary(context),
                              fontSize: 15.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),

                        if (isCurrentBarber)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFC47A3D,
                              ).withValues(alpha: 0.13),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              'المختار حاليًا',
                              style: TextStyle(
                                color: Color(0xFFC47A3D),
                                fontSize: 10.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    StarRatingDisplay(
                      rating: barber.rating,
                      ratingCount: 27,
                      satisfactionRate: 96,
                      starSize: 14,
                      enableDetailsPopup: false,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Icon(
                isSelected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: isSelected
                    ? const Color(0xFFC47A3D)
                    : AppThemeColors.textMuted(context),
                size: 24,
              ),
            ],
          ),
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
            fontSize: 21,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _SalonFallbackHeader extends StatelessWidget {
  const _SalonFallbackHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1D120D),
      child: const Center(
        child: Icon(
          Icons.storefront_rounded,
          color: Color(0x55FFFFFF),
          size: 70,
        ),
      ),
    );
  }
}
