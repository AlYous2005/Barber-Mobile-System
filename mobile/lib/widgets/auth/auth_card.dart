import 'package:flutter/material.dart';

class AuthCard extends StatelessWidget {
  const AuthCard({
    super.key,
    required this.child,
    this.hasError = false,
    this.showErrorGlow = false,
  });

  final Widget child;
  final bool hasError;
  final bool showErrorGlow;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: hasError ? Colors.redAccent : Colors.white24,
        ),
        boxShadow: showErrorGlow && hasError
            ? [
                BoxShadow(
                  color: Colors.red.withValues(alpha: 0.4),
                  blurRadius: 25,
                ),
              ]
            : [],
      ),
      child: child,
    );
  }
}