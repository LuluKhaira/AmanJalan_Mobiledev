import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:amanjalan/core/theme/app_colors.dart';

/// Palet & gaya teks yang mengikuti desain Figma amanJalan.
/// Berdiri sendiri (tidak bergantung pada AppColors) supaya aman dipakai
/// di semua layar baru.
class Aj {
  Aj._();

  // Warna dasar
  static const Color bg = Color(0xFFFDF8F6); // krem hangat (Figma)
  static const Color card = Colors.white;
  static const Color sand = Color(0xFFF5F1EE);
  static const Color line = Color(0xFFF0EAE6);

  // Brand
  static const Color plum = AppColors.plum;
  static const Color berry = Color(0xFF8A3F5C);
  static const Color blush = AppColors.softPink;
  static const Color blushDeep = Color(0xFFF8C6D2);

  // Teks
  static const Color ink = AppColors.textDark;
  static const Color muted = AppColors.textMuted;

  // Status
  static const Color mint = AppColors.sage;
  static const Color mintDeep = Color(0xFF2E7D4F);
  static const Color amber = Color(0xFFFFF0D2);
  static const Color amberDeep = Color(0xFF9A6200);
  static const Color sos = AppColors.emergencyRed;
  static const Color sosSoft = Color(0xFFFDE0E0);

  static const List<BoxShadow> softShadow = [
    BoxShadow(color: Color(0x0F2B1B33), blurRadius: 18, offset: Offset(0, 6)),
  ];

  static TextStyle h(double size, {Color color = ink, FontWeight w = FontWeight.w700, double? height}) =>
      GoogleFonts.poppins(fontSize: size, fontWeight: w, color: color, height: height);

  static TextStyle b(double size, {Color color = ink, FontWeight w = FontWeight.w600, double? height}) =>
      GoogleFonts.nunito(fontSize: size, fontWeight: w, color: color, height: height);
}