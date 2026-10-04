import 'package:flutter/material.dart';

/// Circular Salone colors from [design.json].
abstract final class AppColors {
  static const Color primary = Color(0xFF19A10F);
  static const Color primaryDark = Color(0xFF14850C);
  static const Color secondary = Color(0xFF0045A5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color headingNavy = Color(0xFF0045A5);
  static const Color bodyMuted = Color(0xFF5E7185);
  static const Color progressInactive = Color(0xFFB8C9D9);

  /// Auth screens — same brand green and blue as tokens above.
  static const Color loginPrimary = primary;
  static const Color loginNavy = secondary;
  static const Color inputBorder = Color(0xFFD8E0E8);
  static const Color inputHint = Color(0xFF6B7C8F);
}
