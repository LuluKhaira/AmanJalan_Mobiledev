import 'package:flutter/material.dart';

/// Moda yang dipakai teman yang sedang dipantau.
enum FriendMode { motor, mobil, bus, jalanKaki }

extension FriendModeX on FriendMode {
  String get label => switch (this) {
        FriendMode.motor => 'Motor',
        FriendMode.mobil => 'Mobil',
        FriendMode.bus => 'Bus',
        FriendMode.jalanKaki => 'Jalan Kaki',
      };

  String get verb => switch (this) {
        FriendMode.motor => 'Naik Motor',
        FriendMode.mobil => 'Naik Mobil',
        FriendMode.bus => 'Naik Bus',
        FriendMode.jalanKaki => 'Jalan Kaki',
      };

  IconData get icon => switch (this) {
        FriendMode.motor => Icons.two_wheeler_rounded,
        FriendMode.mobil => Icons.directions_car_filled_rounded,
        FriendMode.bus => Icons.directions_bus_rounded,
        FriendMode.jalanKaki => Icons.directions_walk_rounded,
      };

  String get speed => switch (this) {
        FriendMode.motor => '32 km/j',
        FriendMode.mobil => '38 km/j',
        FriendMode.bus => '24 km/j',
        FriendMode.jalanKaki => '4.1 km/j',
      };
}

/// Data contoh perjalanan teman. Cukup ubah di sini, kartu & halaman peta ikut berubah.
class FriendTrip {
  FriendTrip._();

  static const name = 'Salsabila Rahma';
  static const firstName = 'Salsa';
  static const relation = 'Teman Kos';
  static const photo = 'https://images.unsplash.com/photo-1567532939604-b6b5b0db2604?w=150';

  /// Ganti ke FriendMode.mobil / bus / jalanKaki untuk mengubah tampilan.
  static const mode = FriendMode.motor;

  static const from = 'Kampus UI';
  static const to = 'Kos Melati';
  static const street = 'Jl. Imam Bonjol';
  static const etaMin = 5;
  static const distanceLeft = '1,4 km';
  static const distanceFromYou = '340 m';
  static const routeName = 'Teraman';
  static const score = 90;
  static const warnings = 3;
  static const battery = '78%';
  static const gps = '±3 m';
}