import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:amanjalan/core/theme/aj_theme.dart';
import 'package:amanjalan/features/profile/screens/contact_us_screen.dart';
import 'package:amanjalan/features/profile/widgets/profile_kit.dart';

class _Faq {
  final String cat;
  final String q;
  final String a;

  const _Faq(this.cat, this.q, this.a);
}

const _faqs = <_Faq>[
  _Faq('Keamanan', 'Bagaimana cara melapor kejadian?', 'Buka Beranda, ketuk "Lapor", lalu pilih jenis kejadian (lampu mati, area sepi, orang mencurigakan, atau fasilitas rusak). Laporan langsung diteruskan ke pengelola kampus.'),
  _Faq('Keamanan', 'Apa itu fitur Fake Call?', 'Fake Call membuat panggilan masuk palsu dari kontak pilihanmu (Ayah, Ibu, Teman, atau Pos Satpam) sehingga kamu punya alasan untuk pergi dari situasi yang tidak nyaman.'),
  _Faq('Akun', 'Bagaimana cara mengubah PIN?', 'Buka Profil, pilih Keamanan, lalu ketuk "Ubah PIN". Masukkan PIN lama dan PIN baru 6 digit.'),
  _Faq('Perjalanan', 'Kenapa lokasi saya tidak terdeteksi?', 'Pastikan izin lokasi aktif untuk AmanJalan dan GPS menyala. Coba pindah ke area terbuka, lalu muat ulang peta.'),
  _Faq('Keamanan', 'Apa yang harus dilakukan jika terjadi darurat?', 'Tekan tombol SOS di Beranda atau guncang HP 3 kali. Lokasimu langsung dikirim ke semua Guardian dan PAMDAL.'),
  _Faq('Keamanan', 'Bagaimana cara menghubungi PAMDAL Polibatam?', 'Ketuk "Panggil" pada kartu PAMDAL di bagian bawah Beranda, atau hubungi (0778) 469858 Ext. 102 (24 jam).'),
  _Faq('Perjalanan', 'Apa itu Streak Aman?', 'Streak Aman menghitung berapa hari berturut-turut kamu check-in. Perisai Streak otomatis menyelamatkan streak kalau kamu lupa 1 hari.'),
];

const _cats = ['Semua', 'Akun', 'Perjalanan', 'Keamanan'];

/// BANTUAN & FAQ (7/10)
class HelpFaqScreen extends StatefulWidget {
  const HelpFaqScreen({super.key});

  @override
  State<HelpFaqScreen> createState() => _HelpFaqScreenState();
}

class _HelpFaqScreenState extends State<HelpFaqScreen> {
  String _cat = 'Semua';
  String _query = '';
  int? _open;

  @override
  Widget build(BuildContext context) {
    final list = _faqs.where((f) {
      final okCat = _cat == 'Semua' || f.cat == _cat;
      final okQ = _query.isEmpty || f.q.toLowerCase().contains(_query) || f.a.toLowerCase().contains(_query);
      return okCat && okQ;
    }).toList();

    return PfScaffold(
      title: 'Bantuan & FAQ',
      footer: PfBanner(
        owl: pfOwlPhone,
        title: 'Masih butuh bantuan?',
        sub: 'Hubungi tim kami melalui Live Chat 24/7.',
        button: 'Chat Sekarang',
        onButton: () => pfPush(context, const ContactUsScreen()),
      ),
      children: [
        TextField(
          onChanged: (v) => setState(() {
            _query = v.trim().toLowerCase();
            _open = null;
          }),
          style: Aj.b(14.5, w: FontWeight.w600),
          decoration: InputDecoration(
            hintText: 'Cari pertanyaan...',
            hintStyle: Aj.b(14, color: Aj.muted),
            prefixIcon: const Icon(Icons.search_rounded, color: Aj.muted),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Color(0xFFF3E1E9), width: 1.2)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Aj.plum, width: 1.6)),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _cats.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final sel = _cats[i] == _cat;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _cat = _cats[i];
                    _open = null;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: sel ? Aj.plum : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: sel ? Aj.plum : const Color(0xFFF3E1E9)),
                  ),
                  child: Text(_cats[i], style: Aj.b(13, color: sel ? Colors.white : Aj.muted, w: FontWeight.w800)),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        if (list.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 36),
            child: Column(
              children: [
                const PfOwl(pfOwlThinking, size: 96, fallback: Icons.search_off_rounded),
                const SizedBox(height: 8),
                Text('Pertanyaan tidak ditemukan', style: Aj.h(15)),
                const SizedBox(height: 2),
                Text('Coba kata kunci lain atau hubungi tim kami.', style: Aj.b(12.5, color: Aj.muted)),
              ],
            ),
          )
        else
          PfGroup(
            children: [
              for (var i = 0; i < list.length; i++)
                _FaqTile(
                  faq: list[i],
                  open: _open == i,
                  onTap: () => setState(() => _open = _open == i ? null : i),
                ),
            ],
          ),
      ],
    );
  }
}

class _FaqTile extends StatelessWidget {
  final _Faq faq;
  final bool open;
  final VoidCallback onTap;

  const _FaqTile({required this.faq, required this.open, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(faq.q, style: Aj.b(14, w: FontWeight.w800, height: 1.3))),
                const SizedBox(width: 8),
                AnimatedRotation(
                  turns: open ? 0.25 : 0,
                  duration: const Duration(milliseconds: 220),
                  child: const Icon(Icons.chevron_right_rounded, color: Aj.muted),
                ),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: open
                  ? Padding(
                      padding: const EdgeInsets.only(top: 10, right: 20),
                      child: Text(faq.a, style: Aj.b(13, color: Aj.muted, height: 1.5)),
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }
}