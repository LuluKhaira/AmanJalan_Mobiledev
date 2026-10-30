import 'package:flutter/material.dart';

import 'package:amanjalan/core/theme/aj_theme.dart';
import 'package:amanjalan/core/widgets/aj_common.dart';
import 'package:amanjalan/features/profile/screens/app_version_screen.dart';
import 'package:amanjalan/features/profile/screens/privacy_screen.dart';
import 'package:amanjalan/features/profile/widgets/profile_kit.dart';

/// TENTANG AMANJALAN (8/10)
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PfScaffold(
      title: 'Tentang AmanJalan',
      children: [
        const SizedBox(height: 4),
        Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.8, end: 1),
            duration: const Duration(milliseconds: 700),
            curve: Curves.elasticOut,
            builder: (_, v, child) => Transform.scale(scale: v, child: child),
            child: const PfOwl(pfOwlLogo, size: 210, fallback: Icons.shield_rounded),
          ),
        ),
        const SizedBox(height: 4),
        Center(child: Text('AmanJalan', style: Aj.h(26, color: Aj.plum))),
        const SizedBox(height: 2),
        Center(child: Text('Jalan Aman, Jaga Bersama', style: Aj.b(13.5, color: Aj.muted, w: FontWeight.w700))),
        const SizedBox(height: 16),
        Text(
          'AmanJalan adalah aplikasi keamanan perjalanan yang dirancang untuk semua perempuan, di mana pun berada. Pelajar, mahasiswi, pekerja, ibu rumah tangga, hingga siapa pun yang ingin melangkah lebih tenang. Kami hadir untuk memastikan setiap langkahmu lebih aman, nyaman, dan terlindungi.',
          textAlign: TextAlign.center,
          style: Aj.b(13.5, color: Aj.muted, height: 1.55),
        ),
        const SizedBox(height: 20),
        PfGroup(
          children: [
            PfTile(
              icon: Icons.info_outline_rounded,
              title: 'Versi Aplikasi',
              sub: 'v2.4.1 • Lihat catatan rilis & diagnostik',
              onTap: () => pfPush(context, const AppVersionScreen()),
            ),
            PfTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Kebijakan Privasi',
              sub: 'Lihat kebijakan privasi kami.',
              onTap: () => pfPush(context, const PrivacyScreen()),
            ),
            PfTile(
              icon: Icons.article_outlined,
              title: 'Syarat & Ketentuan',
              sub: 'Lihat syarat & ketentuan.',
              onTap: () => _terms(context),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite_rounded, size: 18, color: Aj.plum),
            const SizedBox(width: 8),
            Text('Untuk Semua Perempuan', style: Aj.b(13, color: Aj.muted, w: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: 4),
        Center(child: Text('Dibuat dengan ❤ untuk keselamatan perempuan', style: Aj.b(11.5, color: Aj.muted))),
      ],
    );
  }

  void _terms(BuildContext context) {
    const terms = <(String, String)>[
      ('1. Penggunaan', 'AmanJalan digunakan untuk membantu keselamatan perjalanan. Jangan menyalahgunakan fitur SOS atau laporan palsu.'),
      ('2. Data & Privasi', 'Lokasi hanya dibagikan ke Guardian yang kamu izinkan. Detail ada di Kebijakan Privasi.'),
      ('3. Tanggung Jawab', 'AmanJalan adalah alat bantu dan tidak menggantikan layanan darurat resmi (110, 112, PAMDAL).'),
    ];
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AjSheet(
        title: 'Syarat & Ketentuan',
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.6),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final t in terms) ...[
                  Text(t.$1, style: Aj.h(14)),
                  const SizedBox(height: 4),
                  Text(t.$2, style: Aj.b(13, color: Aj.muted, height: 1.5)),
                  const SizedBox(height: 14),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}