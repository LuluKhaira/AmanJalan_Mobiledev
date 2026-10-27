import 'package:flutter/material.dart';
import 'package:amanjalan/core/theme/aj_theme.dart';
import 'package:amanjalan/core/widgets/aj_common.dart';
import 'package:amanjalan/features/home/aj_data.dart';

/// Satu baris riwayat — dipakai di Profil (ringkas) & layar riwayat lengkap.
class TripHistoryTile extends StatelessWidget {
  final TripRecord trip;
  const TripHistoryTile(this.trip, {super.key});

  static (Color, Color, IconData, String) style(TripStatus s) {
    switch (s) {
      case TripStatus.selesai:
        return (Aj.mint, Aj.mintDeep, Icons.check_rounded, 'Tiba Aman');
      case TripStatus.sos:
        return (Aj.sosSoft, Aj.sos, Icons.sos_rounded, 'SOS Dikirim');
      case TripStatus.batal:
        return (Aj.sand, Aj.muted, Icons.close_rounded, 'Dibatalkan');
    }
  }

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icon, label) = style(trip.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: AjCard(
        radius: 20,
        shadow: false,
        color: Aj.sand,
        padding: const EdgeInsets.all(12),
        onTap: () => showTripDetail(context, trip),
        child: Row(
          children: [
            AjIconBubble(icon, bg: bg, fg: fg, size: 42),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${trip.from} → ${trip.to}', maxLines: 1, overflow: TextOverflow.ellipsis, style: Aj.b(14, w: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text('${fmtDay(trip.start)}, ${fmtTime(trip.start)} • ${trip.minutes} mnt • ${fmtDistance(trip.meters)}', style: Aj.b(11.5, color: Aj.muted)),
                ],
              ),
            ),
            const SizedBox(width: 6),
            AjPill(label, bg: bg, fg: fg, size: 10),
          ],
        ),
      ),
    );
  }
}

