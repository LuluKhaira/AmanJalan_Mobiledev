import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:amanjalan/core/theme/aj_theme.dart';
import 'package:amanjalan/core/widgets/aj_common.dart';
import 'package:amanjalan/features/home/aj_data.dart';
import 'package:amanjalan/features/home/trip_history_screen.dart';

/// PROFIL — mengikuti desain Figma "Profil Saya".
/// Riwayat perjalanan sekarang ada di sini (bagian "Riwayat Perjalanan").
class ProfileTab extends StatefulWidget {
  final VoidCallback onLogout;

  const ProfileTab({super.key, required this.onLogout});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  // Nilai pengaturan (dummy, disimpan di memori)
  int _sensitivity = 1;
  int _fakeCaller = 0;
  int _siren = 0;

  static const _sensLabels = ['Rendah (Siaga 5x Guncang)', 'Sedang (Siaga 3x Guncang Layar Mati)', 'Tinggi (Siaga 2x Guncang)'];
  static const _callerLabels = ['Panggilan Samaran Ayah • Tunda 5 dtk', 'Panggilan Samaran Teman • Tunda 5 dtk', 'Panggilan Samaran Kak Rian • Tunda 10 dtk'];
  static const _sirenLabels = ['Desibel Maksimal (110 dB) • Uji Bunyi', 'Desibel Sedang (90 dB) • Uji Bunyi', 'Senyap + Getar Kuat'];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TOP BAR
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 14, 16, 8),
              child: Row(
                children: [
                  Expanded(child: Text('Profil Saya', style: Aj.h(22, color: Aj.plum))),
                  IconButton(
                    onPressed: () => _qr(context),
                    icon: const Icon(Icons.qr_code_scanner_rounded, color: Aj.plum),
                  ),
                  IconButton(
                    onPressed: () => ajSnack(context, 'Pengaturan akun segera hadir', icon: Icons.settings_outlined),
                    icon: const Icon(Icons.settings_outlined, color: Aj.plum),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _identityCard(context),
                const SizedBox(height: 16),
                _readinessCard(),
                const SizedBox(height: 16),
                _guardianCard(context),
                const SizedBox(height: 16),
                _historyCard(context),
                const SizedBox(height: 16),
                _featuresCard(context),
                const SizedBox(height: 16),
                _credentialCard(context),
                const SizedBox(height: 20),
                _logout(),
                const SizedBox(height: 14),
                Center(
                  child: Text(
                    'Kerahasiaan data Anda dilindungi protokol enkripsi berlapis\namanJalan © 2025',
                    textAlign: TextAlign.center,
                    style: Aj.b(11.5, color: Aj.muted, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Identitas ──────────────────────────────────────────────
  Widget _identityCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFFFF0F2), Colors.white], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(28),
        boxShadow: Aj.softShadow,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(color: Aj.blush, shape: BoxShape.circle),
            child: const AjAvatar(name: 'Anindya Putri', size: 92, online: true, color: Aj.blushDeep),
          ),
          const SizedBox(height: 12),
          Text('Anindya Putri', style: Aj.h(22, color: Aj.plum)),
          Text('Mahasiswi UI • Pengguna Terproteksi', style: Aj.b(13, color: Aj.muted)),
          const SizedBox(height: 10),
          const AjPill('Terverifikasi KTP & Wali Utama', bg: Aj.mint, fg: Aj.mintDeep, icon: Icons.verified_rounded, size: 12.5),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
            decoration: BoxDecoration(color: Aj.sand, borderRadius: BorderRadius.circular(24)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('ID PROTEKSI:', style: Aj.b(11.5, color: Aj.muted, w: FontWeight.w700)),
                const SizedBox(width: 8),
                Text('#AJ-94821', style: Aj.b(13, w: FontWeight.w800)),
                const SizedBox(width: 8),
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Clipboard.setData(const ClipboardData(text: '#AJ-94821'));
                    ajSnack(context, 'ID Proteksi disalin', icon: Icons.copy_rounded);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                    child: Text('Salin', style: Aj.b(12, w: FontWeight.w800)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => _qr(context),
            style: FilledButton.styleFrom(
              backgroundColor: Aj.plum,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.qr_code_2_rounded, size: 22),
            label: Text('Tampilkan QR Saling Pantau', style: Aj.b(14.5, color: Colors.white, w: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  // ── Kesiapan ───────────────────────────────────────────────
  Widget _readinessCard() {
    Widget mini(IconData i, Color bg, Color fg, String t, String v) => Expanded(
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Aj.sand, borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                AjIconBubble(i, bg: bg, fg: fg, size: 34),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t, style: Aj.b(10.5, color: Aj.muted), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(v, style: Aj.b(12, w: FontWeight.w800), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );

    return AjCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('KESIAPAN PROTEKSI', style: Aj.b(11.5, color: Aj.berry, w: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text('Sangat Siaga (95%)', style: Aj.h(19, color: Aj.plum)),
                  ],
                ),
              ),
              SizedBox(
                width: 62,
                height: 62,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: .95),
                      duration: const Duration(milliseconds: 1100),
                      curve: Curves.easeOutCubic,
                      builder: (_, v, __) => SizedBox.expand(
                        child: CircularProgressIndicator(value: v, strokeWidth: 6, backgroundColor: Aj.blush, valueColor: const AlwaysStoppedAnimation(Aj.berry), strokeCap: StrokeCap.round),
                      ),
                    ),
                    Text('95%', style: Aj.h(14, color: Aj.plum)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(children: [
            mini(Icons.pin_outlined, Aj.mint, Aj.mintDeep, 'PIN Darurat', 'Aktif • 6-Digit'),
            const SizedBox(width: 10),
            mini(Icons.vibration_rounded, Aj.mint, Aj.mintDeep, 'Sensor Guncang', '3x Guncangan'),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            mini(Icons.gps_fixed_rounded, Aj.mint, Aj.mintDeep, 'GPS Darurat', 'Presisi Tinggi'),
            const SizedBox(width: 10),
            mini(Icons.family_restroom_rounded, Aj.blush, Aj.berry, 'Wali & Mitra', '3 Terhubung'),
          ]),
        ],
      ),
    );
  }

  // ── Guardian ───────────────────────────────────────────────
  Widget _guardianCard(BuildContext context) {
    return AjCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.groups_rounded, color: Aj.berry, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text('Guardian & Saling Jaga', style: Aj.h(15.5))),
              const AjPill('3 Terdaftar', bg: Aj.blush, fg: Aj.berry, size: 11),
            ],
          ),
          const SizedBox(height: 12),
          for (final g in kGuardians)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Aj.sand, borderRadius: BorderRadius.circular(18)),
              child: Row(
                children: [
                  AjAvatar(name: g.name, size: 44, color: g.color, online: g.online),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Flexible(child: Text(g.name, overflow: TextOverflow.ellipsis, style: Aj.b(14.5, w: FontWeight.w800))),
                          const SizedBox(width: 6),
                          AjPill(g.role, bg: g.role == 'Wali Utama' ? const Color(0xFFE5DDF2) : g.role == 'Teman Kos' ? Aj.mint : Colors.white, fg: g.role == 'Wali Utama' ? Aj.plum : g.role == 'Teman Kos' ? Aj.mintDeep : Aj.muted, size: 10),
                        ]),
                        const SizedBox(height: 2),
                        Text(_guardianNote(g), style: Aj.b(12, color: Aj.muted, height: 1.25)),
                      ],
                    ),
                  ),
                  Icon(g.role == 'Wali Utama' ? Icons.check_circle_outline_rounded : g.role == 'Teman Kos' ? Icons.sync_rounded : Icons.verified_outlined, color: Aj.plum, size: 22),
                ],
              ),
            ),
          const SizedBox(height: 2),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => ajSnack(context, 'Pilih kontak untuk dijadikan guardian (simulasi)', icon: Icons.person_add_alt_1_rounded),
              style: FilledButton.styleFrom(
                backgroundColor: Aj.blush,
                foregroundColor: Aj.plum,
                elevation: 0,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: const Icon(Icons.person_add_alt_1_outlined, size: 18, color: Aj.plum),
              label: Text('Tambah Kontak Guardian Baru', style: Aj.b(13.5, color: Aj.plum, w: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }

  String _guardianNote(Guardian g) => switch (g.role) {
        'Wali Utama' => 'Akses Peringatan SOS • Respon Cepat',
        'Teman Kos' => 'Barter Pantau Pulang Malam Aktif',
        _ => g.note,
      };

  // ── RIWAYAT PERJALANAN (pindahan dari navbar) ─────────────
  Widget _historyCard(BuildContext context) {
    return ValueListenableBuilder<List<TripRecord>>(
      valueListenable: TripStore.trips,
      builder: (context, list, _) {
        final done = list.where((t) => t.status == TripStatus.selesai).length;
        final km = list.fold<int>(0, (a, t) => a + t.meters) / 1000;
        return AjCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('RIWAYAT PERJALANAN', style: Aj.b(11.5, color: Aj.berry, w: FontWeight.w800)),
                        const SizedBox(height: 2),
                        Text('Jejak Jalan Amanmu', style: Aj.h(18, color: Aj.plum)),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const TripHistoryScreen())),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text('Lihat Semua', style: Aj.b(12.5, color: Aj.berry, w: FontWeight.w800)),
                      const Icon(Icons.chevron_right_rounded, color: Aj.berry, size: 18),
                    ]),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _hStat('${list.length}', 'Perjalanan'),
                  const SizedBox(width: 10),
                  _hStat(km.toStringAsFixed(1), 'Km total'),
                  const SizedBox(width: 10),
                  _hStat('${list.isEmpty ? 0 : done * 100 ~/ list.length}%', 'Tiba aman'),
                ],
              ),
              const SizedBox(height: 14),
              for (final t in list.take(3)) TripHistoryTile(t),
              if (list.isEmpty) Text('Belum ada perjalanan', style: Aj.b(13, color: Aj.muted)),
            ],
          ),
        );
      },
    );
  }

  Widget _hStat(String v, String l) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: Aj.blush, borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              Text(v, style: Aj.h(18, color: Aj.plum)),
              Text(l, style: Aj.b(11, color: Aj.berry, w: FontWeight.w700)),
            ],
          ),
        ),
      );

  // ── Fitur & pemicu ─────────────────────────────────────────
  Widget _featuresCard(BuildContext context) {
    return AjCard(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('KONFIGURASI PENGAMANAN', style: Aj.b(11.5, color: Aj.berry, w: FontWeight.w800)),
          const SizedBox(height: 2),
          Text('Fitur & Pemicu Darurat', style: Aj.h(18, color: Aj.plum)),
          const SizedBox(height: 8),
          _tile(Icons.dialpad_rounded, 'PIN & Biometrik', 'PIN 6-digit & Sidik Jari untuk Batal SOS', () => ajSnack(context, 'PIN & biometrik terkonfigurasi', icon: Icons.fingerprint_rounded)),
          _tile(Icons.vibration_rounded, 'Sensitivitas Sensor Guncang', _sensLabels[_sensitivity], () => _choose(context, 'Sensitivitas Sensor Guncang', _sensLabels, _sensitivity, (i) => setState(() => _sensitivity = i))),
          _tile(Icons.phone_in_talk_outlined, 'Kustomisasi Fake Call', _callerLabels[_fakeCaller], () => _choose(context, 'Kustomisasi Fake Call', _callerLabels, _fakeCaller, (i) => setState(() => _fakeCaller = i))),
          _tile(Icons.volume_up_outlined, 'Sirene & Audio Peringatan', _sirenLabels[_siren], () => _choose(context, 'Sirene & Audio Peringatan', _sirenLabels, _siren, (i) => setState(() => _siren = i))),
          _tile(Icons.location_on_outlined, 'Zona Aman Geofence', 'Kos Melati, Rumah Bandung, Kampus UI', () => ajSnack(context, '3 zona aman aktif', icon: Icons.location_on_outlined), last: true),
        ],
      ),
    );
  }

  Widget _credentialCard(BuildContext context) {
    return AjCard(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('KREDENSIAL & MEDIS', style: Aj.b(11.5, color: Aj.berry, w: FontWeight.w800)),
          const SizedBox(height: 2),
          Text('Informasi Pribadi & Bantuan', style: Aj.h(18, color: Aj.plum)),
          const SizedBox(height: 8),
          _tile(Icons.medical_services_outlined, 'Data Medis Darurat', 'Alergi Penisilin • Penanganan Khusus', () => ajSnack(context, 'Data medis hanya terlihat saat SOS aktif', icon: Icons.medical_information_outlined),
              tag: 'O+', iconBg: Aj.blush, iconFg: Aj.sos),
          _tile(Icons.lock_outline_rounded, 'Privasi & Enkripsi Riwayat', 'Enkripsi E2E • Hapus Otomatis 30 Hari', () => ajSnack(context, 'Riwayat dienkripsi ujung-ke-ujung', icon: Icons.lock_outline_rounded)),
          _tile(Icons.headset_mic_outlined, 'Pusat Bantuan & Layanan 24 Jam', 'Hubungi Tim Hotline Darurat amanJalan', () => ajSnack(context, 'Menghubungkan ke hotline…', icon: Icons.headset_mic_outlined)),
          _tile(Icons.info_outline_rounded, 'Versi Aplikasi', 'amanJalan v2.4.1 (Build Siaga Stabil)', () => ajSnack(context, 'Anda memakai versi terbaru', icon: Icons.verified_outlined), trailingText: 'Terbaru', last: true),
        ],
      ),
    );
  }

  Widget _tile(
    IconData icon,
    String title,
    String sub,
    VoidCallback onTap, {
    bool last = false,
    String? tag,
    String? trailingText,
    Color iconBg = Aj.sand,
    Color iconFg = Aj.plum,
  }) {
    return Column(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                AjIconBubble(icon, bg: iconBg, fg: iconFg, size: 44),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Flexible(child: Text(title, style: Aj.b(14.5, w: FontWeight.w800))),
                        if (tag != null) ...[const SizedBox(width: 6), AjPill(tag, bg: Aj.blush, fg: Aj.sos, size: 10)],
                      ]),
                      const SizedBox(height: 1),
                      Text(sub, style: Aj.b(12, color: Aj.muted, height: 1.3)),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                if (trailingText != null) Padding(padding: const EdgeInsets.only(right: 4), child: Text(trailingText, style: Aj.b(11.5, color: Aj.muted))),
                const Icon(Icons.chevron_right_rounded, color: Aj.muted, size: 22),
              ],
            ),
          ),
        ),
        if (!last) const Divider(height: 1, color: Aj.line),
      ],
    );
  }

  void _choose(BuildContext context, String title, List<String> options, int current, ValueChanged<int> onPick) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AjSheet(
        title: title,
        child: Column(
          children: [
            for (var i = 0; i < options.length; i++)
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  onPick(i);
                  Navigator.pop(ctx);
                  ajSnack(context, 'Pengaturan disimpan');
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: i == current ? Aj.blush : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: i == current ? Aj.blushDeep : Aj.line, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: Text(options[i], style: Aj.b(13.5, w: FontWeight.w800))),
                      if (i == current) const Icon(Icons.check_circle_rounded, color: Aj.berry, size: 20),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Logout ─────────────────────────────────────────────────
  Widget _logout() {
    return InkWell(
      onTap: widget.onLogout,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 54,
        decoration: BoxDecoration(color: const Color(0xFFF0EBEA), borderRadius: BorderRadius.circular(18)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded, color: Aj.sos, size: 20),
            const SizedBox(width: 8),
            Text('Keluar dari Akun', style: Aj.b(15, color: Aj.sos, w: FontWeight.w800)),
          ],
        ),
      ),
    );
  }

  void _qr(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const AjSheet(title: 'QR Saling Pantau', child: Center(child: AjQrBox())),
    );
  }
}