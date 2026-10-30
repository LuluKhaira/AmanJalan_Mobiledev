import 'dart:async';

import 'package:flutter/material.dart';
import 'package:amanjalan/core/theme/aj_theme.dart';
import 'package:amanjalan/core/widgets/aj_common.dart';
import 'package:amanjalan/features/perjalanan/widgets/pantau/radar_sheet.dart';

/// Kartu teman yang sedang berjalan (peta mini bergerak + radar live).
class FriendTrackCard extends StatefulWidget {
  const FriendTrackCard({super.key});

  @override
  State<FriendTrackCard> createState() => _FriendTrackCardState();
}

class _FriendTrackCardState extends State<FriendTrackCard> {
  double _p = .38;
  Timer? _t;

  @override
  void initState() {
    super.initState();
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
                  onPressed: () => showRadarSheet(context),
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
