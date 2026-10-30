import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:amanjalan/core/theme/aj_theme.dart';
import 'package:amanjalan/core/widgets/aj_common.dart';
import 'package:amanjalan/features/home/aj_data.dart';
import 'package:amanjalan/features/perjalanan/perjalanan_actions.dart';
import 'package:amanjalan/features/perjalanan/screens/safe_arrival_screen.dart';
import 'package:amanjalan/features/perjalanan/widgets/pj_widgets.dart';

/// Konfirmasi akhir: sudah sampai, masih jalan, atau batalkan.
class AkhiriPerjalananScreen extends StatelessWidget {
  const AkhiriPerjalananScreen({super.key});

  void _arrived(BuildContext context) {
    HapticFeedback.heavyImpact();
    TripStore.finish();
    final record = TripStore.trips.value.first;
    Navigator.of(context).pushAndRemoveUntil(pjRoute(SafeArrivalScreen(trip: record)), (r) => r.isFirst);
  }

  void _cancel(BuildContext context) {
    HapticFeedback.mediumImpact();
    TripStore.finish(status: TripStatus.batal);
    ajSnack(context, 'Perjalanan dibatalkan dan Guardian diberi tahu', icon: Icons.close_rounded);
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Aj.bg,
      appBar: pjAppBar(context, 'Akhiri Perjalanan'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
          child: Column(
            children: [
              const Spacer(),
              const PjMascot(size: 150),
              const SizedBox(height: 18),
              Text('Apakah kamu sudah\nsampai di tujuan?', textAlign: TextAlign.center, style: Aj.h(22, height: 1.25)),
              const SizedBox(height: 8),
              Text('Pastikan kamu benar-benar aman sebelum mengakhiri perjalanan.', textAlign: TextAlign.center, style: Aj.b(13.5, color: Aj.muted, height: 1.4)),
              const Spacer(),
              PjButton('Saya Sudah Sampai', icon: Icons.check_circle_rounded, onTap: () => _arrived(context)),
              const SizedBox(height: 10),
              PjButton('Saya Masih di Perjalanan', icon: Icons.navigation_rounded, style: PjButtonStyle.outline, onTap: () => Navigator.of(context).pop()),
              const SizedBox(height: 6),
              TextButton(
                onPressed: () => _cancel(context),
                child: Text('Batalkan perjalanan', style: Aj.b(13, color: Aj.muted, w: FontWeight.w800)),
              ),
              const SizedBox(height: 6),
              AjCard(
                color: Aj.blush,
                shadow: false,
                radius: 18,
                padding: const EdgeInsets.all(12),
                onTap: () => pjOpenEmergency(context),
                child: Row(
                  children: [
                    const Icon(Icons.shield_outlined, color: Aj.berry, size: 22),
                    const SizedBox(width: 10),
                    Expanded(child: Text('Merasa tidak aman? Ketuk di sini untuk membuka SOS darurat.', style: Aj.b(12.5, color: Aj.berry, w: FontWeight.w700, height: 1.3))),
                    const Icon(Icons.chevron_right_rounded, color: Aj.berry),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
