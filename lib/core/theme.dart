import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Brand colors. Keep every color used by the UI here so screens stay
/// consistent.
abstract final class AppColors {
  /// Brand colors from the Pandai logo.
  static const brandEmerald = Color(0xFF1E9A70);
  static const brandDeep = Color(0xFF407A58);

  /// Emerald darkened just enough for white text to stay readable (WCAG AA).
  static const forest = Color(0xFF13805C);
  static const forestDark = Color(0xFF0E5C43);
  static const leaf = brandEmerald;
  static const mint = Color(0xFFE2F3EB);
  static const sun = Color(0xFFF2A93B);
  static const sunSoft = Color(0xFFFDF1DC);
  static const sky = Color(0xFF8EC7E6);
  static const skySoft = Color(0xFFE5F3FA);
  static const soil = Color(0xFF8A5A3B);
  static const berry = Color(0xFFD0573F);
  static const berrySoft = Color(0xFFFBE7E3);

  static const ink = Color(0xFF17241F);
  static const inkMuted = Color(0xFF5B6B64);
  static const line = Color(0xFFE1E8E4);
  static const background = Color(0xFFF6F8F6);
  static const surface = Colors.white;
}

/// Spacing scale shared by all screens.
abstract final class Gap {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}

/// Space to leave under scrolling tab content so the floating navigation
/// bar does not cover it.
const kNavBarClearance = 120.0;

abstract final class Radii {
  static const sm = 10.0;
  static const md = 16.0;
  static const lg = 24.0;
}

const _display = 'Poppins';
const _body = 'Inter';

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.forest,
    primary: AppColors.forest,
    onPrimary: Colors.white,
    secondary: AppColors.sun,
    onSecondary: AppColors.ink,
    error: AppColors.berry,
    surface: AppColors.surface,
    onSurface: AppColors.ink,
  ).copyWith(
    primaryContainer: AppColors.mint,
    onPrimaryContainer: AppColors.forestDark,
    surfaceContainerHighest: AppColors.background,
    outline: AppColors.line,
    outlineVariant: AppColors.line,
  );

  const textTheme = TextTheme(
    displaySmall: TextStyle(
      fontFamily: _display,
      fontSize: 30,
      fontWeight: FontWeight.w700,
      height: 1.2,
      color: AppColors.ink,
    ),
    headlineMedium: TextStyle(
      fontFamily: _display,
      fontSize: 26,
      fontWeight: FontWeight.w700,
      height: 1.25,
      color: AppColors.ink,
    ),
    headlineSmall: TextStyle(
      fontFamily: _display,
      fontSize: 22,
      fontWeight: FontWeight.w600,
      height: 1.3,
      color: AppColors.ink,
    ),
    titleLarge: TextStyle(
      fontFamily: _display,
      fontSize: 19,
      fontWeight: FontWeight.w600,
      height: 1.3,
      color: AppColors.ink,
    ),
    titleMedium: TextStyle(
      fontFamily: _display,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.35,
      color: AppColors.ink,
    ),
    titleSmall: TextStyle(
      fontFamily: _body,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.35,
      color: AppColors.ink,
    ),
    bodyLarge: TextStyle(
      fontFamily: _body,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: AppColors.ink,
    ),
    bodyMedium: TextStyle(
      fontFamily: _body,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.45,
      color: AppColors.ink,
    ),
    bodySmall: TextStyle(
      fontFamily: _body,
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.4,
      color: AppColors.inkMuted,
    ),
    labelLarge: TextStyle(
      fontFamily: _body,
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: AppColors.ink,
    ),
    labelMedium: TextStyle(
      fontFamily: _body,
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: AppColors.ink,
    ),
    labelSmall: TextStyle(
      fontFamily: _body,
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.3,
      color: AppColors.inkMuted,
    ),
  );

  final buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(Radii.md),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: _body,
    textTheme: textTheme,
    scaffoldBackgroundColor: AppColors.background,
    splashFactory: InkSparkle.splashFactory,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.ink,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: TextStyle(
        fontFamily: _display,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.md),
        side: const BorderSide(color: AppColors.line),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 52),
        shape: buttonShape,
        textStyle: textTheme.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(64, 52),
        shape: buttonShape,
        foregroundColor: AppColors.forest,
        side: const BorderSide(color: AppColors.line, width: 1.5),
        textStyle: textTheme.labelLarge,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.forest,
        textStyle: textTheme.labelLarge,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.md),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.md),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.md),
        borderSide: const BorderSide(color: AppColors.forest, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.md),
        borderSide: const BorderSide(color: AppColors.berry),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.md),
        borderSide: const BorderSide(color: AppColors.berry, width: 1.5),
      ),
      hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.inkMuted),
      prefixIconColor: AppColors.inkMuted,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.mint,
      side: const BorderSide(color: AppColors.line),
      labelStyle: textTheme.labelMedium,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.line,
      thickness: 1,
      space: 1,
    ),
    listTileTheme: ListTileThemeData(
      iconColor: AppColors.inkMuted,
      titleTextStyle: textTheme.titleSmall,
      subtitleTextStyle: textTheme.bodySmall,
      contentPadding: const EdgeInsets.symmetric(horizontal: Gap.lg),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.ink,
      contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.lg),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.forest,
      linearTrackColor: AppColors.mint,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: AppColors.mint,
      height: 68,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => textTheme.labelSmall?.copyWith(
          color:
              states.contains(WidgetState.selected)
                  ? AppColors.forestDark
                  : AppColors.inkMuted,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color:
              states.contains(WidgetState.selected)
                  ? AppColors.forestDark
                  : AppColors.inkMuted,
        ),
      ),
    ),
  );
}
