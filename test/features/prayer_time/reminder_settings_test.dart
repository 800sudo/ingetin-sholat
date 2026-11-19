import 'package:flutter_test/flutter_test.dart';
import 'package:pengingat_azhan/core/constants/app_constants.dart';
import 'package:pengingat_azhan/features/prayer_time/domain/entities/reminder_settings.dart';

void main() {
  group('ReminderSettings Entity Tests', () {
    test('Default values are correct', () {
      const settings = ReminderSettings();
      expect(settings.defaultOffsetMinutes, 5);
      expect(settings.soundEnabled, isTrue);
      expect(settings.vibrationEnabled, isTrue);
      expect(settings.selectedCityId, 'indramayu');
      expect(settings.isDarkMode, isFalse);
    });

    test('copyWith updates properties properly', () {
      const settings = ReminderSettings();
      final updated = settings.copyWith(
        defaultOffsetMinutes: 10,
        soundEnabled: false,
        vibrationEnabled: true,
        selectedCityId: 'surabaya',
      );

      expect(updated.defaultOffsetMinutes, 10);
      expect(updated.soundEnabled, isFalse);
      expect(updated.vibrationEnabled, isTrue);
      expect(updated.selectedCityId, 'surabaya');
    });

    test('getOffsetFor returns custom offset if defined or default offset', () {
      const settings = ReminderSettings(
        defaultOffsetMinutes: 5,
        perPrayerOffsets: {PrayerType.subuh: 15},
      );

      expect(settings.getOffsetFor(PrayerType.subuh), 15);
      expect(settings.getOffsetFor(PrayerType.dzuhur), 5);
    });
  });
}
