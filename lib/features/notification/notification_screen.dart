import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:amanjalan/core/theme/aj_theme.dart';
import 'package:amanjalan/core/widgets/aj_common.dart';
import 'package:amanjalan/core/widgets/animated_entrance.dart';
import 'package:amanjalan/features/profile/screens/notification_settings_screen.dart';
import 'package:amanjalan/features/profile/widgets/profile_kit.dart';

// ─────────────────────────────────────────────────────────────
// Model
// ─────────────────────────────────────────────────────────────

enum _Kind { info, warning, system }

class _Act {
  final IconData icon;
  final String label;
  final String toast;
  const _Act(this.icon, this.label, this.toast);
}

class _N {
  final String id;
  final _Kind kind;
  final String title;
  final String body;
  final String time;
  final String group; // 'Hari Ini' / 'Kemarin'
  final IconData icon;
  final Color bg;
  final Color fg;
  final bool mascot; // pakai wajah burung hantu sebagai ikon
  final bool urgent;
  final String? detail;
  final List<_Act> acts;
  bool unread;

  _N({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.time,
    required this.group,
    required this.icon,
    required this.bg,
    required this.fg,
    this.mascot = false,
    this.urgent = false,
    this.detail,
    this.acts = const [],
    this.unread = false,
  });
}