void showTripDetail(BuildContext context, TripRecord t) {
  final (bg, fg, _, label) = TripHistoryTile.style(t.status);
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Container(
      padding: EdgeInsets.fromLTRB(22, 12, 22, 24 + MediaQuery.of(ctx).padding.bottom),
      decoration: const BoxDecoration(color: Aj.bg, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFDCD3D6), borderRadius: BorderRadius.circular(4)))),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: Text('Detail Perjalanan', style: Aj.h(18))),
              AjPill(label, bg: bg, fg: fg),
            ],
          ),
          const SizedBox(height: 4),
          Text('${t.id} • ${fmtDay(t.start)}, ${fmtTime(t.start)} WIB', style: Aj.b(12.5, color: Aj.muted)),
          const SizedBox(height: 14),
          RouteMap(height: 150, progress: t.status == TripStatus.batal ? .12 : 1.0),
          const SizedBox(height: 14),
          Text('${t.from} → ${t.to}', style: Aj.h(15)),
          const SizedBox(height: 12),
          Row(
            children: [
              _D(Icons.timer_outlined, '${t.minutes} mnt', 'Durasi'),
              const SizedBox(width: 8),
              _D(Icons.straighten_rounded, fmtDistance(t.meters), 'Jarak'),
              const SizedBox(width: 8),
              _D(Icons.speed_rounded, '${t.avgKmh} km/j', 'Rata-rata'),
              const SizedBox(width: 8),
              _D(Icons.local_police_outlined, '${t.havens}', 'Titik aman'),
            ],
          ),
          const SizedBox(height: 14),
          Text('Dipantau oleh', style: Aj.b(12.5, color: Aj.muted, w: FontWeight.w800)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final g in t.guardians)
                Container(
                  padding: const EdgeInsets.fromLTRB(4, 4, 12, 4),
                  decoration: BoxDecoration(color: Aj.sand, borderRadius: BorderRadius.circular(20)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    AjAvatar(name: g, size: 26),
                    const SizedBox(width: 6),
                    Text(g, style: Aj.b(12.5, w: FontWeight.w800)),
                  ]),
                ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                ajSnack(context, 'Laporan perjalanan dibagikan (simulasi)', icon: Icons.ios_share_rounded);
              },
              icon: const Icon(Icons.ios_share_rounded, size: 18),
              label: Text('Bagikan Laporan', style: Aj.b(14, color: Aj.berry, w: FontWeight.w800)),
              style: OutlinedButton.styleFrom(
                foregroundColor: Aj.berry,
                minimumSize: const Size.fromHeight(48),
                side: const BorderSide(color: Aj.blushDeep, width: 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _D extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _D(this.icon, this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: Aj.sand, borderRadius: BorderRadius.circular(14)),
        child: Column(
          children: [
            Icon(icon, size: 16, color: Aj.berry),
            const SizedBox(height: 4),
            Text(value, style: Aj.h(12.5)),
            Text(label, style: Aj.b(10, color: Aj.muted)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// LAYAR RIWAYAT LENGKAP (dibuka dari Profil)
// ─────────────────────────────────────────────────────────────

class TripHistoryScreen extends StatefulWidget {
  const TripHistoryScreen({super.key});

  @override
  State<TripHistoryScreen> createState() => _TripHistoryScreenState();
}

class _TripHistoryScreenState extends State<TripHistoryScreen> {
  int _filter = 0; // 0 semua, 1 aman, 2 sos, 3 batal
  static const _labels = ['Semua', 'Tiba Aman', 'SOS', 'Dibatalkan'];

  bool _match(TripRecord t) => switch (_filter) {
        1 => t.status == TripStatus.selesai,
        2 => t.status == TripStatus.sos,
        3 => t.status == TripStatus.batal,
        _ => true,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Aj.bg,
      appBar: AppBar(
        backgroundColor: Aj.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Aj.plum),
        title: Text('Riwayat Perjalanan', style: Aj.h(18)),
      ),
      body: ValueListenableBuilder<List<TripRecord>>(
        valueListenable: TripStore.trips,
        builder: (context, all, _) {
          final list = all.where(_match).toList();
          final done = all.where((t) => t.status == TripStatus.selesai).length;
          final km = all.fold<int>(0, (a, t) => a + t.meters) / 1000;
          final mins = all.fold<int>(0, (a, t) => a + t.minutes);

          // kelompokkan per hari
          final groups = <String, List<TripRecord>>{};
          for (final t in list) {
            groups.putIfAbsent(fmtDay(t.start), () => []).add(t);
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
            children: [
              AjCard(
                color: Aj.plum,
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    _Sum('${all.length}', 'Total perjalanan'),
                    _Sum('${km.toStringAsFixed(1)} km', 'Jarak total'),
                    _Sum('${mins ~/ 60}j ${mins % 60}m', 'Waktu jalan'),
                    _Sum('${all.isEmpty ? 0 : done * 100 ~/ all.length}%', 'Tiba aman'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _labels.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final sel = i == _filter;
                    return GestureDetector(
                      onTap: () => setState(() => _filter = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: sel ? Aj.plum : Colors.white, borderRadius: BorderRadius.circular(19), border: Border.all(color: sel ? Aj.plum : Aj.line)),
                        child: Text(_labels[i], style: Aj.b(13, color: sel ? Colors.white : Aj.muted, w: FontWeight.w800)),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),
              if (list.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 60),
                  child: Column(
                    children: [
                      const AjIconBubble(Icons.route_outlined, bg: Aj.sand, fg: Aj.muted, size: 60),
                      const SizedBox(height: 12),
                      Text('Belum ada perjalanan di kategori ini', style: Aj.b(13.5, color: Aj.muted)),
                    ],
                  ),
                ),
              for (final e in groups.entries) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 8, top: 4),
                  child: Text(e.key, style: Aj.b(12.5, color: Aj.muted, w: FontWeight.w800)),
                ),
                for (final t in e.value) TripHistoryTile(t),
              ],
              const SizedBox(height: 8),
              Center(
                child: Text('Riwayat GPS otomatis terhapus setelah 30 hari', style: Aj.b(11.5, color: Aj.muted)),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Sum extends StatelessWidget {
  final String value;
  final String label;
  const _Sum(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          FittedBox(fit: BoxFit.scaleDown, child: Text(value, style: Aj.h(16, color: Colors.white))),
          const SizedBox(height: 2),
          Text(label, textAlign: TextAlign.center, style: Aj.b(10, color: const Color(0xB3FFFFFF))),
        ],
      ),
    );
  }
}