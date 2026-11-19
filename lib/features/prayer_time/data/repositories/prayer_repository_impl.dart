import '../../../../core/utils/prayer_calculator.dart';
import '../../domain/entities/prayer_schedule.dart';
import '../../domain/entities/reminder_settings.dart';
import '../../domain/repositories/prayer_repository.dart';
import '../datasources/settings_local_datasource.dart';

class PrayerRepositoryImpl implements PrayerRepository {
  final SettingsLocalDataSource localDataSource;

  PrayerRepositoryImpl({required this.localDataSource});

  @override
  Future<ReminderSettings> getSettings() async {
    return await localDataSource.getSettings();
  }

  @override
  Future<bool> saveSettings(ReminderSettings settings) async {
    return await localDataSource.saveSettings(settings);
  }

  @override
  Future<PrayerScheduleEntity> getPrayerSchedule({
    DateTime? date,
    CityLocation? location,
    ReminderSettings? settings,
  }) async {
    final effectiveDate = date ?? DateTime.now();
    final effectiveSettings = settings ?? await getSettings();
    final effectiveLocation =
        location ?? CityLocation.findById(effectiveSettings.selectedCityId);

    return PrayerScheduleEntity.create(
      currentTime: effectiveDate,
      location: effectiveLocation,
      settings: effectiveSettings,
    );
  }
}
