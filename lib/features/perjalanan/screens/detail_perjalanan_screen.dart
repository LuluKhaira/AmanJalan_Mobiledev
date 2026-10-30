import 'dart:async';

import 'package:flutter/material.dart';
import 'package:amanjalan/core/theme/aj_theme.dart';
import 'package:amanjalan/core/widgets/aj_common.dart';
import 'package:amanjalan/features/home/aj_data.dart';
import 'package:amanjalan/features/perjalanan/data/perjalanan_data.dart';
import 'package:amanjalan/features/perjalanan/perjalanan_actions.dart';
import 'package:amanjalan/features/perjalanan/widgets/pj_widgets.dart';

/// Detail perjalanan yang sedang berjalan.
class DetailPerjalananScreen extends StatefulWidget {
  const DetailPerjalananScreen({super.key});

  @override
  State<DetailPerjalananScreen> createState() => _DetailPerjalananScreenState();
}

class _DetailPerjalananScreenState extends State<DetailPerjalananScreen> {
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = TripStore.active.value;
    return Scaffold(
      backgroundColor: Aj.bg,
      appBar: pjAppBar(context, 'Detail Perjalanan'),
      body: a == null
          ? Center(child: Text('Tidak ada perjalanan aktif', style: Aj.b(14, color: Aj.muted)))
          : _content(a),
    );
  }

  Widget _content(ActiveTrip a) {
    final p = pjProgress(a);
    final mode = PerjalananSession.mode.value;
    final elapsed = DateTime.now().difference(a.startedAt);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
      children: [
        // status
        AjCard(
          color: Aj.mint,
          shadow: false,
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const PjMascot(size: 54),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Perjalanan Aktif', style: Aj.h(15, color: Aj.mintDeep)),
                    Text('Mulai ${fmtTime(a.startedAt)} WIB • berjalan ${elapsed.inMinutes} mnt', style: Aj.b(12, color: Aj.mintDeep)),
                  ],
                ),
              ),
              const AjPill('Berjalan', bg: Colors.white, fg: Aj.mintDeep, dot: true),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // live map
        AjCard(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text('Lokasi Real-time', style: Aj.h(15))),
                  AjPill('${(p * 100).round()}% rute', bg: Aj.blush, fg: Aj.berry),
                ],
              ),
              const SizedBox(height: 10),
              RouteMap(height: 160, progress: p),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.place_outlined, size: 16, color: Aj.berry),
                  const SizedBox(width: 6),
                  Expanded(child: Text('${a.from} → ${a.to}', style: Aj.b(13, w: FontWeight.w800))),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // statistik
        Row(
          children: [
            PjStatBox(Icons.timer_outlined, '${pjRemainMinutes(a)} mnt', 'Sisa waktu'),
            const SizedBox(width: 8),
            PjStatBox(Icons.straighten_rounded, fmtDistance(pjRemainMeters(a)), 'Jarak sisa'),
            const SizedBox(width: 8),
            PjStatBox(Icons.local_police_outlined, '${a.havens}', 'Titik aman'),
          ],
        ),
        const SizedBox(height: 16),

        // info
        AjCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            children: [
              PjInfoRow(Icons.flag_outlined, 'Tujuan', a.to),
              PjInfoRow(Icons.schedule_rounded, 'Estimasi waktu', '${a.etaMin} menit'),
              PjInfoRow(mode.icon, 'Mode perjalanan', mode.label),
              PjInfoRow(Icons.event_rounded, 'Waktu mulai', '${fmtDay(a.startedAt)}, ${fmtTime(a.startedAt)} WIB', last: true),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // guardian
        AjCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Kontak Darurat', style: Aj.h(15)),
              const SizedBox(height: 8),
              ValueListenableBuilder<List<Guardian>>(
                valueListenable: GuardianStore.guardians,
                builder: (context, list, _) => Column(
                  children: [
                    for (final g in list.take(3))
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: AjAvatar(name: g.name, size: 42, online: g.online, color: g.color, imageUrl: g.imageUrl),
                        title: Text(g.name, style: Aj.b(14, w: FontWeight.w800)),
                        subtitle: Text(g.phone ?? g.note, style: Aj.b(12, color: Aj.muted)),
                        trailing: IconButton(
                          icon: const Icon(Icons.call_rounded, color: Aj.berry),
                          onPressed: () => ajSnack(context, 'Memanggil ${g.name}…', icon: Icons.call_rounded),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        PjButton('Bagikan Lokasi', icon: Icons.share_location_rounded, style: PjButtonStyle.soft, onTap: () => pjShareLocation(context)),
      ],
    );
  }
}
