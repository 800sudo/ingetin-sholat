import 'package:equatable/equatable.dart';

import '../../../../core/constants/app_constants.dart';

class ReminderSettings extends Equatable {
  final int defaultOffsetMinutes; // Misal 5 menit sebelum waktu adzan
  final Map<PrayerType, int> perPrayerOffsets; // Offset khusus per waktu
  final Map<PrayerType, bool> perPrayerEnabled; // Aktif/nonaktif per sholat
  final bool soundEnabled; // Bunyi
  final bool vibrationEnabled; // Getar
  final String notificationTone; // Nada pengingat
  final String selectedCityId; // Kota terpilih
  final bool isDarkMode; // Tema gelap/terang

  const ReminderSettings({
    this.defaultOffsetMinutes = 5,
    this.perPrayerOffsets = const {},
    this.perPrayerEnabled = const {
      PrayerType.subuh: true,
      PrayerType.dzuhur: true,
      PrayerType.ashar: true,
      PrayerType.maghrib: true,
      PrayerType.isya: true,
      PrayerType.imsak: false,
      PrayerType.syuruq: false,
    },
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.notificationTone = 'Adzan Suara Merdu',
    this.selectedCityId = 'indramayu',
    this.isDarkMode = false,
  });

  int getOffsetFor(PrayerType type) {
    return perPrayerOffsets[type] ?? defaultOffsetMinutes;
  }

  bool isEnabledFor(PrayerType type) {
    return perPrayerEnabled[type] ?? type.isMajorPrayer;
  }

  DateTime calculateReminderTime(PrayerType type, DateTime prayerTime) {
    final offset = getOffsetFor(type);
    return prayerTime.subtract(Duration(minutes: offset));
  }

  ReminderSettings copyWith({
    int? defaultOffsetMinutes,
    Map<PrayerType, int>? perPrayerOffsets,
    Map<PrayerType, bool>? perPrayerEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    String? notificationTone,
    String? selectedCityId,
    bool? isDarkMode,
  }) {
    return ReminderSettings(
      defaultOffsetMinutes: defaultOffsetMinutes ?? this.defaultOffsetMinutes,
      perPrayerOffsets: perPrayerOffsets ?? this.perPrayerOffsets,
      perPrayerEnabled: perPrayerEnabled ?? this.perPrayerEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      notificationTone: notificationTone ?? this.notificationTone,
      selectedCityId: selectedCityId ?? this.selectedCityId,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }

  @override
  List<Object?> get props => [
    defaultOffsetMinutes,
    perPrayerOffsets,
    perPrayerEnabled,
    soundEnabled,
    vibrationEnabled,
    notificationTone,
    selectedCityId,
    isDarkMode,
  ];
}
