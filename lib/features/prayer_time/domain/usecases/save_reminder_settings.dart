import '../entities/reminder_settings.dart';
import '../repositories/prayer_repository.dart';

class SaveReminderSettings {
  final PrayerRepository repository;

  SaveReminderSettings(this.repository);

  Future<bool> call(ReminderSettings settings) {
    return repository.saveSettings(settings);
  }
}
