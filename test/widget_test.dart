import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pengingat_azhan/app/theme/app_theme.dart';
import 'package:pengingat_azhan/core/constants/app_constants.dart';
import 'package:pengingat_azhan/core/utils/prayer_calculator.dart';
import 'package:pengingat_azhan/core/widgets/ingetin_sholat_logo.dart';
import 'package:pengingat_azhan/features/prayer_time/domain/entities/prayer_schedule.dart';
import 'package:pengingat_azhan/features/prayer_time/domain/entities/reminder_settings.dart';
import 'package:pengingat_azhan/features/prayer_time/presentation/widgets/next_prayer_hero_card.dart';
import 'package:pengingat_azhan/features/prayer_time/presentation/widgets/prayer_time_tile.dart';

void main() {
  testWidgets('NextPrayerHeroCard renders location and next prayer correctly', (
    WidgetTester tester,
  ) async {
    final now = DateTime(2026, 11, 18, 10, 0);
    const settings = ReminderSettings();
    final schedule = PrayerScheduleEntity.create(
      currentTime: now,
      location: CityLocation.defaultCity,
      settings: settings,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: NextPrayerHeroCard(
            schedule: schedule,
            settings: settings,
            onChangeCityTap: () {},
            onTestAlertTap: () {},
          ),
        ),
      ),
    );

    expect(find.text(CityLocation.defaultCity.name), findsOneWidget);
    expect(find.text('WAKTU SHOLAT BERIKUTNYA'), findsOneWidget);
    expect(find.text('Tes Pengingat'), findsOneWidget);
  });

  testWidgets('PrayerTimeTile renders prayer details and triggers actions', (
    WidgetTester tester,
  ) async {
    final prayer = SinglePrayerInfo(
      type: PrayerType.dzuhur,
      prayerTime: DateTime(2026, 11, 18, 11, 35),
      reminderTime: DateTime(2026, 11, 18, 11, 30),
      offsetMinutes: 5,
      isReminderActive: true,
      isNext: true,
    );

    bool reminderToggled = false;
    bool offsetEdited = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: PrayerTimeTile(
            prayer: prayer,
            onToggleReminder: (val) {
              reminderToggled = true;
            },
            onEditOffset: () {
              offsetEdited = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('Dzuhur'), findsOneWidget);
    expect(find.text('11:35'), findsOneWidget);
    expect(find.textContaining('-5m'), findsOneWidget);

    // Tap edit offset pill
    await tester.tap(find.textContaining('-5m'));
    expect(offsetEdited, isTrue);

    // Toggle switch
    await tester.tap(find.byType(Switch));
    expect(reminderToggled, isTrue);
  });

  testWidgets('IngetinSholatLogo renders with correct size and fallback', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: IngetinSholatLogo(size: 36))),
    );

    expect(find.byType(IngetinSholatLogo), findsOneWidget);
  });
}
