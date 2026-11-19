import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/ingetin_sholat_logo.dart';
import '../../domain/entities/reminder_settings.dart';
import '../bloc/prayer_bloc.dart';
import '../bloc/prayer_event.dart';
import '../bloc/prayer_state.dart';
import '../widgets/city_picker_sheet.dart';
import '../widgets/next_prayer_hero_card.dart';
import '../widgets/offset_picker_sheet.dart';
import '../widgets/prayer_time_tile.dart';
import '../widgets/reminder_alert_dialog.dart';
import 'settings_page.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  Timer? _tickerTimer;
  bool _isAlertDialogShown = false;

  @override
  void initState() {
    super.initState();
    context.read<PrayerBloc>().add(const LoadPrayerDataEvent());

    _tickerTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        context.read<PrayerBloc>().add(PrayerTickEvent(DateTime.now()));
      }
    });
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    super.dispose();
  }

  void _handleAlertTrigger(BuildContext context, PrayerLoadedState state) {
    if (state.isAlertActive &&
        state.triggeredAlertPrayer != null &&
        !_isAlertDialogShown) {
      _isAlertDialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ReminderAlertDialog.show(
          context,
          prayer: state.triggeredAlertPrayer!,
          settings: state.settings,
          onDismiss: () {
            _isAlertDialogShown = false;
            context.read<PrayerBloc>().add(const DismissActiveAlertEvent());
          },
        ).then((_) {
          _isAlertDialogShown = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PrayerBloc, PrayerState>(
      listener: (context, state) {
        if (state is PrayerLoadedState) {
          _handleAlertTrigger(context, state);
        }
      },
      builder: (context, state) {
        if (state is PrayerLoadingState || state is PrayerInitialState) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Color(0xFF10B981)),
                  Gap(16),
                  Text(
                    'Memuat Jadwal Sholat...',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is PrayerErrorState) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: Colors.red,
                    ),
                    const Gap(12),
                    Text(state.message, textAlign: TextAlign.center),
                    const Gap(16),
                    FilledButton(
                      onPressed: () {
                        context.read<PrayerBloc>().add(
                          const LoadPrayerDataEvent(),
                        );
                      },
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final loaded = state as PrayerLoadedState;
        final isDark = loaded.settings.isDarkMode;

        final pages = [PrayerHomePageView(state: loaded), const SettingsPage()];

        return Scaffold(
          body: IndexedStack(
            index: _currentIndex == 2 ? 1 : 0,
            children: pages,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: NavigationBar(
              selectedIndex: _currentIndex,
              height: 68,
              onDestinationSelected: (idx) {
                if (idx == 1) {
                  // Toggle Dark Mode
                  final nextDark = !isDark;
                  context.read<PrayerBloc>().add(
                    ToggleThemeModeEvent(nextDark),
                  );
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: const Duration(milliseconds: 1200),
                      behavior: SnackBarBehavior.floating,
                      content: Text(
                        nextDark
                            ? 'Mode Gelap (Dark Mode) Aktif'
                            : 'Mode Terang (Light Mode) Aktif',
                      ),
                    ),
                  );
                } else {
                  setState(() {
                    _currentIndex = idx;
                  });
                }
              },
              destinations: [
                const NavigationDestination(
                  icon: Icon(Icons.mosque_outlined),
                  selectedIcon: Icon(Icons.mosque_rounded),
                  label: 'Jadwal Sholat',
                ),
                NavigationDestination(
                  icon: Icon(
                    isDark
                        ? Icons.light_mode_outlined
                        : Icons.dark_mode_outlined,
                    color: isDark ? const Color(0xFFF3BA4F) : null,
                  ),
                  selectedIcon: Icon(
                    isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    color: isDark ? const Color(0xFFF3BA4F) : null,
                  ),
                  label: 'Dark Mode',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.tune_outlined),
                  selectedIcon: Icon(Icons.tune_rounded),
                  label: 'Pengaturan',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class PrayerHomePageView extends StatelessWidget {
  final PrayerLoadedState state;

  const PrayerHomePageView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final schedule = state.schedule;
    final settings = state.settings;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 16,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IngetinSholatLogo(size: 32),
            Gap(10),
            Flexible(
              child: Text(
                AppConstants.appName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Ganti Lokasi Kota',
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isDark ? Colors.white12 : const Color(0xFFE2EBE5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.location_on_rounded, size: 18),
            ),
            onPressed: () {
              CityPickerSheet.show(
                context,
                currentCityId: schedule.location.id,
                onCitySelected: (cityId) {
                  context.read<PrayerBloc>().add(UpdateCityEvent(cityId));
                },
              );
            },
          ),
          IconButton(
            tooltip: 'Simulasi Bunyi & Getar',
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.notifications_active_rounded,
                size: 18,
                color: Color(0xFFD97706),
              ),
            ),
            onPressed: () {
              context.read<PrayerBloc>().add(
                const TriggerSimulatedAlertEvent(type: PrayerType.dzuhur),
              );
            },
          ),
          const Gap(8),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 840;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1060),
              child: isWide
                  // Dual-Column Luxury Dashboard for Tablet & Desktop
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 18,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left Pane: Hero Card & Quick Offset Panel
                          Expanded(
                            flex: 5,
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  NextPrayerHeroCard(
                                    schedule: schedule,
                                    settings: settings,
                                    onChangeCityTap: () {
                                      CityPickerSheet.show(
                                        context,
                                        currentCityId: schedule.location.id,
                                        onCitySelected: (cityId) {
                                          context.read<PrayerBloc>().add(
                                            UpdateCityEvent(cityId),
                                          );
                                        },
                                      );
                                    },
                                    onTestAlertTap: () {
                                      context.read<PrayerBloc>().add(
                                        const TriggerSimulatedAlertEvent(
                                          type: PrayerType.dzuhur,
                                        ),
                                      );
                                    },
                                  ),
                                  const Gap(18),
                                  _buildInteractiveOffsetSelector(
                                    context,
                                    settings,
                                    isDark,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Gap(28),

                          // Right Pane: Full Prayer Schedule List
                          Expanded(
                            flex: 6,
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Jadwal Waktu Sholat',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? Colors.white10
                                              : const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Text(
                                          IslamicDateHelper.getIndonesianFullDate(
                                            schedule.date,
                                          ),
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: isDark
                                                ? Colors.white70
                                                : const Color(0xFF475569),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Gap(14),
                                  ...schedule.prayers.map((prayer) {
                                    return PrayerTimeTile(
                                      prayer: prayer,
                                      onToggleReminder: (val) {
                                        context.read<PrayerBloc>().add(
                                          TogglePrayerReminderEvent(
                                            prayer.type,
                                            val,
                                          ),
                                        );
                                      },
                                      onEditOffset: () {
                                        OffsetPickerSheet.show(
                                          context,
                                          prayerType: prayer.type,
                                          prayerTime: prayer.prayerTime,
                                          currentOffsetMinutes:
                                              prayer.offsetMinutes,
                                          onOffsetSaved: (newOffset) {
                                            context.read<PrayerBloc>().add(
                                              UpdatePrayerOffsetEvent(
                                                prayer.type,
                                                newOffset,
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  // Single-Column Clean Layout for Mobile
                  : ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      children: [
                        NextPrayerHeroCard(
                          schedule: schedule,
                          settings: settings,
                          onChangeCityTap: () {
                            CityPickerSheet.show(
                              context,
                              currentCityId: schedule.location.id,
                              onCitySelected: (cityId) {
                                context.read<PrayerBloc>().add(
                                  UpdateCityEvent(cityId),
                                );
                              },
                            );
                          },
                          onTestAlertTap: () {
                            context.read<PrayerBloc>().add(
                              const TriggerSimulatedAlertEvent(
                                type: PrayerType.dzuhur,
                              ),
                            );
                          },
                        ),
                        const Gap(16),

                        // Fast Offset Selector Bar
                        _buildInteractiveOffsetSelector(
                          context,
                          settings,
                          isDark,
                        ),
                        const Gap(20),

                        // Section Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Text(
                                'Jadwal Sholat Hari Ini',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                            const Gap(8),
                            Text(
                              IslamicDateHelper.getIndonesianFullDate(
                                schedule.date,
                              ),
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? Colors.white54
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        const Gap(12),

                        // Prayer Cards List
                        ...schedule.prayers.map((prayer) {
                          return PrayerTimeTile(
                            prayer: prayer,
                            onToggleReminder: (val) {
                              context.read<PrayerBloc>().add(
                                TogglePrayerReminderEvent(prayer.type, val),
                              );
                            },
                            onEditOffset: () {
                              OffsetPickerSheet.show(
                                context,
                                prayerType: prayer.type,
                                prayerTime: prayer.prayerTime,
                                currentOffsetMinutes: prayer.offsetMinutes,
                                onOffsetSaved: (newOffset) {
                                  context.read<PrayerBloc>().add(
                                    UpdatePrayerOffsetEvent(
                                      prayer.type,
                                      newOffset,
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        }),
                        const Gap(24),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInteractiveOffsetSelector(
    BuildContext context,
    ReminderSettings settings,
    bool isDark,
  ) {
    const presetOffsets = [0, 3, 5, 10, 15, 20];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0C241E) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? const Color(0xFF163E32) : const Color(0xFFE2EBE5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.timer_outlined,
                  size: 15,
                  color: Color(0xFFD97706),
                ),
              ),
              const Gap(8),
              const Expanded(
                child: Text(
                  'Atur Cepat Pengingat Sebelum Adzan:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
              const Gap(8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F5A47),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  settings.defaultOffsetMinutes == 0
                      ? 'Tepat Adzan'
                      : '-${settings.defaultOffsetMinutes} Menit',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const Gap(12),

          // Horizontal Fast Selection Pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: presetOffsets.map((mins) {
                final isSelected = settings.defaultOffsetMinutes == mins;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () {
                      context.read<PrayerBloc>().add(
                        UpdateDefaultOffsetEvent(mins),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? const LinearGradient(
                                colors: [Color(0xFF0F5A47), Color(0xFF0B4A3A)],
                              )
                            : null,
                        color: isSelected
                            ? null
                            : (isDark
                                  ? Colors.white10
                                  : const Color(0xFFF1F5F3)),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF10B981)
                              : (isDark
                                    ? Colors.white12
                                    : const Color(0xFFE2EBE5)),
                          width: isSelected ? 1.4 : 1,
                        ),
                      ),
                      child: Text(
                        mins == 0 ? 'Tepat Waktu' : '-$mins Menit',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.w800
                              : FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                    ? Colors.white70
                                    : const Color(0xFF334155)),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
