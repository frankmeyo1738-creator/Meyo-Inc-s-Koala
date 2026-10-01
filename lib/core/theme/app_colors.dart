import 'package:flutter/material.dart';

/// Koala's aesthetic color palette with dark mode support
class AppColors {
  // Primary Colors - The Koala Identity
  static const Color creamWhite = Color(0xFFFAF7F0);
  static const Color sageGreen = Color(0xFF9CAF88);
  static const Color mochaBrown = Color(0xFF8B7355);
  static const Color dustyRose = Color(0xFFD4A5A5);
  static const Color softTerracotta = Color(0xFFD4997D);

  // Light Mode Colors
  static const Color background = creamWhite;
  static const Color brandAccent = sageGreen;
  static const Color subtleDetails = mochaBrown;
  static const Color highlights = dustyRose;
  static const Color ctaButton = softTerracotta;

  // Text Colors - Light Mode
  static const Color textPrimary = Color(0xFF2C2C2C);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textTertiary = Color(0xFF9E9E9E);
  static const Color textOnBrand = Color(0xFFFFFFFF);

  // UI Element Colors - Light Mode
  static const Color divider = Color(0xFFE8E8E8);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color shadow = Color(0x0F000000);

  // Interaction States
  static const Color hoverOverlay = Color(0x14D4A5A5);
  static const Color activeOverlay = Color(0x299CAF88);
  static const Color ripple = Color(0x1F9CAF88);

  // ==================== DARK MODE COLORS ====================
  
  // Dark Mode Backgrounds
  // Dark Mode Backgrounds
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkCardBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  
  // Dark Mode Text
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFE0E0E0);
  static const Color darkTextTertiary = Color(0xFFBDBDBD);
  
  // Dark Mode UI Elements
  static const Color darkDivider = Color(0xFF2A2A2A);
  static const Color darkShadow = Color(0x66000000);

  // Gradients
  static const LinearGradient aestheticGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [dustyRose, softTerracotta],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF252525), Color(0xFF161616)],
  );
}
