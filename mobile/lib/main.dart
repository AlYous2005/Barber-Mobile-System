import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/auth/login_screen.dart';

final ValueNotifier<ThemeMode> appThemeMode = ValueNotifier<ThemeMode>(
  ThemeMode.light,
);

Future<void> saveAppThemeMode(ThemeMode mode) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(
    'app_theme_mode',
    mode == ThemeMode.dark ? 'dark' : 'light',
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? savedTheme = prefs.getString('app_theme_mode');

  appThemeMode.value = savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const Color brandBrown = Color(0xFFC47A3D);
  static const Color darkBackground = Color(0xFF17110D);
  static const Color darkSurface = Color(0xFF241A14);

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,
      colorScheme: ColorScheme.fromSeed(
        seedColor: brandBrown,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF111827)),
        titleTextStyle: TextStyle(
          color: Color(0xFF111827),
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: brandBrown,
        brightness: Brightness.dark,
      ).copyWith(surface: darkSurface, primary: brandBrown),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        surfaceTintColor: darkBackground,
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFFF8F3ED)),
        titleTextStyle: TextStyle(
          color: Color(0xFFF8F3ED),
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeMode,
      builder: (context, themeMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: themeMode,
          theme: _buildLightTheme(),
          darkTheme: _buildDarkTheme(),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('ar'), Locale('en')],
          home: const LoginScreen(),
        );
      },
    );
  }
}
