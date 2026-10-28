import 'dart:async';

import 'package:flutter/material.dart';
import 'package:amanjalan/core/theme/aj_theme.dart';
import 'package:amanjalan/core/widgets/aj_common.dart';
import 'package:amanjalan/core/widgets/app_header.dart';
import 'package:amanjalan/features/home/aj_data.dart';

/// PERJALANAN — dua mode: "Saya Memantau" & "Saya Berjalan".
class PerjalananTab extends StatefulWidget {
  /// Buka layar darurat milik tim (EmergencyScreen).
  final VoidCallback? onOpenEmergency;
  /// Pindah ke tab Peta.
  final VoidCallback? onOpenMap;
  /// Ketuk avatar di header → tab Profil.
  final VoidCallback? onProfileTap;

  const PerjalananTab({super.key, this.onOpenEmergency, this.onOpenMap, this.onProfileTap});

  @override
  State<PerjalananTab> createState() => _PerjalananTabState();
}

class _PerjalananTabState extends State<PerjalananTab> {
  int _mode = 0; // 0 = memantau, 1 = berjalan

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppHeader(onProfileTap: widget.onProfileTap),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _ModeToggle(value: _mode, onChanged: (v) => setState(() => _mode = v)),
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            switchInCurve: Curves.easeOutCubic,
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(0, .03), end: Offset.zero).animate(anim),
                child: child,
              ),
            ),
            child: _mode == 0
                ? _MonitoringView(key: const ValueKey('mon'), onOpenEmergency: widget.onOpenEmergency)
                : _WalkingView(key: const ValueKey('walk'), onOpenEmergency: widget.onOpenEmergency, onOpenMap: widget.onOpenMap),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// TOGGLE
// ─────────────────────────────────────────────────────────────

class _ModeToggle extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const _ModeToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(color: const Color(0xFFEEE9E6), borderRadius: BorderRadius.circular(28)),
      child: LayoutBuilder(builder: (context, c) {
        final w = c.maxWidth / 2;
        return Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              left: value == 0 ? 0 : w,
              width: w,
              top: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Aj.plum,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [BoxShadow(color: Color(0x334A1D5C), blurRadius: 10, offset: Offset(0, 4))],
                ),
              ),
            ),
            Row(
              children: [
                _seg(0, Icons.remove_red_eye_outlined, 'Saya Memantau'),
                _seg(1, Icons.directions_walk_rounded, 'Saya Berjalan'),
              ],
            ),
          ],
        );
      }),
    );
  }

  Widget _seg(int i, IconData icon, String label) {
    final sel = value == i;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(i),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: sel ? Colors.white : Aj.muted),
              const SizedBox(width: 6),
              Flexible(
                child: Text(label, overflow: TextOverflow.ellipsis, style: Aj.b(13.5, color: sel ? Colors.white : Aj.muted, w: FontWeight.w800)),
              ),
              const SizedBox(width: 6),
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(color: sel ? const Color(0xFFFF8FAB) : const Color(0xFFD5CDD0), shape: BoxShape.circle),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// MODE 1 — SAYA MEMANTAU
// ─────────────────────────────────────────────────────────────

class _MonitoringView extends StatelessWidget {
  final VoidCallback? onOpenEmergency;
  const _MonitoringView({super.key, this.onOpenEmergency});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barter proteksi
          AjCard(
            color: Aj.blush,
            shadow: false,
            radius: 22,
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                const AjIconBubble(Icons.sync_alt_rounded, bg: Aj.blushDeep, fg: Aj.berry, size: 44),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Text('Barter Proteksi Aktif', style: Aj.h(13.5)),
                        const SizedBox(width: 6),
                        Container(width: 6, height: 6, decoration: const BoxDecoration(color: Aj.plum, shape: BoxShape.circle)),
                      ]),
                      const SizedBox(height: 2),
                      Text('Anda & Salsa saling menjaga real-time', style: Aj.b(12.5, color: Aj.muted)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _barterSheet(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    child: Text('Detail', style: Aj.b(12.5, color: Aj.plum, w: FontWeight.w800)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // Lingkar pantau
          const AjSectionTitle(
            'Lingkar Pantau Saya',
            trailing: _LiveUpdate(),
          ),
          const _FriendTrackCard(),
          const SizedBox(height: 14),
          const _MotherCard(),
          const SizedBox(height: 18),
          const _TukarProteksiCard(),
        ],
      ),
    );
  }

  void _barterSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const AjSheet(
        title: 'Barter Proteksi',
        child: _BarterDetail(),
      ),
    );
  }
}

