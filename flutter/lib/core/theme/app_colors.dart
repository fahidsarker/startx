import 'package:flutter/material.dart';

/// App color palette based on the Ripple Chat design system

const lightColors = AppColors();
const darkColors = DarkAppColors();

AppColors colors({bool isLight = true}) => isLight ? lightColors : darkColors;

class AppColors {
  const AppColors();

  // Primary colors
  Color get primary => Color(0xFF2B8CEE);
  Color get onPrimary => Color(0xFFFFFFFF);
  Color get primaryDark => Color(0xFF1E6BCC);
  Color get primaryLight => Color(0xFF4FA3F1);

  // Background colors
  Color get background => Color(0xFFF6F7F8);

  // Surface colors
  Color get surface => Color(0xFFFFFFFF);

  // Text colors
  Color get textPrimary => Color(0xFF111418);
  Color get textSecondary => Color(0xFF637588);

  // Border colors
  Color get border => Color(0xFFDCE0E5);

  // Status colors
  Color get success => Color(0xFF10B981);
  Color get warning => Color(0xFFF59E0B);
  Color get error => Color(0xFFEF4444);
  Color get info => Color(0xFF3B82F6);

  // Utility colors
  Color get transparent => Colors.transparent;
  Color get overlay => Color(0x80000000);
}

class DarkAppColors extends AppColors {
  const DarkAppColors();

  @override
  Color get background => Color(0xFF101922);
  @override
  Color get textPrimary => Color(0xFFFFFFFF);
  @override
  Color get textSecondary => Color(0xFF93AEBF);
  @override
  Color get border => Color(0xFF333B45);
  @override
  Color get surface => Color(0xFF283039);
}
