import 'package:flutter/material.dart';
import 'package:amanjalan/core/theme/aj_theme.dart';
import 'package:amanjalan/core/widgets/aj_common.dart';
import 'package:amanjalan/core/widgets/aj_settings_kit.dart';

/// PRIVASI & ENKRIPSI RIWAYAT.
class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  static const _retention = [
    ('7 Hari', 'Paling ketat, cocok untuk mobilitas harian singkat', null),
    ('30 Hari', 'Keseimbangan ideal antara bukti darurat & kerahasiaan', 'Rekomendasi Aman'),
    ('90 Hari', 'Arsip lebih panjang untuk pelaporan berulang', null),
    ('Simpan Manual', 'Hanya dihapus saat Anda menekan tombol hapus', null),
  ];

  int _ret = 1;
  bool _cleanSensor = true;
  bool _fuzzy = true;
  bool _telemetry = true;

  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Hapus seluruh riwayat?', style: Aj.h(17)),
        content: Text('Tindakan ini permanen dan tidak bisa dipulihkan.', style: Aj.b(13.5, color: Aj.muted)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Batal', style: Aj.b(14, color: Aj.muted, w: FontWeight.w800))),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Aj.sos),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Hapus', style: Aj.b(14, color: Colors.white, w: FontWeight.w800)),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      ajSnack(context, 'Seluruh riwayat dihapus (simulasi)', icon: Icons.delete_outline_rounded);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AjSubScaffold(
      title: 'Privasi & Enkripsi Riwayat',
      children: [
        // Banner zero-knowledge
        AjCard(
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  const AjIconBubble(Icons.lock_rounded, bg: Aj.blush, fg: Aj.plum, size: 56),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.check_circle_rounded, color: Aj.mintDeep, size: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ZERO-KNOWLEDGE PROTOCOL', style: Aj.b(11, color: Aj.berry, w: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text('Data Perjalanan Terenkripsi End-to-End', style: Aj.h(18, height: 1.25)),
                    const SizedBox(height: 6),
                    Text('Hanya Anda dan Guardian yang diberi izin yang dapat melihat jejak GPS Anda secara langsung. Tim teknis amanJalan sama sekali tidak dapat mengakses riwayat lokasi pribadi Anda.', style: Aj.b(12.5, color: Aj.muted, height: 1.45)),
                  ],
                ),
              ),
            ],
          ),
        ),
        kGap,

        // Kunci
        const AjBlockTitle('Kunci & Proteksi Perangkat'),
        AjCard(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const AjIconBubble(Icons.enhanced_encryption_outlined, bg: Aj.sand, fg: Aj.muted, size: 46),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AES-256 GCM Hardware', maxLines: 1, overflow: TextOverflow.ellipsis, style: Aj.b(14, w: FontWeight.w800)),
                    Text('Apple Secure Enclave / Android Keystore', maxLines: 1, overflow: TextOverflow.ellipsis, style: Aj.b(11.5, color: Aj.muted)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const AjPill('Terenkripsi Penuh', bg: Aj.mint, fg: Aj.mintDeep, icon: Icons.lock_outline_rounded, size: 10.5),
            ],
          ),
        ),
        kGap,

        // Retensi
        const AjBlockTitle('Retensi & Masa Simpan Jejak', sub: 'Kendalikan seberapa lama riwayat perjalanan disimpan di perangkat.'),
        AjCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
                child: Text('Hapus Otomatis Riwayat Lokasi', style: Aj.b(13, w: FontWeight.w800)),
              ),
              for (var i = 0; i < _retention.length; i++)
                GestureDetector(
                  onTap: () => setState(() => _ret = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: _ret == i ? const Color(0xFFF3EAF8) : Aj.sand, borderRadius: BorderRadius.circular(14)),
                    child: Row(
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: _ret == i ? Aj.plum : const Color(0xFFE2DBDE)),
                          child: _ret == i ? const Icon(Icons.check_rounded, size: 14, color: Colors.white) : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Text(_retention[i].$1, style: Aj.b(14.5, w: FontWeight.w800)),
                                if (_retention[i].$3 != null) ...[const SizedBox(width: 8), AjPill(_retention[i].$3!, bg: Aj.blush, fg: Aj.berry, size: 10)],
                              ]),
                              Text(_retention[i].$2, style: Aj.b(12, color: Aj.muted, height: 1.3)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        kGap,
        AjCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const AjIconBubble(Icons.mic_off_outlined, bg: Aj.blush, fg: Aj.berry, size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bersihkan Sensor & Audio Usai Sesi', style: Aj.b(14.5, w: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text('Rekaman suara sekitar dan data akselerometer darurat otomatis dimusnahkan 10 menit setelah status aman dikonfirmasi.', style: Aj.b(12, color: Aj.muted, height: 1.35)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              AjToggle(value: _cleanSensor, onChanged: (v) => setState(() => _cleanSensor = v)),
            ],
          ),
        ),
        kGap,

        // Privasi lokasi
        const AjBlockTitle('Privasi Lokasi & Komunitas', sub: 'Perlindungan alamat rumah serta kontribusi keamanan kolektif.'),
        AjCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _toggleRow(Icons.blur_on_rounded, const Color(0xFFF1E4F7), Aj.plum, 'Samarkan Koordinat Rumah (Fuzzy Radius)', 'Mengaburkan titik pemberhentian sejauh 200m pada log riwayat agar lokasi pasti kos/rumah tidak terekspos jika ponsel dipinjam.', _fuzzy, (v) => setState(() => _fuzzy = v)),
              const Divider(height: 24, color: Aj.line),
              _toggleRow(Icons.share_location_rounded, Aj.mint, Aj.mintDeep, 'Telemetri Jalur Rawan Batam', 'Menyumbang data kecepatan & titik minim penerangan (tanpa identitas) untuk memperingatkan pengguna perempuan lain di sekitar Batam Center, Nagoya, dan Sekupang.', _telemetry, (v) => setState(() => _telemetry = v), tag: 'Anonim'),
            ],
          ),
        ),
        kGap,

        // Arsip
        const AjBlockTitle('Kendali Arsip Mandiri'),
        AjCard(
          padding: const EdgeInsets.all(14),
          onTap: () => ajSnack(context, 'Menyiapkan berkas .ZIP (simulasi)', icon: Icons.download_rounded),
          child: Row(
            children: [
              const AjIconBubble(Icons.download_rounded, bg: Aj.sand, fg: Aj.muted, size: 46),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Unduh Salinan Data Saya (.ZIP)', style: Aj.b(14, w: FontWeight.w800)),
                    Text('Termasuk berkas GPS terenkripsi dan log riwayat rute', style: Aj.b(12, color: Aj.muted, height: 1.3)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Aj.muted),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFFFDEBEC), borderRadius: BorderRadius.circular(22)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AjIconBubble(Icons.delete_forever_outlined, bg: Aj.sosSoft, fg: Aj.sos, size: 44),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hapus Seluruh Riwayat Sekarang', style: Aj.b(14.5, color: Aj.sos, w: FontWeight.w800)),
                        const SizedBox(height: 2),
                        Text('Tindakan instan dan permanen. Seluruh log perjalanan, koordinat, dan rekaman audio darurat akan dihapus dari penyimpanan tanpa bisa dipulihkan.', style: Aj.b(12, color: Aj.muted, height: 1.35)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: _confirmDelete,
                style: FilledButton.styleFrom(
                  backgroundColor: Aj.sos,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                icon: const Icon(Icons.delete_sweep_outlined, size: 20),
                label: Text('Musnahkan Semua Data Riwayat', style: Aj.b(14, color: Colors.white, w: FontWeight.w800)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.verified_user_outlined, size: 15, color: Aj.ink),
            const SizedBox(width: 6),
            Text('Kepatuhan Regulasi Privasi Indonesia', style: Aj.b(12, w: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: 4),
        Text('Sesuai dengan ketentuan Undang-Undang Perlindungan Data Pribadi (UU PDP No. 27/2022). Hak akses, retensi, dan penghapusan data sepenuhnya berada di bawah kendali Anda.', textAlign: TextAlign.center, style: Aj.b(11.5, color: Aj.muted, height: 1.45)),
      ],
    );
  }

  Widget _toggleRow(IconData icon, Color bg, Color fg, String title, String sub, bool v, ValueChanged<bool> onChanged, {String? tag}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AjIconBubble(icon, bg: bg, fg: fg, size: 44),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Aj.b(14, w: FontWeight.w800, height: 1.25)),
              if (tag != null) ...[const SizedBox(height: 4), AjPill(tag, bg: Aj.mint, fg: Aj.mintDeep, size: 10)],
              const SizedBox(height: 3),
              Text(sub, style: Aj.b(12, color: Aj.muted, height: 1.35)),
            ],
          ),
        ),
        const SizedBox(width: 10),
        AjToggle(value: v, onChanged: onChanged),
      ],
    );
  }
} 