import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/prayer_schedule.dart';
import '../../domain/entities/reminder_settings.dart';

class ReminderAlertDialog extends StatefulWidget {
  final SinglePrayerInfo prayer;
  final ReminderSettings settings;
  final VoidCallback onDismiss;

  const ReminderAlertDialog({
    super.key,
    required this.prayer,
    required this.settings,
    required this.onDismiss,
  });

  static Future<void> show(
    BuildContext context, {
    required SinglePrayerInfo prayer,
    required ReminderSettings settings,
    required VoidCallback onDismiss,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ReminderAlertDialog(
        prayer: prayer,
        settings: settings,
        onDismiss: () {
          Navigator.of(ctx).pop();
          onDismiss();
        },
      ),
    );
  }

  @override
  State<ReminderAlertDialog> createState() => _ReminderAlertDialogState();
}

class _ReminderAlertDialogState extends State<ReminderAlertDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.94, end: 1.06).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final prayer = widget.prayer;
    final settings = widget.settings;
    final timeStr = IslamicDateHelper.formatTime(prayer.prayerTime);
    final offset = prayer.offsetMinutes;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(32),
        side: const BorderSide(color: Color(0xFFD4AF37), width: 1.4),
      ),
      backgroundColor: isDark ? const Color(0xFF09241D) : Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pulsing Luxury Bell Icon
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 86,
                  height: 86,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFD4AF37), Color(0xFFB8860B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.45),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.notifications_active_rounded,
                    size: 44,
                    color: Color(0xFF041410),
                  ),
                ),
              ),
              const Gap(22),

              // Status Tag
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF10B981).withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  offset > 0
                      ? 'PENGINGAT $offset MENIT SEBELUM ADZAN'
                      : 'WAKTU ADZAN TELAH MASUK',
                  style: const TextStyle(
                    color: Color(0xFF10B981),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const Gap(12),

              // Title & Arabic Name
              Text(
                'Waktu Sholat ${prayer.type.nameId}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF06332A),
                  letterSpacing: -0.3,
                ),
              ),
              const Gap(4),
              Text(
                prayer.type.arabicName,
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 22,
                  color: const Color(0xFFD4AF37),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Gap(10),

              Text(
                offset > 0
                    ? 'Waktu adzan ${prayer.type.nameId} akan berkumandang pukul $timeStr WIB. Bersiaplah untuk menyucikan diri dan mengambil air wudhu.'
                    : 'Telah masuk waktu sholat ${prayer.type.nameId} ($timeStr WIB). Segeralah dirikan sholat.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white70 : const Color(0xFF475569),
                  height: 1.5,
                ),
              ),
              const Gap(18),

              // Mode info strip
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF113329)
                      : const Color(0xFFF1F5F3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.white10 : const Color(0xFFE2EBE5),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      settings.soundEnabled
                          ? Icons.volume_up_rounded
                          : Icons.volume_off_rounded,
                      size: 16,
                      color: settings.soundEnabled
                          ? const Color(0xFFD97706)
                          : Colors.grey,
                    ),
                    const Gap(6),
                    Text(
                      settings.soundEnabled
                          ? settings.notificationTone
                          : 'Suara Mati',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? Colors.white70
                            : const Color(0xFF334155),
                      ),
                    ),
                    const Gap(18),
                    Icon(
                      settings.vibrationEnabled
                          ? Icons.vibration_rounded
                          : Icons.do_not_disturb_on_rounded,
                      size: 16,
                      color: settings.vibrationEnabled
                          ? const Color(0xFFD97706)
                          : Colors.grey,
                    ),
                    const Gap(6),
                    Text(
                      settings.vibrationEnabled ? 'Getar Aktif' : 'Getar Mati',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? Colors.white70
                            : const Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(24),

              // Dismiss Button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: widget.onDismiss,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0F5A47),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Matikan Pengingat / Tutup',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
