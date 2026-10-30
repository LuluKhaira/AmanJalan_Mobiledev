import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────
// Helper tanggal (hari ke-N sejak epoch, zona waktu lokal)
// ─────────────────────────────────────────────────────────────

int ajDayNum(DateTime d) => DateTime.utc(d.year, d.month, d.day).millisecondsSinceEpoch ~/ 86400000;

DateTime ajDayFromNum(int n) => DateTime.fromMillisecondsSinceEpoch(n * 86400000, isUtc: true);

// ─────────────────────────────────────────────────────────────
// Milestone
// ─────────────────────────────────────────────────────────────

class StreakMilestone {
  final int days;
  final String title;
  final String desc;
  final IconData icon;
  final bool rewardsFreeze;

  const StreakMilestone(this.days, this.title, this.desc, this.icon, {this.rewardsFreeze = false});
}

const kStreakMilestones = <StreakMilestone>[
  StreakMilestone(3, 'Langkah Awal', 'Tiga hari berturut-turut menjaga diri.', Icons.directions_walk_rounded),
  StreakMilestone(7, 'Pejalan Waspada', 'Seminggu penuh kamu rutin lapor aman.', Icons.visibility_rounded, rewardsFreeze: true),
  StreakMilestone(14, 'Penjaga Rute', 'Dua minggu tanpa putus. Keren!', Icons.alt_route_rounded),
  StreakMilestone(30, 'Sahabat Kampus', 'Sebulan penuh jadi mahasiswa waspada.', Icons.school_rounded, rewardsFreeze: true),
  StreakMilestone(50, 'Pahlawan Malam', 'Kamu panutan buat teman-temanmu.', Icons.nightlight_round),
  StreakMilestone(100, 'Legenda AmanJalan', 'Seratus hari. Kamu legenda sejati.', Icons.workspace_premium_rounded, rewardsFreeze: true),
];

// ─────────────────────────────────────────────────────────────
// State & hasil check-in
// ─────────────────────────────────────────────────────────────

class StreakState {
  final int current;
  final int best;
  final int total;
  final int freezes;
  final int lastDay; // hari terakhir check-in
  final Set<int> days; // hari yang check-in
  final Set<int> frozen; // hari yang diselamatkan perisai
  final DateTime? checkedAt;

  const StreakState({
    required this.current,
    required this.best,
    required this.total,
    required this.freezes,
    required this.lastDay,
    required this.days,
    required this.frozen,
    this.checkedAt,
  });

  bool get checkedToday => lastDay == ajDayNum(DateTime.now());

  /// Streak yang benar-benar masih hidup (kalau lewat sehari penuh & tanpa perisai → 0).
  int get alive {
    final today = ajDayNum(DateTime.now());
    final gap = today - lastDay;
    if (gap <= 1) return current;
    if (gap == 2 && freezes > 0) return current;
    return 0;
  }

  StreakMilestone? get rank {
    StreakMilestone? r;
    for (final m in kStreakMilestones) {
      if (alive >= m.days) r = m;
    }
    return r;
  }

  StreakMilestone? get next {
    for (final m in kStreakMilestones) {
      if (alive < m.days) return m;
    }
    return null;
  }

  /// 0..1 menuju milestone berikutnya.
  double get progress {
    final n = next;
    if (n == null) return 1;
    final prev = rank?.days ?? 0;
    return ((alive - prev) / (n.days - prev)).clamp(0.0, 1.0);
  }
}

class StreakResult {
  final int before;
  final int after;
  final bool usedFreeze;
  final bool isNewBest;
  final StreakMilestone? milestone;
  final bool rewardFreeze;

  const StreakResult({
    required this.before,
    required this.after,
    required this.usedFreeze,
    required this.isNewBest,
    required this.milestone,
    required this.rewardFreeze,
  });
}

// ─────────────────────────────────────────────────────────────
// Store (in-memory, sama seperti GuardianStore)
// ─────────────────────────────────────────────────────────────

class StreakStore {
  static const maxFreezes = 3;

  static final ValueNotifier<StreakState> state = ValueNotifier(_seed());

  /// Data awal demo: sudah 6 hari beruntun, kemarin terakhir check-in,
  /// jadi check-in hari ini langsung menembus milestone 7 hari.
  static StreakState _seed() {
    final today = ajDayNum(DateTime.now());
    return StreakState(
      current: 6,
      best: 12,
      total: 41,
      freezes: 2,
      lastDay: today - 1,
      days: {for (var i = 1; i <= 6; i++) today - i},
      frozen: const {},
    );
  }

  /// Dipanggil saat check-in. Mengembalikan null kalau hari ini sudah check-in.
  static StreakResult? checkIn() {
    final s = state.value;
    final today = ajDayNum(DateTime.now());
    if (s.lastDay == today) return null;

    final gap = today - s.lastDay;
    var next = 1;
    var freezes = s.freezes;
    var usedFreeze = false;
    final frozen = {...s.frozen};

    if (gap == 1) {
      next = s.current + 1;
    } else if (gap == 2 && freezes > 0) {
      freezes -= 1;
      usedFreeze = true;
      frozen.add(today - 1);
      next = s.current + 1;
    }

    StreakMilestone? hit;
    for (final m in kStreakMilestones) {
      if (m.days == next) hit = m;
    }
    final reward = hit != null && hit.rewardsFreeze && freezes < maxFreezes;
    if (reward) freezes += 1;

    final best = next > s.best ? next : s.best;

    state.value = StreakState(
      current: next,
      best: best,
      total: s.total + 1,
      freezes: freezes,
      lastDay: today,
      days: {...s.days, today},
      frozen: frozen,
      checkedAt: DateTime.now(),
    );

    return StreakResult(
      before: gap == 1 || usedFreeze ? s.current : 0,
      after: next,
      usedFreeze: usedFreeze,
      isNewBest: next > s.best,
      milestone: hit,
      rewardFreeze: reward,
    );
  }
}