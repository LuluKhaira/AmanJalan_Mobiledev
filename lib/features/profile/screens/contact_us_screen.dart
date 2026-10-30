import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:amanjalan/core/theme/aj_theme.dart';
import 'package:amanjalan/core/widgets/aj_common.dart';
import 'package:amanjalan/features/profile/widgets/profile_kit.dart';

/// HUBUNGI KAMI (9/10)
class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  static const _email = 'amanjalan@polibatam.ac.id';

  @override
  Widget build(BuildContext context) {
    return PfScaffold(
      title: 'Hubungi Kami',
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(12, 14, 18, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFBDDE8), Color(0xFFFFF1F5)],
            ),
            border: Border.all(color: const Color(0xFFF6D3DE)),
          ),
          child: Row(
            children: [
              const PfOwl(pfOwlPhone, size: 120, fallback: Icons.support_agent_rounded),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Kami siap membantu!', style: Aj.h(17, color: Aj.plum)),
                    const SizedBox(height: 6),
                    Text(
                      'Jika ada pertanyaan, kendala, atau saran, jangan ragu untuk menghubungi kami.',
                      style: Aj.b(12.5, color: Aj.muted, height: 1.45),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        PfGroup(
          children: [
            PfTile(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'Live Chat',
              sub: 'Tersedia 24/7',
              onTap: () => ajSnack(context, 'Menghubungkan ke Live Chat… (simulasi)', icon: Icons.chat_bubble_outline_rounded),
            ),
            PfTile(
              icon: Icons.mail_outline_rounded,
              title: 'Email',
              sub: _email,
              trailing: const Icon(Icons.copy_rounded, size: 18, color: Aj.muted),
              onTap: () {
                Clipboard.setData(const ClipboardData(text: _email));
                ajSnack(context, 'Email disalin', icon: Icons.copy_rounded);
              },
            ),
            PfTile(
              icon: Icons.chat_rounded,
              iconBg: Aj.mint,
              iconFg: Aj.mintDeep,
              title: 'WhatsApp',
              sub: '+62 878-xxxx-xxxx',
              onTap: () => ajSnack(context, 'Membuka WhatsApp… (simulasi)', icon: Icons.chat_rounded),
            ),
            PfTile(
              icon: Icons.location_on_outlined,
              title: 'Lokasi Kantor',
              sub: 'Politeknik Negeri Batam\nGedung Utama, Lantai 1',
              onTap: () => ajSnack(context, 'Membuka peta lokasi kantor… (simulasi)', icon: Icons.location_on_outlined),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Aj.sosSoft,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Aj.sos.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(color: Aj.sos, borderRadius: BorderRadius.circular(13)),
                child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: Aj.b(12.5, color: Aj.ink, height: 1.4),
                    children: [
                      TextSpan(text: 'Darurat? ', style: Aj.b(12.5, color: Aj.sos, w: FontWeight.w900)),
                      const TextSpan(text: 'Segera gunakan fitur SOS di halaman Beranda.'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}