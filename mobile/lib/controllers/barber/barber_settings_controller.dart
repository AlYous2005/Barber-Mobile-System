// state + theme saving

import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../main.dart';
import '../../features/barber/profile/barber_profile.dart';
import '../../features/bookings/utils/booking_window_helper.dart';
import '../../features/settings/settings.dart';
import '../../services/auth_session.dart';

class BarberSettingsController extends ChangeNotifier {
  BarberSettingsController({
    UserSettingsRepository? userSettingsRepository,
    BarberSalonImageRepository? barberSalonImageRepository,
    BarberAvatarRepository? barberAvatarRepository,
    BarberBookingWindowRepository? barberBookingWindowRepository,
  }) : _userSettingsRepository =
           userSettingsRepository ?? const UserSettingsRepository(),
       _barberSalonImageRepository =
           barberSalonImageRepository ?? const BarberSalonImageRepository(),
       _barberAvatarRepository =
           barberAvatarRepository ?? const BarberAvatarRepository(),
       _barberBookingWindowRepository =
           barberBookingWindowRepository ?? const BarberBookingWindowRepository();

  final UserSettingsRepository _userSettingsRepository;
  final BarberSalonImageRepository _barberSalonImageRepository;
  final BarberAvatarRepository _barberAvatarRepository;
  final BarberBookingWindowRepository _barberBookingWindowRepository;

  bool notificationsEnabled = true;
  bool isDarkMode = false;

  bool bookingWindowEnabled = false;
  BookingWindowType bookingWindowType = BookingWindowType.month;
  bool isSavingBookingWindow = false;

  bool hasSalonImage = false;
  bool hasBarberAvatar = false;

  bool isLoadingSettings = false;
  bool isUploadingSalonImage = false;
  bool isUploadingBarberAvatar = false;

  String? settingsErrorMessage;
  String? salonImageUrl;
  String? barberAvatarUrl;

  String get _currentUserId {
    return AuthSession.currentUser?.username ?? '';
  }

  String get _currentBarberId {
    return AuthSession.currentUser?.barberId ?? '';
  }

