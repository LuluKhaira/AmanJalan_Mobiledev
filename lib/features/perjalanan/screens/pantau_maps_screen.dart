import 'dart:async';

import 'package:flutter/material.dart';
import 'package:amanjalan/core/theme/aj_theme.dart';
import 'package:amanjalan/core/widgets/aj_common.dart';
import 'package:amanjalan/features/perjalanan/widgets/pantau/friend_data.dart';
import 'package:amanjalan/features/perjalanan/widgets/pj_widgets.dart';

/// Peta penuh untuk memantau teman.
/// Peta selalu terlihat jelas di belakang; detail ada di jendela bawah yang
/// bisa ditarik naik/turun (kecil → sedang → penuh).
class PantauMapsScreen extends StatefulWidget {
  const PantauMapsScreen({super.key});

  @override
  State<PantauMapsScreen> createState() => _PantauMapsScreenState();
}

class _PantauMapsScreenState extends State<PantauMapsScreen> {
  static const double _minSize = .2;
  static const double _midSize = .42;
  static const double _maxSize = .82;

  final DraggableScrollableController _sheet = DraggableScrollableController();
  double _p = .5;
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
    _sheet.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Aj.bg,
      body: LayoutBuilder(
        builder: (context, box) {
          final h = box.maxHeight;
          return Stack(
            children: [
              // 1) Peta penuh
              Positioned.fill(child: RouteMap(height: h, progress: _p)),

              // 2) Kartu atas (kecil, tinggi mengikuti isi)
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _RoundBtn(Icons.arrow_back_rounded, () => Navigator.of(context).maybePop()),
                      const SizedBox(width: 10),
                      const Expanded(child: _RouteCard()),
                    ],
                  ),
                ),
              ),

              // 3) Tombol peta: selalu menempel di atas jendela bawah
              AnimatedBuilder(
                animation: _sheet,
                builder: (context, _) {
                  final frac = (_sheet.isAttached ? _sheet.size : _midSize).clamp(_minSize, _midSize + .08);
                  return Positioned(
                    right: 16,
                    bottom: h * frac + 14,
                    child: Column(
                      children: [
                        _RoundBtn(Icons.person_pin_circle_rounded, () => ajSnack(context, 'Peta dipusatkan ke ${FriendTrip.firstName}', icon: Icons.person_pin_circle_rounded)),
                        const SizedBox(height: 10),
                        _RoundBtn(Icons.my_location_rounded, () => ajSnack(context, 'Peta dipusatkan ke posisimu', icon: Icons.my_location_rounded)),
                      ],
                    ),
                  );
                },
              ),

              // 4) Jendela bawah yang bisa ditarik
              DraggableScrollableSheet(
                controller: _sheet,
                initialChildSize: _midSize,
                minChildSize: _minSize,
                maxChildSize: _maxSize,
                snap: true,
                snapSizes: const [_minSize, _midSize, _maxSize],
                builder: (context, scroll) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                      boxShadow: [BoxShadow(color: Color(0x26000000), blurRadius: 18, offset: Offset(0, -4))],
                    ),
                    child: ListView(
                      controller: scroll,
                      padding: EdgeInsets.fromLTRB(20, 10, 20, 20 + MediaQuery.of(context).padding.bottom),
                      children: const [
                        _Handle(),
                        SizedBox(height: 12),
                        _Header(),
                        SizedBox(height: 14),
                        _RouteChip(),
                        SizedBox(height: 12),
                        _Actions(),
                        SizedBox(height: 16),
                        _StatsPanel(),
                        SizedBox(height: 12),
                        _WarningRow(),
                        SizedBox(height: 14),
                        _DetailList(),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Elemen peta
// ─────────────────────────────────────────────────────────────

class _RoundBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundBtn(this.icon, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 3,
      shadowColor: const Color(0x33000000),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(width: 46, height: 46, child: Icon(icon, color: Aj.plum, size: 22)),
      ),
    );
  }
}

/// Kartu atas: dari mana → ke mana.
class _RouteCard extends StatelessWidget {
  const _RouteCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Color(0x26000000), blurRadius: 14, offset: Offset(0, 4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // ← kunci: jangan melar sampai tinggi layar
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.my_location_rounded, size: 16, color: Aj.plum),
              const SizedBox(width: 10),
              Expanded(child: Text('${FriendTrip.firstName} sekarang • ${FriendTrip.street}', maxLines: 1, overflow: TextOverflow.ellipsis, style: Aj.b(13, color: Aj.muted))),
            ],
          ),
          const Divider(height: 14, color: Aj.line),
          Row(
            children: [
              const Icon(Icons.place_rounded, size: 16, color: Aj.berry),
              const SizedBox(width: 10),
              Expanded(child: Text(FriendTrip.to, maxLines: 1, overflow: TextOverflow.ellipsis, style: Aj.b(14, w: FontWeight.w800))),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Isi jendela bawah (urut dari yang paling penting)
// ─────────────────────────────────────────────────────────────

class _Handle extends StatelessWidget {
  const _Handle();

  @override
  Widget build(BuildContext context) {
    return Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0x22000000), borderRadius: BorderRadius.circular(4))));
  }
}

