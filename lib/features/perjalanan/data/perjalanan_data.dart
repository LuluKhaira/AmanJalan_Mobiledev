import 'package:flutter/material.dart';
import 'package:amanjalan/core/theme/aj_theme.dart';
import 'package:amanjalan/features/home/aj_data.dart';

// ─────────────────────────────────────────────────────────────
// Data & helper khusus fitur Perjalanan.
// Model inti (TripStore, ActiveTrip, Destination, GuardianStore)
// tetap di features/home/aj_data.dart agar tidak ada yang rusak.
// ─────────────────────────────────────────────────────────────

enum TravelMode { jalanKaki, motor, mobil, lainnya }

extension TravelModeX on TravelMode {
  String get label => switch (this) {
        TravelMode.jalanKaki => 'Jalan Kaki',
        TravelMode.motor => 'Motor',
        TravelMode.mobil => 'Mobil',
        TravelMode.lainnya => 'Lainnya',
      };

  IconData get icon => switch (this) {
        TravelMode.jalanKaki => Icons.directions_walk_rounded,
        TravelMode.motor => Icons.two_wheeler_rounded,
        TravelMode.mobil => Icons.directions_car_filled_rounded,
        TravelMode.lainnya => Icons.more_horiz_rounded,
      };

  /// Kecepatan rata-rata dalam meter per menit.
  double get metersPerMinute => switch (this) {
        TravelMode.jalanKaki => 75,
        TravelMode.motor => 420,
        TravelMode.mobil => 500,
        TravelMode.lainnya => 150,
      };
}

int pjEstimateMinutes(Destination d, TravelMode m) {
  final v = (d.meters / m.metersPerMinute).ceil();
  return v < 1 ? 1 : v;
}

/// Demo: perjalanan dipercepat supaya juri bisa lihat progres tanpa menunggu.
const double kDemoSpeed = 20;

double pjProgress(ActiveTrip a) {
  final total = a.etaMin * 60;
  if (total <= 0) return 1;
  final done = DateTime.now().difference(a.startedAt).inSeconds * kDemoSpeed;
  return (done / total).clamp(0.0, 1.0).toDouble();
}

int pjRemainMinutes(ActiveTrip a) => (a.etaMin * (1 - pjProgress(a))).ceil();

int pjRemainMeters(ActiveTrip a) => (a.meters * (1 - pjProgress(a))).round();

/// State ringan yang dibagi antar layar perjalanan (memori saja).
class PerjalananSession {
  PerjalananSession._();

  static final ValueNotifier<TravelMode> mode = ValueNotifier<TravelMode>(TravelMode.jalanKaki);
  static final ValueNotifier<bool> guncang = ValueNotifier<bool>(true);
  static final ValueNotifier<bool> autoArrive = ValueNotifier<bool>(true);
}

// ─────────────────────────────────────────────────────────────
// Kategori laporan kejadian
// ─────────────────────────────────────────────────────────────

class IncidentType {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color bg;
  final Color fg;

  const IncidentType(this.title, this.subtitle, this.icon, this.bg, this.fg);
}

const List<IncidentType> kIncidentTypes = [
  IncidentType('Kekerasan / Pelecehan', 'Fisik, verbal, atau seksual', Icons.front_hand_rounded, Aj.sosSoft, Aj.sos),
  IncidentType('Tindak Kriminal', 'Pencurian, perampasan, dll.', Icons.shopping_bag_outlined, Aj.blush, Aj.berry),
  IncidentType('Kondisi Membahayakan', 'Jalan gelap, cuaca ekstrem, kerumunan', Icons.warning_amber_rounded, Color(0xFFFFF3E0), Color(0xFFE65100)),
  IncidentType('Lainnya', 'Keluhan atau kejadian lainnya', Icons.more_horiz_rounded, Aj.sand, Aj.plum),
];
