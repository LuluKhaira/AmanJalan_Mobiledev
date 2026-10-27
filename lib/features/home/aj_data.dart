import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────
// DATA DUMMY (tanpa backend). Semua state hidup di memori.
// ─────────────────────────────────────────────────────────────

enum TripStatus { selesai, sos, batal }

class TripRecord {
  final String id;
  final String from;
  final String to;
  final DateTime start;
  final int minutes;
  final int meters;
  final int havens;
  final double avgKmh;
  final TripStatus status;
  final List<String> guardians;

  const TripRecord({
    required this.id,
    required this.from,
    required this.to,
    required this.start,
    required this.minutes,
    required this.meters,
    required this.havens,
    required this.avgKmh,
    required this.status,
    required this.guardians,
  });
}

class ActiveTrip {
  final String from;
  final String to;
  final int etaMin;
  final int meters;
  final int havens;
  final DateTime startedAt;
  final List<String> guardians;

  const ActiveTrip({
    required this.from,
    required this.to,
    required this.etaMin,
    required this.meters,
    required this.havens,
    required this.startedAt,
    required this.guardians,
  });
}

class Destination {
  final String label;
  final IconData icon;
  final String from;
  final String to;
  final int meters;
  final int minutes;
  final int havens;

  const Destination({
    required this.label,
    required this.icon,
    required this.from,
    required this.to,
    required this.meters,
    required this.minutes,
    required this.havens,
  });
}

class Guardian {
  final String name;
  final String role;
  final String note;
  final bool online;
  final Color color;
  final String? imageUrl;

  const Guardian({
    required this.name,
    required this.role,
    required this.note,
    required this.online,
    required this.color,
    this.imageUrl,
  });
}

const List<Destination> kDestinations = [
  Destination(label: 'Kos Melati (Favorit)', icon: Icons.home_outlined, from: 'Kukusan Raya', to: 'Kos Melati', meters: 850, minutes: 12, havens: 3),
  Destination(label: 'Minimarket 24 Jam', icon: Icons.storefront_outlined, from: 'Kos Melati', to: 'Minimarket 24 Jam', meters: 420, minutes: 6, havens: 2),
  Destination(label: 'Kampus UI', icon: Icons.school_outlined, from: 'Kos Melati', to: 'Kampus UI', meters: 1300, minutes: 18, havens: 4),
  Destination(label: 'Halte Terdekat', icon: Icons.directions_bus_outlined, from: 'Kos Melati', to: 'Halte UI', meters: 600, minutes: 8, havens: 2),
];

const List<Guardian> kGuardians = [
  Guardian(
    name: 'Ibu Nurhayati',
    role: 'Wali Utama',
    note: 'WhatsApp Realtime Aktif',
    online: true,
    color: Color(0xFFF4E6F0),
    imageUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150',
  ),
  Guardian(
    name: 'Dinda Permata',
    role: 'Teman Sekos',
    note: 'Notifikasi Cepat Siap',
    online: true,
    color: Color(0xFFE6F0F4),
    imageUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150',
  ),
  Guardian(
    name: 'Salsabila Rahma',
    role: 'Sahabat',
    note: 'Radius Kampus UI Depok',
    online: false,
    color: Color(0xFFF0F4E6),
    imageUrl: 'https://images.unsplash.com/photo-1567532939604-b6b5b0db2604?w=150',
  ),
];

/// Penyimpanan sementara di memori: daftar guardian.
class GuardianStore {
  GuardianStore._();
  static final ValueNotifier<List<Guardian>> guardians =
      ValueNotifier<List<Guardian>>([...kGuardians]);

  static void addGuardian(Guardian g) {
    guardians.value = [...guardians.value, g];
  }

  static void removeGuardian(int index) {
    if (index >= 0 && index < guardians.value.length) {
      final list = [...guardians.value]..removeAt(index);
      guardians.value = list;
    }
  }
}

/// Penyimpanan sementara di memori: riwayat + perjalanan yang sedang aktif.
class TripStore {
  TripStore._();

  static final ValueNotifier<List<TripRecord>> trips = ValueNotifier<List<TripRecord>>(_seed());
  static final ValueNotifier<ActiveTrip?> active = ValueNotifier<ActiveTrip?>(null);

