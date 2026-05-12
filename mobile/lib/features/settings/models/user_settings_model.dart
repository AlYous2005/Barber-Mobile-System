import 'package:flutter/material.dart';

class UserSettingsModel {
  const UserSettingsModel({
    required this.userId,
    required this.notificationsEnabled,
    required this.themeMode,
  });

  final String userId;
  final bool notificationsEnabled;
  final ThemeMode themeMode;

  factory UserSettingsModel.fromMap(Map<String, dynamic> map) {
    return UserSettingsModel(
      userId: map['user_id'].toString(),
      notificationsEnabled: map['notifications_enabled'] == true,
      themeMode: _themeModeFromDatabase(map['theme_mode']),
    );
  }

  String get themeModeForDatabase {
    switch (themeMode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  static ThemeMode _themeModeFromDatabase(dynamic value) {
    switch (value?.toString()) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  UserSettingsModel copyWith({
    bool? notificationsEnabled,
    ThemeMode? themeMode,
  }) {
    return UserSettingsModel(
      userId: userId,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}
