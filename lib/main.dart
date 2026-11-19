import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import 'app/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'features/prayer_time/presentation/bloc/prayer_bloc.dart';
import 'features/prayer_time/presentation/bloc/prayer_state.dart';
import 'features/prayer_time/presentation/pages/home_page.dart';
import 'injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initInjection();
  runApp(const PrayerReminderApp());
}

class PrayerReminderApp extends StatelessWidget {
  const PrayerReminderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<PrayerBloc>(),
      child: BlocBuilder<PrayerBloc, PrayerState>(
        builder: (context, state) {
          final isDark =
              state is PrayerLoadedState && state.settings.isDarkMode;

          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
            home: const MainNavigationScreen(),
          );
        },
      ),
    );
  }
}