class _BarterDetail extends StatelessWidget {
  const _BarterDetail();

  @override
  Widget build(BuildContext context) {
    Widget row(IconData i, String t, String s) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            children: [
              AjIconBubble(i, size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(t, style: Aj.b(14.5, w: FontWeight.w800)),
                  Text(s, style: Aj.b(12.5, color: Aj.muted)),
                ]),
              ),
            ],
          ),
        );
    return Column(
      children: [
        row(Icons.schedule_rounded, 'Aktif sejak 19.30', 'Saling memantau selama salah satu berjalan'),
        row(Icons.location_on_outlined, 'Lokasi live dibagikan', 'Hanya terlihat oleh Anda & Salsa'),
        row(Icons.notifications_active_outlined, 'Peringatan otomatis', 'Guncangan 3x atau berhenti > 2 menit'),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
              ajSnack(context, 'Barter proteksi dijeda 1 jam', icon: Icons.pause_circle_outline_rounded);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Aj.berry,
              minimumSize: const Size.fromHeight(48),
              side: const BorderSide(color: Aj.blushDeep, width: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text('Jeda Barter 1 Jam', style: Aj.b(14, color: Aj.berry, w: FontWeight.w800)),
          ),
        ),
      ],
    );
  }
}

class _LiveUpdate extends StatefulWidget {
  const _LiveUpdate();

  @override
  State<_LiveUpdate> createState() => _LiveUpdateState();
}

class _LiveUpdateState extends State<_LiveUpdate> {
  int _s = 12;
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _s = _s >= 29 ? 3 : _s + 1);
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 7, height: 7, decoration: const BoxDecoration(color: Color(0xFF1F6B45), shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text('Update $_s dtk lalu', style: Aj.b(12, color: Aj.muted)),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _StatTile(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 8, 10),
        decoration: BoxDecoration(color: Aj.sand, borderRadius: BorderRadius.circular(14)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: Aj.berry),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Aj.b(10.5, color: Aj.muted)),
                  Text(value, style: Aj.h(13.5), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FriendTrackCard extends StatefulWidget {
  const _FriendTrackCard();

  @override
  State<_FriendTrackCard> createState() => _FriendTrackCardState();
}

class _FriendTrackCardState extends State<_FriendTrackCard> {
  double _p = .38;
  Timer? _t;

  @override
  void initState() {
    super.initState();
    // Simulasi titik teman bergerak pelan di peta mini.
    _t = Timer.periodic(const Duration(milliseconds: 900), (_) {
      if (!mounted) return;
      setState(() => _p = _p >= .92 ? .2 : _p + .012);
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AjCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AjAvatar(
                name: 'Salsabila Rahma',
                size: 52,
                online: true,
                color: Color(0xFFF0F4E6),
                imageUrl: 'https://images.unsplash.com/photo-1567532939604-b6b5b0db2604?w=150',
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Salsabila Rahma', style: Aj.h(16)),
                    const SizedBox(height: 4),
                    Row(children: [
                      const AjPill('Teman Kos', bg: Aj.sand, fg: Aj.muted),
                      const SizedBox(width: 6),
                      Flexible(child: Text('• Sedang Pulang', overflow: TextOverflow.ellipsis, style: Aj.b(12, color: Aj.berry, w: FontWeight.w800))),
                    ]),
                  ],
                ),
              ),
              const AjPill('Jl. Margonda', bg: Aj.blush, fg: Aj.berry),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              _StatTile(Icons.battery_5_bar_rounded, 'Baterai', '78%'),
              SizedBox(width: 8),
              _StatTile(Icons.gps_fixed_rounded, 'GPS Akurat', '±3m'),
              SizedBox(width: 8),
              _StatTile(Icons.directions_walk_rounded, 'Kecepatan', '4.1 km/j'),
            ],
          ),
          const SizedBox(height: 12),
          Stack(
            children: [
              RouteMap(height: 150, progress: _p),
              Positioned(
                left: 10,
                right: 10,
                bottom: 10,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        decoration: BoxDecoration(color: const Color(0xE6FFFFFF), borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            const Icon(Icons.navigation_outlined, size: 14, color: Aj.plum),
                            const SizedBox(width: 6),
                            Flexible(child: Text('Kampus UI → Kos Melati', overflow: TextOverflow.ellipsis, style: Aj.b(11.5, w: FontWeight.w700))),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                      decoration: BoxDecoration(color: Aj.plum, borderRadius: BorderRadius.circular(12)),
                      child: Text('Est. 8 mnt lagi', style: Aj.b(11.5, color: Colors.white, w: FontWeight.w800)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _radar(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: Aj.plum,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.radar_rounded, size: 20),
                  label: Text('Buka Radar Live', style: Aj.b(14, color: Colors.white, w: FontWeight.w800)),
                ),
              ),
              const SizedBox(width: 8),
              _SquareBtn(Icons.call_outlined, Aj.sand, Aj.muted, () => ajSnack(context, 'Memanggil Salsabila…', icon: Icons.call_rounded)),
              const SizedBox(width: 8),
              _SquareBtn(Icons.campaign_outlined, Aj.blush, Aj.berry, () => ajSnack(context, 'Bunyi peringatan dikirim ke ponsel Salsa', icon: Icons.campaign_rounded)),
            ],
          ),
        ],
      ),
    );
  }

  void _radar(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AjSheet(title: 'Radar Live • Salsabila', child: _RadarSheet()),
    );
  }
}

