import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pengingat_azhan/core/constants/app_constants.dart';
import 'package:pengingat_azhan/core/utils/prayer_calculator.dart';
import 'package:pengingat_azhan/features/prayer_time/domain/entities/prayer_schedule.dart';
import 'package:pengingat_azhan/features/prayer_time/domain/entities/reminder_settings.dart';
import 'package:pengingat_azhan/features/prayer_time/domain/repositories/prayer_repository.dart';
import 'package:pengingat_azhan/features/prayer_time/domain/usecases/get_prayer_schedule.dart';
import 'package:pengingat_azhan/features/prayer_time/domain/usecases/get_reminder_settings.dart';
import 'package:pengingat_azhan/features/prayer_time/domain/usecases/save_reminder_settings.dart';
import 'package:pengingat_azhan/features/prayer_time/presentation/bloc/prayer_bloc.dart';
import 'package:pengingat_azhan/features/prayer_time/presentation/bloc/prayer_event.dart';
import 'package:pengingat_azhan/features/prayer_time/presentation/bloc/prayer_state.dart';

class MockPrayerRepository extends Mock implements PrayerRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(const ReminderSettings());
    registerFallbackValue(CityLocation.defaultCity);
    registerFallbackValue(DateTime.now());
  });

  late MockPrayerRepository mockRepository;
  late GetPrayerSchedule getPrayerSchedule;
  late GetReminderSettings getReminderSettings;
  late SaveReminderSettings saveReminderSettings;
  late PrayerBloc prayerBloc;

  setUp(() {
    mockRepository = MockPrayerRepository();
    getPrayerSchedule = GetPrayerSchedule(mockRepository);
    getReminderSettings = GetReminderSettings(mockRepository);
    saveReminderSettings = SaveReminderSettings(mockRepository);

    prayerBloc = PrayerBloc(
      getPrayerSchedule: getPrayerSchedule,
      getReminderSettings: getReminderSettings,
      saveReminderSettings: saveReminderSettings,
    );
  });

  tearDown(() {
    prayerBloc.close();
  });

  const testSettings = ReminderSettings(
    defaultOffsetMinutes: 5,
    selectedCityId: 'jakarta',
    soundEnabled: true,
    vibrationEnabled: true,
  );

  final testSchedule = PrayerScheduleEntity.create(
    currentTime: DateTime(2026, 11, 18, 10, 0),
    location: CityLocation.defaultCity,
    settings: testSettings,
  );

  group('PrayerBloc Tests', () {
    test('initial state is PrayerInitialState', () {
      expect(prayerBloc.state, equals(const PrayerInitialState()));
    });

    blocTest<PrayerBloc, PrayerState>(
      'emits [PrayerLoadingState, PrayerLoadedState] on LoadPrayerDataEvent',
      build: () {
        when(() => mockRepository.getSettings())
            .thenAnswer((_) async => testSettings);
        when(
          () => mockRepository.getPrayerSchedule(
            date: any(named: 'date'),
            location: any(named: 'location'),
            settings: any(named: 'settings'),
          ),
        ).thenAnswer((_) async => testSchedule);
        return prayerBloc;
      },
      act: (bloc) => bloc.add(const LoadPrayerDataEvent()),
      expect: () => [
        const PrayerLoadingState(),
        isA<PrayerLoadedState>()
            .having((s) => s.settings.defaultOffsetMinutes, 'defaultOffset', 5)
            .having((s) => s.settings.selectedCityId, 'city', 'jakarta'),
      ],
    );

    blocTest<PrayerBloc, PrayerState>(
      'updates offset and emits updated state on UpdateDefaultOffsetEvent',
      build: () {
        when(() => mockRepository.saveSettings(any()))
            .thenAnswer((_) async => true);
        when(
          () => mockRepository.getPrayerSchedule(
            date: any(named: 'date'),
            location: any(named: 'location'),
            settings: any(named: 'settings'),
          ),
        ).thenAnswer((_) async => testSchedule);
        return prayerBloc;
      },
      seed: () => PrayerLoadedState(
        schedule: testSchedule,
        settings: testSettings,
        currentTime: DateTime(2026, 11, 18, 10, 0),
      ),
      act: (bloc) => bloc.add(const UpdateDefaultOffsetEvent(10)),
      expect: () => [
        isA<PrayerLoadedState>().having(
          (s) => s.settings.defaultOffsetMinutes,
          'defaultOffset',
          10,
        ),
      ],
      verify: (_) {
        verify(() => mockRepository.saveSettings(any())).called(1);
      },
    );

    blocTest<PrayerBloc, PrayerState>(
      'triggers simulated alert and emits isAlertActive = true',
      build: () => prayerBloc,
      seed: () => PrayerLoadedState(
        schedule: testSchedule,
        settings: testSettings,
        currentTime: DateTime(2026, 11, 18, 10, 0),
      ),
      act: (bloc) =>
          bloc.add(const TriggerSimulatedAlertEvent(type: PrayerType.dzuhur)),
      wait: const Duration(milliseconds: 400),
      expect: () => [
        isA<PrayerLoadedState>()
            .having((s) => s.isAlertActive, 'isAlertActive', isTrue)
            .having(
              (s) => s.triggeredAlertPrayer?.type,
              'prayerType',
              PrayerType.dzuhur,
            ),
      ],
    );
  });
}
