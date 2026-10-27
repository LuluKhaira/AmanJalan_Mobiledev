import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:amanjalan/core/theme/aj_theme.dart';
import 'package:amanjalan/core/widgets/aj_common.dart';
import 'package:amanjalan/core/widgets/aj_settings_kit.dart';

class _Sens {
  final IconData icon;
  final String title;
  final String sub;
  final int target;
  final String? badge;
  const _Sens(this.icon, this.title, this.sub, this.target, [this.badge]);
}

/// SENSOR GUNCANG (Shake to SOS).
class ShakeSensorScreen extends StatefulWidget {
  const ShakeSensorScreen({super.key});

  @override
  State<ShakeSensorScreen> createState() => _ShakeSensorScreenState();
}

class _ShakeSensorScreenState extends State<ShakeSensorScreen> {
  static const _opts = [
    _Sens(Icons.verified_outlined, 'Standar (Disarankan)', '3× Guncangan tegas. Pas untuk jalan kaki malam & naik ojek tanpa takut kepencet.', 3, 'Paling Pas'),
    _Sens(Icons.bolt_rounded, 'Mudah Terpicu', '2× Guncangan cepat. Cocok saat lewat lorong gelap, gang sepi, atau area sangat rawan.', 2),
    _Sens(Icons.fitness_center_rounded, 'Ketat / Ekstra Kuat', '4× Hentakan kuat. Cocok jika kamu sering lari pagi atau naik transportasi umum bergelombang.', 4),
  ];

  bool _on = true;
  int _sens = 0;
  bool _sendLoc = true;
  bool _vibrate = true;
  bool _siren = false;

  bool _testing = false;
  int _hits = 0;
  int _left = 5;
  Timer? _t;

