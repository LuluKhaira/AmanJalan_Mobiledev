import 'dart:async';

import 'package:flutter/material.dart';
import 'package:amanjalan/core/theme/aj_theme.dart';
import 'package:amanjalan/core/widgets/aj_common.dart';
import 'package:amanjalan/features/perjalanan/screens/pantau_maps_screen.dart';
import 'package:amanjalan/features/perjalanan/widgets/pantau/friend_data.dart';

/// Kartu teman yang sedang berjalan.
/// Urutan: siapa + tiba → pakai apa & rute apa → di mana → angka penting → aksi.
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

  void _openMaps() {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const PantauMapsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    const m = FriendTrip.mode;
    return AjCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1) Siapa + perkiraan tiba
          Row(
            children: [
              const AjAvatar(
                name: FriendTrip.name,
                size: 50,
                online: true,
                color: Color(0xFFF0F4E6),
                imageUrl: FriendTrip.photo,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(FriendTrip.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: Aj.h(16)),
                    const SizedBox(height: 2),
                    Text('${FriendTrip.relation} • menuju ${FriendTrip.to}', maxLines: 1, overflow: TextOverflow.ellipsis, style: Aj.b(12, color: Aj.muted)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${FriendTrip.etaMin} mnt', style: Aj.h(21, color: Aj.plum)),
                  Text('perkiraan tiba', style: Aj.b(10.5, color: Aj.muted)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 2) Pakai apa + rute apa
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Chip(m.icon, m.verb, bg: Aj.blush, fg: Aj.berry),
              _Chip(Icons.shield_outlined, 'Rute ${FriendTrip.routeName} • Skor ${FriendTrip.score}', bg: Aj.mint, fg: Aj.mintDeep),
            ],
          ),
          const SizedBox(height: 12),

          // 3) Peta mini (ketuk = buka peta penuh)
          GestureDetector(
            onTap: _openMaps,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                children: [
                  RouteMap(height: 132, progress: _p),
                  Positioned(
                    left: 10,
                    top: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(color: const Color(0xE6FFFFFF), borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 7, height: 7, decoration: const BoxDecoration(color: Aj.sos, shape: BoxShape.circle)),
                          const SizedBox(width: 5),
                          Text('LIVE', style: Aj.b(10.5, w: FontWeight.w800)),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 10,
                    right: 10,
                    bottom: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                      decoration: BoxDecoration(color: const Color(0xE6FFFFFF), borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          const Icon(Icons.navigation_outlined, size: 14, color: Aj.plum),
                          const SizedBox(width: 6),
                          Flexible(child: Text('${FriendTrip.from} → ${FriendTrip.to}', overflow: TextOverflow.ellipsis, style: Aj.b(11.5, w: FontWeight.w700))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 4) Angka penting: satu panel, tiga kolom
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(color: Aj.sand, borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                const _Stat(FriendTrip.distanceLeft, 'Sisa jarak'),
                const _Divider(),
                _Stat(m.speed, 'Kecepatan'),
                const _Divider(),
                const _Stat(FriendTrip.battery, 'Baterai'),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // 5) Posisi sekarang + peringatan rute
          Row(
            children: [
              const Icon(Icons.place_outlined, size: 16, color: Aj.berry),
              const SizedBox(width: 6),
              Expanded(child: Text('Sekarang di ${FriendTrip.street} • GPS ${FriendTrip.gps}', maxLines: 1, overflow: TextOverflow.ellipsis, style: Aj.b(12, color: Aj.muted, w: FontWeight.w700))),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, size: 16, color: Color(0xFFE65100)),
              const SizedBox(width: 6),
              Expanded(child: Text('${FriendTrip.warnings} titik perlu waspada di rute ini', maxLines: 1, overflow: TextOverflow.ellipsis, style: Aj.b(12, color: const Color(0xFFE65100), w: FontWeight.w700))),
            ],
          ),
          const SizedBox(height: 14),

          // 6) Aksi
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _openMaps,
                  style: FilledButton.styleFrom(
                    backgroundColor: Aj.plum,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.map_rounded, size: 20),
                  label: Text('Buka Maps', style: Aj.b(14, color: Colors.white, w: FontWeight.w800)),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => ajSnack(context, 'Memanggil ${FriendTrip.firstName}…', icon: Icons.call_rounded),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(color: Aj.sand, borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.call_outlined, color: Aj.plum, size: 21),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color bg;
  final Color fg;
  const _Chip(this.icon, this.text, {required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 6),
          Text(text, style: Aj.b(12, color: fg, w: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          FittedBox(fit: BoxFit.scaleDown, child: Text(value, style: Aj.h(14.5))),
          const SizedBox(height: 2),
          Text(label, style: Aj.b(10.5, color: Aj.muted)),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) => Container(width: 1, height: 28, color: const Color(0x1F000000));
}