import 'package:flutter/material.dart';

/// Production dark theme colors for premium wearable app.
class AppColors {
  AppColors._();

  // Backgrounds
  static const Color background = Color(0xFF0D0D0F);
  static const Color surface = Color(0xFF16161A);
  static const Color surfaceElevated = Color(0xFF1E1E24);
  static const Color card = Color(0xFF1A1A1F);

  // Text
  static const Color textPrimary = Color(0xFFF4F4F5);
  static const Color textSecondary = Color(0xFFA1A1AA);
  static const Color textMuted = Color(0xFF71717A);

  // Accent & metrics
  static const Color accent = Color(0xFF22D3EE);
  static const Color accentSecondary = Color(0xFFA78BFA);
  static const Color heart = Color(0xFFF43F5E);
  static const Color success = Color(0xFF34D399);
  static const Color warning = Color(0xFFFBBF24);
  static const Color error = Color(0xFFEF4444);

  // Chart & graph
  static const Color chartLine = Color(0xFF22D3EE);
  static const Color chartLineSecondary = Color(0xFFA78BFA);
  static const Color chartGrid = Color(0xFF27272A);
  static const Color chartFill = Color(0x1A22D3EE);

  // Sleep stages (for timeline)
  static const Color sleepWake = Color(0xFF71717A);
  static const Color sleepRem = Color(0xFFA78BFA);
  static const Color sleepLight = Color(0xFF22D3EE);
  static const Color sleepDeep = Color(0xFF3B82F6);
}
