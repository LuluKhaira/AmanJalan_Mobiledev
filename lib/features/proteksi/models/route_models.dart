import 'package:flutter/material.dart';
import 'package:amanjalan/core/theme/app_colors.dart';

// ==========================================
// WARNA STATUS KEAMANAN
// ==========================================
const Color kSafeColor = Color(0xFF2E7D32);
const Color kWarnColor = Color(0xFFEF6C00);
const Color kDangerColor = Color(0xFFC62828);

/// Warna berdasarkan tingkat keamanan (0..1).
Color levelColor(double v) {
  if (v >= 0.66) return kSafeColor;
  if (v >= 0.4) return kWarnColor;
  return kDangerColor;
}

// ==========================================
// MODA TRANSPORTASI
// ==========================================
enum TransportMode { motor, mobil, bus, jalanKaki }

extension TransportModeX on TransportMode {
  String get label {
    switch (this) {
      case TransportMode.motor:
        return 'Motor';
      case TransportMode.mobil:
        return 'Mobil';
      case TransportMode.bus:
        return 'Bus';
      case TransportMode.jalanKaki:
        return 'Jalan Kaki';
    }
  }

  IconData get icon {
    switch (this) {
      case TransportMode.motor:
        return Icons.two_wheeler_rounded;
      case TransportMode.mobil:
        return Icons.directions_car_filled_rounded;
      case TransportMode.bus:
        return Icons.directions_bus_rounded;
      case TransportMode.jalanKaki:
        return Icons.directions_walk_rounded;
    }
  }
}

// ==========================================
// JENIS RUTE
// ==========================================
enum RouteKind { safest, fastest }

Color kindColor(RouteKind kind) =>
    kind == RouteKind.safest ? AppColors.plum : Colors.orange.shade700;

// ==========================================
// MODEL
// ==========================================

/// Titik penting di sepanjang rute (CCTV, lampu, dll).
class MapPoi {
  final Offset pos;
  final IconData icon;
  final Color color;
  final String label;

  const MapPoi(this.pos, this.icon, this.color, this.label);
}

/// Satu indikator keamanan (penerangan, CCTV, keramaian...).
class RouteMetric {
  final IconData icon;
  final String label;
  final String value;
  final double level; // 0..1

  const RouteMetric(this.icon, this.label, this.value, this.level);
}

/// Satu pilihan rute untuk satu moda transportasi.
class RouteOption {
  final TransportMode mode;
  final RouteKind kind;
  final String title;
  final String duration;
  final String distance;
  final int score;
  final String badge;
  final String summary;
  final IconData icon;
  final Color color;
  final Color tint;
  final List<RouteMetric> metrics;
  final List<MapPoi> pois;

  const RouteOption({
    required this.mode,
    required this.kind,
    required this.title,
    required this.duration,
    required this.distance,
    required this.score,
    required this.badge,
    required this.summary,
    required this.icon,
    required this.color,
    required this.tint,
    required this.metrics,
    required this.pois,
  });

  bool get isSafest => kind == RouteKind.safest;
}

/// Tempat tujuan.
class Place {
  final String name;
  final String address;
  final String distance;

  const Place(this.name, this.address, this.distance);
}
