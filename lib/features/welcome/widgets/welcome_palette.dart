import 'package:flutter/material.dart';

import 'package:amanjalan/core/theme/aj_theme.dart';

/// Palet warna halaman Welcome. t = 0 → siang, t = 1 → malam.
class WelcomePalette {
  final double t;
  const WelcomePalette(this.t);

  bool get isNight => t >= 0.5;

  Color _mix(Color day, Color night) => Color.lerp(day, night, t)!;

  // Langit
  Color get skyTop => _mix(const Color(0xFFFFF1EE), const Color(0xFF12061F));
  Color get skyMid => _mix(const Color(0xFFFDF8F6), const Color(0xFF2A1042));
  Color get skyBottom => _mix(const Color(0xFFF1F7EA), const Color(0xFF4A2070));
  Color get blobA => _mix(Aj.blushDeep.withValues(alpha: 0.8), const Color(0xFF8A3F5C).withValues(alpha: 0.38));
  Color get blobB => _mix(Aj.mint.withValues(alpha: 0.75), const Color(0xFF3D2A7A).withValues(alpha: 0.35));

  // Teks
  Color get title => _mix(Aj.plum, Colors.white);
  Color get subtitle => _mix(Aj.muted, const Color(0xFFE2C8EC));

  // Pemandangan
  Color get skyline => _mix(const Color(0xFFEADFEA), const Color(0xFF1A0C2A));
  Color get hillBack => _mix(const Color(0xFFE6F2DC), const Color(0xFF30194A));
  Color get hillFront => _mix(const Color(0xFFD2E7C3), const Color(0xFF24123A));

  // Tombol
  Color get primary => _mix(Aj.plum, const Color(0xFFF7DDE6));
  Color get onPrimary => _mix(Colors.white, Aj.plum);
  Color get primaryGlow => _mix(Aj.plum.withValues(alpha: 0.30), const Color(0xFFF2A7BE).withValues(alpha: 0.35));
  Color get outlineBorder => _mix(const Color(0xFF4E9A5B), const Color(0xFFB9DDB2));
  Color get outlineText => _mix(const Color(0xFF3E7D4A), const Color(0xFFD6F0D1));
  Color get outlineFill => _mix(Colors.white.withValues(alpha: 0.75), Colors.white.withValues(alpha: 0.07));

  // Chip
  Color get chipBg => _mix(Colors.white.withValues(alpha: 0.88), const Color(0xFF1B0D2B).withValues(alpha: 0.85));
  Color get chipText => _mix(Aj.plum, const Color(0xFFF7DDE6));
  Color get chipDot => _mix(Aj.mintDeep, const Color(0xFFA9D8A3));
  Color get statusBg => _mix(Colors.white.withValues(alpha: 0.7), Colors.white.withValues(alpha: 0.09));
  Color get statusBorder => _mix(const Color(0xFFF0EAE6), const Color(0x33FFFFFF));
  Color get statusText => _mix(Aj.plum, const Color(0xFFF1DDF7));
  Color get statusIcon => _mix(const Color(0xFFF2A33A), const Color(0xFFF6D77A));

  // Toggle
  Color get toggleTrack => _mix(const Color(0xFFFFE3A3), const Color(0xFF3A1D5A));
  Color get toggleKnob => _mix(Colors.white, const Color(0xFFF4E9FF));
}