/// Selalu terlihat, bahkan saat jendela diturunkan.
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    const m = FriendTrip.mode;
    return Row(
      children: [
        const AjAvatar(name: FriendTrip.name, size: 46, online: true, color: Color(0xFFF0F4E6), imageUrl: FriendTrip.photo),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(FriendTrip.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: Aj.h(15.5)),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(m.icon, size: 15, color: Aj.berry),
                  const SizedBox(width: 5),
                  Text(m.verb, style: Aj.b(12.5, color: Aj.berry, w: FontWeight.w800)),
                ],
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('${FriendTrip.etaMin} mnt', style: Aj.h(20, color: Aj.plum)),
            Text(FriendTrip.distanceLeft, style: Aj.b(11.5, color: Aj.muted)),
          ],
        ),
      ],
    );
  }
}

class _RouteChip extends StatelessWidget {
  const _RouteChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Aj.mint, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          const Icon(Icons.shield_outlined, size: 18, color: Aj.mintDeep),
          const SizedBox(width: 8),
          Expanded(child: Text('Rute ${FriendTrip.routeName}', style: Aj.b(13.5, color: Aj.mintDeep, w: FontWeight.w800))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Text('${FriendTrip.score}', style: Aj.h(13, color: Aj.mintDeep)),
          ),
        ],
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: () => ajSnack(context, 'Memanggil ${FriendTrip.firstName}…', icon: Icons.call_rounded),
            style: FilledButton.styleFrom(
              backgroundColor: Aj.plum,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.call_rounded, size: 20),
            label: Text('Telepon', style: Aj.b(14, color: Colors.white, w: FontWeight.w800)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: FilledButton.icon(
            onPressed: () => ajSnack(context, 'Bunyi peringatan dikirim ke ponsel ${FriendTrip.firstName}', icon: Icons.campaign_rounded),
            style: FilledButton.styleFrom(
              backgroundColor: Aj.blush,
              foregroundColor: Aj.berry,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.campaign_outlined, size: 20),
            label: Text('Bunyikan', style: Aj.b(14, color: Aj.berry, w: FontWeight.w800)),
          ),
        ),
      ],
    );
  }
}

class _StatsPanel extends StatelessWidget {
  const _StatsPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: Aj.sand, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          _Stat('Kecepatan', FriendTrip.mode.speed),
          const _Stat('Jarak dari kamu', FriendTrip.distanceFromYou),
          const _Stat('Baterai', FriendTrip.battery),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat(this.label, this.value);

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

class _WarningRow extends StatelessWidget {
  const _WarningRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.warning_amber_rounded, size: 16, color: Color(0xFFE65100)),
        const SizedBox(width: 6),
        Expanded(child: Text('${FriendTrip.warnings} titik perlu waspada di rute ini', style: Aj.b(12, color: const Color(0xFFE65100), w: FontWeight.w700))),
      ],
    );
  }
}

/// Detail lengkap: terlihat setelah jendela ditarik ke atas.
class _DetailList extends StatelessWidget {
  const _DetailList();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Detail Perjalanan', style: Aj.h(14.5)),
        const SizedBox(height: 4),
        PjInfoRow(FriendTrip.mode.icon, 'Transportasi', FriendTrip.mode.label),
        const PjInfoRow(Icons.my_location_rounded, 'Dari', FriendTrip.from),
        const PjInfoRow(Icons.flag_outlined, 'Tujuan', FriendTrip.to),
        const PjInfoRow(Icons.place_outlined, 'Posisi sekarang', FriendTrip.street),
        const PjInfoRow(Icons.route_outlined, 'Sisa jarak', FriendTrip.distanceLeft),
        const PjInfoRow(Icons.schedule_rounded, 'Perkiraan tiba', '${FriendTrip.etaMin} menit lagi'),
        const PjInfoRow(Icons.gps_fixed_rounded, 'Akurasi GPS', FriendTrip.gps, last: true),
      ],
    );
  }
}