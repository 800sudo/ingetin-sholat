import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/reminder_settings.dart';

abstract class SettingsLocalDataSource {
  Future<ReminderSettings> getSettings();
  Future<bool> saveSettings(ReminderSettings settings);
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final SharedPreferences sharedPreferences;

  SettingsLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<ReminderSettings> getSettings() async {
    try {
      final defaultOffset =
          sharedPreferences.getInt(AppConstants.keyDefaultOffsetMinutes) ?? 5;
      final soundEnabled =
          sharedPreferences.getBool(AppConstants.keySoundEnabled) ?? true;
      final vibrationEnabled =
          sharedPreferences.getBool(AppConstants.keyVibrationEnabled) ?? true;
      final tone =
          sharedPreferences.getString(AppConstants.keyNotificationTone) ??
          'Nada Standar Sistem (Ringtone)';
      final cityId =
          sharedPreferences.getString(AppConstants.keySelectedCity) ??
          'indramayu';
      final isDarkMode =
          sharedPreferences.getBool(AppConstants.keyThemeMode) ?? false;

      // Deserialisasi perPrayerOffsets
      final offsetsJson = sharedPreferences.getString(
        AppConstants.keyPrayerOffsets,
      );
      final perPrayerOffsets = <PrayerType, int>{};
      if (offsetsJson != null && offsetsJson.isNotEmpty) {
        final decoded = jsonDecode(offsetsJson) as Map<String, dynamic>;
        for (final entry in decoded.entries) {
          final type = PrayerType.values.firstWhere(
            (e) => e.name == entry.key,
            orElse: () => PrayerType.dzuhur,
          );
          perPrayerOffsets[type] = entry.value as int;
        }
      }

      // Deserialisasi perPrayerEnabled
      final enabledJson = sharedPreferences.getString('prayer_enabled_json');
      final perPrayerEnabled = <PrayerType, bool>{};
      if (enabledJson != null && enabledJson.isNotEmpty) {
        final decoded = jsonDecode(enabledJson) as Map<String, dynamic>;
        for (final entry in decoded.entries) {
          final type = PrayerType.values.firstWhere(
            (e) => e.name == entry.key,
            orElse: () => PrayerType.dzuhur,
          );
          perPrayerEnabled[type] = entry.value as bool;
        }
      } else {
        // default enabled for major prayers
        for (final type in PrayerType.values) {
          perPrayerEnabled[type] = type.isMajorPrayer;
        }
      }

      return ReminderSettings(
        defaultOffsetMinutes: defaultOffset,
        perPrayerOffsets: perPrayerOffsets,
        perPrayerEnabled: perPrayerEnabled,
        soundEnabled: soundEnabled,
        vibrationEnabled: vibrationEnabled,
        notificationTone: tone,
        selectedCityId: cityId,
        isDarkMode: isDarkMode,
      );
    } catch (_) {
      return const ReminderSettings();
    }
  }

  @override
  Future<bool> saveSettings(ReminderSettings settings) async {
    try {
      await sharedPreferences.setInt(
        AppConstants.keyDefaultOffsetMinutes,
        settings.defaultOffsetMinutes,
      );
      await sharedPreferences.setBool(
        AppConstants.keySoundEnabled,
        settings.soundEnabled,
      );
      await sharedPreferences.setBool(
        AppConstants.keyVibrationEnabled,
        settings.vibrationEnabled,
      );
      await sharedPreferences.setString(
        AppConstants.keyNotificationTone,
        settings.notificationTone,
      );
      await sharedPreferences.setString(
        AppConstants.keySelectedCity,
        settings.selectedCityId,
      );
      await sharedPreferences.setBool(
        AppConstants.keyThemeMode,
        settings.isDarkMode,
      );

      // Serialize offsets
      final offsetsMap = <String, int>{};
      settings.perPrayerOffsets.forEach((key, val) {
        offsetsMap[key.name] = val;
      });
      await sharedPreferences.setString(
        AppConstants.keyPrayerOffsets,
        jsonEncode(offsetsMap),
      );

      // Serialize enabled
      final enabledMap = <String, bool>{};
      settings.perPrayerEnabled.forEach((key, val) {
        enabledMap[key.name] = val;
      });
      await sharedPreferences.setString(
        'prayer_enabled_json',
        jsonEncode(enabledMap),
      );

      return true;
    } catch (_) {
      return false;
    }
  }
}
