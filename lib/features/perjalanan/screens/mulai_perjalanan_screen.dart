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

/// "Mulai Perjalanan" = mode PENDAMPING (berbasis orang).
/// Beda dengan tab Proteksi yang berbasis PETA & RUTE (pilih rute teraman):
/// di sini tidak ada peta/rute, fokusnya: ke mana, naik apa, siapa yang
/// menemani, dan pengaman otomatis.
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
                    const SizedBox(height: 20),
                    const PjStep(1, 'Mau ke mana?'),
                    _destinationPicker(),
                    const SizedBox(height: 20),
                    const PjStep(2, 'Naik apa?'),
                    _modePicker(),
                    const SizedBox(height: 20),
                    const PjStep(3, 'Siapa yang menemani?'),
                    _guardianCard(),
                    const SizedBox(height: 20),
                    const PjStep(4, 'Pengaman otomatis'),
                    _safetyCard(),
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
    return Row(
      children: [
        const AjIconBubble(Icons.people_alt_rounded, bg: Aj.blush, fg: Aj.berry, size: 42),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Jalan ditemani Guardian. Mereka memantau langkahmu live sampai kamu tiba.',
            style: Aj.b(13, color: Aj.muted, height: 1.35),
          ),
        ),
      ],
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
                    Text(d.from, style: Aj.b(14, w: FontWeight.w800)),
                    const SizedBox(height: 14),
                    Text(d.to, style: Aj.b(14, w: FontWeight.w800)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.local_police_outlined, size: 16, color: Aj.mintDeep),
              const SizedBox(width: 6),
              Text('${d.havens} Pos Titik Aman di sepanjang rute', style: Aj.b(12, color: Aj.mintDeep, w: FontWeight.w700)),
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

  Widget _guardianCard() {
    return AjCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TripGuardianStrip(showTitle: false),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(child: Text('Kirim lokasi live ke mereka', style: Aj.b(13, w: FontWeight.w800))),
              Switch(
                value: _shareLive,
                activeTrackColor: Aj.plum,
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

  Widget _safetyCard() {
    return AjCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Column(
        children: [
          _SafetyRow(
            icon: Icons.vibration_rounded,
            bg: Aj.blush,
            fg: Aj.berry,
            title: 'Guncang 3x',
            sub: 'Kirim peringatan darurat otomatis',
            notifier: PerjalananSession.guncang,
          ),
          const Divider(height: 1, color: Aj.line),
          _SafetyRow(
            icon: Icons.location_on_outlined,
            bg: Aj.mint,
            fg: Aj.mintDeep,
            title: 'Kabar tiba otomatis',
            sub: 'Guardian diberi tahu saat kamu sampai',
            notifier: PerjalananSession.autoArrive,
          ),
        ],
      ),
    );
  }

  Widget _bottomBar() {
    final d = _selected;
    final arrive = DateTime.now().add(Duration(minutes: d.minutes));
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 14 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, -4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ValueListenableBuilder<List<Guardian>>(
            valueListenable: GuardianStore.guardians,
            builder: (context, list, _) => Text(
              '±${d.minutes} mnt • ${fmtDistance(d.meters)} • tiba ${fmtTime(arrive)} • ${list.length} Guardian memantau',
              textAlign: TextAlign.center,
              style: Aj.b(12, color: Aj.muted, w: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 10),
          PjButton('Mulai Berjalan', icon: Icons.send_rounded, onTap: _start),
        ],
      ),
    );
  }
}

class _SafetyRow extends StatelessWidget {
  final IconData icon;
  final Color bg;
  final Color fg;
  final String title;
  final String sub;
  final ValueNotifier<bool> notifier;

  const _SafetyRow({
    required this.icon,
    required this.bg,
    required this.fg,
    required this.title,
    required this.sub,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: notifier,
      builder: (context, on, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            AjIconBubble(icon, bg: bg, fg: fg, size: 38),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Aj.b(13.5, w: FontWeight.w800)),
                  Text(sub, style: Aj.b(11.5, color: Aj.muted, height: 1.25)),
                ],
              ),
            ),
            Switch(
              value: on,
              activeTrackColor: Aj.plum,
              onChanged: (v) {
                HapticFeedback.selectionClick();
                notifier.value = v;
              },
            ),
          ],
        ),
      ),
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