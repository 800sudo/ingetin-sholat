import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/islamic_pattern_painter.dart';
import '../../domain/entities/prayer_schedule.dart';
import '../../domain/entities/reminder_settings.dart';

class NextPrayerHeroCard extends StatelessWidget {
  final PrayerScheduleEntity schedule;
  final ReminderSettings settings;
  final VoidCallback onChangeCityTap;
  final VoidCallback onTestAlertTap;

  const NextPrayerHeroCard({
    super.key,
    required this.schedule,
    required this.settings,
    required this.onChangeCityTap,
    required this.onTestAlertTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final next = schedule.nextPrayer;

    final nextName = next?.type.nameId ?? 'Sholat';
    final nextArabic = next?.type.arabicName ?? 'الصلاة';
    final nextTimeStr = next != null
        ? IslamicDateHelper.formatTime(next.prayerTime)
        : '--:--';
    final offset = next != null
        ? settings.getOffsetFor(next.type)
        : settings.defaultOffsetMinutes;
    final reminderTimeStr = next != null
        ? IslamicDateHelper.formatTime(next.reminderTime)
        : '--:--';

    // Countdown split
    final duration = schedule.timeUntilNextPrayer;
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF092922), Color(0xFF061D18), Color(0xFF041410)]
              : const [Color(0xFF094337), Color(0xFF06332A), Color(0xFF04241D)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF06332A)
                .withValues(alpha: isDark ? 0.4 : 0.25),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFD4AF37).withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            // Islamic Geometric Decorative Background
            Positioned.fill(
              child: CustomPaint(
                painter: IslamicGeometricPainter(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.08),
                  strokeWidth: 1.2,
                ),
              ),
            ),

            // Foreground Content
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Location Pill & Hijri Date Badge
                  Row(
                    children: [
                      // Location selector button
                      Expanded(
                        child: InkWell(
                          onTap: onChangeCityTap,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFD4AF37)
                                    .withValues(alpha: 0.4),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.near_me_rounded,
                                  size: 14,
                                  color: Color(0xFFF3BA4F),
                                ),
                                const Gap(6),
                                Flexible(
                                  child: Text(
                                    schedule.location.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12.5,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ),
                                const Gap(3),
                                const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 16,
                                  color: Colors.white70,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const Gap(8),

                      // Hijri Date Pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4AF37)
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFD4AF37)
                                .withValues(alpha: 0.25),
                          ),
                        ),
                        child: Text(
                          IslamicDateHelper.getHijriDate(schedule.date),
                          style: const TextStyle(
                            color: Color(0xFFFCEFC7),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Gap(24),

                  // Middle Section: Prayer Name & Arabic Calligraphy
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3.5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981)
                                  .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFF10B981)
                                    .withValues(alpha: 0.4),
                              ),
                            ),
                            child: const Text(
                              'WAKTU SHOLAT BERIKUTNYA',
                              style: TextStyle(
                                color: Color(0xFF6EE7B7),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          const Gap(6),
                          Text(
                            nextName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                              height: 1.1,
                            ),
                          ),
                          const Gap(4),
                          Text(
                            'Waktu Adzan: $nextTimeStr WIB',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      // Elegant Arabic Text
                      Text(
                        nextArabic,
                        style: TextStyle(
                          fontFamily: 'serif',
                          color: const Color(0xFFD4AF37)
                              .withValues(alpha: 0.65),
                          fontSize: 42,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const Gap(22),

                  // Precision Countdown Box (Jam : Menit : Detik)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildDigitBlock(hours, 'JAM'),
                            _buildSeparator(),
                            _buildDigitBlock(minutes, 'MENIT'),
                            _buildSeparator(),
                            _buildDigitBlock(seconds, 'DETIK', isAccent: true),
                          ],
                        ),
                        const Gap(10),
                        Divider(
                          color: Colors.white.withValues(alpha: 0.1),
                          height: 1,
                        ),
                        const Gap(8),
                        // Reminder Info Line
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              offset > 0
                                  ? Icons.alarm_on_rounded
                                  : Icons.notifications_active_rounded,
                              size: 15,
                              color: const Color(0xFFF3BA4F),
                            ),
                            const Gap(6),
                            Flexible(
                              child: Text(
                                offset > 0
                                    ? 'Pengingat Aktif: Pukul $reminderTimeStr WIB (-$offset Menit Sebelum Adzan)'
                                    : 'Pengingat Aktif: Tepat Saat Waktu Adzan ($nextTimeStr WIB)',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFFFCEFC7),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Gap(18),

                  // Bottom Action Strip: Audio/Haptic Badges & Quick Test Button
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 10,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildStatusPill(
                            icon: settings.soundEnabled
                                ? Icons.volume_up_rounded
                                : Icons.volume_off_rounded,
                            label: settings.soundEnabled
                                ? 'Suara Aktif'
                                : 'Mute',
                            isActive: settings.soundEnabled,
                          ),
                          const Gap(8),
                          _buildStatusPill(
                            icon: settings.vibrationEnabled
                                ? Icons.vibration_rounded
                                : Icons.do_not_disturb_on_rounded,
                            label: settings.vibrationEnabled
                                ? 'Getar Aktif'
                                : 'No Getar',
                            isActive: settings.vibrationEnabled,
                          ),
                        ],
                      ),
                      // Test simulation button
                      InkWell(
                        onTap: onTestAlertTap,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFD4AF37), Color(0xFFB8860B)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFD4AF37)
                                    .withValues(alpha: 0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.play_arrow_rounded,
                                size: 16,
                                color: Color(0xFF041410),
                              ),
                              Gap(4),
                              Text(
                                'Tes Pengingat',
                                style: TextStyle(
                                  color: Color(0xFF041410),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDigitBlock(String value, String label, {bool isAccent = false}) {
    return Column(
      children: [
        Container(
          width: 52,
          padding: const EdgeInsets.symmetric(vertical: 4),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: isAccent ? 0.15 : 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isAccent
                  ? const Color(0xFF34D399).withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.12),
              width: 1,
            ),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              fontFamily: 'monospace',
              letterSpacing: 1.5,
              color: isAccent ? const Color(0xFF6EE7B7) : Colors.white,
            ),
          ),
        ),
        const Gap(4),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildSeparator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Text(
        ':',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.5),
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildStatusPill({
    required IconData icon,
    required String label,
    required bool isActive,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: isActive ? 0.12 : 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? const Color(0xFFD4AF37).withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: isActive ? const Color(0xFFF3BA4F) : Colors.white38,
          ),
          const Gap(5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : Colors.white38,
            ),
          ),
        ],
      ),
    );
  }
}
