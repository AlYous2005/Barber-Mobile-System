import 'dart:async';
import 'package:flutter/material.dart';

import '../../widgets/auth/auth_background.dart';
import '../../widgets/auth/auth_card.dart';
import '../home/home_screen.dart';

class AuthTransitionScreen extends StatefulWidget {
  const AuthTransitionScreen({
    super.key,
    required this.userName,
    required this.role,
  });

  final String userName;
  final String role;

  @override
  State<AuthTransitionScreen> createState() => _AuthTransitionScreenState();
}

class _AuthTransitionScreenState extends State<AuthTransitionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  Timer? _statusTimer;
  int statusIndex = 0;

  final List<String> statusMessages = const [
    "جارٍ تحميل المواعيد...",
    "جارٍ تجهيز الخدمات...",
    "جارٍ مزامنة ساعات العمل...",
    "جارٍ تطبيق الإعدادات...",
  ];

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _progressAnimation = Tween<double>(begin: 0.04, end: 0.92).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
    );

    _progressController.forward();

    _statusTimer = Timer.periodic(const Duration(milliseconds: 700), (timer) {
      if (!mounted) return;

      setState(() {
        statusIndex = (statusIndex + 1) % statusMessages.length;
      });
    });

    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 650),
          pageBuilder: (context, animation, secondaryAnimation) {
            return HomeScreen(userName: widget.userName, role: widget.role);
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _progressController.dispose();
    super.dispose();
  }

  String get roleText {
    if (widget.role == "barber") {
      return "لوحة الحلاق";
    }

    return "حساب الزبون";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const AuthBackground(),

          Center(
            child: AuthCard(
              hasError: false,
              showErrorGlow: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Barb",
                    textDirection: TextDirection.ltr,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    "أهلاً بعودتك",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    widget.userName.trim().isEmpty
                        ? roleText
                        : widget.userName.trim(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "يتم الآن تجهيز لوحة التحكم الخاصة بك",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      statusMessages[statusIndex],
                      key: ValueKey(statusIndex),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 14,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  SizedBox(
                    width: 82,
                    height: 82,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 82,
                          height: 82,
                          child: CircularProgressIndicator(
                            strokeWidth: 4,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.orange,
                            ),
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.08,
                            ),
                          ),
                        ),
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.06),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: const Icon(
                            Icons.content_cut,
                            color: Colors.orange,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: _progressAnimation.value,
                          minHeight: 8,
                          backgroundColor: Colors.white.withValues(alpha: 0.08),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.orange,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 14),

                  const Text(
                    "لحظات قليلة ونبدأ",
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
