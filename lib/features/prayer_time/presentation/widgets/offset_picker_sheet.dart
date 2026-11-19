import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/date_formatter.dart';

class OffsetPickerSheet extends StatefulWidget {
  final PrayerType prayerType;
  final DateTime prayerTime;
  final int currentOffsetMinutes;
  final ValueChanged<int> onOffsetSaved;

  const OffsetPickerSheet({
    super.key,
    required this.prayerType,
    required this.prayerTime,
    required this.currentOffsetMinutes,
    required this.onOffsetSaved,
  });

  static Future<void> show(
    BuildContext context, {
    required PrayerType prayerType,
    required DateTime prayerTime,
    required int currentOffsetMinutes,
    required ValueChanged<int> onOffsetSaved,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => OffsetPickerSheet(
        prayerType: prayerType,
        prayerTime: prayerTime,
        currentOffsetMinutes: currentOffsetMinutes,
        onOffsetSaved: onOffsetSaved,
      ),
    );
  }

  @override
  State<OffsetPickerSheet> createState() => _OffsetPickerSheetState();
}

class _OffsetPickerSheetState extends State<OffsetPickerSheet> {
  late int _selectedOffset;

  @override
  void initState() {
    super.initState();
    _selectedOffset = widget.currentOffsetMinutes;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final prayerTimeStr = IslamicDateHelper.formatTime(widget.prayerTime);
    final reminderTime = widget.prayerTime.subtract(
      Duration(minutes: _selectedOffset),
    );
    final reminderTimeStr = IslamicDateHelper.formatTime(reminderTime);

    const presetOffsets = [0, 3, 5, 7, 10, 15, 20, 30];

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: Container(
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0C241E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(
              color: isDark ? const Color(0xFF1A453A) : const Color(0xFFE2EBE5),
              width: 1,
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
                const Gap(18),

                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Atur Pengingat ${widget.prayerType.nameId}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const Gap(2),
                        Text(
                          'Berapa menit sebelum waktu adzan tiba?',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: isDark
                                ? Colors.white54
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Gap(20),

                // Dynamic Live Preview Box
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [const Color(0xFF133E32), const Color(0xFF0C2921)]
                          : [const Color(0xFFE8F5EE), const Color(0xFFDCEDE3)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF10B981).withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.alarm_on_rounded,
                          color: Color(0xFF10B981),
                          size: 24,
                        ),
                      ),
                      const Gap(16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedOffset > 0
                                  ? 'Pengingat: Pukul $reminderTimeStr WIB'
                                  : 'Pengingat: Pukul $prayerTimeStr WIB (Tepat Adzan)',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF064E3B),
                              ),
                            ),
                            const Gap(3),
                            Text(
                              _selectedOffset > 0
                                  ? '($_selectedOffset menit sebelum adzan $prayerTimeStr WIB)'
                                  : '(Tepat saat adzan berkumandang)',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? Colors.white70
                                    : const Color(0xFF334155),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(22),

                // Preset Chips
                const Text(
                  'Pilihan Cepat Waktu:',
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
                ),
                const Gap(10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: presetOffsets.map((offset) {
                    final isSelected = _selectedOffset == offset;
                    return ChoiceChip(
                      label: Text(
                        offset == 0 ? 'Tepat Adzan (0m)' : '-$offset Menit',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.w800
                              : FontWeight.w600,
                          color: isSelected ? Colors.white : null,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: const Color(0xFF0F5A47),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedOffset = offset;
                          });
                        }
                      },
                    );
                  }).toList(),
                ),
                const Gap(20),

                // Slider
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Atur Slider Menit:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '$_selectedOffset Menit',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _selectedOffset.toDouble(),
                  min: 0,
                  max: 60,
                  divisions: 60,
                  activeColor: const Color(0xFF0F5A47),
                  inactiveColor: isDark ? Colors.white12 : Colors.grey.shade300,
                  label: '$_selectedOffset Menit',
                  onChanged: (val) {
                    setState(() {
                      _selectedOffset = val.round();
                    });
                  },
                ),
                const Gap(18),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      widget.onOffsetSaved(_selectedOffset);
                      Navigator.of(context).pop();
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF0F5A47),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Simpan Pengaturan Pengingat',
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
      ),
    );
  }
}
