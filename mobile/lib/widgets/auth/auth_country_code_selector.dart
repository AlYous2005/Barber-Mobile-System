import 'package:flutter/material.dart';

class AuthCountryCodeSelector extends StatelessWidget {
  const AuthCountryCodeSelector({
    super.key,
    required this.selectedCountry,
    required this.onCountryChanged,
  });

  final String selectedCountry;
  final ValueChanged<String> onCountryChanged;

  String get _code {
    return selectedCountry == "فلسطين" ? "+970" : "+972";
  }

  void _openCountrySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            tween: Tween(begin: 0.94, end: 1),
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                alignment: Alignment.bottomCenter,
                child: child,
              );
            },
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF151515),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 28,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    "اختر رمز الدولة",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    "سيتم استخدام هذا الرمز مع رقم الهاتف",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 16),

                  _CountryOptionTile(
                    country: "فلسطين",
                    code: "+970",
                    isSelected: selectedCountry == "فلسطين",
                    onTap: () {
                      onCountryChanged("فلسطين");
                      Navigator.pop(context);
                    },
                  ),

                  const SizedBox(height: 10),

                  _CountryOptionTile(
                    country: "إسرائيل",
                    code: "+972",
                    isSelected: selectedCountry == "إسرائيل",
                    onTap: () {
                      onCountryChanged("إسرائيل");
                      Navigator.pop(context);
                    },
                  ),

                  const SizedBox(height: 6),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _openCountrySheet(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 132,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.phone, color: Colors.orange, size: 18),

            const SizedBox(width: 4),

            _CountryFlag(country: selectedCountry, width: 24, height: 16),

            const SizedBox(width: 4),

            Text(
              _code,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 13,
              ),
            ),

            const SizedBox(width: 4),

            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.orange,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _CountryOptionTile extends StatelessWidget {
  const _CountryOptionTile({
    required this.country,
    required this.code,
    required this.isSelected,
    required this.onTap,
  });

  final String country;
  final String code;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: isSelected
            ? Colors.orange.withValues(alpha: 0.18)
            : Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isSelected ? Colors.orange : Colors.white24),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              _CountryFlag(country: country, width: 38, height: 24),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  country,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              Text(
                code,
                style: const TextStyle(
                  color: Color(0xFFFFC66D),
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(width: 10),

              AnimatedOpacity(
                duration: const Duration(milliseconds: 160),
                opacity: isSelected ? 1 : 0,
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.orange,
                  size: 21,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountryFlag extends StatelessWidget {
  const _CountryFlag({
    required this.country,
    this.width = 24,
    this.height = 16,
  });

  final String country;
  final double width;
  final double height;

  String get _assetPath {
    return country == 'فلسطين'
        ? 'assets/flags/palestine.png'
        : 'assets/flags/israel.png';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
          width: 0.7,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        _assetPath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.white.withValues(alpha: 0.08),
            child: Center(
              child: Text(
                country == 'فلسطين' ? 'PS' : 'IL',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
