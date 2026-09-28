import 'package:flutter/material.dart';

/// FitFlow colour palette.
///
/// Reference these constants (or `Theme.of(context)`) instead of writing raw
/// colour values inside screens and widgets.
abstract final class AppColors {
  static const Color primary = Color(0xFF2E7D5B);
  static const Color primaryDark = Color(0xFF1F5A43);
  static const Color accent = Color(0xFFA8D5BA);
  static const Color background = Color(0xFFF6F8F5);
  static const Color card = Color(0xFFFFFFFF);
  static const Color heading = Color(0xFF1C2823);
  static const Color secondaryText = Color(0xFF6B756F);
  static const Color progressAccent = Color(0xFF4CAF7A);
  static const Color border = Color(0xFFE2E8E4);

  /// Soft shadow used under cards; intentionally very light.
  static const Color cardShadow = Color(0x0F1C2823);
}
