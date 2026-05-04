import 'package:flutter/material.dart';

import '../auth/logout_transition_screen.dart';
import '../barber/barber_home_screen.dart';
import '../customer/customer_home_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.userName, required this.role});

  final String userName;
  final String role;

  void logout(
    BuildContext context, {
    String footerTitle = 'شكرًا لاستخدام لوحة التحكم',
    String footerSubtitle = 'نتمنى لك يوم عمل موفق',
  }) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) {
          return LogoutTransitionScreen(
            footerTitle: footerTitle,
            footerSubtitle: footerSubtitle,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCustomer = role == 'customer';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        logout(context);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: isCustomer
            ? CustomerHomeScreen(
                userName: userName,
                onLogout: () => logout(
                  context,
                  footerTitle: 'شكرًا لاستخدام تطبيق Barb',
                  footerSubtitle: 'نراك قريبًا في موعدك القادم',
                ),
              )
            : BarberHomeScreen(
                onLogout: () => logout(context),
                userName: userName,
              ),
      ),
    );
  }
}
