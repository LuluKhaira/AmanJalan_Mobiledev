import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:amanjalan/core/theme/aj_theme.dart';
import 'package:amanjalan/core/widgets/aj_common.dart';
import 'package:amanjalan/features/home/aj_data.dart';
import 'package:amanjalan/features/home/manage_guardian_screen.dart';
import 'package:amanjalan/features/perjalanan/data/perjalanan_data.dart';
import 'package:amanjalan/features/perjalanan/perjalanan_actions.dart';
import 'package:amanjalan/features/perjalanan/screens/tracking_screen.dart';
import 'package:amanjalan/features/perjalanan/widgets/pj_widgets.dart';

/// Halaman "Mulai Perjalanan": 4 langkah jelas → tombol Mulai.
class MulaiPerjalananScreen extends StatefulWidget {
  const MulaiPerjalananScreen({super.key});

  @override
  State<MulaiPerjalananScreen> createState() => _MulaiPerjalananScreenState();
}

class _MulaiPerjalananScreenState extends State<MulaiPerjalananScreen> {
  int _dest = 0;
  TravelMode _mode = PerjalananSession.mode.value;
  bool _shareLive = true;

  Destination get _selected {
    final d = kDestinations[_dest];
    return Destination(
      label: d.label,
      icon: d.icon,
      from: d.from,
      to: d.to,
      meters: d.meters,
      minutes: pjEstimateMinutes(d, _mode),
      havens: d.havens,
    );
  }

  void _start() {
    if (GuardianStore.guardians.value.isEmpty) {
      ajSnack(context, 'Tambahkan minimal 1 Guardian dulu ya', icon: Icons.warning_amber_rounded);
      return;
    }
    HapticFeedback.mediumImpact();
    PerjalananSession.mode.value = _mode;
    TripStore.start(_selected);
    ajSnack(context, 'Jalan aman dimulai. Live monitor dikirim ke Guardian.', icon: Icons.directions_walk_rounded);
    Navigator.of(context).pushReplacement(pjRoute(const TrackingScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Aj.bg,
      appBar: pjAppBar(context, 'Mulai Perjalanan'),
      body: ValueListenableBuilder<ActiveTrip?>(
        valueListenable: TripStore.active,
        builder: (context, active, _) {
          if (active != null) return _AlreadyActive(trip: active);
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                  children: [
                    _intro(),
                    const SizedBox(height: 18),
                    const PjStep(1, 'Tujuan Perjalanan'),
                    _destinationPicker(),
                    const SizedBox(height: 18),
                    const PjStep(2, 'Pilih Mode'),
                    _modePicker(),
                    const SizedBox(height: 18),
                    const PjStep(3, 'Estimasi Waktu', hint: 'otomatis'),
                    _estimateCard(),
                    const SizedBox(height: 18),
                    const PjStep(4, 'Siapa yang Memantau?'),
                    _guardianCard(),
                  ],
                ),
              ),
              _bottomBar(),
            ],
          );
        },
      ),
    );
  }

  Widget _intro() {
    return AjCard(
      color: Aj.blush,
      shadow: false,
      radius: 24,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const PjMascot(size: 72),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Perjalanan Aman Dimulai dari Sini', style: Aj.h(15, color: Aj.berry, height: 1.2)),
                const SizedBox(height: 4),
                Text('Pastikan kamu berada di tempat yang aman sebelum memulai.', style: Aj.b(12.5, color: Aj.muted, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _destinationPicker() {
    final d = _selected;
    return AjCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _dest = i);
                  },
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
          // titik awal → tujuan
          Row(
            children: [
              Column(
                children: [
                  const Icon(Icons.circle, size: 11, color: Aj.plum),
                  Container(width: 2, height: 22, color: Aj.line),
                  const Icon(Icons.flag_rounded, size: 15, color: Aj.berry),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TITIK AWAL', style: Aj.b(10, color: Aj.muted, w: FontWeight.w800)),
                    Text(d.from, style: Aj.b(14, w: FontWeight.w800)),
                    const SizedBox(height: 8),
                    Text('TUJUAN', style: Aj.b(10, color: Aj.muted, w: FontWeight.w800)),
                    Text(d.to, style: Aj.b(14, w: FontWeight.w800)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const RouteMap(height: 120, progress: 0.0),
          const SizedBox(height: 10),
          Row(
            children: [
              const AjIconBubble(Icons.local_police_outlined, bg: Aj.mint, fg: Aj.mintDeep, size: 34),
              const SizedBox(width: 10),
              Expanded(child: Text('${d.havens} Pos Titik Aman di sepanjang rute', style: Aj.b(12.5, w: FontWeight.w700))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _modePicker() {
    return Row(
      children: [
        for (final m in TravelMode.values) ...[
          Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _mode = m);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: _mode == m ? Aj.plum : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: _mode == m ? Aj.plum : Aj.line, width: 1.4),
                ),
                child: Column(
                  children: [
                    Icon(m.icon, size: 24, color: _mode == m ? Colors.white : Aj.plum),
                    const SizedBox(height: 6),
                    Text(m.label, style: Aj.b(11.5, color: _mode == m ? Colors.white : Aj.ink, w: FontWeight.w800)),
                  ],
                ),
              ),
            ),
          ),
          if (m != TravelMode.values.last) const SizedBox(width: 8),
        ],
      ],
    );
  }

  Widget _estimateCard() {
    final d = _selected;
    final arrive = DateTime.now().add(Duration(minutes: d.minutes));
    return AjCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${d.minutes}', style: Aj.h(40, color: Aj.plum, height: 1)),
                  const SizedBox(width: 6),
                  Padding(padding: const EdgeInsets.only(bottom: 5), child: Text('menit', style: Aj.h(15, color: Aj.plum))),
                ],
              ),
              Text('Tiba sekitar ${fmtTime(arrive)} WIB', style: Aj.b(12, color: Aj.muted)),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AjPill(fmtDistance(d.meters), bg: Aj.sand, fg: Aj.ink, icon: Icons.straighten_rounded),
              const SizedBox(height: 6),
              AjPill(_mode.label, bg: Aj.blush, fg: Aj.berry, icon: _mode.icon),
            ],
          ),
        ],
      ),
    );
  }

  Widget _guardianCard() {
    return AjCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TripGuardianStrip(),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(child: Text('Kirim lokasi live ke Guardian', style: Aj.b(13, w: FontWeight.w800))),
              Switch(
                value: _shareLive,
                activeColor: Aj.plum,
                onChanged: (v) => setState(() => _shareLive = v),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ManageGuardianScreen())),
              icon: const Icon(Icons.manage_accounts_rounded, size: 18, color: Aj.berry),
              label: Text('Kelola Guardian', style: Aj.b(12.5, color: Aj.berry, w: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 14 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, -4))],
      ),
      child: PjButton('Mulai Sekarang', icon: Icons.send_rounded, onTap: _start),
    );
  }
}

class _AlreadyActive extends StatelessWidget {
  final ActiveTrip trip;
  const _AlreadyActive({required this.trip});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const PjMascot(size: 120),
          const SizedBox(height: 16),
          Text('Perjalanan masih berlangsung', style: Aj.h(18), textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text('${trip.from} → ${trip.to}', style: Aj.b(13.5, color: Aj.muted), textAlign: TextAlign.center),
          const SizedBox(height: 22),
          PjButton(
            'Buka Tracking',
            icon: Icons.navigation_rounded,
            onTap: () => Navigator.of(context).pushReplacement(pjRoute(const TrackingScreen())),
          ),
        ],
      ),
    );
  }
}
