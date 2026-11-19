import 'package:flutter_test/flutter_test.dart';
import 'package:pengingat_azhan/core/constants/app_constants.dart';
import 'package:pengingat_azhan/core/utils/prayer_calculator.dart';
import 'package:pengingat_azhan/features/prayer_time/domain/entities/reminder_settings.dart';

void main() {
  group('PrayerCalculator & Offset Calculation Tests', () {
    test('Calculates valid prayer times for Jakarta', () {
      final date = DateTime(2026, 11, 18, 12, 0);
      final city = CityLocation.findById('jakarta');

      final result = PrayerCalculator.calculate(date: date, location: city);

      expect(result.prayerTimes.containsKey(PrayerType.subuh), isTrue);
      expect(result.prayerTimes.containsKey(PrayerType.dzuhur), isTrue);
      expect(result.prayerTimes.containsKey(PrayerType.ashar), isTrue);
      expect(result.prayerTimes.containsKey(PrayerType.maghrib), isTrue);
      expect(result.prayerTimes.containsKey(PrayerType.isya), isTrue);

      final subuh = result.getTime(PrayerType.subuh);
      final dzuhur = result.getTime(PrayerType.dzuhur);
      final ashar = result.getTime(PrayerType.ashar);
      final maghrib = result.getTime(PrayerType.maghrib);
      final isya = result.getTime(PrayerType.isya);

      // Verify chronological order
      expect(subuh.isBefore(dzuhur), isTrue);
      expect(dzuhur.isBefore(ashar), isTrue);
      expect(ashar.isBefore(maghrib), isTrue);
      expect(maghrib.isBefore(isya), isTrue);
    });

    test('Calculates custom offset correctly (misal dzuhur 11:35 dengan offset -5 menit -> 11:30)', () {
      final dzuhurTime = DateTime(2026, 11, 18, 11, 35);
      const settings = ReminderSettings(
        defaultOffsetMinutes: 5,
        perPrayerOffsets: {PrayerType.dzuhur: 5, PrayerType.subuh: 15},
      );

      final reminderDzuhur = settings.calculateReminderTime(
        PrayerType.dzuhur,
        dzuhurTime,
      );
      expect(reminderDzuhur.hour, equals(11));
      expect(reminderDzuhur.minute, equals(30));

      final subuhTime = DateTime(2026, 11, 18, 4, 15);
      final reminderSubuh = settings.calculateReminderTime(
        PrayerType.subuh,
        subuhTime,
      );
      expect(reminderSubuh.hour, equals(4));
      expect(reminderSubuh.minute, equals(0));
    });
  });
}
