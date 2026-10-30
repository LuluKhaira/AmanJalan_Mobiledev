import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:amanjalan/core/theme/aj_theme.dart';
import 'package:amanjalan/core/widgets/aj_common.dart';
import 'package:amanjalan/core/widgets/app_header.dart';
import 'package:amanjalan/core/widgets/press_scale.dart';
import 'package:amanjalan/features/home/aj_data.dart';
import 'package:amanjalan/features/home/manage_guardian_screen.dart';
import 'package:amanjalan/features/perjalanan/data/perjalanan_data.dart';
import 'package:amanjalan/features/perjalanan/perjalanan_actions.dart';
import 'package:amanjalan/features/perjalanan/screens/laporan_kejadian_screen.dart';
import 'package:amanjalan/features/perjalanan/screens/mulai_perjalanan_screen.dart';
import 'package:amanjalan/features/perjalanan/screens/pantau_screen.dart';
import 'package:amanjalan/features/perjalanan/screens/riwayat_screen.dart';
import 'package:amanjalan/features/perjalanan/screens/tracking_screen.dart';
import 'package:amanjalan/features/perjalanan/widgets/pj_widgets.dart';

/// TAB PERJALANAN — hub. Setiap fitur dibuka di halamannya sendiri.
class PerjalananTab extends StatelessWidget {
  /// Dipertahankan agar home_screen.dart tidak perlu diubah.
  final VoidCallback? onOpenEmergency;
  final VoidCallback? onOpenMap;
  final VoidCallback? onProfileTap;

  const PerjalananTab({super.key, this.onOpenEmergency, this.onOpenMap, this.onProfileTap});

  void _push(BuildContext context, Widget page) => Navigator.of(context).push(pjRoute(page));

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppHeader(onProfileTap: onProfileTap),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _hero(),
                const SizedBox(height: 16),
                ValueListenableBuilder<ActiveTrip?>(
                  valueListenable: TripStore.active,
                  builder: (context, a, _) => a == null ? _mainActions(context) : _activeBanner(context, a),
                ),
                const SizedBox(height: 22),
                const AjSectionTitle('Alat Cepat'),
                _quickTools(context),
                const SizedBox(height: 22),
                const AjSectionTitle('Sensor Siaga', trailing: _SensorHint()),
                const _SensorRow(),
                const SizedBox(height: 22),
                AjSectionTitle(
                  'Perjalanan Terakhir',
                  trailing: GestureDetector(
                    onTap: () => _push(context, const TripHistoryScreen()),
                    child: Text('Lihat Semua', style: Aj.b(12.5, color: Aj.berry, w: FontWeight.w800)),
                  ),
                ),
                _recent(context),
                const SizedBox(height: 22),
                _guardianCard(context),
                const SizedBox(height: 16),
                _tip(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── HERO ───────────────────────────────────────────────
  Widget _hero() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 12, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFFDEEF3), Color(0xFFF3E6F4)]),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Perjalanan', style: Aj.h(26, color: Aj.plum)),
                const SizedBox(height: 6),
                Text('Mulai perjalananmu dengan aman. Kami akan memantau dan mendampingi setiap langkahmu.', style: Aj.b(13, color: Aj.muted, height: 1.4)),
              ],
            ),
          ),
          const SizedBox(width: 6),
          const PjMascot(size: 104),
        ],
      ),
    );
  }

  // ─── DUA AKSI UTAMA ─────────────────────────────────────
  Widget _mainActions(BuildContext context) {
    return Column(
      children: [
        _BigAction(
          icon: Icons.location_on_rounded,
          title: 'Mulai Perjalanan',
          subtitle: 'Aktifkan pelacakan lokasi dan mulai perjalananmu.',
          bg: Aj.plum,
          fg: Colors.white,
          iconBg: const Color(0x26FFFFFF),
          onTap: () => _push(context, const MulaiPerjalananScreen()),
        ),
        const SizedBox(height: 12),
        ValueListenableBuilder<List<Guardian>>(
          valueListenable: GuardianStore.guardians,
          builder: (context, list, _) => _BigAction(
            icon: Icons.groups_rounded,
            title: 'Saya Memantau',
            subtitle: 'Pantau orang terdekatmu secara real-time.',
            badge: '${list.where((g) => g.online).length} online',
            bg: Aj.mint,
            fg: Aj.mintDeep,
            iconBg: Colors.white,
            onTap: () => _push(context, const PantauScreen()),
          ),
        ),
      ],
    );
  }

  Widget _activeBanner(BuildContext context, ActiveTrip a) {
    return PressScale(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => _push(context, const TrackingScreen()),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(colors: [Color(0xFF4A1D5C), Color(0xFF6A2E80)]),
            boxShadow: const [BoxShadow(color: Color(0x404A1D5C), blurRadius: 16, offset: Offset(0, 8))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const AjPill('Sedang Berlangsung', bg: Colors.white, fg: Aj.mintDeep, dot: true),
                  const Spacer(),
                  Text('Mulai ${fmtTime(a.startedAt)}', style: Aj.b(12, color: const Color(0xCCFFFFFF))),
                ],
              ),
              const SizedBox(height: 12),
              Text('${a.from} → ${a.to}', style: Aj.h(16, color: Colors.white)),
              const SizedBox(height: 10),
              StreamBuilder<int>(
                stream: Stream<int>.periodic(const Duration(seconds: 1), (i) => i),
                builder: (context, _) {
                  final p = pjProgress(a);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: p,
                          minHeight: 8,
                          backgroundColor: const Color(0x33FFFFFF),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF8FAB)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(p >= 1 ? 'Kamu sudah di tujuan' : '${pjRemainMinutes(a)} menit lagi • ${fmtDistance(pjRemainMeters(a))}', style: Aj.b(12.5, color: const Color(0xCCFFFFFF), w: FontWeight.w700)),
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                      child: Text('Buka Tracking', style: Aj.h(13.5, color: Aj.plum)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── ALAT CEPAT ─────────────────────────────────────────
  Widget _quickTools(BuildContext context) {
    return Row(
      children: [
        PjQuickAction(icon: Icons.phone_in_talk_rounded, label: 'Panggilan\nPalsu', onTap: () => pjOpenFakeCall(context)),
        const SizedBox(width: 8),
        PjQuickAction(
          icon: Icons.warning_rounded,
          label: 'SOS\nDarurat',
          bg: Aj.sosSoft,
          fg: Aj.sos,
          onTap: () => onOpenEmergency != null ? onOpenEmergency!() : pjOpenEmergency(context),
        ),
        const SizedBox(width: 8),
        PjQuickAction(icon: Icons.report_gmailerrorred_rounded, label: 'Lapor\nKejadian', bg: Aj.sand, fg: Aj.plum, onTap: () => _push(context, const LaporanKejadianScreen())),
        const SizedBox(width: 8),
        PjQuickAction(icon: Icons.map_outlined, label: 'Peta\nRute Aman', bg: Aj.mint, fg: Aj.mintDeep, onTap: () => onOpenMap != null ? onOpenMap!() : ajSnack(context, 'Buka tab Peta', icon: Icons.map_outlined)),
      ],
    );
  }

  // ─── RIWAYAT TERAKHIR ───────────────────────────────────
  Widget _recent(BuildContext context) {
    return ValueListenableBuilder<List<TripRecord>>(
      valueListenable: TripStore.trips,
      builder: (context, list, _) {
        if (list.isEmpty) {
          return AjCard(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                const AjIconBubble(Icons.route_outlined, bg: Aj.sand, fg: Aj.muted, size: 44),
                const SizedBox(width: 12),
                Expanded(child: Text('Belum ada perjalanan. Mulai yang pertama!', style: Aj.b(13, color: Aj.muted))),
              ],
            ),
          );
        }
        return Column(children: [for (final t in list.take(3)) TripHistoryTile(t)]);
      },
    );
  }

  // ─── GUARDIAN ───────────────────────────────────────────
  Widget _guardianCard(BuildContext context) {
    return AjCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TripGuardianStrip(),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                HapticFeedback.selectionClick();
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ManageGuardianScreen()));
              },
              icon: const Icon(Icons.manage_accounts_rounded, size: 18, color: Aj.berry),
              label: Text('Kelola Guardian', style: Aj.b(12.5, color: Aj.berry, w: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tip() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Aj.blush, borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          const Icon(Icons.favorite_rounded, color: Aj.berry, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text('Perjalanan lebih aman dengan AmanJalan. Karena kamu berharga.', style: Aj.b(12.5, color: Aj.berry, w: FontWeight.w700, height: 1.3))),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Komponen privat hub
// ─────────────────────────────────────────────────────────────

class _BigAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? badge;
  final Color bg;
  final Color fg;
  final Color iconBg;
  final VoidCallback onTap;

  const _BigAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.bg,
    required this.fg,
    required this.iconBg,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final sub = fg == Colors.white ? const Color(0xCCFFFFFF) : fg;
    return PressScale(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(24),
            boxShadow: bg == Aj.plum ? const [BoxShadow(color: Color(0x404A1D5C), blurRadius: 16, offset: Offset(0, 8))] : null,
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                child: Icon(icon, color: bg == Aj.plum ? Colors.white : fg, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(child: Text(title, style: Aj.h(16, color: fg))),
                        if (badge != null) ...[
                          const SizedBox(width: 8),
                          AjPill(badge!, bg: Colors.white, fg: fg, size: 10, dot: true),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(subtitle, style: Aj.b(12.5, color: sub, height: 1.3)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 16, color: fg),
            ],
          ),
        ),
      ),
    );
  }
}

