import 'package:flutter/material.dart';
import 'package:amanjalan/core/theme/aj_theme.dart';
import 'package:amanjalan/core/widgets/aj_common.dart';

/// Kartu Ibu: satu baris saja → status aman + sapa via WhatsApp.
class FamilyCard extends StatelessWidget {
  const FamilyCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AjCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          const AjAvatar(
            name: 'Ibu Nurhayati',
            size: 48,
            online: true,
            checkmark: true,
            color: Color(0xFFF4E6F0),
            imageUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150',
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ibu Nurhayati', style: Aj.h(15.5)),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, size: 15, color: Aj.mintDeep),
                    const SizedBox(width: 4),
                    Text('Aman di rumah', style: Aj.b(12.5, color: Aj.mintDeep, w: FontWeight.w800)),
                  ],
                ),
                const SizedBox(height: 2),
                Text('Tiba 20:45 • Baterai 89%', style: Aj.b(11.5, color: Aj.muted)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () => ajSnack(context, 'Membuka WhatsApp…', icon: Icons.chat_bubble_outline_rounded),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: Aj.mint, borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.chat_bubble_outline_rounded, color: Aj.mintDeep, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}