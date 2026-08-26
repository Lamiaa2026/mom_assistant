import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette - Warm Rose & Soft Peach
  static const Color primary = Color(0xFFFF6F91);
  static const Color primaryLight = Color(0xFFFF9671);
  static const Color primaryDark = Color(0xFFD64D73);
  static const Color primarySoft = Color(0xFFFFF0F3);

  // Secondary Palette - Calming Lavender & Dreamy Purple
  static const Color secondary = Color(0xFF845EC2);
  static const Color secondaryLight = Color(0xFFB39CD0);
  static const Color secondarySoft = Color(0xFFF3E8FF);

  // Accent Palette - Gentle Mint, Warm Amber & Sky Blue
  static const Color mint = Color(0xFF00C9A7);
  static const Color mintSoft = Color(0xFFE8FBF8);
  static const Color amber = Color(0xFFFFC75F);
  static const Color amberSoft = Color(0xFFFFF8E7);
  static const Color skyBlue = Color(0xFF4D80E4);
  static const Color skyBlueSoft = Color(0xFFEBF3FF);
  static const Color coral = Color(0xFFFF8066);

  // Neutral Colors (Light Mode)
  static const Color backgroundLight = Color(0xFFFBF9FA);
  static const Color surfaceLight = Colors.white;
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF2C2738);
  static const Color textSecondaryLight = Color(0xFF7E7A8A);
  static const Color textMutedLight = Color(0xFFA7A3B4);
  static const Color dividerLight = Color(0xFFF0ECF4);
  static const Color borderLight = Color(0xFFEBE6F0);

  // Neutral Colors (Dark Mode - Soothing Night Nursing Mode)
  static const Color backgroundDark = Color(0xFF16151E);
  static const Color surfaceDark = Color(0xFF1F1D2B);
  static const Color cardDark = Color(0xFF252336);
  static const Color textPrimaryDark = Color(0xFFF5F3F8);
  static const Color textSecondaryDark = Color(0xFFADA9BC);
  static const Color textMutedDark = Color(0xFF6B677A);
  static const Color dividerDark = Color(0xFF2D2B3F);
  static const Color borderDark = Color(0xFF35324A);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF6F91), Color(0xFFFF9671)],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  static const LinearGradient lavenderGradient = LinearGradient(
    colors: [Color(0xFF845EC2), Color(0xFFB39CD0)],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  static const LinearGradient mintGradient = LinearGradient(
    colors: [Color(0xFF00C9A7), Color(0xFF4D80E4)],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  static const LinearGradient nightGradient = LinearGradient(
    colors: [Color(0xFF1A1829), Color(0xFF2A2440)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient warmCardGradient = LinearGradient(
    colors: [Color(0xFFFFF5F7), Color(0xFFFFF0F5)],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );
}
