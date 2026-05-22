import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Dark Blue colors
  static const Color primary = Color(0xFF0F2027); // Deep rich dark blue
  static const Color primaryDark = Color(0xFF071115);
  static const Color primaryLight = Color(0xFF203A43);

  // Accent Solar Orange colors
  static const Color accent = Color(0xFFF2709C); // Warm Orange-Pink gradient feeling or Solid Solar Orange
  static const Color solarOrange = Color(0xFFFF7E00); // Solar Orange
  static const Color solarOrangeLight = Color(0xFFFFB037);

  // Background and Surfaces
  static const Color backgroundLight = Color(0xFFFAFAFC);
  static const Color surfaceLight = Colors.white;
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // Status Colors
  static const Color lead = Color(0xFF0288D1); // Light Blue
  static const Color surveyPending = Color(0xFFF57C00); // Orange
  static const Color quotationSent = Color(0xFF7B1FA2); // Purple
  static const Color approved = Color(0xFF388E3C); // Green
  static const Color completed = Color(0xFF2E7D32); // Dark Green
  static const Color cancelled = Color(0xFFD32F2F); // Red

  // Text Colors
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textLight = Color(0xFFEEEEEE);
  static const Color textMuted = Color(0xFF757575);

  // Quotation lock colors
  static const Color locked = Color(0xFFE53935);
  static const Color unlocked = Color(0xFF43A047);
}
