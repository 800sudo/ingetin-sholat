import 'package:equatable/equatable.dart';

import '../../../../core/constants/app_constants.dart';

abstract class PrayerEvent extends Equatable {
  const PrayerEvent();

  @override
  List<Object?> get props => [];
}

class LoadPrayerDataEvent extends PrayerEvent {
  const LoadPrayerDataEvent();
}

class PrayerTickEvent extends PrayerEvent {
  final DateTime now;
  const PrayerTickEvent(this.now);

  @override
  List<Object?> get props => [now];
}

class UpdateCityEvent extends PrayerEvent {
  final String cityId;
  const UpdateCityEvent(this.cityId);

  @override
  List<Object?> get props => [cityId];
}

class UpdateDefaultOffsetEvent extends PrayerEvent {
  final int minutes;
  const UpdateDefaultOffsetEvent(this.minutes);

  @override
  List<Object?> get props => [minutes];
}

class UpdatePrayerOffsetEvent extends PrayerEvent {
  final PrayerType type;
  final int minutes;
  const UpdatePrayerOffsetEvent(this.type, this.minutes);

  @override
  List<Object?> get props => [type, minutes];
}

class TogglePrayerReminderEvent extends PrayerEvent {
  final PrayerType type;
  final bool isEnabled;
  const TogglePrayerReminderEvent(this.type, this.isEnabled);

  @override
  List<Object?> get props => [type, isEnabled];
}

class UpdateSoundSettingEvent extends PrayerEvent {
  final bool enabled;
  const UpdateSoundSettingEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class UpdateVibrationSettingEvent extends PrayerEvent {
  final bool enabled;
  const UpdateVibrationSettingEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class UpdateNotificationToneEvent extends PrayerEvent {
  final String tone;
  const UpdateNotificationToneEvent(this.tone);

  @override
  List<Object?> get props => [tone];
}

class ToggleThemeModeEvent extends PrayerEvent {
  final bool isDark;
  const ToggleThemeModeEvent(this.isDark);

  @override
  List<Object?> get props => [isDark];
}

class TriggerSimulatedAlertEvent extends PrayerEvent {
  final PrayerType type;
  const TriggerSimulatedAlertEvent({this.type = PrayerType.dzuhur});

  @override
  List<Object?> get props => [type];
}

class DismissActiveAlertEvent extends PrayerEvent {
  const DismissActiveAlertEvent();
}
