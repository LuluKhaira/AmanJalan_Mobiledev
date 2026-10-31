import 'package:flutter/material.dart';
import 'package:amanjalan/features/proteksi/models/route_models.dart';

// =====================================================================
// DATA CONTOH
// Nanti tinggal diganti dengan data dari API / database.
// =====================================================================

// ---- Titik di peta ----
const List<MapPoi> kSafePois = [
  MapPoi(Offset(600, 1030), Icons.local_police_rounded, kSafeColor, 'Pos Satpam'),
  MapPoi(Offset(710, 920), Icons.videocam_rounded, kSafeColor, 'CCTV'),
  MapPoi(Offset(820, 810), Icons.groups_rounded, kSafeColor, 'Ramai'),
  MapPoi(Offset(930, 700), Icons.lightbulb_rounded, kSafeColor, 'Lampu LED'),
];

const List<MapPoi> kFastPois = [
  MapPoi(Offset(690, 1040), Icons.warning_amber_rounded, kWarnColor, 'Gang sempit'),
  MapPoi(Offset(765, 890), Icons.visibility_off_rounded, kWarnColor, 'Minim penerangan'),
  MapPoi(Offset(900, 800), Icons.person_off_rounded, kWarnColor, 'Sepi saat malam'),
];

// ---- Indikator keamanan ----
const List<RouteMetric> _safeMetrics = [
  RouteMetric(Icons.lightbulb_rounded, 'Penerangan', 'Terang', 0.95),
  RouteMetric(Icons.videocam_rounded, 'CCTV', 'Banyak', 0.90),
  RouteMetric(Icons.groups_rounded, 'Keramaian', 'Ramai', 0.85),
];

const List<RouteMetric> _fastMetrics = [
  RouteMetric(Icons.visibility_off_rounded, 'Penerangan', 'Minim', 0.30),
  RouteMetric(Icons.person_off_rounded, 'Keramaian', 'Sepi', 0.20),
  RouteMetric(Icons.warning_amber_rounded, 'Jalur', 'Gang sempit', 0.35),
];

const List<RouteMetric> _busSafeMetrics = [
  RouteMetric(Icons.lightbulb_rounded, 'Penerangan', 'Terang', 0.90),
  RouteMetric(Icons.videocam_rounded, 'CCTV', 'Banyak', 0.85),
  RouteMetric(Icons.directions_bus_rounded, 'Halte', 'Ramai', 0.85),
];

const List<RouteMetric> _busFastMetrics = [
  RouteMetric(Icons.visibility_off_rounded, 'Penerangan', 'Minim', 0.30),
  RouteMetric(Icons.videocam_rounded, 'CCTV', 'Sedikit', 0.25),
  RouteMetric(Icons.directions_bus_rounded, 'Halte', 'Sepi', 0.20),
];

// ---- Pembuat rute ----
RouteOption _safest({
  required TransportMode mode,
  required String duration,
  required String distance,
  required int score,
  required String summary,
  List<RouteMetric> metrics = _safeMetrics,
}) =>
    RouteOption(
      mode: mode,
      kind: RouteKind.safest,
      title: 'Rute Teraman',
      duration: duration,
      distance: distance,
      score: score,
      badge: 'Direkomendasikan',
      summary: summary,
      icon: Icons.shield_rounded,
      color: kindColor(RouteKind.safest),
      tint: const Color(0xFFF6EEF8),
      metrics: metrics,
      pois: kSafePois,
    );

RouteOption _fastest({
  required TransportMode mode,
  required String duration,
  required String distance,
  required int score,
  required String summary,
  List<RouteMetric> metrics = _fastMetrics,
}) =>
    RouteOption(
      mode: mode,
      kind: RouteKind.fastest,
      title: 'Rute Tercepat',
      duration: duration,
      distance: distance,
      score: score,
      badge: 'Kurang aman',
      summary: summary,
      icon: Icons.bolt_rounded,
      color: kindColor(RouteKind.fastest),
      tint: const Color(0xFFFFF6EA),
      metrics: metrics,
      pois: kFastPois,
    );

/// Daftar rute untuk tiap moda. Index 0 = teraman, index 1 = tercepat.
final Map<TransportMode, List<RouteOption>> kRoutesByMode = {
  TransportMode.motor: [
    _safest(
      mode: TransportMode.motor,
      duration: '5 mnt',
      distance: '1,4 km',
      score: 90,
      summary: 'Lewat jalan utama yang terang dan ramai, jauh dari gang sepi.',
    ),
    _fastest(
      mode: TransportMode.motor,
      duration: '3 mnt',
      distance: '900 m',
      score: 60,
      summary: 'Lebih cepat lewat gang pintas, tapi minim lampu dan sepi saat malam.',
    ),
  ],
  TransportMode.mobil: [
    _safest(
      mode: TransportMode.mobil,
      duration: '6 mnt',
      distance: '1,5 km',
      score: 94,
      summary: 'Lewat jalan utama dengan CCTV dan pos satpam di sepanjang jalur.',
    ),
    _fastest(
      mode: TransportMode.mobil,
      duration: '4 mnt',
      distance: '1,0 km',
      score: 66,
      summary: 'Lebih cepat lewat jalan pintas yang sempit dan minim penerangan.',
    ),
  ],
  TransportMode.bus: [
    _safest(
      mode: TransportMode.bus,
      duration: '12 mnt',
      distance: '1,6 km',
      score: 88,
      summary: 'Naik dari halte yang terang dan ramai, menuju halte lewat jalan utama.',
      metrics: _busSafeMetrics,
    ),
    _fastest(
      mode: TransportMode.bus,
      duration: '9 mnt',
      distance: '1,2 km',
      score: 62,
      summary: 'Lebih cepat, tapi halte awal sepi dan minim penerangan.',
      metrics: _busFastMetrics,
    ),
  ],
  TransportMode.jalanKaki: [
    _safest(
      mode: TransportMode.jalanKaki,
      duration: '14 mnt',
      distance: '1,1 km',
      score: 92,
      summary: 'Lewat jalan utama yang terang, dipantau CCTV, dan ramai warga.',
    ),
    _fastest(
      mode: TransportMode.jalanKaki,
      duration: '10 mnt',
      distance: '800 m',
      score: 58,
      summary: 'Lebih singkat, tapi lewat gang sempit. Sebaiknya hindari saat malam.',
    ),
  ],
};

// ---- Daftar tempat tujuan ----
const List<Place> kPlaces = [
  Place('Gedung JE', 'Politeknik Negeri Batam, Jl. Ahmad Yani, Teluk Tering', '0,8 km'),
  Place('Pintu Masuk Polibatam', 'Jl. Ahmad Yani, Teluk Tering, Batam Kota', '1,1 km'),
  Place('Asrama A', 'Politeknik Negeri Batam, Teluk Tering', '1,3 km'),
  Place('Perpustakaan', 'Politeknik Negeri Batam, Teluk Tering', '0,9 km'),
  Place('Kantin Pusat', 'Politeknik Negeri Batam, Teluk Tering', '0,7 km'),
  Place('Lab Teknik Informatika', 'Politeknik Negeri Batam, Teluk Tering', '1,0 km'),
  Place('Mess Mahasiswa', 'Jl. Ahmad Yani, Teluk Tering, Batam Kota', '1,2 km'),
];