class _SquareBtn extends StatelessWidget {
  final IconData icon;
  final Color bg;
  final Color fg;
  final VoidCallback onTap;
  const _SquareBtn(this.icon, this.bg, this.fg, this.onTap);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
        child: Icon(icon, color: fg, size: 21),
      ),
    );
  }
}

class _MotherCard extends StatelessWidget {
  const _MotherCard();

  @override
  Widget build(BuildContext context) {
    return AjCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              const AjAvatar(
                name: 'Ibu Nurhayati',
                size: 48,
                online: true,
                checkmark: true,
                color: Color(0xFFF4E6F0),
                imageUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150',
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ibu Nurhayati', style: Aj.h(15.5)),
                    Text('Ibu Tercinta', style: Aj.b(12, color: Aj.muted)),
                  ],
                ),
              ),
              const AjPill('Aman di Rumah', bg: Aj.mint, fg: Aj.mintDeep, icon: Icons.location_on_outlined),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Aj.sand, borderRadius: BorderRadius.circular(14)),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline_rounded, size: 18, color: Aj.muted),
                const SizedBox(width: 8),
                Expanded(child: Text('Masuk geofence rumah pukul 20:45', style: Aj.b(12.5, w: FontWeight.w700))),
                const Icon(Icons.battery_5_bar_rounded, size: 15, color: Aj.muted),
                const SizedBox(width: 2),
                Text('89%', style: Aj.b(11.5, color: Aj.muted)),
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => ajSnack(context, 'Membuka WhatsApp…', icon: Icons.chat_bubble_outline_rounded),
              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16, color: Aj.berry),
              label: Text('Sapa Ibu via WhatsApp', style: Aj.b(12.5, color: Aj.berry, w: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }
}

class _TukarProteksiCard extends StatelessWidget {
  const _TukarProteksiCard();

