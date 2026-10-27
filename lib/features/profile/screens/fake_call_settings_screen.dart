import 'package:flutter/material.dart';
import 'package:amanjalan/core/theme/aj_theme.dart';
import 'package:amanjalan/core/widgets/aj_common.dart';
import 'package:amanjalan/core/widgets/aj_settings_kit.dart';

/// PENGATURAN PANGGILAN SAMARAN (Fake Call).
/// Layar panggilan masuknya sendiri ada di features/fake_call/fake_call_screen.dart.
class FakeCallSettingsScreen extends StatefulWidget {
  const FakeCallSettingsScreen({super.key});

  @override
  State<FakeCallSettingsScreen> createState() => _FakeCallSettingsScreenState();
}

class _FakeCallSettingsScreenState extends State<FakeCallSettingsScreen> {
  static const _callers = [
    ('Ayah', '"Ayah jemput sekarang"', Color(0xFFF4E6F0)),
    ('Ibu', '"Cepat pulang makan, Nak"', Color(0xFFF0F4E6)),
    ('Teman Dekat', '"Udah di depan halte nih"', Color(0xFFE6F0F4)),
    ('Pos Satpam', '"Patroli kawasan sektor"', Color(0xFFEFE9E5)),
  ];
  static const _delays = [('Instan', '0 dtk'), ('5 dtk', 'Disarankan'), ('15 dtk', 'Santai'), ('30 dtk', 'Terencana')];

  bool _enabled = true;
  int _caller = 0;
  int _delay = 1;
  bool _power = true;
  bool _chat = true;

  @override
  Widget build(BuildContext context) {
    return AjSubScaffold(
      title: 'Panggilan Samaran',
      children: [
        // Master switch
        AjCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const AjIconBubble(Icons.phone_in_talk_rounded, bg: Aj.blushDeep, fg: Aj.sos, size: 54),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Panggilan Samaran', style: Aj.h(18)),
                    Text('Alasan pamit instan saat situasi cang…', maxLines: 1, overflow: TextOverflow.ellipsis, style: Aj.b(12.5, color: Aj.muted)),
                  ],
                ),
              ),
              AjToggle(value: _enabled, onChanged: (v) => setState(() => _enabled = v)),
            ],
          ),
        ),
        kGap,

        Opacity(
          opacity: _enabled ? 1 : .45,
          child: IgnorePointer(
            ignoring: !_enabled,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Siapa yang menelepon
                Row(
                  children: [
                    Text('Siapa yang Menelepon?', style: Aj.h(16, color: Aj.plum)),
                    const SizedBox(width: 6),
                    Text('(Pilih Satu)', style: Aj.b(12, color: Aj.berry)),
                    const Spacer(),
                    InkWell(
                      onTap: () => ajSnack(context, 'Pilih foto penelepon (simulasi)', icon: Icons.photo_camera_outlined),
                      child: Row(children: [
                        const Icon(Icons.edit_outlined, size: 14, color: Aj.berry),
                        const SizedBox(width: 4),
                        Text('Ubah Foto', style: Aj.b(12.5, color: Aj.berry, w: FontWeight.w700)),
                      ]),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                for (var r = 0; r < _callers.length; r += 2)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Expanded(child: _callerCard(r)),
                        const SizedBox(width: 12),
                        Expanded(child: _callerCard(r + 1)),
                      ],
                    ),
                  ),
                const SizedBox(height: 6),

                // Waktu dering
                Row(children: [
                  const Icon(Icons.schedule_rounded, color: Aj.berry, size: 20),
                  const SizedBox(width: 8),
                  Text('Waktu Dering', style: Aj.h(16, color: Aj.plum)),
                ]),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (var i = 0; i < _delays.length; i++)
                        GestureDetector(
                          onTap: () => setState(() => _delay = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(color: _delay == i ? Aj.plum : Colors.white, borderRadius: BorderRadius.circular(16)),
                            child: Column(children: [
                              Text(_delays[i].$1, style: Aj.b(13.5, color: _delay == i ? Colors.white : Aj.ink, w: FontWeight.w800)),
                              Text(_delays[i].$2, style: Aj.b(11.5, color: _delay == i ? const Color(0xCCFFFFFF) : Aj.muted)),
                            ]),
                          ),
                        ),
                    ],
                  ),
                ),
                kGap,

                // Pemicu
                Row(children: [
                  const Icon(Icons.touch_app_outlined, color: Aj.berry, size: 20),
                  const SizedBox(width: 8),
                  Text('Pemicu & Detail Senyap', style: Aj.h(16, color: Aj.plum)),
                ]),
                const SizedBox(height: 12),
                AjCard(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  child: Column(
                    children: [
                      _trigger(Icons.power_settings_new_rounded, 'Tekan Tombol Power 3×', 'Bisa dari saku tanpa buka layar', _power, (v) => setState(() => _power = v)),
                      const Divider(height: 1, color: Aj.line),
                      _trigger(Icons.record_voice_over_outlined, 'Suara Obrolan Otomatis', 'Ada suara natural saat diangkat', _chat, (v) => setState(() => _chat = v)),
                    ],
                  ),
                ),
                kGap,

                // Coba deringkan
                InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: () => ajSnack(context, 'Panggilan dari ${_callers[_caller].$1} akan berdering ${_delay == 0 ? 'sekarang' : _delays[_delay].$1 + ' lagi'}', icon: Icons.phone_in_talk_rounded),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Aj.blushDeep, borderRadius: BorderRadius.circular(22)),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(color: Color(0x33FFFFFF), shape: BoxShape.circle),
                          child: const Icon(Icons.play_arrow_rounded, color: Aj.berry),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Coba Deringkan Sekarang', style: Aj.b(14.5, color: Aj.berry, w: FontWeight.w800)),
                              Text('Simulasi layar panggilan dalam 5 detik', style: Aj.b(12, color: Aj.berry)),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: Aj.berry),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        kGap,
        AjSaveButton('Simpan Pengaturan', onTap: () {
          ajSnack(context, 'Pengaturan panggilan samaran disimpan', icon: Icons.check_circle_outline_rounded);
          Navigator.pop(context);
        }),
        const AjFootnote(Icons.circle, '100% Berjalan Offline • Bebas Pulsa & Kuota'),
      ],
    );
  }

  Widget _callerCard(int i) {
    final c = _callers[i];
    final sel = _caller == i;
    return GestureDetector(
      onTap: () => setState(() => _caller = i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: sel ? Aj.plum : Colors.transparent, width: 2),
          boxShadow: Aj.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (i == 3)
                  const AjIconBubble(Icons.shield_rounded, bg: Color(0xFFE9E3E1), fg: Aj.plum, size: 52)
                else
                  AjAvatar(name: c.$1, size: 52, color: c.$3),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: sel ? Aj.plum : const Color(0xFFEDE7E5)),
                  child: sel ? const Icon(Icons.check_rounded, size: 15, color: Colors.white) : null,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(c.$1, style: Aj.h(16)),
            const SizedBox(height: 2),
            Text(c.$2, maxLines: 1, overflow: TextOverflow.ellipsis, style: Aj.b(12, color: Aj.muted)),
          ],
        ),
      ),
    );
  }

  Widget _trigger(IconData icon, String title, String sub, bool v, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          AjIconBubble(icon, bg: Aj.sand, fg: Aj.muted, size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Aj.b(14.5, w: FontWeight.w800)),
                Text(sub, style: Aj.b(12, color: Aj.muted)),
              ],
            ),
          ),
          AjToggle(value: v, onChanged: onChanged),
        ],
      ),
    );
  }
}