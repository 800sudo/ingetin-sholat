import 'package:equatable/equatable.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/prayer_calculator.dart';
import 'reminder_settings.dart';

class SinglePrayerInfo extends Equatable {
  final PrayerType type;
  final DateTime prayerTime;
  final DateTime reminderTime;
  final int offsetMinutes;
  final bool isReminderActive;
  final bool isNext;
  final bool isPassed;

  const SinglePrayerInfo({
    required this.type,
    required this.prayerTime,
    required this.reminderTime,
    required this.offsetMinutes,
    required this.isReminderActive,
    this.isNext = false,
    this.isPassed = false,
  });

  @override
  List<Object?> get props => [
    type,
    prayerTime,
    reminderTime,
    offsetMinutes,
    isReminderActive,
    isNext,
    isPassed,
  ];
}

class PrayerScheduleEntity extends Equatable {
  final DateTime date;
  final CityLocation location;
  final List<SinglePrayerInfo> prayers;
  final SinglePrayerInfo? nextPrayer;
  final Duration timeUntilNextPrayer;

  const PrayerScheduleEntity({
    required this.date,
    required this.location,
    required this.prayers,
    this.nextPrayer,
    this.timeUntilNextPrayer = Duration.zero,
  });

  static PrayerScheduleEntity create({
    required DateTime currentTime,
    required CityLocation location,
    required ReminderSettings settings,
  }) {
    final scheduleResult = PrayerCalculator.calculate(
      date: currentTime,
      location: location,
    );

    // List of displayed prayers in chronological order
    const displayTypes = [
      PrayerType.imsak,
      PrayerType.subuh,
      PrayerType.syuruq,
      PrayerType.dzuhur,
      PrayerType.ashar,
      PrayerType.maghrib,
      PrayerType.isya,
    ];

    SinglePrayerInfo? next;
    final prayerList = <SinglePrayerInfo>[];

    for (final type in displayTypes) {
      final pTime = scheduleResult.getTime(type);
      final offset = settings.getOffsetFor(type);
      final rTime = settings.calculateReminderTime(type, pTime);
      final isEnabled = settings.isEnabledFor(type);
      final isPassed = currentTime.isAfter(pTime);

      final info = SinglePrayerInfo(
        type: type,
        prayerTime: pTime,
        reminderTime: rTime,
        offsetMinutes: offset,
        isReminderActive: isEnabled,
        isPassed: isPassed,
      );

      // Cari sholat berikutnya yang belum terlewat (fokus 5 waktu + subuh)
      if (next == null && !isPassed && type.isMajorPrayer) {
        next = info;
      }

      prayerList.add(info);
    }

    // Jika semua sholat hari ini sudah terlewat, maka sholat berikutnya adalah Subuh besok
    Duration durationUntilNext = Duration.zero;
    if (next == null) {
      final tomorrow = currentTime.add(const Duration(days: 1));
      final tomorrowSchedule = PrayerCalculator.calculate(
        date: tomorrow,
        location: location,
      );
      final subuhBesok = tomorrowSchedule.getTime(PrayerType.subuh);
      final offset = settings.getOffsetFor(PrayerType.subuh);
      next = SinglePrayerInfo(
        type: PrayerType.subuh,
        prayerTime: subuhBesok,
        reminderTime: settings.calculateReminderTime(
          PrayerType.subuh,
          subuhBesok,
        ),
        offsetMinutes: offset,
        isReminderActive: settings.isEnabledFor(PrayerType.subuh),
        isNext: true,
      );
      durationUntilNext = subuhBesok.difference(currentTime);
    } else {
      durationUntilNext = next.prayerTime.difference(currentTime);
    }

    // Update isNext flag pada prayerList
    final updatedList = prayerList.map((p) {
      final isNextItem =
          next != null &&
          p.type == next.type &&
          p.prayerTime.day == next.prayerTime.day;
      return SinglePrayerInfo(
        type: p.type,
        prayerTime: p.prayerTime,
        reminderTime: p.reminderTime,
        offsetMinutes: p.offsetMinutes,
        isReminderActive: p.isReminderActive,
        isNext: isNextItem,
        isPassed: p.isPassed,
      );
    }).toList();

    return PrayerScheduleEntity(
      date: currentTime,
      location: location,
      prayers: updatedList,
      nextPrayer: next,
      timeUntilNextPrayer: durationUntilNext.isNegative
          ? Duration.zero
          : durationUntilNext,
    );
  }

  @override
  List<Object?> get props => [
    date,
    location,
    prayers,
    nextPrayer,
    timeUntilNextPrayer,
  ];
}
