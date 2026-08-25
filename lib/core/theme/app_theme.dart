import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Text roles. Headings use Caprasimo (display, characterful),
/// body/UI uses Figtree — matching the reference design system.
class AppText {
  AppText._();

  static TextStyle heading(
          {double size = 24, Color? color, double height = 1.15}) =>
      GoogleFonts.caprasimo(
          fontSize: size, color: color ?? AppColors.text, height: height);

  static TextStyle body({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double height = 1.4,
  }) =>
      GoogleFonts.figtree(
          fontSize: size,
          fontWeight: weight,
          color: color ?? AppColors.text,
          height: height);
}

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final base = ThemeData.light();
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bg,
      primaryColor: AppColors.accent,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.accent,
        secondary: AppColors.accent2,
        surface: AppColors.surface,
        onSurface: AppColors.text,
      ),
      // fontFamily: GoogleFonts.figtree().fontFamily,
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.text,
        displayColor: AppColors.text,
        fontFamily: GoogleFonts.figtree().fontFamily,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.text),
        titleTextStyle: AppText.heading(size: 20),
      ),
      splashFactory: InkRipple.splashFactory,
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      }),
    );
  }
}

/// Shared radii/spacing tokens (mirrors --radius / --space in the ref CSS).
class AppRadius {
  AppRadius._();
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 28.0;
  static const pill = 999.0;
}

class AppSpace {
  AppSpace._();
  static const s1 = 4.0;
  static const s2 = 8.0;
  static const s3 = 12.0;
  static const s4 = 16.0;
  static const s6 = 24.0;
  static const s8 = 32.0;
}

class AppShadow {
  AppShadow._();
  static List<BoxShadow> sm = [
    BoxShadow(
        color: AppColors.neutral900.withOpacity(0.10),
        blurRadius: 4,
        offset: const Offset(0, 1)),
  ];
  static List<BoxShadow> md = [
    BoxShadow(
        color: AppColors.neutral900.withOpacity(0.12),
        blurRadius: 14,
        offset: const Offset(0, 4)),
  ];
  static List<BoxShadow> lg = [
    BoxShadow(
        color: AppColors.neutral900.withOpacity(0.18),
        blurRadius: 32,
        offset: const Offset(0, 12)),
  ];
}