/// NOTIFIKASI — inbox. Pengaturannya ada di features/profile/screens/notification_settings_screen.dart
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  static const _filters = <(String, IconData, _Kind?)>[
    ('Semua', Icons.notifications_rounded, null),
    ('Info', Icons.info_rounded, _Kind.info),
    ('Peringatan', Icons.warning_amber_rounded, _Kind.warning),
    ('Sistem', Icons.settings_suggest_rounded, _Kind.system),
  ];

  final List<_N> _items = [
    _N(
      id: 'n1',
      kind: _Kind.warning,
      urgent: true,
      title: 'Guncangan Terdeteksi',
      body: 'Sensor mendeteksi guncangan 3× dari ponsel Salsabila. Dia sudah membatalkannya dan menyatakan aman.',
      time: '15 mnt lalu',
      group: 'Hari Ini',
      icon: Icons.vibration_rounded,
      bg: Aj.sosSoft,
      fg: Aj.sos,
      unread: true,
      detail: 'Pembatalan dilakukan oleh Salsabila sendiri dalam 4 detik. Tidak ada sinyal SOS yang dikirim. Kamu tetap bisa mengecek lokasi terakhirnya bila perlu.',
      acts: [
        _Act(Icons.place_rounded, 'Cek Lokasi', 'Membuka lokasi terakhir Salsabila… (simulasi)'),
        _Act(Icons.call_rounded, 'Telepon', 'Menghubungi Salsabila… (simulasi)'),
      ],
    ),
    _N(
      id: 'n2',
      kind: _Kind.info,
      mascot: true,
      title: 'Perjalanan Kamu Aman!',
      body: 'Terima kasih sudah menggunakan AmanJalan. Kamu tiba dengan selamat, sampai jumpa di perjalanan selanjutnya!',
      time: '2 menit lalu',
      group: 'Hari Ini',
      icon: Icons.pets_rounded,
      bg: Aj.blush,
      fg: Aj.plum,
      unread: true,
      detail: 'Perjalanan selesai tanpa kejadian. Streak Aman-mu bertambah 1 hari. Pertahankan ya!',
      acts: [
        _Act(Icons.history_rounded, 'Lihat Riwayat', 'Membuka riwayat perjalanan… (simulasi)'),
      ],
    ),
    _N(
      id: 'n3',
      kind: _Kind.info,
      title: 'Update Rute Terdekat',
      body: 'Terdapat perubahan kondisi lalu lintas di sekitar lokasi kamu. Cek rute alternatif pada peta.',
      time: '15 menit lalu',
      group: 'Hari Ini',
      icon: Icons.location_on_rounded,
      bg: Aj.mint,
      fg: Aj.mintDeep,
      unread: true,
      detail: 'Ada penutupan sebagian jalan. Rute alternatif menambah waktu sekitar 6 menit tetapi melewati jalan yang lebih terang dan ramai.',
      acts: [
        _Act(Icons.map_rounded, 'Buka Peta', 'Membuka peta rute alternatif… (simulasi)'),
      ],
    ),
    _N(
      id: 'n4',
      kind: _Kind.warning,
      title: 'Peringatan Cuaca',
      body: 'Hujan ringan diperkirakan turun pada 14.00 – 16.00 WIB di area Batam. Harap berhati-hati saat berkendara.',
      time: '1 jam lalu',
      group: 'Hari Ini',
      icon: Icons.thunderstorm_rounded,
      bg: Color(0xFFFFE0E6),
      fg: Aj.sos,
      detail: 'Jalanan bisa licin dan jarak pandang berkurang. Pertimbangkan berangkat lebih awal atau berbagi lokasi dengan Guardian.',
      acts: [
        _Act(Icons.share_location_rounded, 'Bagikan Lokasi', 'Lokasi dibagikan ke Guardian (simulasi)'),
      ],
    ),
    _N(
      id: 'n5',
      kind: _Kind.warning,
      title: 'Baterai Teman Rendah',
      body: 'Daya ponsel Dinda tinggal 18% dan dia sedang dalam perjalanan. Mode hemat daya darurat disarankan.',
      time: '2 jam lalu',
      group: 'Hari Ini',
      icon: Icons.battery_alert_rounded,
      bg: Color(0xFFFFF0C9),
      fg: Color(0xFFB45309),
      detail: 'Kamu bisa mengirim pengingat singkat agar Dinda mengisi daya atau menyalakan mode hemat.',
      acts: [
        _Act(Icons.chat_rounded, 'Ingatkan via WhatsApp', 'Mengirim pengingat ke Dinda… (simulasi)'),
      ],
    ),
    _N(
      id: 'n6',
      kind: _Kind.system,
      title: 'Verifikasi Akun Berhasil',
      body: 'Akun kamu sudah terverifikasi. Sekarang kamu bisa mengakses semua fitur.',
      time: '3 jam lalu',
      group: 'Hari Ini',
      icon: Icons.verified_user_rounded,
      bg: Aj.mint,
      fg: Aj.mintDeep,
      detail: 'Email dan nomor teleponmu sudah terverifikasi, sehingga akunmu lebih aman dan mudah dipulihkan.',
      acts: [
        _Act(Icons.verified_rounded, 'Lihat Status', 'Membuka status akun… (simulasi)'),
      ],
    ),
    _N(
      id: 'n7',
      kind: _Kind.info,
      title: 'Saling Pantau Terhubung',
      body: 'Kamu dan Dinda kini saling menjaga. Lokasi hanya dibagikan saat kamu mengizinkan.',
      time: 'Kemarin 20:15',
      group: 'Kemarin',
      icon: Icons.people_alt_rounded,
      bg: Color(0xFFEDE5FA),
      fg: Color(0xFF5C2880),
      detail: 'Kamu bisa menghentikan Saling Pantau kapan saja dari menu QR Saling Pantau di Profil.',
      acts: [
        _Act(Icons.qr_code_2_rounded, 'Kelola Teman', 'Membuka Saling Pantau… (simulasi)'),
      ],
    ),
    _N(
      id: 'n8',
      kind: _Kind.system,
      title: 'Informasi Penting',
      body: 'Demi keamanan bersama, pastikan selalu mengaktifkan lokasi saat menggunakan layanan AmanJalan.',
      time: 'Kemarin 09:00',
      group: 'Kemarin',
      icon: Icons.campaign_rounded,
      bg: Aj.blush,
      fg: Aj.berry,
      detail: 'Tanpa lokasi aktif, fitur SOS, Pantau Perjalanan, dan Rute Aman tidak dapat bekerja dengan akurat.',
      acts: [
        _Act(Icons.my_location_rounded, 'Cek Izin Lokasi', 'Membuka pengaturan izin lokasi… (simulasi)'),
      ],
    ),
  ];

  int _filter = 0;
  String? _open;

  int get _unreadCount => _items.where((n) => n.unread).length;

  int _unreadOf(_Kind? k) => _items.where((n) => n.unread && (k == null || n.kind == k)).length;

  List<_N> get _visible {
    final k = _filters[_filter].$3;
    return _items.where((n) => k == null || n.kind == k).toList();
  }

  void _markAll() {
    if (_unreadCount == 0) {
      ajSnack(context, 'Semua sudah dibaca', icon: Icons.done_all_rounded);
      return;
    }
    HapticFeedback.lightImpact();
    setState(() {
      for (final n in _items) {
        n.unread = false;
      }
    });
    ajSnack(context, 'Semua notifikasi ditandai dibaca', icon: Icons.done_all_rounded);
  }

  void _toggle(_N n) {
    HapticFeedback.selectionClick();
    setState(() {
      n.unread = false;
      _open = _open == n.id ? null : n.id;
    });
  }

  void _dismiss(_N n) {
    final idx = _items.indexOf(n);
    setState(() {
      _items.remove(n);
      if (_open == n.id) _open = null;
    });
    final m = ScaffoldMessenger.of(context);
    m.hideCurrentSnackBar();
    m.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Aj.plum,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Text('Notifikasi dihapus', style: Aj.b(13, color: Colors.white, w: FontWeight.w700)),
        action: SnackBarAction(
          label: 'URUNGKAN',
          textColor: const Color(0xFFFFB8D1),
          onPressed: () => setState(() => _items.insert(idx.clamp(0, _items.length), n)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _visible;
    final groups = <String>[];
    for (final n in list) {
      if (!groups.contains(n.group)) groups.add(n.group);
    }

    var idx = 0;
    return Scaffold(
      backgroundColor: Aj.bg,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFEEF4), Color(0xFFFFFAFC)],
            stops: [0, 0.5],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _topBar(),
              _filterBar(),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 28),
                  children: [
                    if (list.isEmpty)
                      _empty()
                    else
                      for (final g in groups) ...[
                        _groupLabel(g, list.where((n) => n.group == g && n.unread).length),
                        for (final n in list.where((n) => n.group == g)) _card(n, idx++),
                      ],
                    const SizedBox(height: 6),
                    PfBanner(
                      owl: pfOwlPhone,
                      title: 'Selalu aktifkan notifikasi, ya!',
                      sub: 'Agar kamu tidak ketinggalan informasi penting dari AmanJalan.',
                      button: 'Atur',
                      onButton: () => pfPush(context, const NotificationSettingsScreen()),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lock_outline_rounded, size: 13, color: Aj.muted),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Riwayat terenkripsi & dihapus otomatis setelah 30 hari.',
                            textAlign: TextAlign.center,
                            style: Aj.b(11.5, color: Aj.muted),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────
  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: [
          _round(Icons.arrow_back_ios_new_rounded, () => Navigator.of(context).maybePop(), size: 17),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                Flexible(child: Text('Notifikasi', maxLines: 1, overflow: TextOverflow.ellipsis, style: Aj.h(26, color: Aj.plum))),
                if (_unreadCount > 0) ...[
                  const SizedBox(width: 8),
                  AjPill('$_unreadCount Baru', bg: Aj.plum, fg: Colors.white, size: 11),
                ],
              ],
            ),
          ),
          Tooltip(
            message: 'Tandai semua dibaca',
            child: _round(
              Icons.done_all_rounded,
              _markAll,
              color: _unreadCount > 0 ? Aj.plum : Aj.mintDeep,
            ),
          ),
          const SizedBox(width: 8),
          _round(Icons.tune_rounded, () => pfPush(context, const NotificationSettingsScreen())),
        ],
      ),
    );
  }

  Widget _round(IconData icon, VoidCallback onTap, {double size = 21, Color color = Aj.plum}) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFF3E1E9)),
          boxShadow: Aj.softShadow,
        ),
        child: Icon(icon, size: size, color: color),
      ),
    );
  }

  // ── Filter ────────────────────────────────────────────────
  Widget _filterBar() {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final sel = i == _filter;
          final f = _filters[i];
          final un = _unreadOf(f.$3);
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                _filter = i;
                _open = null;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: sel ? const LinearGradient(colors: [Color(0xFF4A1D5C), Color(0xFF6A2E80)]) : null,
                color: sel ? null : Colors.white,
                border: Border.all(color: sel ? Colors.transparent : const Color(0xFFF3E1E9), width: 1.2),
                boxShadow: sel ? const [BoxShadow(color: Color(0x334A1D5C), blurRadius: 10, offset: Offset(0, 4))] : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(f.$2, size: 16, color: sel ? Colors.white : Aj.muted),
                  const SizedBox(width: 6),
                  Text(f.$1, style: Aj.b(13, color: sel ? Colors.white : Aj.muted, w: FontWeight.w800)),
                  if (un > 0) ...[
                    const SizedBox(width: 7),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(color: sel ? const Color(0x33FFFFFF) : Aj.sosSoft, borderRadius: BorderRadius.circular(10)),
                      child: Text('$un', style: Aj.b(11, color: sel ? Colors.white : Aj.sos, w: FontWeight.w900)),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _groupLabel(String text, int unread) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 14, 4, 10),
      child: Row(
        children: [
          Container(width: 6, height: 6, decoration: const BoxDecoration(color: Aj.berry, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(text.toUpperCase(), style: Aj.b(11.5, color: Aj.plum, w: FontWeight.w900).copyWith(letterSpacing: 0.8)),
          const Spacer(),
          if (unread > 0) Text('$unread belum dibaca', style: Aj.b(11.5, color: Aj.muted, w: FontWeight.w700)),
        ],
      ),
    );
  }

  // ── Kartu notifikasi ──────────────────────────────────────
  Widget _card(_N n, int i) {
    final open = _open == n.id;
    return AnimatedEntrance(
      index: i.clamp(0, 8),
      child: Dismissible(
        key: ValueKey(n.id),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => _dismiss(n),
        background: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.only(right: 24),
          alignment: Alignment.centerRight,
          decoration: BoxDecoration(color: Aj.sosSoft, borderRadius: BorderRadius.circular(24)),
          child: const Icon(Icons.delete_outline_rounded, color: Aj.sos, size: 26),
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () => _toggle(n),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: n.unread ? const LinearGradient(colors: [Color(0xFFFFE4EC), Color(0xFFFFF3F7)], begin: Alignment.topLeft, end: Alignment.bottomRight) : null,
                color: n.unread ? null : Colors.white,
                border: Border.all(
                  color: n.urgent && n.unread ? Aj.sos.withValues(alpha: 0.45) : (n.unread ? const Color(0xFFF6D3DE) : const Color(0xFFF3E1E9)),
                  width: n.urgent && n.unread ? 1.5 : 1.2,
                ),
                boxShadow: Aj.softShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _leading(n),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(n.title, style: Aj.b(14.5, color: n.unread ? Aj.plum : Aj.ink, w: FontWeight.w900, height: 1.25)),
                                ),
                                const SizedBox(width: 8),
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(n.time, style: Aj.b(11, color: Aj.muted, w: FontWeight.w700)),
                                ),
                              ],
                            ),
                            if (n.urgent) ...[
                              const SizedBox(height: 5),
                              const AjPill('Penting', bg: Aj.sosSoft, fg: Aj.sos, icon: Icons.priority_high_rounded, size: 10.5),
                            ],
                            const SizedBox(height: 5),
                            Text(n.body, style: Aj.b(12.5, color: const Color(0xFF5E5663), height: 1.5)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: AnimatedRotation(
                          turns: open ? 0.25 : 0,
                          duration: const Duration(milliseconds: 220),
                          child: const Icon(Icons.chevron_right_rounded, color: Aj.muted, size: 22),
                        ),
                      ),
                    ],
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    alignment: Alignment.topCenter,
                    child: open ? _expanded(n) : const SizedBox(width: double.infinity),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _leading(_N n) {
    return SizedBox(
      width: 54,
      height: 54,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (n.mascot)
            const PfAvatar(size: 54)
          else
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: n.bg,
                border: Border.all(color: Colors.white, width: 2.5),
                boxShadow: Aj.softShadow,
              ),
              child: Icon(n.icon, color: n.fg, size: 26),
            ),
          if (n.unread)
            Positioned(
              right: -1,
              top: -1,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(color: Aj.sos, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _expanded(_N n) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (n.detail != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.75), borderRadius: BorderRadius.circular(16)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline_rounded, size: 16, color: Aj.berry),
                  const SizedBox(width: 8),
                  Expanded(child: Text(n.detail!, style: Aj.b(12, color: Aj.muted, height: 1.5))),
                ],
              ),
            ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final a in n.acts)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    ajSnack(context, a.toast, icon: a.icon);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(colors: [Color(0xFF4A1D5C), Color(0xFF6A2E80)]),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(a.icon, size: 15, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(a.label, style: Aj.b(12, color: Colors.white, w: FontWeight.w800)),
                      ],
                    ),
                  ),
                ),
              GestureDetector(
                onTap: () => _dismiss(n),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFF3E1E9))),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.delete_outline_rounded, size: 15, color: Aj.muted),
                      const SizedBox(width: 6),
                      Text('Hapus', style: Aj.b(12, color: Aj.muted, w: FontWeight.w800)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Kosong ────────────────────────────────────────────────
  Widget _empty() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          const PfOwl(pfOwlThinking, size: 130, fallback: Icons.notifications_off_outlined),
          const SizedBox(height: 10),
          Text('Belum ada notifikasi', style: Aj.h(16, color: Aj.plum)),
          const SizedBox(height: 4),
          Text('Semua tenang di sini. Kami akan kabari kalau ada info penting.', textAlign: TextAlign.center, style: Aj.b(12.5, color: Aj.muted, height: 1.45)),
        ],
      ),
    );
  }
}