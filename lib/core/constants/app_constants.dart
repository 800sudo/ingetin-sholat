class AppConstants {
  static const String appName = 'Ingetin Sholat';
  static const String appVersion = '1.0.0';

  // SharedPreferences Keys
  static const String keySelectedCity = 'selected_city';
  static const String keyCustomLatitude = 'custom_latitude';
  static const String keyCustomLongitude = 'custom_longitude';
  static const String keyDefaultOffsetMinutes = 'default_offset_minutes';
  static const String keyPrayerOffsets = 'prayer_offsets_json';
  static const String keySoundEnabled = 'sound_enabled';
  static const String keyVibrationEnabled = 'vibration_enabled';
  static const String keyNotificationTone = 'notification_tone';
  static const String keyThemeMode = 'app_theme_mode';
  static const String keyCalculationMethod = 'calculation_method';

  // Default Values
  static const int defaultOffsetMinutes = 5; // -5 menit sebelum adzan
  static const bool defaultSoundEnabled = true;
  static const bool defaultVibrationEnabled = true;
  static const String defaultNotificationTone = 'Adzan Suara Merdu';
}

enum PrayerType { imsak, subuh, syuruq, dzuhur, ashar, maghrib, isya }

extension PrayerTypeExt on PrayerType {
  String get nameId {
    switch (this) {
      case PrayerType.imsak:
        return 'Imsak';
      case PrayerType.subuh:
        return 'Subuh';
      case PrayerType.syuruq:
        return 'Terbit / Syuruq';
      case PrayerType.dzuhur:
        return 'Dzuhur';
      case PrayerType.ashar:
        return 'Ashar';
      case PrayerType.maghrib:
        return 'Maghrib';
      case PrayerType.isya:
        return 'Isya';
    }
  }

  String get arabicName {
    switch (this) {
      case PrayerType.imsak:
        return 'الإمساك';
      case PrayerType.subuh:
        return 'الفجر';
      case PrayerType.syuruq:
        return 'الشروق';
      case PrayerType.dzuhur:
        return 'الظهر';
      case PrayerType.ashar:
        return 'العصر';
      case PrayerType.maghrib:
        return 'المغرب';
      case PrayerType.isya:
        return 'العشاء';
    }
  }

  bool get isMajorPrayer {
    // Sholat 5 waktu utama
    return this == PrayerType.subuh ||
        this == PrayerType.dzuhur ||
        this == PrayerType.ashar ||
        this == PrayerType.maghrib ||
        this == PrayerType.isya;
  }
}
