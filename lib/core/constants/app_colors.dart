import 'package:flutter/material.dart';

class AppColors {
  // ─── Brand Colors ────────────────────────────────────────────────────────────
  // Richer electric blue — stays consistent as the brand color
  static const Color primary = Color(0xFF2979FF);
  // Deep sapphire for secondary accents
  static const Color secondary = Color(0xFF0D47A1);
  // Gold accent — kept for highlights
  static const Color accent = Color(0xFFFFB300);

  // ─── Background & Surface (Sophisticated Charcoal / Deep Slate) ──────────────
  // Deep Charcoal Slate background — rich and modern
  static const Color background = Color(0xFF0F1115);
  // Charcoal Grey surface for cards — distinct from background
  static const Color surface = Color(0xFF1A1D23);
  // Slightly lighter slate for nested elements or input fields
  static const Color surfaceVariant = Color(0xFF252932);
  // Muted Slate border for subtle separation
  static const Color border = Color(0xFF2E343D);

  // ─── Status Colors (High Contrast for Dark) ──────────────────────────────────
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // ─── Busy Status Colors ──────────────────────────────────────────────────────
  static const Color statusNotBusy = Color(0xFF10B981);
  static const Color statusBusy = Color(0xFFF59E0B);
  static const Color statusVeryBusy = Color(0xFFEF4444);

  // ─── Text Colors (Complementary Slate Palette) ───────────────────────────────
  // High contrast white with a hint of cool slate to complement the theme
  static const Color textPrimary = Color(0xFFF8FAFC);
  // Soft silver-slate — clearly legible but secondary in hierarchy
  static const Color textSecondary = Color(0xFFCBD5E1);
  // Muted slate — for hints, timestamps, and tertiary info
  static const Color textTertiary = Color(0xFF64748B);

  // ─── Gradient Helpers ────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2979FF), Color(0xFF60A5FA)],
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A1D23), Color(0xFF0F1115)],
  );
}
