import 'package:flutter/material.dart';

class ProfileData {
  final String fullName;
  final String nickname;
  final String email;
  final String phone;
  final String birth;
  final String city;
  final String status; // Pelajar / Mahasiswa / Pekerja / Ibu Rumah Tangga / dll.
  final String gender;

  const ProfileData({
    required this.fullName,
    required this.nickname,
    required this.email,
    required this.phone,
    required this.birth,
    required this.city,
    required this.status,
    required this.gender,
  });

  String get displayName =>
      nickname.trim().isNotEmpty
          ? nickname.trim()
          : fullName.split(' ').first;

  ProfileData copyWith({
    String? fullName,
    String? nickname,
    String? email,
    String? phone,
    String? birth,
    String? city,
    String? status,
    String? gender,
  }) {
    return ProfileData(
      fullName: fullName ?? this.fullName,
      nickname: nickname ?? this.nickname,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      birth: birth ?? this.birth,
      city: city ?? this.city,
      status: status ?? this.status,
      gender: gender ?? this.gender,
    );
  }
}

/// Teman "Saling Pantau" yang terhubung lewat QR / kode proteksi.
class Buddy {
  final String name;
  final String code;
  final DateTime addedAt;

  const Buddy({required this.name, required this.code, required this.addedAt});
}

enum BuddyResult { added, invalid, self, duplicate }

class ProfileStore {
  static const String myCode = 'AJ-94821';

  /// Isi QR milik sendiri. Format sederhana supaya mudah dibaca ulang.
  static const String myQrPayload = 'AMANJALAN:$myCode';

  static final ValueNotifier<ProfileData> data = ValueNotifier(
    const ProfileData(
      fullName: 'Puja Davi',
      nickname: 'Puja',
      email: 'pujadavi@gmail.com',
      phone: '+62 878-xxxx-xxxx',
      birth: '12 Mei 2007',
      city: 'Batam, Kepulauan Riau',
      status: 'Mahasiswa',
      gender: 'Perempuan',
    ),
  );

  static void update(ProfileData Function(ProfileData old) change) {
    data.value = change(data.value);
  }

  // ── Status / aktivitas pengguna ─────────────────────────
  static const List<String> statusOptions = [
    'Pelajar',
    'Mahasiswa',
    'Pekerja',
    'Ibu Rumah Tangga',
    'Wirausaha',
    'Lainnya…',
  ];

  static IconData statusIcon(String status) {
    final s = status.toLowerCase();
    if (s.contains('pelajar') || s.contains('siswa')) return Icons.backpack_rounded;
    if (s.contains('mahasiswa')) return Icons.school_rounded;
    if (s.contains('pekerja') || s.contains('karyawan')) return Icons.work_rounded;
    if (s.contains('rumah tangga') || s.contains('ibu')) return Icons.home_rounded;
    if (s.contains('wirausaha') || s.contains('usaha')) return Icons.storefront_rounded;
    return Icons.person_rounded;
  }

  // ── Saling Pantau ───────────────────────────────────────
  static final ValueNotifier<List<Buddy>> buddies = ValueNotifier(const []);

  /// Ambil kode "AJ-12345" dari isi QR atau ketikan manual. Null bila tidak valid.
  static String? parseCode(String raw) {
    final m = RegExp(r'AJ-?(\d{5})', caseSensitive: false).firstMatch(raw.trim());
    if (m == null) return null;
    return 'AJ-${m.group(1)}';
  }

  static BuddyResult addBuddy(String raw) {
    final code = parseCode(raw);
    if (code == null) return BuddyResult.invalid;
    if (code == myCode) return BuddyResult.self;
    if (buddies.value.any((b) => b.code == code)) return BuddyResult.duplicate;
    // Tanpa server: nama sementara dari kode. Nanti diganti nama asli dari backend.
    buddies.value = [
      Buddy(name: 'Teman #${code.substring(3)}', code: code, addedAt: DateTime.now()),
      ...buddies.value,
    ];
    return BuddyResult.added;
  }

  static void removeBuddy(String code) {
    buddies.value = buddies.value.where((b) => b.code != code).toList();
  }

  // ── Preferensi aplikasi ─────────────────────────────────
  static String language = 'Bahasa Indonesia';
  static String themeMode = 'Terang';
  static String textSize = 'Normal';
  static bool sound = true;
  static bool dataSaver = false;

  static void resetPrefs() {
    language = 'Bahasa Indonesia';
    themeMode = 'Terang';
    textSize = 'Normal';
    sound = true;
    dataSaver = false;
  }
}