class _SensorHint extends StatelessWidget {
  const _SensorHint();

  @override
  Widget build(BuildContext context) => Text('Otomatis melindungi', style: Aj.b(12, color: Aj.muted));
}

class _SensorRow extends StatelessWidget {
  const _SensorRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ValueListenableBuilder<bool>(
            valueListenable: PerjalananSession.guncang,
            builder: (context, on, _) => _SensorTile(
              icon: Icons.vibration_rounded,
              iconBg: Aj.blush,
              iconFg: Aj.berry,
              title: 'Guncang 3x',
              sub: 'Deteksi Bahaya',
              on: on,
              onTap: () {
                PerjalananSession.guncang.value = !on;
                ajSnack(context, !on ? 'Deteksi guncangan aktif' : 'Deteksi guncangan dimatikan', icon: Icons.vibration_rounded);
              },
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ValueListenableBuilder<bool>(
            valueListenable: PerjalananSession.autoArrive,
            builder: (context, on, _) => _SensorTile(
              icon: Icons.location_on_outlined,
              iconBg: Aj.mint,
              iconFg: Aj.mintDeep,
              title: 'Auto Sampai',
              sub: 'Geofence Kos',
              on: on,
              onTap: () {
                PerjalananSession.autoArrive.value = !on;
                ajSnack(context, !on ? 'Kabar tiba otomatis aktif' : 'Kabar tiba otomatis dimatikan', icon: Icons.location_on_outlined);
              },
            ),
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: _SensorTile(
            icon: Icons.battery_charging_full_rounded,
            iconBg: Aj.sand,
            iconFg: Aj.muted,
            title: 'Baterai Aman',
            sub: '~4.5 Jam Pantau',
            badge: '85%',
          ),
        ),
      ],
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
    return AjCard(
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
    );
  }
}
