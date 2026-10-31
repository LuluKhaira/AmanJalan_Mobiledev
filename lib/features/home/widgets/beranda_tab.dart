import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:amanjalan/core/theme/aj_theme.dart';
import 'package:amanjalan/core/widgets/aj_common.dart';
import 'package:amanjalan/core/widgets/animated_entrance.dart';
import 'package:amanjalan/core/widgets/app_header.dart';
import 'package:amanjalan/core/widgets/press_scale.dart';
import 'package:amanjalan/features/home/aj_data.dart';
import 'package:amanjalan/features/home/streak_store.dart';
import 'package:amanjalan/features/home/streak_widgets.dart';

// Maskot untuk kartu tips (burung hantu jempol + kompas)
const _tipOwlAsset = 'assets/images/onboarding/owl_compass.png';

// ─────────────────────────────────────────────────────────────
// Data tampilan (dummy)
// ─────────────────────────────────────────────────────────────

class _Mode {
  final IconData icon;
  final String label;
  final String badge;
  final String title;
  final String tag;
  final String desc;
  final String cta;
  final Color bg;
  final Color fg;

  const _Mode({
    required this.icon,
    required this.label,
    required this.badge,
    required this.title,
    required this.tag,
    required this.desc,
    required this.cta,
    required this.bg,
    required this.fg,
  });
}

const _modes = [
  _Mode(
    icon: Icons.directions_walk_rounded,
    label: 'Jalan Kaki',
    badge: 'Rute Terang',
    title: 'Proteksi Jalan Kaki Aktif',
    tag: 'Sensor Saku',
    desc: 'Deteksi guncangan saku siaga. Rute peta otomatis memprioritaskan jalan ramai berlampu terang.',
    cta: 'Mulai Jalan Bareng',
    bg: Color(0xFFE8F5E9),
    fg: Color(0xFF2E7D4F),
  ),
  _Mode(
    icon: Icons.two_wheeler_rounded,
    label: 'Naik Motor',
    badge: 'Simpan Plat',
    title: 'Proteksi Naik Motor / Ojol',
    tag: 'Simpan Plat',
    desc: 'Catat plat nomor motor driver agar otomatis terkirim & tersimpan di HP Guardian.',
    cta: 'Pantau Naik Motor',
    bg: Color(0xFFFFF0D2),
    fg: Color(0xFF9A6200),
  ),
  _Mode(
    icon: Icons.directions_car_rounded,
    label: 'Naik Mobil',
    badge: 'Deviasi Rute',
    title: 'Proteksi Mobil / Taksi Online',
    tag: 'Anti-Deviasi',
    desc: 'Alarm deviasi rute aktif. Sistem membunyikan peringatan bila kendaraan keluar dari jalur.',
    cta: 'Pantau Naik Mobil',
    bg: Color(0xFFE3F2FD),
    fg: Color(0xFF1565C0),
  ),
];

const _tips = [
  ('Perjalanan malam?', 'Pilih rute berpenerangan penuh dekat Gedung Utama & Lab TI ya!'),
  ('Aktifkan sensor saku', 'Guncang HP 3x untuk kirim sinyal darurat tanpa membuka aplikasi.'),
  ('Kabari Guardian', 'Check-in sebelum pulang supaya Guardian tahu kamu sudah bergerak.'),
];

class _RouteRec {
  final String title;
  final int minutes;
  final String dist;
  final String badge;
  final Color bg;
  final Color fg;
  final List<(IconData, String)> tags;

  const _RouteRec(this.title, this.minutes, this.dist, this.badge, this.bg, this.fg, this.tags);
}

