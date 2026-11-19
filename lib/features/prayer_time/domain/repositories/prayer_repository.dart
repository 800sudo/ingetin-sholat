import '../../../../core/utils/prayer_calculator.dart';
import '../entities/prayer_schedule.dart';
import '../entities/reminder_settings.dart';

abstract class PrayerRepository {
  Future<ReminderSettings> getSettings();
  Future<bool> saveSettings(ReminderSettings settings);
  Future<PrayerScheduleEntity> getPrayerSchedule({
    DateTime? date,
    CityLocation? location,
    ReminderSettings? settings,
  });
}
