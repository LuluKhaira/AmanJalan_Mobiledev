import 'package:flutter/material.dart';
import 'package:amanjalan/core/theme/aj_theme.dart';
import 'package:amanjalan/core/widgets/aj_common.dart';

/// Kartu Ibu: status geofence rumah + sapa via WhatsApp.
class FamilyCard extends StatelessWidget {
  const FamilyCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AjCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
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
                    Text('Ibu Tercinta', style: Aj.b(12, color: Aj.muted)),
                  ],
                ),
              ),
              const AjPill('Aman di Rumah', bg: Aj.mint, fg: Aj.mintDeep, icon: Icons.location_on_outlined),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Aj.sand, borderRadius: BorderRadius.circular(14)),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline_rounded, size: 18, color: Aj.muted),
                const SizedBox(width: 8),
                Expanded(child: Text('Masuk geofence rumah pukul 20:45', style: Aj.b(12.5, w: FontWeight.w700))),
                const Icon(Icons.battery_5_bar_rounded, size: 15, color: Aj.muted),
                const SizedBox(width: 2),
                Text('89%', style: Aj.b(11.5, color: Aj.muted)),
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => ajSnack(context, 'Membuka WhatsApp…', icon: Icons.chat_bubble_outline_rounded),
              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16, color: Aj.berry),
              label: Text('Sapa Ibu via WhatsApp', style: Aj.b(12.5, color: Aj.berry, w: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }
}