final _routes = <_RouteRec>[
  _RouteRec('Kampus Utama → Rumah (Batam Centre)', 30, '800 m', 'Sangat Aman', Aj.mint, Aj.mintDeep, const [
    (Icons.videocam_outlined, 'CCTV Terpantau'),
    (Icons.wb_sunny_outlined, 'Lampu Penuh'),
  ]),
  _RouteRec('Kampus → Mess Mahasiswa', 18, '1.2 km', 'Direkomendasikan', Aj.blush, Aj.berry, const [
    (Icons.groups_outlined, 'Jalur Pedestrian Ramai'),
    (Icons.local_police_outlined, 'Pos Satpam 2'),
  ]),
  _RouteRec('Gedung RTF → Technopreneur', 6, '350 m', 'Aman Cepat', Color(0xFFE3F2FD), Color(0xFF1565C0), const [
    (Icons.apartment_outlined, 'Indoor Koridor'),
    (Icons.videocam_outlined, 'CCTV Terkoneksi'),
  ]),
];

final _havens = <(IconData, String, String, String, Color, Color)>[
  (Icons.local_police_rounded, 'Pos Satpam Gedung Utama', '120 m', 'Siaga 24/7', const Color(0xFFE3F2FD), const Color(0xFF1565C0)),
  (Icons.storefront_rounded, 'Minimarket 24 Jam', '350 m', 'Buka 24 Jam', const Color(0xFFE8F5E9), const Color(0xFF2E7D4F)),
  (Icons.local_hospital_rounded, 'Klinik Kampus', '500 m', 'Penerangan Baik', const Color(0xFFFFF3E0), const Color(0xFFE65100)),
];

// ─────────────────────────────────────────────────────────────
// TAB BERANDA
// ─────────────────────────────────────────────────────────────

class BerandaTab extends StatefulWidget {
  final String name;
  final VoidCallback onProfileTap;
  final VoidCallback onOpenMap;
  final VoidCallback onOpenEmergency;
  final VoidCallback onOpenFakeCall;
  final VoidCallback onOpenReport;
  final VoidCallback onManageGuardians;
  final VoidCallback onAddGuardian;

  const BerandaTab({
    super.key,
    required this.name,
    required this.onProfileTap,
    required this.onOpenMap,
    required this.onOpenEmergency,
    required this.onOpenFakeCall,
    required this.onOpenReport,
    required this.onManageGuardians,
    required this.onAddGuardian,
  });

  @override
  State<BerandaTab> createState() => _BerandaTabState();
}

class _BerandaTabState extends State<BerandaTab> {
  static const _maxGuardians = 5;

