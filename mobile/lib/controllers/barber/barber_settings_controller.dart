//state + theme saving

import 'package:flutter/material.dart';

import '../../main.dart';

class BarberSettingsController extends ChangeNotifier {
  bool notificationsEnabled = true;
  bool isDarkMode = false;
  bool hasSalonImage = false;

  void initialize() {
    isDarkMode = appThemeMode.value == ThemeMode.dark;
    notifyListeners();
  }

  void toggleNotifications() {
    notificationsEnabled = !notificationsEnabled;
    notifyListeners();
  }

  Future<void> setThemeMode(bool value) async {
    isDarkMode = value;
    notifyListeners();

    appThemeMode.value = value ? ThemeMode.dark : ThemeMode.light;
    await saveAppThemeMode(appThemeMode.value);
  }

  bool addOrChangeSalonImage() {
    final bool alreadyHadImage = hasSalonImage;

    hasSalonImage = true;
    notifyListeners();

    return alreadyHadImage;
  }

  void removeSalonImage() {
    hasSalonImage = false;
    notifyListeners();
  }
}
