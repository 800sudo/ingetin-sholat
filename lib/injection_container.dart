import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/prayer_time/data/datasources/settings_local_datasource.dart';
import 'features/prayer_time/data/repositories/prayer_repository_impl.dart';
import 'features/prayer_time/domain/repositories/prayer_repository.dart';
import 'features/prayer_time/domain/usecases/get_prayer_schedule.dart';
import 'features/prayer_time/domain/usecases/get_reminder_settings.dart';
import 'features/prayer_time/domain/usecases/save_reminder_settings.dart';
import 'features/prayer_time/presentation/bloc/prayer_bloc.dart';

final sl = GetIt.instance;

Future<void> initInjection() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // Data sources
  sl.registerLazySingleton<SettingsLocalDataSource>(
    () => SettingsLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // Repositories
  sl.registerLazySingleton<PrayerRepository>(
    () => PrayerRepositoryImpl(localDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetPrayerSchedule(sl()));
  sl.registerLazySingleton(() => GetReminderSettings(sl()));
  sl.registerLazySingleton(() => SaveReminderSettings(sl()));

  // BLoC
  sl.registerFactory(
    () => PrayerBloc(
      getPrayerSchedule: sl(),
      getReminderSettings: sl(),
      saveReminderSettings: sl(),
    ),
  );
}
