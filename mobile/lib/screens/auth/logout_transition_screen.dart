import 'dart:async';
import 'package:flutter/material.dart';

import '../../widgets/auth/auth_background.dart';
import 'login_screen.dart';

class LogoutTransitionScreen extends StatefulWidget {
  const LogoutTransitionScreen({super.key});

  @override
  State<LogoutTransitionScreen> createState() => _LogoutTransitionScreenState();
}

class _LogoutTransitionScreenState extends State<LogoutTransitionScreen>
    with TickerProviderStateMixin {
  late AnimationController _pageController;
  late AnimationController _orbController;
  late AnimationController _lineController;
  late AnimationController _floatController;

  late Animation<double> _pageFade;
  late Animation<Offset> _panelSlide;
  late Animation<double> _orbScale;
  late Animation<double> _lineMove;
  late Animation<double> _floatValue;

  Timer? _redirectTimer;

  @override
  void initState() {
    super.initState();

    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);

    _lineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 10000),
    )..repeat(reverse: true);

    _pageFade = CurvedAnimation(
      parent: _pageController,
      curve: Curves.easeOut,
    );

    _panelSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _pageController,
        curve: Curves.easeOutCubic,
      ),
    );

    _orbScale = Tween<double>(
      begin: 1,
      end: 1.06,
    ).animate(
      CurvedAnimation(
        parent: _orbController,
        curve: Curves.easeInOut,
      ),
    );

    _lineMove = Tween<double>(
      begin: -0.35,
      end: 0.35,
    ).animate(
      CurvedAnimation(
        parent: _lineController,
        curve: Curves.easeInOut,
      ),
    );

    _floatValue = Tween<double>(
      begin: -1,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _floatController,
        curve: Curves.easeInOut,
      ),
    );

    _pageController.forward();

    _redirectTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
        (route) => false,
      );
    });
  }

  @override
  void dispose() {
    _redirectTimer?.cancel();
    _pageController.dispose();
    _orbController.dispose();
    _lineController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Stack(
          children: [
            const AuthBackground(),

            AnimatedBuilder(
              animation: _floatValue,
              builder: (context, child) {
                return Stack(
                  children: [
                    Positioned(
                      top: 90 + (_floatValue.value * -10),
                      left: 32 + (_floatValue.value * 6),
                      child: Transform.rotate(
                        angle: -0.12 + (_floatValue.value * 0.08),
                        child: Icon(
                          Icons.content_cut,
                          size: 30,
                          color: Colors.white.withValues(alpha: 0.14),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 110 + (_floatValue.value * 8),
                      right: 36 + (_floatValue.value * -8),
                      child: Transform.rotate(
                        angle: 0.10 + (_floatValue.value * -0.06),
                        child: Icon(
                          Icons.auto_awesome,
                          size: 28,
                          color: Colors.orange.withValues(alpha: 0.18),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            Center(
              child: FadeTransition(
                opacity: _pageFade,
                child: SlideTransition(
                  position: _panelSlide,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: "B",
                                style: TextStyle(
                                  color: Color(0xFFD4B896),
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              TextSpan(
                                text: "arb",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          textDirection: TextDirection.ltr,
                          style: TextStyle(
                            fontSize: 42,
                            letterSpacing: 2,
                          ),
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          "تم تسجيل الخروج بنجاح",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          "نأمل أن نراك قريبًا",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          "يتم الآن إعادتك إلى صفحة تسجيل الدخول",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 30),

                        AnimatedBuilder(
                          animation: _orbScale,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _orbScale.value,
                              child: Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.orange.withValues(alpha: 0.26),
                                  ),
                                  color: Colors.white.withValues(alpha: 0.05),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.orange.withValues(alpha: 0.18),
                                      blurRadius: 24,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Container(
                                    width: 26,
                                    height: 26,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.orange.withValues(alpha: 0.55),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.orange.withValues(alpha: 0.28),
                                          blurRadius: 14,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 26),

                        SizedBox(
                          width: 280,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: Container(
                              height: 5,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: AnimatedBuilder(
                                animation: _lineMove,
                                builder: (context, child) {
                                  return FractionalTranslation(
                                    translation: Offset(_lineMove.value, 0),
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Container(
                                        width: 120,
                                        height: 5,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(999),
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.transparent,
                                              Colors.orange.withValues(alpha: 0.60),
                                              Colors.white.withValues(alpha: 0.42),
                                              Colors.orange.withValues(alpha: 0.55),
                                              Colors.transparent,
                                            ],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.orange
                                                  .withValues(alpha: 0.28),
                                              blurRadius: 12,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          "شكرًا لاستخدام لوحة التحكم",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 6),

                        const Text(
                          "نتمنى لك يوم عمل موفق",
                          textAlign: TextAlign.center,
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}