  static void start(Destination d) {
    if (active.value != null) return;
    active.value = ActiveTrip(
      from: d.from,
      to: d.to,
      etaMin: d.minutes,
      meters: d.meters,
      havens: d.havens,
      startedAt: DateTime.now(),
      guardians: const ['Ibu Nurhayati', 'Dinda Kirana'],
    );
  }

  static void finish({TripStatus status = TripStatus.selesai}) {
    final a = active.value;
    if (a == null) return;
    final mins = DateTime.now().difference(a.startedAt).inMinutes;
    trips.value = [
      TripRecord(
        id: 'AJ-${DateTime.now().millisecondsSinceEpoch % 100000}',
        from: a.from,
        to: a.to,
        start: a.startedAt,
        minutes: status == TripStatus.selesai ? a.etaMin : (mins < 1 ? 1 : mins),
        meters: a.meters,
        havens: a.havens,
        avgKmh: 4.4,
        status: status,
        guardians: a.guardians,
      ),
      ...trips.value,
    ];
    active.value = null;
  }

  static List<TripRecord> _seed() {
    DateTime ago(int days, int h, int m) {
      final n = DateTime.now().subtract(Duration(days: days));
      return DateTime(n.year, n.month, n.day, h, m);
    }

    const ibu = 'Ibu Nurhayati';
    const dinda = 'Dinda Kirana';
    const salsa = 'Salsabila Rahma';

    return [
      TripRecord(id: 'AJ-20418', from: 'Kampus UI', to: 'Kos Melati', start: ago(0, 19, 42), minutes: 14, meters: 1100, havens: 3, avgKmh: 4.7, status: TripStatus.selesai, guardians: const [ibu, dinda]),
      TripRecord(id: 'AJ-20397', from: 'Minimarket 24 Jam', to: 'Kos Melati', start: ago(1, 21, 15), minutes: 7, meters: 420, havens: 2, avgKmh: 3.6, status: TripStatus.selesai, guardians: const [dinda]),
      TripRecord(id: 'AJ-20361', from: 'Stasiun UI', to: 'Kos Melati', start: ago(2, 22, 5), minutes: 19, meters: 1450, havens: 4, avgKmh: 4.6, status: TripStatus.selesai, guardians: const [ibu, dinda, salsa]),
      TripRecord(id: 'AJ-20344', from: 'Kukusan Raya', to: 'Kampus UI', start: ago(3, 6, 50), minutes: 16, meters: 1250, havens: 3, avgKmh: 4.7, status: TripStatus.selesai, guardians: const [ibu]),
      TripRecord(id: 'AJ-20302', from: 'Jl. Margonda', to: 'Kos Melati', start: ago(5, 23, 10), minutes: 11, meters: 780, havens: 2, avgKmh: 4.3, status: TripStatus.sos, guardians: const [ibu, dinda]),
      TripRecord(id: 'AJ-20288', from: 'Kos Melati', to: 'Halte UI', start: ago(6, 17, 30), minutes: 2, meters: 90, havens: 0, avgKmh: 2.7, status: TripStatus.batal, guardians: const [dinda]),
      TripRecord(id: 'AJ-20251', from: 'Perpustakaan UI', to: 'Kos Melati', start: ago(8, 20, 48), minutes: 17, meters: 1300, havens: 4, avgKmh: 4.6, status: TripStatus.selesai, guardians: const [ibu, salsa]),
      TripRecord(id: 'AJ-20233', from: 'Kampus UI', to: 'Kos Melati', start: ago(10, 18, 20), minutes: 15, meters: 1100, havens: 3, avgKmh: 4.4, status: TripStatus.selesai, guardians: const [ibu, dinda]),
    ];
  }
}

// ─────────────────────────────────────────────────────────────
// Helper format (tanpa paket intl)
// ─────────────────────────────────────────────────────────────

const _bulan = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];

String fmtDistance(int m) => m >= 1000 ? '${(m / 1000).toStringAsFixed(1)} km' : '$m m';

String fmtTime(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}.${d.minute.toString().padLeft(2, '0')}';

String fmtDay(DateTime d) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(d.year, d.month, d.day);
  final diff = today.difference(day).inDays;
  if (diff == 0) return 'Hari ini';
  if (diff == 1) return 'Kemarin';
  return '${d.day} ${_bulan[d.month - 1]}';
}