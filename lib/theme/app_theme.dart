import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppColors {
  static const bg       = Color(0xFF0F0E0C);
  static const surface  = Color(0xFF1A1915);
  static const surface2 = Color(0xFF23211D);
  static const surface3 = Color(0xFF2A2720);
  static const gold     = Color(0xFFC8A96E);
  static const gold2    = Color(0xFFE8C98A);
  static const cream    = Color(0xFFF0E6D3);
  static const muted    = Color(0xFF7A7060);
  static const dim      = Color(0xFF4A4538);
  static const green    = Color(0xFF2ECC71);
  static const red      = Color(0xFFE74C3C);

  // 투명도 변형 (withOpacity 대신 하드코드 — 15% alpha = 0x26)
  static const goldSubtle  = Color(0x26C8A96E);
  static const mutedSubtle = Color(0x267A7060);
}

abstract final class AppTheme {
  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    final noto = GoogleFonts.notoSansKr;

    final tt = base.textTheme.copyWith(
      bodyLarge:   noto(color: AppColors.cream),
      bodyMedium:  noto(color: AppColors.cream),
      bodySmall:   noto(color: AppColors.muted, fontSize: 12),
      titleLarge:  noto(color: AppColors.cream, fontWeight: FontWeight.w600),
      titleMedium: noto(color: AppColors.cream, fontWeight: FontWeight.w500),
      labelSmall:  noto(color: AppColors.muted, fontSize: 11),
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: const ColorScheme.dark(
        primary:     AppColors.gold,
        onPrimary:   AppColors.bg,
        secondary:   AppColors.gold2,
        onSecondary: AppColors.bg,
        surface:     AppColors.surface,
        onSurface:   AppColors.cream,
        error:       AppColors.red,
        onError:     AppColors.cream,
        outline:     AppColors.dim,
      ),
      textTheme: tt,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.cream,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.cream),
        titleTextStyle: noto(
          color: AppColors.cream,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface2,
        labelStyle: noto(color: AppColors.muted),
        hintStyle: noto(color: AppColors.muted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.dim),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.dim),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.red, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.bg,
          disabledBackgroundColor: AppColors.dim,
          textStyle: noto(fontWeight: FontWeight.w600, fontSize: 15),
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.gold),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.dim,
        space: 1,
        thickness: 1,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.surface2,
        titleTextStyle: TextStyle(color: AppColors.cream, fontSize: 17, fontWeight: FontWeight.w600),
        contentTextStyle: TextStyle(color: AppColors.cream),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.surface3,
        contentTextStyle: TextStyle(color: AppColors.cream),
      ),
    );
  }
}
