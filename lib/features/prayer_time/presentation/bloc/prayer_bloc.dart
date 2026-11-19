import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/audio_helper.dart';
import '../../../../core/utils/prayer_calculator.dart';
import '../../domain/entities/prayer_schedule.dart';
import '../../domain/usecases/get_prayer_schedule.dart';
import '../../domain/usecases/get_reminder_settings.dart';
import '../../domain/usecases/save_reminder_settings.dart';
import 'prayer_event.dart';
import 'prayer_state.dart';

class PrayerBloc extends Bloc<PrayerEvent, PrayerState> {
  final GetPrayerSchedule getPrayerSchedule;
  final GetReminderSettings getReminderSettings;
  final SaveReminderSettings saveReminderSettings;

  final Set<String> _triggeredAlertKeys = {};

  PrayerBloc({
    required this.getPrayerSchedule,
    required this.getReminderSettings,
    required this.saveReminderSettings,
  }) : super(const PrayerInitialState()) {
    on<LoadPrayerDataEvent>(_onLoadPrayerData);
    on<PrayerTickEvent>(_onPrayerTick);
    on<UpdateCityEvent>(_onUpdateCity);
    on<UpdateDefaultOffsetEvent>(_onUpdateDefaultOffset);
    on<UpdatePrayerOffsetEvent>(_onUpdatePrayerOffset);
    on<TogglePrayerReminderEvent>(_onTogglePrayerReminder);
    on<UpdateSoundSettingEvent>(_onUpdateSoundSetting);
    on<UpdateVibrationSettingEvent>(_onUpdateVibrationSetting);
    on<UpdateNotificationToneEvent>(_onUpdateNotificationToneEvent);
    on<ToggleThemeModeEvent>(_onToggleThemeMode);
    on<TriggerSimulatedAlertEvent>(_onTriggerSimulatedAlert);
    on<DismissActiveAlertEvent>(_onDismissActiveAlert);
  }

  Future<void> _onLoadPrayerData(
    LoadPrayerDataEvent event,
    Emitter<PrayerState> emit,
  ) async {
    emit(const PrayerLoadingState());
    try {
      var settings = await getReminderSettings();
      if (settings.selectedCityId == 'jakarta') {
        settings = settings.copyWith(selectedCityId: 'indramayu');
        await saveReminderSettings(settings);
      }
      final now = DateTime.now();
      final location = CityLocation.findById(settings.selectedCityId);
      final schedule = await getPrayerSchedule(
        date: now,
        location: location,
        settings: settings,
      );

      emit(
        PrayerLoadedState(
          schedule: schedule,
          settings: settings,
          currentTime: now,
        ),
      );
    } catch (e) {
      emit(PrayerErrorState('Gagal memuat jadwal sholat: ${e.toString()}'));
    }
  }

  Future<void> _onPrayerTick(
    PrayerTickEvent event,
    Emitter<PrayerState> emit,
  ) async {
    if (state is! PrayerLoadedState) return;
    final currentState = state as PrayerLoadedState;
    final now = event.now;

    // Refresh jadwal & countdown
    final location = CityLocation.findById(
      currentState.settings.selectedCityId,
    );
    final updatedSchedule = await getPrayerSchedule(
      date: now,
      location: location,
      settings: currentState.settings,
    );

    // Cek apakah ada jadwal pengingat yang pas dengan waktu sekarang
    SinglePrayerInfo? matchedPrayer;
    for (final prayer in updatedSchedule.prayers) {
      if (!prayer.isReminderActive) continue;

      final rTime = prayer.reminderTime;
      if (rTime.year == now.year &&
          rTime.month == now.month &&
          rTime.day == now.day &&
          rTime.hour == now.hour &&
          rTime.minute == now.minute) {
        final alertKey =
            '${prayer.type.name}_${rTime.day}_${rTime.hour}_${rTime.minute}';
        if (!_triggeredAlertKeys.contains(alertKey)) {
          _triggeredAlertKeys.add(alertKey);
          matchedPrayer = prayer;
          break;
        }
      }
    }

    if (matchedPrayer != null) {
      // Trigger getar dan suara sesuai pengaturan user
      await AudioHapticHelper.triggerAlert(
        playSound: currentState.settings.soundEnabled,
        vibrate: currentState.settings.vibrationEnabled,
      );

      emit(
        currentState.copyWith(
          schedule: updatedSchedule,
          currentTime: now,
          triggeredAlertPrayer: matchedPrayer,
          isAlertActive: true,
        ),
      );
    } else {
      emit(currentState.copyWith(schedule: updatedSchedule, currentTime: now));
    }
  }

  Future<void> _onUpdateCity(
    UpdateCityEvent event,
    Emitter<PrayerState> emit,
  ) async {
    if (state is! PrayerLoadedState) return;
    final currentState = state as PrayerLoadedState;

    final newSettings = currentState.settings.copyWith(
      selectedCityId: event.cityId,
    );
    await saveReminderSettings(newSettings);

    final location = CityLocation.findById(event.cityId);
    final updatedSchedule = await getPrayerSchedule(
      date: currentState.currentTime,
      location: location,
      settings: newSettings,
    );

    emit(
      currentState.copyWith(settings: newSettings, schedule: updatedSchedule),
    );
  }

