import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:amanjalan/core/theme/aj_theme.dart';
import 'package:amanjalan/core/widgets/aj_common.dart';
import 'package:amanjalan/features/home/aj_data.dart';
import 'package:amanjalan/features/perjalanan/data/perjalanan_data.dart';
import 'package:amanjalan/features/perjalanan/perjalanan_actions.dart';
import 'package:amanjalan/features/perjalanan/screens/akhiri_perjalanan_screen.dart';
import 'package:amanjalan/features/perjalanan/screens/detail_perjalanan_screen.dart';
import 'package:amanjalan/features/perjalanan/screens/laporan_kejadian_screen.dart';
import 'package:amanjalan/features/perjalanan/widgets/pj_widgets.dart';

/// Tracking real-time: peta di atas, panel info + aksi cepat di bawah.
class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
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
    return ValueListenableBuilder<ActiveTrip?>(
      valueListenable: TripStore.active,
      builder: (context, a, _) {
        if (a == null) return const _NoTrip();
        final size = MediaQuery.of(context).size;
        final top = MediaQuery.of(context).padding.top;
        final p = pjProgress(a);
        final mapH = size.height * 0.52;
        final arrived = p >= 1;

        return Scaffold(
          backgroundColor: Aj.bg,
          body: Stack(
            children: [
              // PETA
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: mapH,
                child: RouteMap(height: mapH, progress: p),
              ),

              // TOP BAR
              Positioned(
                top: top + 8,
                left: 16,
                right: 16,
                child: Row(
                  children: [
                    _RoundBtn(Icons.arrow_back_rounded, () {
                      ajSnack(context, 'Perjalanan tetap berjalan. Buka lagi dari tab Perjalanan.', icon: Icons.info_outline_rounded);
                      Navigator.of(context).pop();
                    }),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: .95), borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          children: [
                            const Icon(Icons.navigation_rounded, size: 16, color: Aj.plum),
                            const SizedBox(width: 8),
                            Expanded(child: Text(a.to, maxLines: 1, overflow: TextOverflow.ellipsis, style: Aj.b(13.5, w: FontWeight.w800))),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => pjOpenEmergency(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                        decoration: BoxDecoration(
                          color: Aj.sos,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [BoxShadow(color: Color(0x55D32F2F), blurRadius: 10, offset: Offset(0, 4))],
                        ),
                        child: Text('SOS', style: Aj.h(13, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),

              // Chip jarak di peta
              Positioned(
                top: top + 66,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: .95), borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.place_outlined, size: 16, color: Aj.berry),
                      const SizedBox(width: 6),
                      Text('${fmtDistance(pjRemainMeters(a))} menuju tujuan', style: Aj.b(12, w: FontWeight.w800)),
                    ],
                  ),
                ),
              ),

              // PANEL BAWAH
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  constraints: BoxConstraints(maxHeight: size.height * 0.60),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                    boxShadow: [BoxShadow(color: Color(0x1F000000), blurRadius: 24, offset: Offset(0, -6))],
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(20, 12, 20, 16 + MediaQuery.of(context).padding.bottom),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFDCD3D6), borderRadius: BorderRadius.circular(4)))),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            const AjPill('Sedang Berlangsung', bg: Aj.mint, fg: Aj.mintDeep, dot: true),
                            const Spacer(),
                            Text('Mulai ${fmtTime(a.startedAt)} WIB', style: Aj.b(12, color: Aj.muted)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(arrived ? 'Tiba!' : '${pjRemainMinutes(a)}', style: Aj.h(40, color: Aj.plum, height: 1)),
                            const SizedBox(width: 6),
                            if (!arrived) Padding(padding: const EdgeInsets.only(bottom: 5), child: Text('menit lagi', style: Aj.h(15, color: Aj.plum))),
                            const Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(fmtDistance(pjRemainMeters(a)), style: Aj.h(18)),
                                Text('JARAK SISA', style: Aj.b(10.5, color: Aj.muted, w: FontWeight.w800)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: p,
                            minHeight: 9,
                            backgroundColor: const Color(0xFFF0EDF2),
                            valueColor: const AlwaysStoppedAnimation<Color>(Aj.plum),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(child: Text(a.from, maxLines: 1, overflow: TextOverflow.ellipsis, style: Aj.b(12, color: Aj.muted))),
                            const SizedBox(width: 8),
                            Flexible(child: Text(a.to, maxLines: 1, overflow: TextOverflow.ellipsis, style: Aj.b(12, w: FontWeight.w800))),
                          ],
                        ),
                        if (arrived) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Aj.mint, borderRadius: BorderRadius.circular(14)),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle_rounded, color: Aj.mintDeep, size: 20),
                                const SizedBox(width: 8),
                                Expanded(child: Text('Kamu sudah di tujuan. Konfirmasi dengan menekan "Akhiri Perjalanan".', style: Aj.b(12.5, color: Aj.mintDeep, w: FontWeight.w700, height: 1.3))),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        const TripGuardianStrip(),
                        const SizedBox(height: 4),
                        // AKSI CEPAT — Panggilan Palsu & SOS memakai layar yang sudah ada
                        Row(
                          children: [
                            PjQuickAction(icon: Icons.phone_in_talk_rounded, label: 'Panggilan\nPalsu', onTap: () => pjOpenFakeCall(context)),
                            const SizedBox(width: 8),
                            PjQuickAction(icon: Icons.warning_rounded, label: 'SOS\nDarurat', bg: Aj.sosSoft, fg: Aj.sos, onTap: () => pjOpenEmergency(context)),
                            const SizedBox(width: 8),
                            PjQuickAction(icon: Icons.report_gmailerrorred_rounded, label: 'Lapor\nKejadian', bg: Aj.sand, fg: Aj.plum, onTap: () => Navigator.of(context).push(pjRoute(const LaporanKejadianScreen()))),
                            const SizedBox(width: 8),
                            PjQuickAction(icon: Icons.share_location_rounded, label: 'Bagikan\nLokasi', bg: Aj.mint, fg: Aj.mintDeep, onTap: () => pjShareLocation(context)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: PjButton(
                                'Lihat Detail',
                                icon: Icons.list_alt_rounded,
                                style: PjButtonStyle.outline,
                                onTap: () => Navigator.of(context).push(pjRoute(const DetailPerjalananScreen())),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: PjButton(
                                'Akhiri Perjalanan',
                                icon: Icons.flag_rounded,
                                onTap: () => Navigator.of(context).push(pjRoute(const AkhiriPerjalananScreen())),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RoundBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundBtn(this.icon, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
        child: Icon(icon, color: Aj.ink),
      ),
    );
  }
}

class _NoTrip extends StatelessWidget {
  const _NoTrip();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Aj.bg,
      appBar: pjAppBar(context, 'Perjalanan Aktif'),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const PjMascot(size: 110),
              const SizedBox(height: 14),
              Text('Tidak ada perjalanan aktif', style: Aj.h(17)),
              const SizedBox(height: 18),
              PjButton('Kembali', onTap: () => Navigator.of(context).pop()),
            ],
          ),
        ),
      ),
    );
  }
}
