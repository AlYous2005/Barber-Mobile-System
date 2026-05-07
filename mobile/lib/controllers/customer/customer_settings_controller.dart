// state + theme saving logic

import 'package:flutter/material.dart';

import '../../main.dart';
import '../../repositories/user_settings_repository.dart';
import '../../services/auth_session.dart';

class CustomerSettingsController extends ChangeNotifier {
  CustomerSettingsController({UserSettingsRepository? userSettingsRepository})
    : _userSettingsRepository =
          userSettingsRepository ?? const UserSettingsRepository();

  final UserSettingsRepository _userSettingsRepository;

  bool notificationsEnabled = true;
  bool isDarkMode = false;

  bool isLoadingSettings = false;
  String? settingsErrorMessage;

  String get _currentUserId {
    return AuthSession.currentUser?.username ?? '';
  }

  Future<void> initialize() async {
    isDarkMode = appThemeMode.value == ThemeMode.dark;

    final userId = _currentUserId;
    if (userId.isEmpty) {
      notifyListeners();
      return;
    }

    isLoadingSettings = true;
    settingsErrorMessage = null;
    notifyListeners();

    try {
      final settings = await _userSettingsRepository.getUserSettings(
        userId: userId,
      );

      notificationsEnabled = settings.notificationsEnabled;
      isDarkMode = settings.themeMode == ThemeMode.dark;

      appThemeMode.value = settings.themeMode;
      await saveAppThemeMode(settings.themeMode);
    } catch (error) {
      settingsErrorMessage = error.toString();
    } finally {
      isLoadingSettings = false;
      notifyListeners();
    }
  }

  Future<void> setNotificationsEnabled(bool value) async {
    final oldValue = notificationsEnabled;
    final userId = _currentUserId;

    notificationsEnabled = value;
    notifyListeners();

    if (userId.isEmpty) {
      return;
    }

    try {
      final settings = await _userSettingsRepository.setNotificationsEnabled(
        userId: userId,
        notificationsEnabled: value,
      );

      notificationsEnabled = settings.notificationsEnabled;
    } catch (error) {
      notificationsEnabled = oldValue;
      settingsErrorMessage = error.toString();
    }

    notifyListeners();
  }

  Future<void> setThemeMode(bool dark) async {
    final oldIsDarkMode = isDarkMode;
    final oldThemeMode = appThemeMode.value;
    final userId = _currentUserId;

    final newThemeMode = dark ? ThemeMode.dark : ThemeMode.light;

    isDarkMode = dark;
    appThemeMode.value = newThemeMode;
    notifyListeners();

    await saveAppThemeMode(newThemeMode);

    if (userId.isEmpty) {
      return;
    }

    try {
      final settings = await _userSettingsRepository.setThemeMode(
        userId: userId,
        themeMode: newThemeMode,
      );

      isDarkMode = settings.themeMode == ThemeMode.dark;
      appThemeMode.value = settings.themeMode;
      await saveAppThemeMode(settings.themeMode);
    } catch (error) {
      isDarkMode = oldIsDarkMode;
      appThemeMode.value = oldThemeMode;
      await saveAppThemeMode(oldThemeMode);
      settingsErrorMessage = error.toString();
    }

    notifyListeners();
  }
}
