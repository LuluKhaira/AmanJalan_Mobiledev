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
                const AjSectionTitle('Perlindungan Otomatis'),
                const _AutoProtectCard(),
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
      padding: const EdgeInsets.fromLTRB(20, 14, 12, 14),
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
                Text('Jalan dengan tenang, kami temani tiap langkahmu.', style: Aj.b(13, color: Aj.muted, height: 1.4)),
              ],
            ),
          ),
          const SizedBox(width: 6),
          const PjMascot(size: 84),
        ],
      ),
    );
  }

  // ─── DUA PERAN: berjalan & memantau ────────────────────
  Widget _mainActions(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _RoleCard(
              icon: Icons.directions_walk_rounded,
              title: 'Saya Berjalan',
              subtitle: 'Mulai perjalanan, Guardian ikut memantau.',
              bg: Aj.plum,
              fg: Colors.white,
              iconBg: const Color(0x26FFFFFF),
              onTap: () => _push(context, const MulaiPerjalananScreen()),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ValueListenableBuilder<List<Guardian>>(
              valueListenable: GuardianStore.guardians,
              builder: (context, list, _) => _RoleCard(
                icon: Icons.groups_rounded,
                title: 'Saya Memantau',
                subtitle: 'Pantau orang terdekatmu real-time.',
                badge: '${list.where((g) => g.online).length} online',
                bg: Aj.mint,
                fg: Aj.mintDeep,
                iconBg: Colors.white,
                onTap: () => _push(context, const PantauScreen()),
              ),
            ),
          ),
        ],
      ),
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
        return Column(children: [for (final t in list.take(2)) TripHistoryTile(t)]);
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
}

// ─────────────────────────────────────────────────────────────
// Komponen privat hub
// ─────────────────────────────────────────────────────────────

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? badge;
  final Color bg;
  final Color fg;
  final Color iconBg;
  final VoidCallback onTap;

  const _RoleCard({
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
    final dark = bg == Aj.plum;
    final sub = dark ? const Color(0xCCFFFFFF) : fg;
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
            boxShadow: dark ? const [BoxShadow(color: Color(0x404A1D5C), blurRadius: 16, offset: Offset(0, 8))] : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                    child: Icon(icon, color: dark ? Colors.white : fg, size: 24),
                  ),
                  const Spacer(),
                  if (badge != null) AjPill(badge!, bg: Colors.white, fg: fg, size: 10, dot: true),
                ],
              ),
              const SizedBox(height: 16),
              Text(title, style: Aj.h(16, color: fg)),
              const SizedBox(height: 4),
              Text(subtitle, style: Aj.b(12, color: sub, height: 1.3)),
              const Spacer(),
              const SizedBox(height: 12),
              Align(alignment: Alignment.centerRight, child: Icon(Icons.arrow_forward_rounded, size: 20, color: fg)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tiga pengaman otomatis dalam satu kartu: jelas mana yang bisa di-switch.
class _AutoProtectCard extends StatelessWidget {
  const _AutoProtectCard();

  @override
  Widget build(BuildContext context) {
    return AjCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Column(
        children: [
          _toggle(
            context,
            icon: Icons.vibration_rounded,
            bg: Aj.blush,
            fg: Aj.berry,
            title: 'Guncang 3x',
            sub: 'Kirim peringatan darurat otomatis',
            notifier: PerjalananSession.guncang,
            onMsg: 'Deteksi guncangan aktif',
            offMsg: 'Deteksi guncangan dimatikan',
          ),
          const Divider(height: 1, color: Aj.line),
          _toggle(
            context,
            icon: Icons.location_on_outlined,
            bg: Aj.mint,
            fg: Aj.mintDeep,
            title: 'Kabar Tiba Otomatis',
            sub: 'Kirim "sudah sampai" saat masuk area kos',
            notifier: PerjalananSession.autoArrive,
            onMsg: 'Kabar tiba otomatis aktif',
            offMsg: 'Kabar tiba otomatis dimatikan',
          ),
          const Divider(height: 1, color: Aj.line),
          _ProtectTile(
            icon: Icons.battery_charging_full_rounded,
            bg: Aj.sand,
            fg: Aj.muted,
            title: 'Baterai Aman',
            sub: 'Cukup untuk ±4,5 jam pemantauan',
            trailing: Text('85%', style: Aj.h(14)),
          ),
        ],
      ),
    );
  }

  Widget _toggle(
    BuildContext context, {
    required IconData icon,
    required Color bg,
    required Color fg,
    required String title,
    required String sub,
    required ValueNotifier<bool> notifier,
    required String onMsg,
    required String offMsg,
  }) {
    return ValueListenableBuilder<bool>(
      valueListenable: notifier,
      builder: (context, on, _) => _ProtectTile(
        icon: icon,
        bg: bg,
        fg: fg,
        title: title,
        sub: sub,
        trailing: Switch(
          value: on,
          activeTrackColor: Aj.plum,
          onChanged: (v) {
            HapticFeedback.selectionClick();
            notifier.value = v;
            ajSnack(context, v ? onMsg : offMsg, icon: icon);
          },
        ),
      ),
    );
  }
}

class _ProtectTile extends StatelessWidget {
  final IconData icon;
  final Color bg;
  final Color fg;
  final String title;
  final String sub;
  final Widget trailing;

  const _ProtectTile({
    required this.icon,
    required this.bg,
    required this.fg,
    required this.title,
    required this.sub,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                const SizedBox(height: 1),
                Text(sub, style: Aj.b(11.5, color: Aj.muted, height: 1.25)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          trailing,
        ],
      ),
    );
  }
}