import 'package:flutter/material.dart';
import 'package:amanjalan/core/theme/aj_theme.dart';
import 'package:amanjalan/core/widgets/aj_common.dart';
import 'package:amanjalan/core/widgets/aj_settings_kit.dart';

/// VERSI APLIKASI.
class AppVersionScreen extends StatefulWidget {
  const AppVersionScreen({super.key});

  @override
  State<AppVersionScreen> createState() => _AppVersionScreenState();
}

class _AppVersionScreenState extends State<AppVersionScreen> {
  static const _news = [
    (Icons.vibration_rounded, Aj.blush, Aj.berry, 'Deteksi Guncangan Presisi', 'Inti', 'Peningkatan sensitivitas fitur Shake-to-SOS secara adaptif, meminimalisir pemicu palsu saat berjalan cepat atau menaiki transportasi umum.'),
    (Icons.lock_outline_rounded, Aj.sand, Aj.plum, 'PIN Paksaan (Duress PIN)', 'Rahasia', 'Input PIN alternatif darurat untuk menutup ancaman visual seketika sembari menyiarkan koordinat diam-diam ke kontak wali terverifikasi.'),
    (Icons.sync_alt_rounded, Aj.mint, Aj.mintDeep, 'Offline Queuing GPS', 'Jaringan', 'Penyimpanan rute lokal saat sinyal seluler hilang (area blank spot) dan pengiriman otomatis segera setelah koneksi pulih.'),
    (Icons.battery_saver_outlined, Aj.blush, Aj.berry, 'Efisiensi Daya Malam Hari', 'Hemat 30%', 'Konsumsi daya baterai hingga 30% lebih hemat pada mode penjagaan latar belakang aktif selama perjalanan malam.'),
  ];

  static const _diag = [
    (Icons.screen_rotation_alt_outlined, 'Akselerometer & Giroskop', 'Sampling Aktif • 100 Hz', 'Normal'),
    (Icons.location_on_outlined, 'Modul GPS & Lokasi Halus', 'Presisi Tinggi • Akurasi ~3m', 'Terkunci'),
    (Icons.mic_none_rounded, 'Izin Mikrofon Lingkungan', 'Akses Pemicu Suara Siap', 'Siaga'),
    (Icons.notifications_active_outlined, 'Layanan Latar Belakang', 'Tanpa Batasan Optimasi Baterai', 'Diizinkan'),
  ];

  bool _checking = false;
  bool _scanning = false;

