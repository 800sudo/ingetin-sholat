import 'package:equatable/equatable.dart';

import '../../domain/entities/prayer_schedule.dart';
import '../../domain/entities/reminder_settings.dart';

abstract class PrayerState extends Equatable {
  const PrayerState();

  @override
  List<Object?> get props => [];
}

class PrayerInitialState extends PrayerState {
  const PrayerInitialState();
}

class PrayerLoadingState extends PrayerState {
  const PrayerLoadingState();
}

class PrayerLoadedState extends PrayerState {
  final PrayerScheduleEntity schedule;
  final ReminderSettings settings;
  final DateTime currentTime;
  final SinglePrayerInfo? triggeredAlertPrayer;
  final bool isAlertActive;

  const PrayerLoadedState({
    required this.schedule,
    required this.settings,
    required this.currentTime,
    this.triggeredAlertPrayer,
    this.isAlertActive = false,
  });

  PrayerLoadedState copyWith({
    PrayerScheduleEntity? schedule,
    ReminderSettings? settings,
    DateTime? currentTime,
    SinglePrayerInfo? triggeredAlertPrayer,
    bool? isAlertActive,
  }) {
    return PrayerLoadedState(
      schedule: schedule ?? this.schedule,
      settings: settings ?? this.settings,
      currentTime: currentTime ?? this.currentTime,
      triggeredAlertPrayer: triggeredAlertPrayer ?? this.triggeredAlertPrayer,
      isAlertActive: isAlertActive ?? this.isAlertActive,
    );
  }

  @override
  List<Object?> get props => [
    schedule,
    settings,
    currentTime,
    triggeredAlertPrayer,
    isAlertActive,
  ];
}

class PrayerErrorState extends PrayerState {
  final String message;

  const PrayerErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
