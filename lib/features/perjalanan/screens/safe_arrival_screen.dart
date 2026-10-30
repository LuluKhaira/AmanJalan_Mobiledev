import 'package:flutter/material.dart';
import 'package:amanjalan/core/theme/aj_theme.dart';
import 'package:amanjalan/core/widgets/aj_common.dart';
import 'package:amanjalan/features/home/aj_data.dart';
import 'package:amanjalan/features/perjalanan/widgets/pj_widgets.dart';
import 'package:amanjalan/features/perjalanan/screens/riwayat_screen.dart';

/// Layar sukses. Sekarang menampilkan data perjalanan yang BENAR (bukan angka tetap).
class SafeArrivalScreen extends StatelessWidget {
  final TripRecord? trip;
  const SafeArrivalScreen({super.key, this.trip});

  @override
  Widget build(BuildContext context) {
    final t = trip;
    return Scaffold(
      backgroundColor: const Color(0xFFF3F9F4),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 700),
                curve: Curves.elasticOut,
                builder: (_, v, child) => Transform.scale(scale: v.clamp(0.0, 1.2), child: child),
                child: Container(
                  width: 104,
                  height: 104,
                  decoration: const BoxDecoration(color: Color(0xFFDCEBDD), shape: BoxShape.circle),
                  child: const Icon(Icons.check_rounded, size: 56, color: Colors.green),
                ),
              ),
              const SizedBox(height: 24),
              Text('Alhamdulillah,\nKamu Sudah Tiba!', textAlign: TextAlign.center, style: Aj.h(24, height: 1.3)),
              const SizedBox(height: 10),
              Text('Perjalananmu selesai dan kabar tiba sudah dikirim ke Guardian.', textAlign: TextAlign.center, style: Aj.b(14, color: Aj.muted, height: 1.4)),
              const SizedBox(height: 28),
              if (t != null)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFFDCEBDD), width: 2),
                  ),
                  child: Column(
                    children: [
                      Text('${t.from} → ${t.to}', textAlign: TextAlign.center, style: Aj.b(13.5, w: FontWeight.w800)),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _item('${t.minutes} Menit', 'Waktu'),
                          Container(width: 1, height: 38, color: Colors.grey.shade300),
                          _item(fmtDistance(t.meters), 'Jarak'),
                          Container(width: 1, height: 38, color: Colors.grey.shade300),
                          _item('${t.havens}', 'Titik aman'),
                        ],
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 28),
              if (t != null)
                PjButton('Lihat Detail Perjalanan', icon: Icons.receipt_long_rounded, style: PjButtonStyle.soft, onTap: () => showTripDetail(context, t)),
              const SizedBox(height: 10),
              PjButton(
                'Kembali ke Beranda',
                icon: Icons.home_rounded,
                onTap: () {
                  pjDone(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void pjDone(BuildContext context) {
    ajSnack(context, 'Streak aman terjaga. Sampai jumpa di perjalanan berikutnya!', icon: Icons.local_fire_department_rounded);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Widget _item(String value, String label) {
    return Column(
      children: [
        Text(value, style: Aj.h(16)),
        const SizedBox(height: 2),
        Text(label, style: Aj.b(12, color: Aj.muted)),
      ],
    );
  }
}
