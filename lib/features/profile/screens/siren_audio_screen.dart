import 'dart:async';

import 'package:flutter/material.dart';
import 'package:amanjalan/core/theme/aj_theme.dart';
import 'package:amanjalan/core/widgets/aj_common.dart';
import 'package:amanjalan/core/widgets/aj_settings_kit.dart';

/// SIRENE & AUDIO PERINGATAN.
class SirenAudioScreen extends StatefulWidget {
  const SirenAudioScreen({super.key});

  @override
  State<SirenAudioScreen> createState() => _SirenAudioScreenState();
}

class _SirenAudioScreenState extends State<SirenAudioScreen> {
  static const _types = [
    (Icons.local_police_outlined, 'Sirene Polisi / Darurat', 'Melengking berulang 110 dB. Paling efektif memecah konsentrasi pelaku di tempat ramai.', 'Rekomendasi Utama'),
    (Icons.warning_amber_rounded, 'Alarm Kebakaran / Klakson Cepat', 'Nada ritmis menusuk telinga dan kontras tinggi. Cocok untuk lorong sepi atau jembatan penyeberangan.', null),
    (Icons.record_voice_over_outlined, 'Panggilan Tolong Suara Manusia', 'Rekaman lantang "TOLONG! RAMPOK/KEBAKARAN". Memancing respon spontan warga sekitar.', null),
  ];

