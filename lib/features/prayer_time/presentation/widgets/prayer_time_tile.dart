import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/prayer_schedule.dart';

class PrayerTimeTile extends StatelessWidget {
  final SinglePrayerInfo prayer;
  final ValueChanged<bool> onToggleReminder;
  final VoidCallback onEditOffset;

  const PrayerTimeTile({
    super.key,
    required this.prayer,
    required this.onToggleReminder,
    required this.onEditOffset,
  });

  IconData _getPrayerIcon(PrayerType type) {
    switch (type) {
      case PrayerType.imsak:
        return Icons.nights_stay_rounded;
      case PrayerType.subuh:
        return Icons.wb_twilight_rounded;
      case PrayerType.syuruq:
        return Icons.wb_sunny_outlined;
      case PrayerType.dzuhur:
        return Icons.wb_sunny_rounded;
      case PrayerType.ashar:
        return Icons.cloud_queue_rounded;
      case PrayerType.maghrib:
        return Icons.wb_twilight_rounded;
      case PrayerType.isya:
        return Icons.bedtime_rounded;
    }
  }

  Color _getPrayerAccentColor(PrayerType type) {
    switch (type) {
      case PrayerType.imsak:
        return const Color(0xFF6366F1); // Indigo
      case PrayerType.subuh:
        return const Color(0xFF0EA5E9); // Sky
      case PrayerType.syuruq:
        return const Color(0xFFF59E0B); // Amber
      case PrayerType.dzuhur:
        return const Color(0xFFEAB308); // Gold Sun
      case PrayerType.ashar:
        return const Color(0xFFF97316); // Orange
      case PrayerType.maghrib:
        return const Color(0xFFEF4444); // Sunset
      case PrayerType.isya:
        return const Color(0xFF8B5CF6); // Purple
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isNext = prayer.isNext;
    final timeStr = IslamicDateHelper.formatTime(prayer.prayerTime);
    final reminderTimeStr = IslamicDateHelper.formatTime(prayer.reminderTime);
    final accentColor = _getPrayerAccentColor(prayer.type);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isNext
            ? (isDark ? const Color(0xFF0F2E26) : const Color(0xFFF0FDF4))
            : (isDark ? const Color(0xFF0A1F1A) : Colors.white),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isNext
              ? const Color(0xFF10B981)
              : (isDark ? const Color(0xFF173830) : const Color(0xFFE5EDE8)),
          width: isNext ? 1.8 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isNext
                ? const Color(0xFF10B981).withValues(alpha: 0.18)
                : Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: isNext ? 18 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Left active indicator strip
          if (isNext)
            Positioned(
              left: 0,
              top: 10,
              bottom: 10,
              child: Container(
                width: 4.5,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withValues(alpha: 0.6),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
            child: Row(
              children: [
                // Icon avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: isDark ? 0.2 : 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: accentColor.withValues(alpha: isDark ? 0.4 : 0.25),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    _getPrayerIcon(prayer.type),
                    color: accentColor,
                    size: 20,
                  ),
                ),
                const Gap(14),

                // Prayer Name & Reminder Offset Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            prayer.type.nameId,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isNext
                                  ? FontWeight.w800
                                  : FontWeight.w700,
                              color: isNext
                                  ? (isDark
                                        ? const Color(0xFF6EE7B7)
                                        : const Color(0xFF065F46))
                                  : (isDark
                                        ? Colors.white
                                        : const Color(0xFF0F172A)),
                            ),
                          ),
                          const Gap(8),
                          Text(
                            prayer.type.arabicName,
                            style: TextStyle(
                              fontFamily: 'serif',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white38 : Colors.black38,
                            ),
                          ),
                          if (isNext) ...[
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'SELANJUTNYA',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const Gap(4),

                      // Interactive Offset Badge
                      if (prayer.type.isMajorPrayer)
                        InkWell(
                          onTap: onEditOffset,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: prayer.isReminderActive
                                  ? (isDark
                                        ? const Color(0xFFD4AF37)
                                              .withValues(alpha: 0.15)
                                        : const Color(0xFFFEF3C7))
                                  : (isDark
                                        ? Colors.white10
                                        : const Color(0xFFF1F5F9)),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: prayer.isReminderActive
                                    ? const Color(0xFFD4AF37)
                                          .withValues(alpha: 0.4)
                                    : Colors.transparent,
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  prayer.isReminderActive
                                      ? Icons.alarm_on_rounded
                                      : Icons.alarm_off_rounded,
                                  size: 13,
                                  color: prayer.isReminderActive
                                      ? const Color(0xFFD97706)
                                      : Colors.grey,
                                ),
                                const Gap(5),
                                Text(
                                  prayer.isReminderActive
                                      ? (prayer.offsetMinutes > 0
                                            ? 'Pengingat: -${prayer.offsetMinutes}m ($reminderTimeStr)'
                                            : 'Pengingat tepat waktu ($timeStr)')
                                      : 'Pengingat nonaktif',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: prayer.isReminderActive
                                        ? (isDark
                                              ? const Color(0xFFFDE68A)
                                              : const Color(0xFFB45309))
                                        : Colors.grey.shade600,
                                  ),
                                ),
                                const Gap(4),
                                Icon(
                                  Icons.edit_outlined,
                                  size: 11,
                                  color: prayer.isReminderActive
                                      ? const Color(0xFFD97706)
                                      : Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const Gap(14),

                // Exact Adzan Time & Toggle Switch
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      timeStr,
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: isNext
                            ? (isDark
                                  ? const Color(0xFF6EE7B7)
                                  : const Color(0xFF047857))
                            : (isDark ? Colors.white : const Color(0xFF0F172A)),
                      ),
                    ),
                    if (prayer.type.isMajorPrayer) ...[
                      const Gap(2),
                      SizedBox(
                        height: 28,
                        child: Switch(
                          value: prayer.isReminderActive,
                          onChanged: onToggleReminder,
                          activeThumbColor: Colors.white,
                          activeTrackColor: const Color(0xFF10B981),
                          inactiveThumbColor: Colors.grey.shade400,
                          inactiveTrackColor: isDark
                              ? Colors.white12
                              : Colors.grey.shade200,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