  Future<void> _checkUpdate() async {
    setState(() => _checking = true);
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() => _checking = false);
    ajSnack(context, 'Anda memakai versi terbaru', icon: Icons.verified_outlined);
  }

  Future<void> _rescan() async {
    setState(() => _scanning = true);
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() => _scanning = false);
    ajSnack(context, 'Semua sensor berfungsi normal', icon: Icons.check_circle_outline_rounded);
  }

  @override
  Widget build(BuildContext context) {
    return AjSubScaffold(
      title: 'Versi Aplikasi',
      children: [
        // Header versi
        Container(
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFFFF0F2), Colors.white], begin: Alignment.topRight, end: Alignment.bottomLeft),
            borderRadius: BorderRadius.circular(28),
            boxShadow: Aj.softShadow,
          ),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: const BoxDecoration(color: Aj.plum, shape: BoxShape.circle),
                    child: const Icon(Icons.shield_rounded, color: Colors.white, size: 40),
                  ),
                  const Positioned(bottom: -10, child: AjPill('Siaga', bg: Aj.mint, fg: Aj.mintDeep, dot: true, size: 11)),
                ],
              ),
              const SizedBox(height: 20),
              Text('amanJalan Companion', style: Aj.h(22, color: Aj.plum)),
              const SizedBox(height: 8),
              const AjPill('v2.4.1 (Build Siaga Stabil)', bg: Aj.sand, fg: Aj.muted, size: 12),
              const SizedBox(height: 10),
              const AjPill('Versi Terbaru Terpasang • Proteksi Optimal', bg: Aj.mint, fg: Aj.mintDeep, icon: Icons.verified_rounded, size: 11.5),
              const SizedBox(height: 10),
              Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.event_available_outlined, size: 15, color: Aj.muted),
                const SizedBox(width: 6),
                Text('Pembaruan Terakhir: 24 Februari 2025', style: Aj.b(12, color: Aj.muted)),
              ]),
            ],
          ),
        ),
        kGap,

        // Apa yang baru
        Row(
          children: [
            const Icon(Icons.auto_awesome_rounded, color: Aj.berry, size: 20),
            const SizedBox(width: 6),
            Expanded(child: Text('Apa yang Baru di v2.4.1', style: Aj.h(17, color: Aj.plum))),
            const AjPill('Catatan Rilis', bg: Aj.blush, fg: Aj.berry, size: 11),
          ],
        ),
        const SizedBox(height: 12),
        AjCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              for (var i = 0; i < _news.length; i++) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AjIconBubble(_news[i].$1, bg: _news[i].$2, fg: _news[i].$3, size: 46),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Flexible(child: Text(_news[i].$4, style: Aj.b(14.5, w: FontWeight.w800))),
                            const SizedBox(width: 6),
                            AjPill(_news[i].$5, bg: Aj.blush, fg: Aj.berry, size: 9.5),
                          ]),
                          const SizedBox(height: 3),
                          Text(_news[i].$6, style: Aj.b(12.5, color: Aj.muted, height: 1.4)),
                        ],
                      ),
                    ),
                  ],
                ),
                if (i < _news.length - 1) const Divider(height: 26, color: Aj.line),
              ],
            ],
          ),
        ),
        kGap,

        // Diagnostik
        Row(
          children: [
            const Icon(Icons.health_and_safety_outlined, color: Aj.plum, size: 20),
            const SizedBox(width: 6),
            Expanded(child: Text('Diagnostik Sensor & Perangkat', style: Aj.h(17, color: Aj.plum))),
            InkWell(
              onTap: _scanning ? null : _rescan,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(color: Aj.sand, shape: BoxShape.circle),
                child: _scanning
                    ? const Padding(padding: EdgeInsets.all(11), child: CircularProgressIndicator(strokeWidth: 2.5, color: Aj.plum))
                    : const Icon(Icons.sync_rounded, color: Aj.plum, size: 20),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AjCard(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              for (final d in _diag)
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Aj.sand, borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      AjIconBubble(d.$1, bg: Aj.mint, fg: Aj.mintDeep, size: 44),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(d.$2, style: Aj.b(13.5, w: FontWeight.w800)),
                            Text(d.$3, style: Aj.b(11.5, color: Aj.muted)),
                          ],
                        ),
                      ),
                      AjPill(d.$4, bg: Colors.white, fg: Aj.ink, dot: true, size: 11),
                    ],
                  ),
                ),
            ],
          ),
        ),
        kGap,

        // Legal
        Padding(padding: const EdgeInsets.only(left: 4, bottom: 12), child: Text('Informasi Legal & Pengembang', style: Aj.h(18, color: Aj.plum))),
        AjCard(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Column(
            children: [
              _legal(Icons.article_outlined, 'Syarat & Ketentuan Layanan', true),
              _legal(Icons.privacy_tip_outlined, 'Kebijakan Privasi & Perlindungan Data', true),
              _legal(Icons.code_rounded, 'Lisensi Open Source & Komunitas', false),
            ],
          ),
        ),
        kGap,
        InkWell(
          onTap: _checking ? null : _checkUpdate,
          borderRadius: BorderRadius.circular(28),
          child: Container(
            height: 56,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), boxShadow: Aj.softShadow),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_checking)
                  const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.5, color: Aj.plum))
                else
                  const Icon(Icons.system_update_alt_rounded, color: Aj.berry, size: 20),
                const SizedBox(width: 10),
                Text(_checking ? 'Memeriksa…' : 'Periksa Pembaruan Sistem', style: Aj.b(14.5, w: FontWeight.w800)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Dibuat dengan ', style: Aj.b(12, color: Aj.muted)),
            const Icon(Icons.favorite_rounded, size: 14, color: Aj.berry),
            Text(' untuk keselamatan perempuan di seluruh dunia.', style: Aj.b(12, color: Aj.muted)),
          ],
        ),
        const SizedBox(height: 4),
        Center(child: Text('ID Instalasi: AJ-ID-8829-JKT-PROD', style: Aj.b(11, color: Aj.muted))),
      ],
    );
  }

  Widget _legal(IconData icon, String label, bool divider) {
    return Column(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => ajSnack(context, '$label segera hadir', icon: icon),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                AjIconBubble(icon, bg: Aj.sand, fg: Aj.muted, size: 40),
                const SizedBox(width: 12),
                Expanded(child: Text(label, style: Aj.b(14, w: FontWeight.w700))),
                const Icon(Icons.chevron_right_rounded, color: Aj.muted),
              ],
            ),
          ),
        ),
        if (divider) const Divider(height: 1, color: Aj.line),
      ],
    );
  }
}