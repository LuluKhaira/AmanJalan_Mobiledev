import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:amanjalan/core/theme/aj_theme.dart';
import 'package:amanjalan/core/widgets/aj_common.dart';
import 'package:amanjalan/features/perjalanan/data/perjalanan_data.dart';
import 'package:amanjalan/features/perjalanan/perjalanan_actions.dart';
import 'package:amanjalan/features/perjalanan/widgets/pj_widgets.dart';

/// Laporan kejadian: pilih kategori → ceritakan → kirim.
class LaporanKejadianScreen extends StatefulWidget {
  const LaporanKejadianScreen({super.key});

  @override
  State<LaporanKejadianScreen> createState() => _LaporanKejadianScreenState();
}

class _LaporanKejadianScreenState extends State<LaporanKejadianScreen> {
  int? _selected;
  bool _withLocation = true;
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _send() {
    if (_selected == null) {
      ajSnack(context, 'Pilih jenis kejadian dulu ya', icon: Icons.warning_amber_rounded);
      return;
    }
    HapticFeedback.mediumImpact();
    final type = kIncidentTypes[_selected!];
    final id = 'LP-${DateTime.now().millisecondsSinceEpoch % 100000}';
    showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AjSheet(
        title: 'Laporan Terkirim',
        child: Column(
          children: [
            const AjIconBubble(Icons.check_rounded, bg: Aj.mint, fg: Aj.mintDeep, size: 64),
            const SizedBox(height: 12),
            Text('Terima kasih sudah melapor', style: Aj.h(16)),
            const SizedBox(height: 4),
            Text('${type.title} • No. $id', style: Aj.b(12.5, color: Aj.muted)),
            const SizedBox(height: 4),
            Text('Tim AmanJalan akan menindaklanjuti laporanmu.', textAlign: TextAlign.center, style: Aj.b(12.5, color: Aj.muted)),
            const SizedBox(height: 18),
            PjButton('Selesai', onTap: () {
              Navigator.pop(ctx);
              Navigator.of(context).pop();
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Aj.bg,
      appBar: pjAppBar(context, 'Laporan Kejadian'),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              children: [
                AjCard(
                  color: Aj.blush,
                  shadow: false,
                  radius: 18,
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: Aj.berry),
                      const SizedBox(width: 10),
                      Expanded(child: Text('Laporkan kejadian yang kamu alami agar bisa ditindaklanjuti dengan cepat.', style: Aj.b(12.5, color: Aj.berry, w: FontWeight.w700, height: 1.3))),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => pjOpenEmergency(context),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text('Dalam bahaya sekarang? Buka SOS Darurat →', style: Aj.b(12.5, color: Aj.sos, w: FontWeight.w800)),
                  ),
                ),
                const PjStep(1, 'Jenis Kejadian'),
                for (var i = 0; i < kIncidentTypes.length; i++) _typeTile(i),
                const SizedBox(height: 10),
                const PjStep(2, 'Ceritakan Singkat', hint: 'opsional'),
                TextField(
                  controller: _ctrl,
                  maxLines: 4,
                  maxLength: 300,
                  style: Aj.b(13.5),
                  decoration: InputDecoration(
                    hintText: 'Apa yang terjadi, di mana, dan kapan?',
                    hintStyle: Aj.b(13, color: Aj.muted),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Aj.line)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Aj.line)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Aj.plum, width: 1.6)),
                  ),
                ),
                const SizedBox(height: 6),
                const PjStep(3, 'Lokasi'),
                AjCard(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  child: Row(
                    children: [
                      const AjIconBubble(Icons.my_location_rounded, bg: Aj.sand, fg: Aj.berry, size: 38),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Sertakan lokasi saat ini', style: Aj.b(13.5, w: FontWeight.w800)),
                            Text('Membantu tim menemukan titik kejadian', style: Aj.b(11.5, color: Aj.muted)),
                          ],
                        ),
                      ),
                      Switch(value: _withLocation, activeColor: Aj.plum, onChanged: (v) => setState(() => _withLocation = v)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(20, 12, 20, 14 + MediaQuery.of(context).padding.bottom),
            decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, -4))]),
            child: PjButton('Kirim Laporan', icon: Icons.send_rounded, onTap: _send),
          ),
        ],
      ),
    );
  }

  Widget _typeTile(int i) {
    final t = kIncidentTypes[i];
    final sel = _selected == i;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _selected = i);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: sel ? Aj.blush : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: sel ? Aj.berry : Aj.line, width: sel ? 1.8 : 1.2),
          ),
          child: Row(
            children: [
              AjIconBubble(t.icon, bg: t.bg, fg: t.fg, size: 42),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.title, style: Aj.b(14, w: FontWeight.w800)),
                    Text(t.subtitle, style: Aj.b(11.5, color: Aj.muted)),
                  ],
                ),
              ),
              Icon(sel ? Icons.check_circle_rounded : Icons.chevron_right_rounded, color: sel ? Aj.berry : Aj.muted),
            ],
          ),
        ),
      ),
    );
  }
}
