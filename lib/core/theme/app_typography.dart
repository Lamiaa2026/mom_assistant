import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  static TextStyle get displayLarge => GoogleFonts.cairo(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      );

  static TextStyle get displayMedium => GoogleFonts.cairo(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      );

  static TextStyle get titleLarge => GoogleFonts.cairo(
        fontSize: 20,
        fontWeight: FontWeight.w700,
      );

  static TextStyle get titleMedium => GoogleFonts.cairo(
        fontSize: 17,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get titleSmall => GoogleFonts.cairo(
        fontSize: 15,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get bodyLarge => GoogleFonts.cairo(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.cairo(
        fontSize: 13,
        fontWeight: FontWeight.normal,
        height: 1.5,
      );

  static TextStyle get bodySmall => GoogleFonts.cairo(
        fontSize: 11,
        fontWeight: FontWeight.normal,
      );

  static TextStyle get labelLarge => GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w700,
      );

  static TextStyle get labelMedium => GoogleFonts.cairo(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get labelSmall => GoogleFonts.cairo(
        fontSize: 10,
        fontWeight: FontWeight.w500,
      );
}
