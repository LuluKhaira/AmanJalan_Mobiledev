import 'package:flutter/material.dart';
import 'package:amanjalan/core/theme/aj_theme.dart';
import 'package:amanjalan/core/widgets/aj_common.dart';

/// Tukar proteksi: QR, link undangan, dan daftar lingkaran timbal-balik.
class TukarProteksiCard extends StatelessWidget {
  const TukarProteksiCard({super.key});

  @override
  Widget build(BuildContext context) {
    Widget friend(String name, String tag, bool active, bool two) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: active ? Aj.plum : const Color(0xFFD5CDD0), shape: BoxShape.circle)),
              const SizedBox(width: 10),
              Expanded(child: Text(name, style: Aj.b(13, w: FontWeight.w800))),
              AjPill(tag, bg: two ? Aj.blush : Aj.sand, fg: two ? Aj.berry : Aj.muted, size: 10.5),
            ],
          ),
        );

    return AjCard(
      color: const Color(0xFFEFE9E5),
      shadow: false,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tukar Proteksi Teman', style: Aj.h(16.5)),
                    const SizedBox(height: 4),
                    Text('Saling jaga saat jalan malam tanpa perlu diminta berulang kali.', style: Aj.b(12.5, color: Aj.muted, height: 1.3)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: () => _qr(context),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(color: Aj.plum, borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.qr_code_2_rounded, color: Colors.white, size: 26),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _WhiteBtn(Icons.share_outlined, 'Bagi Link Unik', () => ajSnack(context, 'Link undangan disalin: amanjalan.id/u/anindya', icon: Icons.link_rounded))),
              const SizedBox(width: 10),
              Expanded(child: _WhiteBtn(Icons.photo_camera_outlined, 'Scan QR Teman', () => ajSnack(context, 'Kamera pemindai dibuka (simulasi)', icon: Icons.qr_code_scanner_rounded))),
            ],
          ),
          const SizedBox(height: 16),
          Text('Lingkaran Timbal-Balik Aktif (3)', style: Aj.b(12, w: FontWeight.w800)),
          const SizedBox(height: 4),
          friend('Dinda Kirana', 'Saling Pantau', true, true),
          friend('Salsabila Rahma', 'Saling Pantau', true, true),
          friend('Rio Pratama', 'Hanya Pemantau', false, false),
        ],
      ),
    );
  }

  void _qr(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const AjSheet(title: 'QR Saling Pantau', child: AjQrBox()),
    );
  }
}

class _WhiteBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _WhiteBtn(this.icon, this.label, this.onTap);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 44,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 17, color: Aj.plum),
            const SizedBox(width: 6),
            Flexible(child: Text(label, overflow: TextOverflow.ellipsis, style: Aj.b(12.5, w: FontWeight.w800))),
          ],
        ),
      ),
    );
  }
}
