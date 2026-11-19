import 'package:material_ui/material_ui.dart';

class AppTheme {
  // Luxury Islamic Palette
  static const Color darkBg = Color(0xFF061512);
  static const Color darkCard = Color(0xFF0C221D);
  static const Color darkCardBorder = Color(0xFF163830);

  static const Color lightBg = Color(0xFFF6F9F7);
  static const Color lightCard = Colors.white;
  static const Color lightCardBorder = Color(0xFFE2EBE5);

  static const Color imperialEmerald = Color(0xFF074337);
  static const Color vibrantEmerald = Color(0xFF10B981);
  static const Color lightEmerald = Color(0xFF34D399);

  static const Color royalGold = Color(0xFFD4AF37);
  static const Color deepGold = Color(0xFFB8860B);
  static const Color warmGold = Color(0xFFF3BA4F);
  static const Color paleGold = Color(0xFFFDF6E2);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightBg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: imperialEmerald,
      brightness: Brightness.light,
      primary: imperialEmerald,
      secondary: royalGold,
      surface: lightCard,
      surfaceContainer: const Color(0xFFF0F5F2),
      surfaceContainerHighest: const Color(0xFFE4ECE7),
      outline: const Color(0xFFC8D7CE),
      outlineVariant: lightCardBorder,
    ),
    fontFamily: 'Segoe UI',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: Color(0xFF08261F),
        letterSpacing: 0.3,
      ),
      iconTheme: IconThemeData(color: Color(0xFF08261F)),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: lightCardBorder, width: 1.2),
      ),
      color: lightCard,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      elevation: 3,
      shadowColor: Colors.black12,
      indicatorColor: imperialEmerald.withValues(alpha: 0.12),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: imperialEmerald,
            letterSpacing: 0.2,
          );
        }
        return const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF64748B),
        );
      }),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: imperialEmerald,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          letterSpacing: 0.3,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: imperialEmerald,
        side: const BorderSide(color: imperialEmerald, width: 1.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: vibrantEmerald,
      brightness: Brightness.dark,
      primary: lightEmerald,
      secondary: warmGold,
      surface: darkCard,
      surfaceContainer: const Color(0xFF102D26),
      surfaceContainerHighest: const Color(0xFF163B32),
      outline: const Color(0xFF204E43),
      outlineVariant: darkCardBorder,
    ),
    fontFamily: 'Segoe UI',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: Colors.white,
        letterSpacing: 0.3,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: darkCardBorder, width: 1.2),
      ),
      color: darkCard,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFF091F1A),
      elevation: 0,
      indicatorColor: lightEmerald.withValues(alpha: 0.2),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: lightEmerald,
            letterSpacing: 0.2,
          );
        }
        return const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF94A3B8),
        );
      }),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: lightEmerald,
        foregroundColor: const Color(0xFF041914),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 14,
          letterSpacing: 0.3,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: lightEmerald,
        side: const BorderSide(color: Color(0xFF1F584C), width: 1.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
      ),
    ),
  );
}
