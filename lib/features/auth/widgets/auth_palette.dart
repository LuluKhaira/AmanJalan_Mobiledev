import 'package:flutter/material.dart';

import 'package:amanjalan/core/theme/aj_theme.dart';
import 'package:amanjalan/features/welcome/widgets/welcome_palette.dart';

/// Warna tambahan untuk kartu form, field, dan tautan di halaman Login/Daftar.
/// Mengikuti t dari WelcomePalette (0 = siang, 1 = malam).
extension AuthPalette on WelcomePalette {
  Color _m(Color day, Color night) => Color.lerp(day, night, t)!;

  Color get cardBg => _m(
        Colors.white.withValues(alpha: 0.97),
        const Color(0xFF1E0E31).withValues(alpha: 0.97),
      );
  Color get cardBorder => _m(const Color(0xFFF1E9EE), const Color(0x26FFFFFF));
  Color get cardShadow => _m(
        Aj.plum.withValues(alpha: 0.13),
        Colors.black.withValues(alpha: 0.45),
      );

  Color get fieldFill => _m(const Color(0xFFF7F5F9), const Color(0x12FFFFFF));
  Color get fieldBorder => _m(const Color(0xFFECE7F0), const Color(0x26FFFFFF));
  Color get fieldText => _m(const Color(0xFF2B1B33), Colors.white);
  Color get hint => _m(const Color(0xFF9A95A6), const Color(0xFF9D8BB0));
  Color get label => _m(Aj.plum, const Color(0xFFF1DDF7));
  Color get iconMuted => _m(const Color(0xFF9A95A6), const Color(0xFFB9A3CC));
  Color get focus => _m(Aj.plum, const Color(0xFFF2A7BE));
  Color get error => _m(const Color(0xFFB83A5E), const Color(0xFFFF8FAE));
  Color get line => _m(const Color(0xFFE9E4EE), const Color(0x26FFFFFF));
  Color get checkBorder => _m(const Color(0xFFC9C3D1), const Color(0x66FFFFFF));
  Color get link => _m(Aj.plum, const Color(0xFFF2A7BE));
}