  @override
  Widget build(BuildContext context) {
    Widget friend(String name, String tag, bool active, bool two) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: active ? Aj.plum : const Color(0xFFD5CDD0), shape: BoxShape.circle)),
              const SizedBox(width: 10),
              Expanded(child: Text(name, style: Aj.b(13, w: FontWeight.w800))),
              AjPill(tag, bg: two ? Aj.blush : Aj.sand, fg: two ? Aj.berry : Aj.muted, size: 10.5),
            ],
          ),
        );

    return AjCard(
      color: const Color(0xFFEFE9E5),
      shadow: false,
      padding: const EdgeInsets.all(18),
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
                    Text('Tukar Proteksi Teman', style: Aj.h(16.5)),
                    const SizedBox(height: 4),
                    Text('Saling jaga saat jalan malam tanpa perlu diminta berulang kali.', style: Aj.b(12.5, color: Aj.muted, height: 1.3)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: () => _qr(context),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(color: Aj.plum, borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.qr_code_2_rounded, color: Colors.white, size: 26),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _WhiteBtn(Icons.share_outlined, 'Bagi Link Unik', () => ajSnack(context, 'Link undangan disalin: amanjalan.id/u/anindya', icon: Icons.link_rounded))),
              const SizedBox(width: 10),
              Expanded(child: _WhiteBtn(Icons.photo_camera_outlined, 'Scan QR Teman', () => ajSnack(context, 'Kamera pemindai dibuka (simulasi)', icon: Icons.qr_code_scanner_rounded))),
            ],
          ),
          const SizedBox(height: 16),
          Text('Lingkaran Timbal-Balik Aktif (3)', style: Aj.b(12, w: FontWeight.w800)),
          const SizedBox(height: 4),
          friend('Dinda Kirana', 'Saling Pantau', true, true),
          friend('Salsabila Rahma', 'Saling Pantau', true, true),
          friend('Rio Pratama', 'Hanya Pemantau', false, false),
        ],
      ),
    );
  }

  void _qr(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const AjSheet(title: 'QR Saling Pantau', child: AjQrBox()),
    );
  }
}

class _WhiteBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _WhiteBtn(this.icon, this.label, this.onTap);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 44,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 17, color: Aj.plum),
            const SizedBox(width: 6),
            Flexible(child: Text(label, overflow: TextOverflow.ellipsis, style: Aj.b(12.5, w: FontWeight.w800))),
          ],
        ),
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────
// MODE 2 — SAYA BERJALAN
// ─────────────────────────────────────────────────────────────

class _WalkingView extends StatefulWidget {
  final VoidCallback? onOpenEmergency;
  final VoidCallback? onOpenMap;
  const _WalkingView({super.key, this.onOpenEmergency, this.onOpenMap});

  @override
  State<_WalkingView> createState() => _WalkingViewState();
}

class _WalkingViewState extends State<_WalkingView> {
  int _dest = 0;
  bool _guncang = true;
  bool _autoArrive = true;

