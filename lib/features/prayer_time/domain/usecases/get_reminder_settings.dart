import '../entities/reminder_settings.dart';
import '../repositories/prayer_repository.dart';

class GetReminderSettings {
  final PrayerRepository repository;

  GetReminderSettings(this.repository);

  Future<ReminderSettings> call() {
    return repository.getSettings();
  }
}
