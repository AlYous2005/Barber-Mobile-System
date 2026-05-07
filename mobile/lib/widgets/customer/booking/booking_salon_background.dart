import 'package:flutter/material.dart';

class BookingSalonBackground extends StatelessWidget {
  const BookingSalonBackground({
    super.key,
    required this.salonImageUrl,
    required this.enabled,
    required this.child,
  });

  final String? salonImageUrl;
  final bool enabled;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final imageUrl = salonImageUrl?.trim();

    if (!enabled || imageUrl == null || imageUrl.isEmpty) {
      return child;
    }

    return Stack(
      children: [
        Positioned.fill(
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Theme.of(context).scaffoldBackgroundColor,
              );
            },
          ),
        ),

        // طبقة خفيفة فقط حتى لا تخفي الصورة
        Positioned.fill(
          child: Container(color: Colors.black.withValues(alpha: 0.22)),
        ),

        // تدرج بسيط: يخلي أسفل الصفحة مقروء بدون ما يخنق الصورة
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.10),
                  Colors.black.withValues(alpha: 0.22),
                  Colors.black.withValues(alpha: 0.42),
                ],
              ),
            ),
          ),
        ),

        child,
      ],
    );
  }
}
