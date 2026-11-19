import '../../../../core/utils/prayer_calculator.dart';
import '../entities/prayer_schedule.dart';
import '../entities/reminder_settings.dart';
import '../repositories/prayer_repository.dart';

class GetPrayerSchedule {
  final PrayerRepository repository;

  GetPrayerSchedule(this.repository);

  Future<PrayerScheduleEntity> call({
    DateTime? date,
    CityLocation? location,
    ReminderSettings? settings,
  }) {
    return repository.getPrayerSchedule(
      date: date,
      location: location,
      settings: settings,
    );
  }
}