  int get _target => _opts[_sens].target;

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  void _startTest() {
    _t?.cancel();
    setState(() {
      _testing = true;
      _hits = 0;
      _left = 5;
    });
    _t = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_left <= 1) {
        _stopTest();
        ajSnack(context, 'Waktu habis, coba lagi ya', icon: Icons.timer_off_outlined);
        return;
      }
      setState(() => _left--);
    });
  }

  void _stopTest() {
    _t?.cancel();
    if (mounted) setState(() => _testing = false);
  }

  void _shake() {
    if (!_testing) return;
    HapticFeedback.mediumImpact();
    setState(() => _hits++);
    if (_hits >= _target) {
      _stopTest();
      ajSnack(context, 'Terdeteksi! Jika nyata, SOS akan terkirim', icon: Icons.check_circle_outline_rounded);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AjSubScaffold(
      title: 'Sensor Guncang (Shake SOS)',
      children: [
        // Master switch
        AjCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const AjIconBubble(Icons.vibration_rounded, bg: Aj.blush, fg: Aj.berry, size: 56),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Guncang untuk SOS', style: Aj.h(18)),
                        const SizedBox(height: 4),
                        Row(children: [
                          Container(width: 8, height: 8, decoration: BoxDecoration(color: _on ? const Color(0xFF1F6B45) : const Color(0xFFD5CDD0), shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          Text(_on ? 'Status: Aktif Siaga' : 'Status: Nonaktif', style: Aj.b(12.5, w: FontWeight.w700)),
                        ]),
                      ],
                    ),
                  ),
                  AjToggle(value: _on, onChanged: (v) => setState(() => _on = v)),
                ],
              ),
              const SizedBox(height: 14),
              Text('Kocok ponsel 3 kali dengan kuat saat darurat untuk langsung memanggil bantuan tanpa perlu membuka layar atau menarik perhatian.', style: Aj.b(13.5, color: Aj.muted, height: 1.45)),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Aj.sand, borderRadius: BorderRadius.circular(14)),
                child: Row(
                  children: [
                    const Icon(Icons.verified_user_outlined, color: Aj.berry, size: 20),
                    const SizedBox(width: 10),
                    Expanded(child: Text('Terhubung ke 3 Kontak Penjaga & layanan darurat amanJalan.', style: Aj.b(12, color: Aj.muted, height: 1.35))),
                  ],
                ),
              ),
            ],
          ),
        ),
        kGap,

        Opacity(
          opacity: _on ? 1 : .45,
          child: IgnorePointer(
            ignoring: !_on,
            child: Column(
              children: [
                // Sensitivitas
                AjCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AjBlockTitle('Pilihan Sensitivitas', sub: 'Pilih yang paling pas dengan rutinitas harianmu'),
                      for (var i = 0; i < _opts.length; i++)
                        AjOptionCard(
                          icon: _opts[i].icon,
                          title: _opts[i].title,
                          sub: _opts[i].sub,
                          badge: _opts[i].badge,
                          selected: _sens == i,
                          onTap: () => setState(() {
                            _sens = i;
                            _stopTest();
                            _hits = 0;
                          }),
                        ),
                    ],
                  ),
                ),
                kGap,

                // Uji coba
                AjCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const AjIconBubble(Icons.smartphone_rounded, bg: Aj.blush, fg: Aj.berry, size: 40),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Uji Coba Guncangan', style: Aj.h(16)),
                                Text('Coba rasakan kekuatannya sebelum bepergian', style: Aj.b(12.5, color: Aj.muted)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(color: Aj.sand, borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              child: const Icon(Icons.vibration_rounded, color: Aj.plum, size: 28),
                            ),
                            const SizedBox(height: 10),
                            Text(_testing ? 'Goyangkan sekarang! ($_left dtk)' : 'Coba Goyangkan HP Sekarang', style: Aj.b(14.5, w: FontWeight.w800)),
                            const SizedBox(height: 2),
                            Text('Target: $_hits dari $_target Guncangan', style: Aj.b(13, color: Aj.muted)),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                for (var i = 1; i <= _target; i++)
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    margin: const EdgeInsets.symmetric(horizontal: 6),
                                    width: 40,
                                    height: 40,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(color: i <= _hits ? Aj.plum : const Color(0xFFE9E3E1), shape: BoxShape.circle),
                                    child: Text('$i', style: Aj.b(14, color: i <= _hits ? Colors.white : Aj.ink, w: FontWeight.w800)),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: AjSoftButton(icon: Icons.play_circle_outline_rounded, label: _testing ? 'Mengulang…' : 'Mulai Tes (5 dtk)', onTap: _startTest)),
                          const SizedBox(width: 10),
                          Expanded(child: AjSoftButton(icon: Icons.vibration_rounded, label: 'Simulasi Goyang', bg: Aj.blush, fg: Aj.berry, enabled: _testing, onTap: _shake)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text('Layar akan bergetar lembut saat sensor berhasil mendeteksi guncanganmu.', style: Aj.b(11.5, color: Aj.muted, height: 1.4)),
                    ],
                  ),
                ),
                kGap,

                // Tindakan otomatis
                AjCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AjBlockTitle('Tindakan Otomatis Saat Terguncang', sub: 'Bantuan langsung yang diaktifkan sistem'),
                      AjSwitchRow(icon: Icons.my_location_rounded, iconColor: Aj.berry, title: 'Kirim Lokasi ke Guardian', sub: 'Otomatis kirim koordinat GPS & pesan WhatsApp darurat.', value: _sendLoc, onChanged: (v) => setState(() => _sendLoc = v)),
                      AjSwitchRow(icon: Icons.vibration_rounded, title: 'Getar Konfirmasi 5 Detik', sub: 'Beri waktu jeda untuk membatalkan jika tak sengaja terguncang.', value: _vibrate, onChanged: (v) => setState(() => _vibrate = v)),
                      AjSwitchRow(icon: Icons.volume_up_rounded, iconColor: Aj.sos, title: 'Bunyikan Sirene Keras', sub: 'Tambahan alarm suara untuk menarik perhatian orang terdekat.', value: _siren, onChanged: (v) => setState(() => _siren = v)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        kGap,
        AjSaveButton('Simpan Pengaturan', onTap: () {
          ajSnack(context, 'Pengaturan guncangan disimpan', icon: Icons.check_circle_outline_rounded);
          Navigator.pop(context);
        }),
        const AjFootnote(Icons.shield_outlined, 'Sensor tetap aktif meski ponsel di dalam saku atau layar terkunci.'),
      ],
    );
  }
}