import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/ingetin_sholat_logo.dart';
import '../bloc/prayer_bloc.dart';
import '../bloc/prayer_event.dart';
import '../bloc/prayer_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrayerBloc, PrayerState>(
      builder: (context, state) {
        if (state is! PrayerLoadedState) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final settings = state.settings;
        final isDark = settings.isDarkMode;

        return Scaffold(
          appBar: AppBar(
            centerTitle: false,
            title: const Text(
              'Pengaturan',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 840),
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                children: [
                  // Section 1: Mode Bunyi & Getar
                  _buildSectionHeader(
                    context,
                    title: 'Mode Bunyi & Getar',
                    subtitle: 'Atur preferensi audio dan getaran saat pengingat aktif',
                    icon: Icons.notifications_active_outlined,
                  ),
                  const Gap(14),

                  Card(
                    child: Column(
                      children: [
                        SwitchListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 4,
                          ),
                          secondary: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: settings.soundEnabled
                                  ? const Color(0xFF10B981)
                                        .withValues(alpha: 0.15)
                                  : Colors.grey.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              settings.soundEnabled
                                  ? Icons.volume_up_rounded
                                  : Icons.volume_off_rounded,
                              color: settings.soundEnabled
                                  ? const Color(0xFF10B981)
                                  : Colors.grey,
                            ),
                          ),
                          title: const Text(
                            'Bunyi Pengingat',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: const Text(
                            'Memainkan suara adzan atau nada pengingat',
                          ),
                          value: settings.soundEnabled,
                          onChanged: (val) {
                            context.read<PrayerBloc>().add(
                              UpdateSoundSettingEvent(val),
                            );
                          },
                        ),
                        const Divider(height: 1, indent: 20, endIndent: 20),
                        SwitchListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 4,
                          ),
                          secondary: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: settings.vibrationEnabled
                                  ? const Color(0xFF10B981)
                                        .withValues(alpha: 0.15)
                                  : Colors.grey.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              settings.vibrationEnabled
                                  ? Icons.vibration_rounded
                                  : Icons.do_not_disturb_on_rounded,
                              color: settings.vibrationEnabled
                                  ? const Color(0xFF10B981)
                                  : Colors.grey,
                            ),
                          ),
                          title: const Text(
                            'Getar (Vibrate)',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: const Text(
                            'Menggetarkan perangkat saat pengingat aktif',
                          ),
                          value: settings.vibrationEnabled,
                          onChanged: (val) {
                            context.read<PrayerBloc>().add(
                              UpdateVibrationSettingEvent(val),
                            );
                          },
                        ),
                        const Divider(height: 1, indent: 20, endIndent: 20),
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 4,
                          ),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4AF37)
                                  .withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.music_note_rounded,
                              color: Color(0xFFD97706),
                            ),
                          ),
                          title: const Text(
                            'Pilihan Nada Pengingat',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(settings.notificationTone),
                          trailing: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                          ),
                          onTap: () {
                            _showTonePicker(context, settings.notificationTone);
                          },
                        ),
                      ],
                    ),
                  ),
                  const Gap(24),

                  // Section 2: Metode Perhitungan Astronomis
                  _buildSectionHeader(
                    context,
                    title: 'Metode Perhitungan Hisab',
                    subtitle: 'Standar penentuan jadwal sholat offline',
                    icon: Icons.calculate_outlined,
                  ),
                  const Gap(14),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F5A47)
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.verified_rounded,
                                  color: Color(0xFF0F5A47),
                                  size: 20,
                                ),
                              ),
                              const Gap(12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Kementerian Agama RI (Kemenag)',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Gap(2),
                                    Text(
                                      'Hisab Astronomis Matahari (Offline)',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981)
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Aktif',
                                  style: TextStyle(
                                    color: Color(0xFF10B981),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Gap(14),
                          const Divider(height: 1),
                          const Gap(14),
                          _buildParameterRow('Sudut Fajar Subuh', '20.0°'),
                          const Gap(8),
                          _buildParameterRow('Sudut Syafaq Isya', '18.0°'),
                          const Gap(8),
                          _buildParameterRow(
                            'Waktu Imsak',
                            '10 menit sebelum Subuh',
                          ),
                          const Gap(8),
                          _buildParameterRow(
                            'Faktor Kehati-hatian (Ihtiyat)',
                            '+2 Menit',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Gap(24),

                  // Section 3: Tentang Aplikasi
                  _buildSectionHeader(
                    context,
                    title: 'Tentang Aplikasi',
                    subtitle: 'Informasi dan versi Ingetin Sholat',
                    icon: Icons.info_outline_rounded,
                  ),
                  const Gap(14),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Row(
                            children: [
                              IngetinSholatLogo(size: 48, borderRadius: 12),
                              Gap(16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppConstants.appName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16.5,
                                      ),
                                    ),
                                    Gap(2),
                                    Text(
                                      'Versi ${AppConstants.appVersion} • 100% Offline',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Gap(16),
                          Text(
                            'Aplikasi pengingat waktu adzan elegan dengan hisab astronomis lokal, kustomisasi menit pengingat sebelum adzan, dan cakupan 345+ kota se-Indonesia.',
                            style: TextStyle(
                              fontSize: 12.5,
                              height: 1.45,
                              color: isDark
                                  ? Colors.white70
                                  : Colors.grey.shade700,
                            ),
                          ),
                          const Gap(16),
                          const Divider(height: 1),
                          const Gap(14),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF102821)
                                  : const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF10B981)
                                    .withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF25D366)
                                        .withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.support_agent_rounded,
                                    color: Color(0xFF10B981),
                                    size: 22,
                                  ),
                                ),
                                const Gap(12),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Layanan Bantuan & Dukungan:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Gap(2),
                                      Text(
                                        '089660626800',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                          color: Color(0xFF10B981),
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Gap(32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _buildParameterRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12.5, color: Colors.grey)),
        Text(
          value,
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: const Color(0xFF0F5A47).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF0F5A47)),
        ),
        const Gap(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
              const Gap(2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showTonePicker(BuildContext context, String currentTone) {
    const tones = [
      'Adzan Suara Merdu',
      'Adzan Makkah Al-Mukarramah',
      'Adzan Madinah Al-Munawwarah',
      'Nada Lembut Islami',
      'Beep Alarm Pengingat',
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Pilih Nada Pengingat',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const Gap(14),
              ...tones.map((tone) {
                final isSelected = tone == currentTone;
                return ListTile(
                  title: Text(
                    tone,
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.w500,
                      color: isSelected ? const Color(0xFF0F5A47) : null,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF0F5A47),
                        )
                      : null,
                  onTap: () {
                    context.read<PrayerBloc>().add(
                      UpdateNotificationToneEvent(tone),
                    );
                    Navigator.of(ctx).pop();
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