  Future<void> _onUpdateDefaultOffset(
    UpdateDefaultOffsetEvent event,
    Emitter<PrayerState> emit,
  ) async {
    if (state is! PrayerLoadedState) return;
    final currentState = state as PrayerLoadedState;

    final newSettings = currentState.settings.copyWith(
      defaultOffsetMinutes: event.minutes,
    );
    await saveReminderSettings(newSettings);

    final updatedSchedule = await getPrayerSchedule(
      date: currentState.currentTime,
      location: CityLocation.findById(newSettings.selectedCityId),
      settings: newSettings,
    );

    emit(
      currentState.copyWith(settings: newSettings, schedule: updatedSchedule),
    );
  }

  Future<void> _onUpdatePrayerOffset(
    UpdatePrayerOffsetEvent event,
    Emitter<PrayerState> emit,
  ) async {
    if (state is! PrayerLoadedState) return;
    final currentState = state as PrayerLoadedState;

    final updatedOffsets = Map<PrayerType, int>.from(
      currentState.settings.perPrayerOffsets,
    );
    updatedOffsets[event.type] = event.minutes;

    final newSettings = currentState.settings.copyWith(
      perPrayerOffsets: updatedOffsets,
    );
    await saveReminderSettings(newSettings);

    final updatedSchedule = await getPrayerSchedule(
      date: currentState.currentTime,
      location: CityLocation.findById(newSettings.selectedCityId),
      settings: newSettings,
    );

    emit(
      currentState.copyWith(settings: newSettings, schedule: updatedSchedule),
    );
  }

  Future<void> _onTogglePrayerReminder(
    TogglePrayerReminderEvent event,
    Emitter<PrayerState> emit,
  ) async {
    if (state is! PrayerLoadedState) return;
    final currentState = state as PrayerLoadedState;

    final updatedEnabled = Map<PrayerType, bool>.from(
      currentState.settings.perPrayerEnabled,
    );
    updatedEnabled[event.type] = event.isEnabled;

    final newSettings = currentState.settings.copyWith(
      perPrayerEnabled: updatedEnabled,
    );
    await saveReminderSettings(newSettings);

    final updatedSchedule = await getPrayerSchedule(
      date: currentState.currentTime,
      location: CityLocation.findById(newSettings.selectedCityId),
      settings: newSettings,
    );

    emit(
      currentState.copyWith(settings: newSettings, schedule: updatedSchedule),
    );
  }

  Future<void> _onUpdateSoundSetting(
    UpdateSoundSettingEvent event,
    Emitter<PrayerState> emit,
  ) async {
    if (state is! PrayerLoadedState) return;
    final currentState = state as PrayerLoadedState;

    final newSettings = currentState.settings.copyWith(
      soundEnabled: event.enabled,
    );
    await saveReminderSettings(newSettings);

    emit(currentState.copyWith(settings: newSettings));
  }

  Future<void> _onUpdateVibrationSetting(
    UpdateVibrationSettingEvent event,
    Emitter<PrayerState> emit,
  ) async {
    if (state is! PrayerLoadedState) return;
    final currentState = state as PrayerLoadedState;

    final newSettings = currentState.settings.copyWith(
      vibrationEnabled: event.enabled,
    );
    await saveReminderSettings(newSettings);

    if (event.enabled) {
      await AudioHapticHelper.triggerVibration();
    }

    emit(currentState.copyWith(settings: newSettings));
  }

  Future<void> _onUpdateNotificationToneEvent(
    UpdateNotificationToneEvent event,
    Emitter<PrayerState> emit,
  ) async {
    if (state is! PrayerLoadedState) return;
    final currentState = state as PrayerLoadedState;

    final newSettings = currentState.settings.copyWith(
      notificationTone: event.tone,
    );
    await saveReminderSettings(newSettings);

    emit(currentState.copyWith(settings: newSettings));
  }

  Future<void> _onToggleThemeMode(
    ToggleThemeModeEvent event,
    Emitter<PrayerState> emit,
  ) async {
    if (state is! PrayerLoadedState) return;
    final currentState = state as PrayerLoadedState;

    final newSettings = currentState.settings.copyWith(
      isDarkMode: event.isDark,
    );
    await saveReminderSettings(newSettings);

    emit(currentState.copyWith(settings: newSettings));
  }

  Future<void> _onTriggerSimulatedAlert(
    TriggerSimulatedAlertEvent event,
    Emitter<PrayerState> emit,
  ) async {
    if (state is! PrayerLoadedState) return;
    final currentState = state as PrayerLoadedState;

    final prayerInfo = currentState.schedule.prayers.firstWhere(
      (p) => p.type == event.type,
      orElse: () => currentState.schedule.prayers.first,
    );

    // Trigger getar dan suara
    await AudioHapticHelper.triggerAlert(
      playSound: currentState.settings.soundEnabled,
      vibrate: currentState.settings.vibrationEnabled,
    );

    emit(
      currentState.copyWith(
        triggeredAlertPrayer: prayerInfo,
        isAlertActive: true,
      ),
    );
  }

  void _onDismissActiveAlert(
    DismissActiveAlertEvent event,
    Emitter<PrayerState> emit,
  ) {
    if (state is! PrayerLoadedState) return;
    final currentState = state as PrayerLoadedState;

    emit(
      currentState.copyWith(isAlertActive: false, triggeredAlertPrayer: null),
    );
  }
}
