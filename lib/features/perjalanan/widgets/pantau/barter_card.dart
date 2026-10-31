import 'package:flutter/material.dart';
import 'package:amanjalan/core/theme/aj_theme.dart';
import 'package:amanjalan/core/widgets/aj_common.dart';

/// Strip tipis "Barter Proteksi" (satu baris) + sheet detail.
class BarterCard extends StatelessWidget {
  const BarterCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AjCard(
      color: Aj.blush,
      shadow: false,
      radius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      onTap: () => _sheet(context),
      child: Row(
        children: [
          const AjIconBubble(Icons.sync_alt_rounded, bg: Aj.blushDeep, fg: Aj.berry, size: 36),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Barter Proteksi aktif', style: Aj.h(13.5)),
                Text('Kamu & Salsa saling menjaga', style: Aj.b(12, color: Aj.muted)),
              ],
            ),
          ),
          Text('Detail', style: Aj.b(12.5, color: Aj.plum, w: FontWeight.w800)),
          const Icon(Icons.chevron_right_rounded, color: Aj.plum, size: 20),
        ],
      ),
    );
  }

  void _sheet(BuildContext context) {
    Widget row(IconData i, String t, String s) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            children: [
              AjIconBubble(i, size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(t, style: Aj.b(14.5, w: FontWeight.w800)),
                  Text(s, style: Aj.b(12.5, color: Aj.muted)),
                ]),
              ),
            ],
          ),
        );

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AjSheet(
        title: 'Barter Proteksi',
        child: Column(
          children: [
            row(Icons.schedule_rounded, 'Aktif sejak 19.30', 'Saling memantau selama salah satu berjalan'),
            row(Icons.location_on_outlined, 'Lokasi live dibagikan', 'Hanya terlihat oleh Anda & Salsa'),
            row(Icons.notifications_active_outlined, 'Peringatan otomatis', 'Guncangan 3x atau berhenti > 2 menit'),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ajSnack(context, 'Barter proteksi dijeda 1 jam', icon: Icons.pause_circle_outline_rounded);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Aj.berry,
                  minimumSize: const Size.fromHeight(48),
                  side: const BorderSide(color: Aj.blushDeep, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('Jeda Barter 1 Jam', style: Aj.b(14, color: Aj.berry, w: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}