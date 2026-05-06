// state + theme saving logic

import 'package:flutter/material.dart';

import '../../main.dart';

class CustomerSettingsController extends ChangeNotifier {
  bool notificationsEnabled = true;
  bool isDarkMode = false;

  void initialize() {
    isDarkMode = appThemeMode.value == ThemeMode.dark;
    notifyListeners();
  }

  void setNotificationsEnabled(bool value) {
    notificationsEnabled = value;
    notifyListeners();
  }

  Future<void> setThemeMode(bool dark) async {
    isDarkMode = dark;
    notifyListeners();

    appThemeMode.value = dark ? ThemeMode.dark : ThemeMode.light;
    await saveAppThemeMode(appThemeMode.value);
  }
}