  @override
  Widget build(BuildContext context) {
    final d = kDestinations[_dest];

    return ValueListenableBuilder<ActiveTrip?>(
      valueListenable: TripStore.active,
      builder: (context, active, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner proteksi
              AjCard(
                color: Aj.blush,
                shadow: false,
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.verified_user_outlined, color: Aj.berry),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Flexible(child: Text('Proteksi Siap Menemani', style: Aj.h(13.5, color: Aj.berry))),
                            const SizedBox(width: 6),
                            const AjPill('GPS Presisi Tinggi', bg: Colors.white, fg: Aj.berry, dot: true, size: 9.5),
                          ]),
                          const SizedBox(height: 4),
                          Text.rich(
                            TextSpan(style: Aj.b(12.5, color: Aj.muted, height: 1.3), children: [
                              TextSpan(text: 'Ibu Nurhayati', style: Aj.b(12.5, w: FontWeight.w800)),
                              const TextSpan(text: ' & '),
                              TextSpan(text: 'Dinda', style: Aj.b(12.5, w: FontWeight.w800)),
                              const TextSpan(text: ' siaga mengawal langkahmu dari jauh secara real-time.'),
                            ]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              if (active != null) ...[
                ActiveTripCard(trip: active),
                const SizedBox(height: 16),
              ] else ...[
                // Mau jalan ke mana
                AjCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const AjIconBubble(Icons.explore_outlined, bg: Aj.sand, fg: Aj.muted, size: 40),
                          const SizedBox(width: 12),
                          Expanded(child: Text('Mau jalan ke mana\nmalam ini?', style: Aj.h(16, height: 1.25))),
                          const AjPill('Jalur Terang Prioritas', bg: Aj.mint, fg: Aj.mintDeep, icon: Icons.wb_sunny_outlined, size: 10.5),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 42,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: kDestinations.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (_, i) {
                            final sel = i == _dest;
                            final it = kDestinations[i];
                            return GestureDetector(
                              onTap: () => setState(() => _dest = i),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                decoration: BoxDecoration(color: sel ? Aj.plum : Aj.sand, borderRadius: BorderRadius.circular(21)),
                                child: Row(
                                  children: [
                                    Icon(it.icon, size: 17, color: sel ? Colors.white : Aj.plum),
                                    const SizedBox(width: 6),
                                    Text(it.label, style: Aj.b(13, color: sel ? Colors.white : Aj.ink, w: FontWeight.w800)),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 14),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: Container(
                          key: ValueKey(_dest),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(color: Aj.sand, borderRadius: BorderRadius.circular(18)),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.location_on_outlined, color: Aj.muted, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('${d.from} → ${d.to}', style: Aj.h(14)),
                                        Text('Jarak ${fmtDistance(d.meters)} • Rata-rata ${d.minutes - 1}-${d.minutes + 1} menit jalan kaki', style: Aj.b(12, color: Aj.muted, height: 1.3)),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text('${d.minutes}', style: Aj.h(24, height: 1)),
                                      Text('Menit', style: Aj.b(12, color: Aj.muted, w: FontWeight.w800)),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const RouteMap(height: 110, progress: 0.0),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                                child: Row(
                                  children: [
                                    const AjIconBubble(Icons.local_police_outlined, bg: Aj.mint, fg: Aj.mintDeep, size: 34),
                                    const SizedBox(width: 10),
                                    Expanded(child: Text('${d.havens} Pos Titik Aman (Safe Havens) di sepanjang rute', style: Aj.b(12.5, w: FontWeight.w700, height: 1.25))),
                                    TextButton(
                                      onPressed: widget.onOpenMap ?? () => ajSnack(context, 'Peta titik aman dibuka', icon: Icons.map_outlined),
                                      child: Text('Lihat\nPeta', textAlign: TextAlign.center, style: Aj.b(12, color: Aj.berry, w: FontWeight.w800, height: 1.15)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          TripStore.start(d);
                          ajSnack(context, 'Jalan aman dimulai. Live monitor dikirim ke 2 Guardian.', icon: Icons.directions_walk_rounded);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFF4A1D5C), Color(0xFF6A2E80)]),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [BoxShadow(color: Color(0x404A1D5C), blurRadius: 14, offset: Offset(0, 6))],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: const BoxDecoration(color: Color(0x26FFFFFF), shape: BoxShape.circle),
                                child: const Icon(Icons.directions_walk_rounded, color: Colors.white),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Mulai Jalan Aman Sekarang', style: Aj.h(14.5, color: Colors.white)),
                                    Text('Kirim tautan live monitor ke 2 Guardian', style: Aj.b(12, color: const Color(0xCCFFFFFF))),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
              ],

              // Sensor siaga
              AjSectionTitle('Sensor Siaga Aktif', trailing: Text('Otomatis melindungi', style: Aj.b(12, color: Aj.muted))),
              Row(
                children: [
                  _SensorTile(
                    icon: Icons.vibration_rounded,
                    iconBg: Aj.blush,
                    iconFg: Aj.berry,
                    title: 'Guncang 3x',
                    sub: 'Deteksi Bahaya',
                    on: _guncang,
                    onTap: () {
                      setState(() => _guncang = !_guncang);
                      ajSnack(context, _guncang ? 'Deteksi guncangan aktif' : 'Deteksi guncangan dimatikan', icon: Icons.vibration_rounded);
                    },
                  ),
                  const SizedBox(width: 10),
                  _SensorTile(
                    icon: Icons.location_on_outlined,
                    iconBg: Aj.mint,
                    iconFg: Aj.mintDeep,
                    title: 'Auto Sampai',
                    sub: 'Geofence Kos',
                    on: _autoArrive,
                    onTap: () {
                      setState(() => _autoArrive = !_autoArrive);
                      ajSnack(context, _autoArrive ? 'Kabar tiba otomatis aktif' : 'Kabar tiba otomatis dimatikan', icon: Icons.location_on_outlined);
                    },
                  ),
                  const SizedBox(width: 10),
                  const _SensorTile(
                    icon: Icons.battery_charging_full_rounded,
                    iconBg: Aj.sand,
                    iconFg: Aj.muted,
                    title: 'Baterai Aman',
                    sub: '~4.5 Jam Pantau',
                    badge: '85%',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _ActionTile(
                      icon: Icons.phone_in_talk_outlined,
                      iconBg: Aj.blush,
                      iconFg: Aj.berry,
                      title: 'Pura-pura Telep',
                      sub: 'Suara Ayah / Teman',
                      onTap: () => _fakeCall(context),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ActionTile(
                      icon: Icons.volume_up_outlined,
                      iconBg: Aj.sand,
                      iconFg: Aj.muted,
                      title: 'Tes Sirene Siaga',
                      sub: 'Bunyi Keras Cepat',
                      onTap: () => ajSnack(context, 'Tes sirene: bunyi 2 detik (simulasi)', icon: Icons.volume_up_rounded),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // Guardian yang mengawasi
              ValueListenableBuilder<List<Guardian>>(
                valueListenable: GuardianStore.guardians,
                builder: (context, guardians, _) {
                  final onlineCount = guardians.where((g) => g.online).length;
                  return AjCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text('Guardian yang\nMengawasi', style: Aj.h(16, height: 1.25))),
                            AjPill('$onlineCount Online', bg: Aj.blushDeep, fg: Aj.berry, size: 11),
                          ],
                        ),
                        const SizedBox(height: 8),
                        for (final g in guardians) _GuardianRow(g),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _fakeCall(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => AjSheet(
        title: 'Pura-pura Telepon',
        child: Column(
          children: [
            for (final n in ['Ayah', 'Dinda (Teman Kos)', 'Kak Rian'])
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: AjAvatar(name: n, size: 42),
                title: Text(n, style: Aj.b(15, w: FontWeight.w800)),
                subtitle: Text('Berdering dalam 5 detik', style: Aj.b(12, color: Aj.muted)),
                trailing: const Icon(Icons.call_rounded, color: Aj.berry),
                onTap: () {
                  Navigator.pop(context);
                  ajSnack(context, 'Panggilan palsu dari $n akan berdering 5 detik lagi', icon: Icons.phone_in_talk_rounded);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _SensorTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconFg;
  final String title;
  final String sub;
  final bool? on;
  final String? badge;
  final VoidCallback? onTap;

  const _SensorTile({
    required this.icon,
    required this.iconBg,
    required this.iconFg,
    required this.title,
    required this.sub,
    this.on,
    this.badge,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AjCard(
        radius: 20,
        padding: const EdgeInsets.all(12),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AjIconBubble(icon, bg: iconBg, fg: iconFg, size: 36),
                if (badge != null)
                  Text(badge!, style: Aj.h(12.5))
                else
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(color: (on ?? true) ? const Color(0xFF1F6B45) : const Color(0xFFD5CDD0), shape: BoxShape.circle),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Text(title, style: Aj.b(13, w: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(sub, style: Aj.b(11, color: Aj.muted)),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconFg;
  final String title;
  final String sub;
  final VoidCallback onTap;
  const _ActionTile({required this.icon, required this.iconBg, required this.iconFg, required this.title, required this.sub, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AjCard(
      radius: 20,
      padding: const EdgeInsets.all(12),
      onTap: onTap,
      child: Row(
        children: [
          AjIconBubble(icon, bg: iconBg, fg: iconFg, size: 40),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Aj.b(13, w: FontWeight.w800), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(sub, style: Aj.b(11, color: Aj.muted), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GuardianRow extends StatelessWidget {
  final Guardian g;
  const _GuardianRow(this.g);

  void _openQuickMessageSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _QuickMessageSheet(guardian: g),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: Aj.sand, borderRadius: BorderRadius.circular(18)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _openQuickMessageSheet(context),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                AjAvatar(name: g.name, size: 44, online: g.online, color: g.color, imageUrl: g.imageUrl),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Flexible(child: Text(g.name, overflow: TextOverflow.ellipsis, style: Aj.b(14.5, w: FontWeight.w800))),
                        const SizedBox(width: 6),
                        AjPill(g.role, bg: Colors.white, fg: Aj.muted, size: 10),
                      ]),
                      Text(g.note, style: Aj.b(12, color: Aj.muted)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _openQuickMessageSheet(context),
                  tooltip: 'Kirim pesan update ke ' + g.name,
                  icon: const Icon(Icons.chat_outlined, color: Aj.berry, size: 21),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickMessageSheet extends StatefulWidget {
  final Guardian guardian;
  const _QuickMessageSheet({required this.guardian});

  @override
  State<_QuickMessageSheet> createState() => _QuickMessageSheetState();
}

class _QuickMessageSheetState extends State<_QuickMessageSheet> {
  late final TextEditingController _controller;
  int _selectedIndex = 0;

  static const List<({String title, String text, IconData icon, Color iconBg, Color iconFg})> _templates = [
    (
      title: 'Status Aman',
      text: 'Aku aman, sekarang sedang jalan menuju tujuan.',
      icon: Icons.directions_walk_rounded,
      iconBg: Color(0xFFE8F5E9),
      iconFg: Color(0xFF2E7D4F),
    ),
    (
      title: 'Pantau Saya',
      text: 'Jalanan di sini agak sepi, tolong pantau live rute aku ya.',
      icon: Icons.visibility_outlined,
      iconBg: Color(0xFFFFF3E0),
      iconFg: Color(0xFFE65100),
    ),
    (
      title: 'Kirim Titik Live',
      text: 'Ini koordinat live lokasiku sekarang di AmanJalan.',
      icon: Icons.share_location_rounded,
      iconBg: Color(0xFFFBE8F0),
      iconFg: Aj.berry,
    ),
    (
      title: 'Sudah Tiba',
      text: 'Alhamdulillah aku sudah sampai di tujuan dengan selamat!',
      icon: Icons.check_circle_outline_rounded,
      iconBg: Color(0xFFE0F2F1),
      iconFg: Color(0xFF00796B),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _templates[0].text);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendWhatsApp() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    Navigator.pop(context);
    ajSnack(
      context,
      'Pesan WhatsApp terkirim ke ' + widget.guardian.name,
      icon: Icons.chat_bubble_rounded,
    );
  }

  void _sendInApp() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    Navigator.pop(context);
    ajSnack(
      context,
      'Notifikasi cepat terkirim ke ponsel ' + widget.guardian.name,
      icon: Icons.notifications_active_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: Aj.bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFDCD3D6),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                AjAvatar(
                  name: widget.guardian.name,
                  size: 46,
                  online: widget.guardian.online,
                  color: widget.guardian.color,
                  imageUrl: widget.guardian.imageUrl,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              widget.guardian.name,
                              style: Aj.h(15.5),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          AjPill(widget.guardian.role, bg: Colors.white, fg: Aj.plum),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.guardian.phone ?? widget.guardian.note,
                        style: Aj.b(12, color: Aj.muted),
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: () {
                    Navigator.pop(context);
                    ajSnack(
                      context,
                      'Memanggil ' + widget.guardian.name + ' (' + (widget.guardian.phone ?? 'Kontak') + ')…',
                      icon: Icons.phone_rounded,
                    );
                  },
                  tooltip: 'Telepon Guardian',
                  style: IconButton.styleFrom(
                    backgroundColor: Aj.sand,
                    foregroundColor: Aj.berry,
                  ),
                  icon: const Icon(Icons.call_rounded, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, color: Aj.line),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.bolt_rounded, size: 18, color: Aj.berry),
                const SizedBox(width: 6),
                Text('Pilih Pesan Singkat', style: Aj.h(13.5)),
              ],
            ),
            const SizedBox(height: 10),
            for (int i = 0; i < _templates.length; i++) ...[
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  setState(() {
                    _selectedIndex = i;
                    _controller.text = _templates[i].text;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: _selectedIndex == i ? const Color(0xFFFDEEF2) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _selectedIndex == i ? Aj.berry : const Color(0xFFEBE5E3),
                      width: _selectedIndex == i ? 1.6 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _templates[i].iconBg,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(_templates[i].icon, size: 19, color: _templates[i].iconFg),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _templates[i].title,
                              style: Aj.b(
                                13,
                                w: FontWeight.w800,
                                color: _selectedIndex == i ? Aj.berry : Aj.ink,
                              ),
                            ),
                            Text(
                              _templates[i].text,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Aj.b(11.5, color: Aj.muted),
                            ),
                          ],
                        ),
                      ),
                      if (_selectedIndex == i)
                        const Icon(Icons.check_circle_rounded, color: Aj.berry, size: 18),
                    ],
                  ),
                ),
              ),
              if (i < _templates.length - 1) const SizedBox(height: 8),
            ],
            const SizedBox(height: 14),
            Text('Kustomisasi Pesan:', style: Aj.b(12, color: Aj.muted, w: FontWeight.w700)),
            const SizedBox(height: 6),
            TextField(
              controller: _controller,
              maxLines: 2,
              style: Aj.b(13),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE5DDD9)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE5DDD9)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Aj.berry, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _sendInApp,
                    icon: const Icon(Icons.notifications_active_outlined, size: 17),
                    label: const Text('In-App'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Aj.plum,
                      side: const BorderSide(color: Aj.plum, width: 1.2),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      textStyle: Aj.b(13, w: FontWeight.w800),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: _sendWhatsApp,
                    icon: const Icon(Icons.chat_bubble_rounded, size: 17),
                    label: const Text('Kirim WhatsApp'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      textStyle: Aj.b(13, w: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SHEET / RADAR / QR
// ─────────────────────────────────────────────────────────────

class _RadarSheet extends StatefulWidget {
  const _RadarSheet();

  @override
  State<_RadarSheet> createState() => _RadarSheetState();
}

class _RadarSheetState extends State<_RadarSheet> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 240,
          width: double.infinity,
          child: AnimatedBuilder(
            animation: _c,
            builder: (_, __) => CustomPaint(painter: _RadarPainter(_c.value)),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.near_me_outlined, color: Aj.berry, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text('Salsa berada 340 m dari Anda, bergerak ke arah Kos Melati', style: Aj.b(13, w: FontWeight.w700, height: 1.3))),
          ],
        ),
      ],
    );
  }
}

class _RadarPainter extends CustomPainter {
  final double t;
  _RadarPainter(this.t);

  @override
  void paint(Canvas canvas, Size s) {
    final c = Offset(s.width / 2, s.height / 2);
    final maxR = s.height / 2;
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0xFFE6D9DE);
    for (final r in [.33, .66, 1.0]) {
      canvas.drawCircle(c, maxR * r, ring);
    }
    for (var i = 0; i < 3; i++) {
      final p = (t + i / 3) % 1;
      canvas.drawCircle(
        c,
        maxR * p,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = Color.fromRGBO(138, 63, 92, (1 - p) * .45),
      );
    }
    canvas.drawCircle(c, 9, Paint()..color = Aj.plum);
    canvas.drawCircle(c, 3.5, Paint()..color = Colors.white);
    final f = Offset(c.dx + maxR * .55, c.dy - maxR * .42);
    canvas.drawCircle(f, 16, Paint()..color = const Color(0x40B6788F));
    canvas.drawCircle(f, 9, Paint()..color = Aj.berry);
    canvas.drawCircle(f, 3.5, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _RadarPainter old) => old.t != t;
}