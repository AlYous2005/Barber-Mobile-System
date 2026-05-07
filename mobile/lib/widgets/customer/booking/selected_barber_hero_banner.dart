import 'package:flutter/material.dart';

import '../../../models/barber_model.dart';
import 'barber_public_profile_dialog.dart';

class SelectedBarberHeroBanner extends StatelessWidget {
  const SelectedBarberHeroBanner({
    super.key,
    required this.barber,
    required this.onBarberSelected,
  });

  final BarberModel barber;
  final Future<void> Function(BarberModel barber) onBarberSelected;

  @override
  Widget build(BuildContext context) {
    final imageUrl = barber.salonImageUrl?.trim();
    final Size screenSize = MediaQuery.of(context).size;

    final double bannerHeight = (screenSize.height * 0.18).clamp(135.0, 190.0);
    final double horizontalMargin = screenSize.width < 380 ? 14.0 : 20.0;
    final double borderRadius = screenSize.width < 380 ? 22.0 : 28.0;
    final double titleSize = screenSize.height < 740 ? 25.0 : 31.0;
    final double bottomPadding = screenSize.height < 740 ? 13.0 : 18.0;

    return Container(
      width: double.infinity,
      height: bannerHeight,
      margin: EdgeInsets.fromLTRB(
        horizontalMargin,
        10,
        horizontalMargin,
        screenSize.height < 740 ? 10 : 14,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: const Color(0xFFC47A3D).withValues(alpha: 0.65),
                  width: 1.3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(borderRadius),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: imageUrl == null || imageUrl.isEmpty
                          ? _FallbackSalonBackground(shopName: barber.shopName)
                          : Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.high,
                              errorBuilder: (context, error, stackTrace) {
                                return _FallbackSalonBackground(
                                  shopName: barber.shopName,
                                );
                              },
                            ),
                    ),

                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.black.withValues(alpha: 0.12),
                              Colors.black.withValues(alpha: 0.38),
                              Colors.black.withValues(alpha: 0.70),
                            ],
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified_rounded,
                              color: Color(0xFFC47A3D),
                              size: 15,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'الصالون المختار',
                              style: TextStyle(
                                color: Color(0xFF2A1710),
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Positioned(
                      right: 16,
                      left: 16,
                      bottom: bottomPadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            barber.shopName,
                            textAlign: TextAlign.right,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: titleSize,
                              height: 1.05,
                              fontWeight: FontWeight.w900,
                            ),
                          ),

                          if (screenSize.height >= 700) ...[
                            const SizedBox(height: 6),
                            Text(
                              imageUrl == null || imageUrl.isEmpty
                                  ? 'لم يضف الحلاق صورة صالون بعد'
                                  : 'الصورة الحقيقية للصالون المختار',
                              textAlign: TextAlign.right,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.88),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            top: -10,
            left: -6,
            child: _BarberAvatarCircle(
              avatarUrl: barber.barberAvatarUrl,
              barberName: barber.name,
              onTap: () async {
                final selectedBarber = await showDialog<BarberModel>(
                  context: context,
                  builder: (_) {
                    return BarberPublicProfileDialog(barber: barber);
                  },
                );

                if (selectedBarber == null) {
                  return;
                }

                await onBarberSelected(selectedBarber);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FallbackSalonBackground extends StatelessWidget {
  const _FallbackSalonBackground({required this.shopName});

  final String shopName;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1D120D),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topRight,
                  radius: 1.1,
                  colors: [
                    const Color(0xFFC47A3D).withValues(alpha: 0.35),
                    const Color(0xFF1D120D),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: Icon(
              Icons.storefront_rounded,
              color: Colors.white.withValues(alpha: 0.16),
              size: 86,
            ),
          ),
        ],
      ),
    );
  }
}

class _BarberAvatarCircle extends StatelessWidget {
  const _BarberAvatarCircle({
    required this.avatarUrl,
    required this.barberName,
    required this.onTap,
  });

  final String? avatarUrl;
  final String barberName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final imageUrl = avatarUrl?.trim();

    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Ink(
          width: 54,
          height: 54,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.95),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.22),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipOval(
            child: imageUrl == null || imageUrl.isEmpty
                ? _BarberAvatarFallback(barberName: barberName)
                : Image.network(
                    imageUrl,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                    errorBuilder: (context, error, stackTrace) {
                      return _BarberAvatarFallback(barberName: barberName);
                    },
                  ),
          ),
        ),
      ),
    );
  }
}

class _BarberAvatarFallback extends StatelessWidget {
  const _BarberAvatarFallback({required this.barberName});

  final String barberName;

  @override
  Widget build(BuildContext context) {
    final String firstLetter = barberName.trim().isEmpty
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
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
