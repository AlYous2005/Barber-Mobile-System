import 'package:flutter/material.dart';

import '../models/user_settings_model.dart';
import '../services/supabase_config.dart';

class UserSettingsRepository {
  const UserSettingsRepository();

  Future<UserSettingsModel> getUserSettings({required String userId}) async {
    final row = await SupabaseConfig.client
        .from('user_settings')
        .select('user_id, notifications_enabled, theme_mode')
        .eq('user_id', userId)
        .maybeSingle();

    if (row != null) {
      return UserSettingsModel.fromMap(row);
    }

    return createDefaultSettings(userId: userId);
  }

  Future<UserSettingsModel> createDefaultSettings({
    required String userId,
  }) async {
    final row = await SupabaseConfig.client
        .from('user_settings')
        .insert({
          'user_id': userId,
          'notifications_enabled': true,
          'theme_mode': 'system',
        })
        .select('user_id, notifications_enabled, theme_mode')
        .single();

    return UserSettingsModel.fromMap(row);
  }

  Future<UserSettingsModel> setNotificationsEnabled({
    required String userId,
    required bool notificationsEnabled,
  }) async {
    final row = await SupabaseConfig.client
        .from('user_settings')
        .upsert({
          'user_id': userId,
          'notifications_enabled': notificationsEnabled,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        }, onConflict: 'user_id')
        .select('user_id, notifications_enabled, theme_mode')
        .single();

    return UserSettingsModel.fromMap(row);
  }

  Future<UserSettingsModel> setThemeMode({
    required String userId,
    required ThemeMode themeMode,
  }) async {
    final row = await SupabaseConfig.client
        .from('user_settings')
        .upsert({
          'user_id': userId,
          'theme_mode': _themeModeToDatabase(themeMode),
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        }, onConflict: 'user_id')
        .select('user_id, notifications_enabled, theme_mode')
        .single();

    return UserSettingsModel.fromMap(row);
  }

  String _themeModeToDatabase(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}
