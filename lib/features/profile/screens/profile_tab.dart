import 'package:amanjalan/features/home/tambah_guardian_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:amanjalan/core/theme/aj_theme.dart';
import 'package:amanjalan/core/widgets/aj_common.dart';
import 'package:amanjalan/features/home/aj_data.dart';
import 'package:amanjalan/features/profile/screens/screens.dart';

/// PROFIL — mengikuti desain Figma "Profil Saya".
class ProfileTab extends StatefulWidget {
  final VoidCallback onLogout;

  const ProfileTab({super.key, required this.onLogout});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  void _push(BuildContext c, Widget w) =>
      Navigator.of(c).push(MaterialPageRoute<void>(builder: (_) => w));

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
                _featuresCard(context),
                const SizedBox(height: 16),
                _credentialCard(context),
                const SizedBox(height: 20),
                _logout(context),
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
    return ValueListenableBuilder<List<Guardian>>(
      valueListenable: GuardianStore.guardians,
      builder: (context, guardians, _) {
        return AjCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.groups_rounded, color: Aj.berry, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Guardian & Saling Jaga', style: Aj.h(15.5))),
                  AjPill('${guardians.length} Terdaftar', bg: Aj.blush, fg: Aj.berry, size: 11),
                  const SizedBox(width: 6),
                  TextButton.icon(
                    onPressed: () => _push(context, const TambahGuardianScreen()),
                    icon: const Icon(Icons.person_add_alt_1_outlined, size: 16, color: Aj.berry),
                    label: Text('Tambah', style: Aj.b(13, color: Aj.berry, w: FontWeight.w800)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              for (final g in guardians)
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Aj.sand, borderRadius: BorderRadius.circular(18)),
                  child: Row(
                    children: [
                      AjAvatar(name: g.name, size: 44, color: g.color, online: g.online, imageUrl: g.imageUrl),
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
                  onPressed: () => _push(context, const TambahGuardianScreen()),
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
      },
    );
  }

  String _guardianNote(Guardian g) => switch (g.role) {
        'Wali Utama' => 'Akses Peringatan SOS • Respon Cepat',
        'Teman Kos' => 'Barter Pantau Pulang Malam Aktif',
        _ => g.note,
      };

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
          _tile(Icons.vibration_rounded, 'Sensitivitas Sensor Guncang', 'Sedang (Siaga 3x Guncang Layar Mati)', () => _push(context, const ShakeSensorScreen())),
          _tile(Icons.phone_in_talk_outlined, 'Kustomisasi Fake Call', 'Panggilan Samaran Ayah • Tunda 5 dtk', () => _push(context, const FakeCallSettingsScreen())),
          _tile(Icons.volume_up_outlined, 'Sirene & Audio Peringatan', 'Desibel Maksimal (110 dB) • Uji Bunyi', () => _push(context, const SirenAudioScreen()), last: true),
        ],
      ),
    );
  }

  // ── Kredensial & medis ─────────────────────────────────────
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
          _tile(Icons.lock_outline_rounded, 'Privasi & Enkripsi Riwayat', 'Enkripsi E2E • Hapus Otomatis 30 Hari', () => _push(context, const PrivacyScreen())),
          _tile(Icons.headset_mic_outlined, 'Pusat Bantuan & Layanan 24 Jam', 'Hubungi Tim Hotline Darurat amanJalan', () => ajSnack(context, 'Menghubungkan ke hotline…', icon: Icons.headset_mic_outlined)),
          _tile(Icons.info_outline_rounded, 'Versi Aplikasi', 'amanJalan v2.4.1 (Build Siaga Stabil)', () => _push(context, const AppVersionScreen()), trailingText: 'Terbaru', last: true),
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

  // ── Logout ─────────────────────────────────────────────────
  Widget _logout(BuildContext context) {
    return InkWell(
      onTap: () => _confirmLogout(context),
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

  void _confirmLogout(BuildContext context) {
    HapticFeedback.lightImpact();
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        elevation: 8,
        insetPadding: const EdgeInsets.symmetric(horizontal: 38),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: Color(0xFFFDE8E8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Aj.sos,
                  size: 26,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Keluar Akun?',
                style: Aj.h(17, color: Aj.ink),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Apakah Anda yakin ingin keluar dari akun amanJalan?',
                textAlign: TextAlign.center,
                style: Aj.b(12.5, color: Aj.muted, height: 1.35),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Aj.ink,
                        side: const BorderSide(color: Color(0xFFE0D8DA)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text('Batal', style: Aj.b(13, w: FontWeight.w800)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        Navigator.pop(ctx);
                        widget.onLogout();
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Aj.sos,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Keluar',
                        style: Aj.b(13, color: Colors.white, w: FontWeight.w800),
                      ),
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

  void _qr(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const AjSheet(title: 'QR Saling Pantau', child: Center(child: AjQrBox())),
    );
  }
}