  int _type = 0;
  bool _maxVol = true;
  bool _countdown = true;
  bool _flash = true;
  bool _playing = false;
  int _left = 3;
  Timer? _t;

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  void _test() {
    if (_playing) return;
    setState(() {
      _playing = true;
      _left = 3;
    });
    _t = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_left <= 1) {
        _t?.cancel();
        setState(() => _playing = false);
        return;
      }
      setState(() => _left--);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AjSubScaffold(
      title: 'Sirene & Audio Peringatan',
      children: [
        // Banner status
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: Aj.sand, borderRadius: BorderRadius.circular(24)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AjPill('SIAGA AKTIF', bg: Aj.mint, fg: Aj.mintDeep, dot: true, size: 11),
                  Row(children: [
                    const Icon(Icons.volume_up_rounded, size: 16, color: Aj.ink),
                    const SizedBox(width: 4),
                    Text('100% Penuh', style: Aj.b(12.5, w: FontWeight.w800)),
                  ]),
                ],
              ),
              const SizedBox(height: 12),
              Text('Perlindungan Audio Nyaring', style: Aj.h(20, color: Aj.plum)),
              const SizedBox(height: 6),
              Text('Sirene darurat menarik perhatian warga sekitar dan mengejutkan pelaku kejahatan seketika saat kamu butuh pertolongan cepat.', style: Aj.b(13.5, color: Aj.muted, height: 1.45)),
              const SizedBox(height: 12),
              Row(children: [
                const Icon(Icons.verified_user_outlined, size: 16, color: Aj.berry),
                const SizedBox(width: 6),
                Expanded(child: Text('Dikalibrasi untuk kebisingan jalanan perkotaan', style: Aj.b(12, color: Aj.berry))),
              ]),
            ],
          ),
        ),
        kGap,

        // Tes sirene
        AjCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              const AjIconBubble(Icons.campaign_outlined, bg: Aj.blush, fg: Aj.berry, size: 60),
              const SizedBox(height: 10),
              Text('Coba Suara Sirene', style: Aj.h(18)),
              const SizedBox(height: 4),
              Text('Pastikan kamu tahu seberapa keras suaranya sebelum situasi genting.', textAlign: TextAlign.center, style: Aj.b(13, color: Aj.muted, height: 1.4)),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: _test,
                style: FilledButton.styleFrom(
                  backgroundColor: Aj.plum,
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
                ),
                icon: Icon(_playing ? Icons.graphic_eq_rounded : Icons.volume_up_rounded, size: 20),
                label: Text(_playing ? 'Berbunyi… ($_left dtk)' : 'Tes Bunyi Sirene (3 Detik)', style: Aj.b(14.5, color: Colors.white, w: FontWeight.w800)),
              ),
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.timer_outlined, size: 14, color: Aj.muted),
                const SizedBox(width: 6),
                Text('Otomatis berhenti setelah 3 detik', style: Aj.b(11.5, color: Aj.muted)),
              ]),
            ],
          ),
        ),
        kGap,

        // Tipe suara
        const AjBlockTitle('Pilihan Tipe Suara', sub: 'Pilih karakter audio yang paling efektif'),
        for (var i = 0; i < _types.length; i++)
          AjOptionCard(
            icon: _types[i].$1,
            title: _types[i].$2,
            sub: _types[i].$3,
            badge: _types[i].$4,
            selected: _type == i,
            onTap: () => setState(() => _type = i),
          ),
        kGap,

        // Otomatisasi
        AjCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Icon(Icons.tune_rounded, color: Aj.plum, size: 20),
                const SizedBox(width: 8),
                Text('Otomatisasi & Keamanan', style: Aj.h(17, color: Aj.plum)),
              ]),
              const SizedBox(height: 6),
              AjSwitchRow(boxed: false, title: 'Maksimumkan Volume Otomatis', sub: 'Tetap berbunyi keras meski ponsel dalam mode Hening atau Do Not Disturb.', value: _maxVol, onChanged: (v) => setState(() => _maxVol = v)),
              AjSwitchRow(boxed: false, title: 'Hitung Mundur 5 Detik', sub: 'Memberi jeda aman untuk membatalkan jika tombol tak sengaja tersentuh.', value: _countdown, onChanged: (v) => setState(() => _countdown = v)),
              AjSwitchRow(boxed: false, title: 'Lampu Kilat Mengikuti Irama', sub: 'Flash kamera belakang berkedip cepat untuk visibilitas malam hari.', value: _flash, onChanged: (v) => setState(() => _flash = v)),
            ],
          ),
        ),
        kGap,

        // Peringatan suara khusus
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: Aj.sand, borderRadius: BorderRadius.circular(24)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AjIconBubble(Icons.mic_none_rounded, bg: Aj.blush, fg: Aj.berry, size: 44),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Peringatan Suara Khusus', style: Aj.h(16))),
                  const AjPill('Opsional', bg: Color(0xFFE9E3E1), fg: Aj.muted, size: 10.5),
                ],
              ),
              const SizedBox(height: 8),
              Text('Rekam kalimat peringatan tegas pribadimu, atau gunakan kalimat bawaan:', style: Aj.b(12.5, color: Aj.muted, height: 1.4)),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                child: Text('"Saya sedang dipantau langsung oleh polisi & guardian!"', style: Aj.b(13, height: 1.35).copyWith(fontStyle: FontStyle.italic)),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(flex: 3, child: AjSoftButton(icon: Icons.fiber_manual_record_outlined, label: 'Rekam Suara Sendiri', bg: const Color(0xFFE9E3E1), fg: Aj.ink, onTap: () => ajSnack(context, 'Perekam suara dibuka (simulasi)', icon: Icons.mic_rounded))),
                  const SizedBox(width: 10),
                  Expanded(flex: 2, child: AjSoftButton(icon: Icons.restart_alt_rounded, label: 'Standar', bg: Colors.white, fg: Aj.ink, onTap: () => ajSnack(context, 'Kembali ke kalimat standar', icon: Icons.restart_alt_rounded))),
                ],
              ),
            ],
          ),
        ),
        kGap,
        AjSaveButton('Simpan Pengaturan Audio', onTap: () {
          ajSnack(context, 'Pengaturan audio disimpan', icon: Icons.check_circle_outline_rounded);
          Navigator.pop(context);
        }),
        const AjFootnote(Icons.lock_outline_rounded, 'Sirene tidak akan bersuara saat mode SOS Senyap diaktifkan.'),
      ],
    );
  }
}