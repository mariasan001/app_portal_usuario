import 'package:flutter/material.dart';
import 'colores.dart';

class TemaApp {
  static ThemeData construir() {
    final scheme = ColorScheme.fromSeed(seedColor: ColoresApp.vino);

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: ColoresApp.blanco,
      fontFamily: 'Manrope', // ✅
    );

    final tt = base.textTheme.apply(fontFamily: 'Manrope'); // ✅

    return base.copyWith(
      textTheme: tt.copyWith(
        titleLarge: tt.titleLarge?.copyWith(fontSize: 20, fontWeight: FontWeight.w700),
        titleMedium: tt.titleMedium?.copyWith(fontSize: 14.5, fontWeight: FontWeight.w800),
        bodyMedium: tt.bodyMedium?.copyWith(fontSize: 13, height: 1.35),
        bodySmall: tt.bodySmall?.copyWith(fontSize: 11, height: 1.35),
        labelMedium: tt.labelMedium?.copyWith(fontSize: 12, fontWeight: FontWeight.w600),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF3F3F3),
        hintStyle: tt.bodySmall?.copyWith(color: const Color(0xFF9A9A9A), fontSize: 12),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF9A5A44),
          foregroundColor: Colors.white,
          textStyle: tt.labelLarge?.copyWith(fontWeight: FontWeight.w700, fontSize: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          minimumSize: const Size(220, 40),
        ),
      ),
    );
  }
}