  Future<void> initialize() async {
    isDarkMode = appThemeMode.value == ThemeMode.dark;

    final userId = _currentUserId;
    final barberId = _currentBarberId;

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

      barberAvatarUrl = await _barberAvatarRepository.getBarberAvatarUrl(
        userId: userId,
      );

      hasBarberAvatar = barberAvatarUrl != null && barberAvatarUrl!.isNotEmpty;

      if (barberId.isNotEmpty) {
        salonImageUrl = await _barberSalonImageRepository.getSalonImageUrl(
          barberId: barberId,
        );

        hasSalonImage = salonImageUrl != null && salonImageUrl!.isNotEmpty;

        try {
          final bookingWindow = await _barberBookingWindowRepository
              .fetchForBarber(barberId: barberId);
          if (bookingWindow != null) {
            bookingWindowEnabled = bookingWindow.enabled;
            bookingWindowType = BookingWindowType.fromStorage(
              bookingWindow.type,
            );
          }
        } catch (_) {
          bookingWindowEnabled = false;
          bookingWindowType = BookingWindowType.month;
        }
      }
    } catch (error) {
      settingsErrorMessage = error.toString();
    } finally {
      isLoadingSettings = false;
      notifyListeners();
    }
  }

  Future<void> toggleNotifications() async {
    await setNotificationsEnabled(!notificationsEnabled);
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

  Future<void> setBookingWindowEnabled(bool value) async {
    final String barberId = _currentBarberId;
    if (barberId.isEmpty) {
      return;
    }

    final bool oldEnabled = bookingWindowEnabled;
    bookingWindowEnabled = value;
    notifyListeners();

    isSavingBookingWindow = true;
    notifyListeners();

    try {
      await _barberBookingWindowRepository.updateForBarber(
        barberId: barberId,
        enabled: value,
        bookingWindowType: bookingWindowType.storageValue,
      );
    } catch (error) {
      bookingWindowEnabled = oldEnabled;
      settingsErrorMessage = error.toString();
    } finally {
      isSavingBookingWindow = false;
      notifyListeners();
    }
  }

  Future<void> setBookingWindowType(BookingWindowType type) async {
    final String barberId = _currentBarberId;
    if (barberId.isEmpty) {
      return;
    }

    final BookingWindowType oldType = bookingWindowType;
    bookingWindowType = type;
    notifyListeners();

    if (!bookingWindowEnabled) {
      return;
    }

    isSavingBookingWindow = true;
    notifyListeners();

    try {
      await _barberBookingWindowRepository.updateForBarber(
        barberId: barberId,
        enabled: true,
        bookingWindowType: type.storageValue,
      );
    } catch (error) {
      bookingWindowType = oldType;
      settingsErrorMessage = error.toString();
    } finally {
      isSavingBookingWindow = false;
      notifyListeners();
    }
  }

  Future<void> setThemeMode(bool value) async {
    final oldIsDarkMode = isDarkMode;
    final oldThemeMode = appThemeMode.value;
    final userId = _currentUserId;

    final newThemeMode = value ? ThemeMode.dark : ThemeMode.light;

    isDarkMode = value;
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

  Future<bool> addOrChangeSalonImage({
    required Uint8List imageBytes,
    required String originalFileName,
  }) async {
    final barberId = _currentBarberId;

    if (barberId.isEmpty) {
      throw StateError('لا يوجد حلاق مسجل حاليًا');
    }

    final alreadyHadImage = hasSalonImage;

    isUploadingSalonImage = true;
    settingsErrorMessage = null;
    notifyListeners();

    try {
      salonImageUrl = await _barberSalonImageRepository.uploadSalonImage(
        barberId: barberId,
        imageBytes: imageBytes,
        originalFileName: originalFileName,
      );

      hasSalonImage = salonImageUrl != null && salonImageUrl!.isNotEmpty;

      return alreadyHadImage;
    } catch (error) {
      settingsErrorMessage = error.toString();
      rethrow;
    } finally {
      isUploadingSalonImage = false;
      notifyListeners();
    }
  }

  Future<void> removeSalonImage() async {
    final barberId = _currentBarberId;

    if (barberId.isEmpty) {
      throw StateError('لا يوجد حلاق مسجل حاليًا');
    }

    isUploadingSalonImage = true;
    settingsErrorMessage = null;
    notifyListeners();

    try {
      await _barberSalonImageRepository.removeSalonImage(
        barberId: barberId,
        salonImageUrl: salonImageUrl,
      );

      salonImageUrl = null;
      hasSalonImage = false;
    } catch (error) {
      settingsErrorMessage = error.toString();
      rethrow;
    } finally {
      isUploadingSalonImage = false;
      notifyListeners();
    }
  }

  Future<bool> addOrChangeBarberAvatar({
    required Uint8List imageBytes,
    required String originalFileName,
  }) async {
    final userId = _currentUserId;

    if (userId.isEmpty) {
      throw StateError('لا يوجد مستخدم مسجل حاليًا');
    }

    final alreadyHadImage = hasBarberAvatar;

    isUploadingBarberAvatar = true;
    settingsErrorMessage = null;
    notifyListeners();

    try {
      barberAvatarUrl = await _barberAvatarRepository.uploadBarberAvatar(
        userId: userId,
        imageBytes: imageBytes,
        originalFileName: originalFileName,
      );

      hasBarberAvatar = barberAvatarUrl != null && barberAvatarUrl!.isNotEmpty;

      return alreadyHadImage;
    } catch (error) {
      settingsErrorMessage = error.toString();
      rethrow;
    } finally {
      isUploadingBarberAvatar = false;
      notifyListeners();
    }
  }

  Future<void> removeBarberAvatar() async {
    final userId = _currentUserId;

    if (userId.isEmpty) {
      throw StateError('لا يوجد مستخدم مسجل حاليًا');
    }

    isUploadingBarberAvatar = true;
    settingsErrorMessage = null;
    notifyListeners();

    try {
      await _barberAvatarRepository.removeBarberAvatar(userId: userId);

      barberAvatarUrl = null;
      hasBarberAvatar = false;
    } catch (error) {
      settingsErrorMessage = error.toString();
      rethrow;
    } finally {
      isUploadingBarberAvatar = false;
      notifyListeners();
    }
  }
}
