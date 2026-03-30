import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// App theme configuration for Ripple Chat
class AppTheme {
  AppTheme._();

  /// Light theme configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      pageTransitionsTheme: pageTransitionTheme,
      colorScheme: ColorScheme.light(
        brightness: Brightness.light,
        primary: lightColors.primary,
        onPrimary: Colors.white,
        primaryContainer: lightColors.primaryLight.withOpacity(0.1),
        onPrimaryContainer: lightColors.primaryDark,
        secondary: lightColors.primary.withOpacity(0.7),
        onSecondary: Colors.white,
        surface: lightColors.surface,
        onSurface: lightColors.textPrimary,
        background: lightColors.background,
        onBackground: lightColors.textPrimary,
        error: lightColors.error,
        onError: Colors.white,
        outline: lightColors.border,
        outlineVariant: lightColors.border.withOpacity(0.5),
        surfaceVariant: lightColors.background,
        onSurfaceVariant: lightColors.textSecondary,
      ),
      textTheme: AppTypography.createTextTheme().apply(
        bodyColor: lightColors.textPrimary,
        displayColor: lightColors.textPrimary,
      ),
      scaffoldBackgroundColor: lightColors.background,
      appBarTheme: _buildAppBarTheme(isLight: true),
      elevatedButtonTheme: _buildElevatedButtonTheme(isLight: true),
      outlinedButtonTheme: _buildOutlinedButtonTheme(isLight: true),
      textButtonTheme: _buildTextButtonTheme(isLight: true),
      inputDecorationTheme: _buildInputDecorationTheme(isLight: true),
      cardTheme: _buildCardTheme(isLight: true),
      bottomNavigationBarTheme: _buildBottomNavTheme(isLight: true),
      dividerTheme: DividerThemeData(
        color: lightColors.border,
        thickness: 1,
        space: 1,
      ),
      iconTheme: IconThemeData(color: lightColors.textSecondary, size: 24),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      fontFamily: AppTypography.fontFamily,
    );
  }

  /// Dark theme configuration
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      pageTransitionsTheme: pageTransitionTheme,
      colorScheme: ColorScheme.dark(
        brightness: Brightness.dark,
        primary: darkColors.primary,
        onPrimary: Colors.white,
        primaryContainer: darkColors.primaryDark.withOpacity(0.2),
        onPrimaryContainer: darkColors.primaryLight,
        secondary: darkColors.primary.withOpacity(0.8),
        onSecondary: Colors.white,
        surface: darkColors.surface,
        onSurface: darkColors.textPrimary,
        background: darkColors.background,
        onBackground: darkColors.textPrimary,
        error: darkColors.error,
        onError: Colors.white,
        outline: darkColors.border,
        outlineVariant: darkColors.border.withOpacity(0.5),
        surfaceVariant: darkColors.surface,
        onSurfaceVariant: darkColors.textSecondary,
      ),
      textTheme: AppTypography.createTextTheme().apply(
        bodyColor: darkColors.textPrimary,
        displayColor: darkColors.textPrimary,
      ),
      scaffoldBackgroundColor: darkColors.background,
      appBarTheme: _buildAppBarTheme(isLight: false),
      elevatedButtonTheme: _buildElevatedButtonTheme(isLight: false),
      outlinedButtonTheme: _buildOutlinedButtonTheme(isLight: false),
      textButtonTheme: _buildTextButtonTheme(isLight: false),
      inputDecorationTheme: _buildInputDecorationTheme(isLight: false),
      cardTheme: _buildCardTheme(isLight: false),
      bottomNavigationBarTheme: _buildBottomNavTheme(isLight: false),
      dividerTheme: DividerThemeData(
        color: darkColors.border,
        thickness: 1,
        space: 1,
      ),
      iconTheme: IconThemeData(color: darkColors.textSecondary, size: 24),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      fontFamily: AppTypography.fontFamily,
    );
  }

  // AppBar theme
  static AppBarTheme _buildAppBarTheme({required bool isLight}) {
    return AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: isLight ? lightColors.background : darkColors.background,
      foregroundColor: isLight
          ? lightColors.textPrimary
          : darkColors.textPrimary,
      titleTextStyle: AppTypography.headlineSmall.copyWith(
        color: isLight ? lightColors.textPrimary : darkColors.textPrimary,
      ),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isLight ? Brightness.dark : Brightness.light,
        statusBarBrightness: isLight ? Brightness.light : Brightness.dark,
      ),
    );
  }

  // Elevated button theme
  static ElevatedButtonThemeData _buildElevatedButtonTheme({
    required bool isLight,
  }) {
    return ElevatedButtonThemeData(
      style:
          ElevatedButton.styleFrom(
            backgroundColor: isLight ? lightColors.primary : darkColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shadowColor: isLight
                ? lightColors.primary.withOpacity(0.25)
                : darkColors.primary.withOpacity(0.25),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: const Size(0, 56),
            textStyle: AppTypography.buttonLarge,
          ).copyWith(
            overlayColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.pressed)) {
                return Colors.white.withOpacity(0.1);
              }
              if (states.contains(MaterialState.hovered)) {
                return Colors.white.withOpacity(0.05);
              }
              return null;
            }),
          ),
    );
  }

  // Outlined button theme
  static OutlinedButtonThemeData _buildOutlinedButtonTheme({
    required bool isLight,
  }) {
    return OutlinedButtonThemeData(
      style:
          OutlinedButton.styleFrom(
            foregroundColor: isLight
                ? lightColors.textPrimary
                : darkColors.textPrimary,
            backgroundColor: Colors.transparent,
            side: BorderSide(
              color: isLight ? lightColors.border : darkColors.border,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: const Size(0, 56),
            textStyle: AppTypography.buttonLarge,
          ).copyWith(
            overlayColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.pressed)) {
                return (colors(isLight: isLight).textPrimary).withOpacity(0.05);
              }
              if (states.contains(MaterialState.hovered)) {
                return (colors(isLight: isLight).textPrimary).withOpacity(0.02);
              }
              return null;
            }),
          ),
    );
  }

  // Text button theme
  static TextButtonThemeData _buildTextButtonTheme({required bool isLight}) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colors(isLight: isLight).primary,
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        minimumSize: const Size(0, 48),
        textStyle: AppTypography.buttonMedium,
      ),
    );
  }

  // Input decoration theme
  static InputDecorationTheme _buildInputDecorationTheme({
    required bool isLight,
  }) {
    return InputDecorationTheme(
      filled: true,
      fillColor: colors(isLight: isLight).surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors(isLight: isLight).border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors(isLight: isLight).border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: colors(isLight: isLight).primary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors(isLight: isLight).error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors(isLight: isLight).error, width: 2),
      ),
      labelStyle: AppTypography.bodyMedium.copyWith(
        color: colors(isLight: isLight).textSecondary,
      ),
      hintStyle: AppTypography.bodyMedium.copyWith(
        color: colors(isLight: isLight).textSecondary,
      ),
    );
  }

  // Card theme
  static CardThemeData _buildCardTheme({required bool isLight}) {
    return CardThemeData(
      elevation: 0,
      color: colors(isLight: isLight).surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        // side: BorderSide(color: colors(isLight: isLight).border, width: 1),
      ),
      margin: EdgeInsets.zero,
    );
  }

  // Bottom navigation theme
  static BottomNavigationBarThemeData _buildBottomNavTheme({
    required bool isLight,
  }) {
    return BottomNavigationBarThemeData(
      backgroundColor: colors(isLight: isLight).surface,
      selectedItemColor: colors(isLight: isLight).primary,
      unselectedItemColor: colors(isLight: isLight).textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: AppTypography.labelSmall,
      unselectedLabelStyle: AppTypography.labelSmall,
    );
  }
}

final pageTransitionTheme = PageTransitionsTheme(
  builders: kIsWeb
      ? {
          for (final platform in TargetPlatform.values)
            platform: const FadeForwardsPageTransitionsBuilder(),
        }
      : const {
          // Use default transitions for non-web platforms
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        },
);