  int _modeIndex = 0;
  int _tip = 0;
  String _plat = '';
  // Status check-in hari ini dibaca dari StreakStore (satu sumber kebenaran).
  DateTime? get _checkedAt => StreakStore.state.value.checkedToday ? (StreakStore.state.value.checkedAt ?? DateTime.now()) : null;

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 11) return 'Selamat pagi';
    if (h < 15) return 'Selamat siang';
    if (h < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  Future<void> _checkIn() async {
    HapticFeedback.mediumImpact();
    final at = _checkedAt;
    if (at != null) {
      ajSnack(context, 'Kamu sudah check-in pukul ${fmtTime(at)}', icon: Icons.verified_rounded);
      return;
    }
    final n = GuardianStore.guardians.value.length;
    final result = StreakStore.checkIn();
    setState(() {});
    ajSnack(context, 'Check-in terkirim ke $n Guardian', icon: Icons.check_circle_rounded);
    if (result == null) return;
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;
    await showStreakCelebration(context, result);
  }

  void _call(String label, String number) {
    HapticFeedback.mediumImpact();
    ajSnack(context, 'Memanggil $label $number…', icon: Icons.phone_rounded);
  }

  void _showPlatDialog() {
    final controller = TextEditingController(text: _plat);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: [
            const Icon(Icons.two_wheeler_rounded, color: Aj.plum),
            const SizedBox(width: 8),
            Text('Catat Plat Motor', style: Aj.h(16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Masukkan nomor plat motor driver (cth: BP 4521 SXZ) agar otomatis tersimpan & dibagikan ke Guardian.',
              style: Aj.b(13, color: Aj.muted, height: 1.4),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              textCapitalization: TextCapitalization.characters,
              autofocus: true,
              style: Aj.h(15),
              decoration: InputDecoration(
                hintText: 'Contoh: BP 1234 ABC',
                filled: true,
                fillColor: Aj.sand,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Aj.plum, width: 1.5),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: Aj.b(14, color: Aj.muted, w: FontWeight.w700)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Aj.plum,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              final text = controller.text.trim();
              Navigator.pop(ctx);
              setState(() => _plat = text);
              if (text.isNotEmpty) {
                ajSnack(context, 'Plat $text tersimpan & dibagikan ke Guardian', icon: Icons.verified_rounded);
              }
            },
            child: Text('Simpan', style: Aj.b(14, color: Colors.white, w: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppHeader(onProfileTap: widget.onProfileTap),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                AnimatedEntrance(index: 0, child: _hero()),
                const SizedBox(height: 16),
                AnimatedEntrance(index: 1, child: StreakCard(onCheckIn: _checkIn)),
                const SizedBox(height: 26),
                AnimatedEntrance(index: 2, child: _title('Fitur Keamanan Cepat')),
                const SizedBox(height: 12),
                AnimatedEntrance(index: 3, child: _quickRow()),
                const SizedBox(height: 20),
                AnimatedEntrance(index: 4, child: _tipCard()),
                const SizedBox(height: 28),
                AnimatedEntrance(index: 5, child: _title('Pilih Moda Perjalanan')),
                const SizedBox(height: 12),
                AnimatedEntrance(index: 6, child: _modeSection()),
                const SizedBox(height: 28),
                AnimatedEntrance(
                  index: 7,
                  child: _title(
                    'Rekomendasi Rute Aman',
                    sub: 'Jalur aktif dengan pengawasan keamanan',
                    trailing: _link('Lihat Semua', widget.onOpenMap),
                  ),
                ),
                const SizedBox(height: 12),
                for (var i = 0; i < _routes.length; i++) ...[
                  AnimatedEntrance(index: 8 + i, child: _routeCard(_routes[i])),
                  const SizedBox(height: 12),
                ],
                const SizedBox(height: 16),
                AnimatedEntrance(
                  index: 11,
                  child: _title('Titik Aman Terdekat', trailing: _link('Lihat Peta', widget.onOpenMap)),
                ),
                const SizedBox(height: 12),
                AnimatedEntrance(index: 12, child: _havenRow()),
                const SizedBox(height: 28),
                AnimatedEntrance(index: 13, child: _title('Guardian Kamu', trailing: _link('Kelola', widget.onManageGuardians))),
                const SizedBox(height: 12),
                AnimatedEntrance(index: 14, child: _guardianRow()),
                const SizedBox(height: 24),
                AnimatedEntrance(index: 15, child: _pamdalCard()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // Potongan UI kecil
  // ─────────────────────────────────────────────────────────
  Widget _title(String text, {String? sub, Widget? trailing}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(text, style: Aj.h(16.5)),
              if (sub != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(sub, style: Aj.b(12.5, color: Aj.muted)),
                ),
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _link(String text, VoidCallback onTap) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(text, style: Aj.b(13.5, color: Aj.plum, w: FontWeight.w800)),
            const SizedBox(width: 2),
            const Icon(Icons.chevron_right_rounded, size: 18, color: Aj.plum),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // HERO
  // ─────────────────────────────────────────────────────────
  Widget _hero() {
    final checked = _checkedAt != null;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF38123E), Color(0xFF561D5E), Color(0xFF7A2E5E)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF38123E).withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            Positioned(
              top: -34,
              right: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.06)),
              ),
            ),
            Positioned(
              bottom: -50,
              left: -30,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFFF8FAB).withValues(alpha: 0.10)),
              ),
            ),
            const Positioned.fill(child: IgnorePointer(child: _Sheen())),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const _PulseDot(),
                                  const SizedBox(width: 8),
                                  Text('SISTEM AKTIF 24/7', style: Aj.b(11, color: Colors.white, w: FontWeight.w800)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              '$_greeting, ${widget.name}',
                              style: Aj.b(13, color: const Color(0xCCFFFFFF), w: FontWeight.w700),
                            ),
                            const SizedBox(height: 2),
                            Text('Status Kamu: Aman', style: Aj.h(23, color: Colors.white, height: 1.2)),
                            const SizedBox(height: 4),
                            Text(
                              'Terpantau di area Kampus Terpadu',
                              style: Aj.b(13, color: const Color(0xCCFFFFFF), w: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      _checkInButton(checked),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _heroStats(),
                  const SizedBox(height: 14),
                  Container(height: 1, color: Colors.white.withValues(alpha: 0.14)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 16, color: Colors.white),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Depan Gedung Utama',
                          overflow: TextOverflow.ellipsis,
                          style: Aj.b(13, color: Colors.white, w: FontWeight.w800),
                        ),
                      ),
                      Text(
                        checked ? 'Check-in ${fmtTime(_checkedAt!)}' : 'Pembaruan: 1 mnt lalu',
                        style: Aj.b(11.5, color: const Color(0xB3FFFFFF), w: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Tiga statistik kaca di dalam hero
  Widget _heroStats() {
    return ValueListenableBuilder<List<Guardian>>(
      valueListenable: GuardianStore.guardians,
      builder: (context, guardians, _) {
        return ValueListenableBuilder<StreakState>(
          valueListenable: StreakStore.state,
          builder: (context, st, _) {
            final online = guardians.where((g) => g.online).length;
            return Row(
              children: [
                _heroStat(Icons.shield_rounded, '$online/${guardians.length}', 'Guardian aktif', const Color(0xFF86EFAC)),
                const SizedBox(width: 8),
                _heroStat(Icons.local_fire_department_rounded, '${st.alive} hari', 'Streak aman', const Color(0xFFFFC21A)),
                const SizedBox(width: 8),
                _heroStat(Icons.verified_user_rounded, '3 titik', 'Pos aman dekat', const Color(0xFF9CCBF4)),
              ],
            );
          },
        );
      },
    );
  }

  Widget _heroStat(IconData icon, String value, String label, Color accent) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: accent),
            const SizedBox(width: 7),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: Aj.h(12.5, color: Colors.white)),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Aj.b(9.5, color: const Color(0xB3FFFFFF), w: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _checkInButton(bool checked) {
    return PressScale(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _checkIn,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 78,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: checked ? const Color(0xFF4ADE80).withValues(alpha: 0.22) : Colors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: checked ? const Color(0xFF4ADE80).withValues(alpha: 0.7) : Colors.white.withValues(alpha: 0.3),
              width: 1.3,
            ),
          ),
          child: Column(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: Icon(
                  checked ? Icons.verified_rounded : Icons.check_circle_outline_rounded,
                  key: ValueKey(checked),
                  size: 26,
                  color: checked ? const Color(0xFF86EFAC) : Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                checked ? 'Tercatat' : 'Check-in',
                style: Aj.b(11.5, color: Colors.white, w: FontWeight.w800),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // FITUR CEPAT
  // ─────────────────────────────────────────────────────────
  Widget _quickRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _QuickTile(
          icon: Icons.map_outlined,
          label: 'Jalur Aman',
          sub: 'CCTV & Terang',
          bg: Aj.mint,
          fg: Aj.mintDeep,
          onTap: widget.onOpenMap,
        ),
        const SizedBox(width: 10),
        _QuickTile(
          icon: Icons.warning_amber_rounded,
          label: 'SOS',
          sub: 'Bantuan Kilat',
          bg: Aj.sosSoft,
          fg: Aj.sos,
          danger: true,
          onTap: widget.onOpenEmergency,
        ),
        const SizedBox(width: 10),
        _QuickTile(
          icon: Icons.campaign_outlined,
          label: 'Lapor',
          sub: 'Kejadian',
          bg: Aj.blush,
          fg: Aj.berry,
          onTap: widget.onOpenReport,
        ),
        const SizedBox(width: 10),
        _QuickTile(
          icon: Icons.phone_in_talk_outlined,
          label: 'Fake Call',
          sub: 'Telepon Palsu',
          bg: const Color(0xFFF1E8FB),
          fg: const Color(0xFF7B3FBF),
          onTap: widget.onOpenFakeCall,
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────
  // TIPS + MASKOT
  // ─────────────────────────────────────────────────────────
  Widget _tipCard() {
    final t = _tips[_tip];

    return PressScale(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _tip = (_tip + 1) % _tips.length);
        },
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFBE3EB), Color(0xFFFFF3F6)],
            ),
            border: Border.all(color: const Color(0xFFF6D3DE)),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 104,
                height: 104,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 98,
                      height: 98,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: Aj.softShadow,
                      ),
                    ),
                    // Burung hantu "keluar" dari lingkaran
                    Positioned(
                      top: -14,
                      child: Image.asset(
                        _tipOwlAsset,
                        width: 112,
                        height: 112,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(Icons.pets_rounded, size: 40, color: Aj.plum),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Column(
                    key: ValueKey(_tip),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AjPill('TIPS SI KECIL', bg: Colors.white, fg: Aj.berry, icon: Icons.lightbulb_outline_rounded, size: 10),
                      const SizedBox(height: 8),
                      Text(t.$1, style: Aj.h(15.5)),
                      const SizedBox(height: 3),
                      Text(t.$2, style: Aj.b(12.5, color: Aj.muted, height: 1.4)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // MODA PERJALANAN
  // ─────────────────────────────────────────────────────────
  Widget _modeSection() {
    final m = _modes[_modeIndex];

    return Column(
      children: [
        Row(
          children: [
            for (var i = 0; i < _modes.length; i++) ...[
              if (i > 0) const SizedBox(width: 10),
              Expanded(child: _modeChip(i)),
            ],
          ],
        ),
        const SizedBox(height: 12),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: KeyedSubtree(
            key: ValueKey(_modeIndex),
            child: AjCard(
              radius: 22,
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AjIconBubble(m.icon, bg: m.bg, fg: m.fg, size: 44),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(child: Text(m.title, style: Aj.h(13.5), overflow: TextOverflow.ellipsis)),
                                const SizedBox(width: 6),
                                AjPill(m.tag, bg: m.bg, fg: m.fg, size: 9.5),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(m.desc, style: Aj.b(12, color: Aj.muted, height: 1.4)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (_modeIndex == 1) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 40,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(color: Aj.sand, borderRadius: BorderRadius.circular(12)),
                            child: Row(
                              children: [
                                const Icon(Icons.pin_outlined, size: 16, color: Aj.plum),
                                const SizedBox(width: 6),
                                Text(
                                  _plat.isEmpty ? 'Plat: Belum dicatat' : 'Plat: $_plat',
                                  style: Aj.b(12.5, color: _plat.isEmpty ? Aj.muted : Aj.plum, w: FontWeight.w800),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton.icon(
                          onPressed: _showPlatDialog,
                          style: FilledButton.styleFrom(
                            backgroundColor: Aj.plum,
                            minimumSize: const Size(0, 40),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.edit_rounded, size: 14),
                          label: Text(_plat.isEmpty ? 'Catat Plat' : 'Ubah Plat', style: Aj.b(12, color: Colors.white, w: FontWeight.w800)),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 14),
                  _startButton(m),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _modeChip(int i) {
    final m = _modes[i];
    final sel = i == _modeIndex;

    return PressScale(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (sel) return;
          HapticFeedback.selectionClick();
          setState(() => _modeIndex = i);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 6),
          decoration: BoxDecoration(
            color: sel ? Aj.blush : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: sel ? Aj.plum : Aj.line, width: sel ? 1.7 : 1.1),
            boxShadow: sel ? null : Aj.softShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(m.icon, size: 26, color: sel ? Aj.plum : Aj.muted),
              const SizedBox(height: 6),
              Text(m.label, style: Aj.b(12.5, color: sel ? Aj.plum : Aj.ink, w: FontWeight.w800)),
              const SizedBox(height: 1),
              Text(m.badge, style: Aj.b(10, color: sel ? Aj.plum : Aj.muted, w: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _startButton(_Mode m) {
    return PressScale(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          widget.onOpenMap();
        },
        child: Container(
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: const LinearGradient(colors: [Color(0xFF4A1D5C), Color(0xFF6A2E80)]),
            boxShadow: const [BoxShadow(color: Color(0x404A1D5C), blurRadius: 14, offset: Offset(0, 6))],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(m.icon, size: 20, color: Colors.white),
              const SizedBox(width: 8),
              Text(m.cta, style: Aj.h(14.5, color: Colors.white)),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // REKOMENDASI RUTE
  // ─────────────────────────────────────────────────────────
  Widget _routeCard(_RouteRec r) {
    return AjCard(
      radius: 22,
      padding: const EdgeInsets.all(14),
      onTap: widget.onOpenMap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AjIconBubble(Icons.trending_up_rounded, bg: r.bg, fg: r.fg, size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: Aj.h(14, height: 1.25)),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(Icons.schedule_rounded, size: 14, color: Aj.plum),
                        const SizedBox(width: 4),
                        Text('${r.minutes} menit', style: Aj.b(12.5, color: Aj.plum, w: FontWeight.w800)),
                        Text('  •  ${r.dist}', style: Aj.b(12.5, color: Aj.muted, w: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AjPill(r.badge, bg: r.bg, fg: r.fg, size: 10),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: Aj.line),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final t in r.tags) AjPill(t.$2, bg: Aj.sand, fg: Aj.muted, icon: t.$1, size: 10.5),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // TITIK AMAN
  // ─────────────────────────────────────────────────────────
  Widget _havenRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          for (final h in _havens) ...[
            _havenCard(h),
            const SizedBox(width: 12),
          ],
        ],
      ),
    );
  }

  Widget _havenCard((IconData, String, String, String, Color, Color) h) {
    return PressScale(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          widget.onOpenMap();
        },
        child: Container(
          width: 178,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Aj.line, width: 1.1),
            boxShadow: Aj.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AjIconBubble(h.$1, bg: Aj.blush, fg: Aj.plum, size: 40),
                  AjPill(h.$4, bg: h.$5, fg: h.$6, size: 9.5),
                ],
              ),
              const SizedBox(height: 12),
              Text(h.$2, maxLines: 1, overflow: TextOverflow.ellipsis, style: Aj.h(13)),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.near_me_rounded, size: 12, color: Aj.plum),
                  const SizedBox(width: 4),
                  Text(h.$3, style: Aj.b(12, color: Aj.plum, w: FontWeight.w800)),
                  Text('  •  Pos Aman', style: Aj.b(12, color: Aj.muted)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // GUARDIAN
  // ─────────────────────────────────────────────────────────
  Widget _guardianRow() {
    return ValueListenableBuilder<List<Guardian>>(
      valueListenable: GuardianStore.guardians,
      builder: (context, list, _) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final g in list) ...[
                _guardianItem(g),
                const SizedBox(width: 16),
              ],
              if (list.length < _maxGuardians) _addGuardianItem(),
            ],
          ),
        );
      },
    );
  }

  Widget _guardianItem(Guardian g) {
    return GestureDetector(
      onTap: widget.onManageGuardians,
      child: SizedBox(
        width: 76,
        child: Column(
          children: [
            AjAvatar(name: g.name, size: 62, online: g.online, color: g.color, imageUrl: g.imageUrl),
            const SizedBox(height: 7),
            Text(
              g.name.split(' ').first,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Aj.b(13, w: FontWeight.w800),
            ),
            Text(g.role, maxLines: 1, overflow: TextOverflow.ellipsis, style: Aj.b(11, color: Aj.muted)),
          ],
        ),
      ),
    );
  }

  Widget _addGuardianItem() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onAddGuardian();
      },
      child: SizedBox(
        width: 76,
        child: Column(
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFD5C9DC), width: 1.5),
                boxShadow: Aj.softShadow,
              ),
              child: const Icon(Icons.person_add_alt_1_outlined, color: Aj.plum, size: 24),
            ),
            const SizedBox(height: 7),
            Text('Tambah', style: Aj.b(13, color: Aj.muted, w: FontWeight.w800)),
            Text('Guardian', style: Aj.b(11, color: Aj.muted)),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // PAMDAL
  // ─────────────────────────────────────────────────────────
  Widget _pamdalCard() {
    return AjCard(
      radius: 22,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: Aj.sosSoft, borderRadius: BorderRadius.circular(14)),
            child: Text('24h', style: Aj.h(14, color: Aj.sos)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('PAMDAL Polibatam', style: Aj.h(14)),
                const SizedBox(height: 2),
                Text('(0778) 469858 • Ext. 102', style: Aj.b(12, color: Aj.muted, w: FontWeight.w600)),
              ],
            ),
          ),
          PressScale(
            child: GestureDetector(
              onTap: () => _call('PAMDAL Polibatam', '(0778) 469858'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                decoration: BoxDecoration(color: Aj.plum, borderRadius: BorderRadius.circular(22)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.phone_rounded, size: 15, color: Colors.white),
                    const SizedBox(width: 6),
                    Text('Panggil', style: Aj.b(13, color: Colors.white, w: FontWeight.w800)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// KARTU FITUR CEPAT
// ─────────────────────────────────────────────────────────────

class _QuickTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final Color bg;
  final Color fg;
  final bool danger;
  final VoidCallback onTap;

  const _QuickTile({
    required this.icon,
    required this.label,
    required this.sub,
    required this.bg,
    required this.fg,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: PressScale(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            danger ? HapticFeedback.heavyImpact() : HapticFeedback.selectionClick();
            onTap();
          },
          child: Container(
            height: 132,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
            decoration: BoxDecoration(
              color: danger ? Aj.sosSoft : Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: danger ? Aj.sos.withValues(alpha: 0.35) : Aj.line,
                width: danger ? 1.4 : 1.1,
              ),
              boxShadow: Aj.softShadow,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: danger ? Aj.sos : bg,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: danger
                        ? [BoxShadow(color: Aj.sos.withValues(alpha: 0.35), blurRadius: 12, offset: const Offset(0, 5))]
                        : null,
                  ),
                  child: Icon(icon, size: 26, color: danger ? Colors.white : fg),
                ),
                const SizedBox(height: 10),
                Text(
                  label,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: Aj.b(12.5, color: danger ? Aj.sos : Aj.ink, w: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: Aj.b(10.5, color: Aj.muted, height: 1.2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// KILAU YANG MELINTAS DI HERO
// ─────────────────────────────────────────────────────────────

class _Sheen extends StatefulWidget {
  const _Sheen();

  @override
  State<_Sheen> createState() => _SheenState();
}

class _SheenState extends State<_Sheen> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 5200),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final x = -1.8 + 3.6 * Curves.easeInOut.transform(_c.value);
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(x - 0.5, -1),
              end: Alignment(x + 0.5, 1),
              colors: [
                Colors.white.withValues(alpha: 0),
                Colors.white.withValues(alpha: 0.10),
                Colors.white.withValues(alpha: 0),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// TITIK HIJAU BERDENYUT
// ─────────────────────────────────────────────────────────────

class _PulseDot extends StatefulWidget {
  const _PulseDot();

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 14,
      height: 14,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 8 + 6 * _c.value,
                height: 8 + 6 * _c.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF4ADE80).withValues(alpha: (1 - _c.value) * 0.45),
                ),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(color: Color(0xFF4ADE80), shape: BoxShape.circle),
              ),
            ],
          );
        },
      ),
    );
  }
}