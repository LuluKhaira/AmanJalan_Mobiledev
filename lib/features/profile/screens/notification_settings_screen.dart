import 'package:flutter/material.dart';

import 'package:amanjalan/core/theme/aj_theme.dart';
import 'package:amanjalan/core/widgets/aj_common.dart';
import 'package:amanjalan/features/profile/widgets/profile_kit.dart';

/// PENGATURAN NOTIFIKASI (6/10)
/// Inbox notifikasi ada di features/notification/notification_screen.dart (tidak diubah).
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  static const _items = <(IconData, String, String)>[
    (Icons.shield_outlined, 'Notifikasi Keamanan', 'Peringatan & informasi penting.'),
    (Icons.system_update_alt_rounded, 'Update Aplikasi', 'Fitur baru dan pembaruan.'),
    (Icons.campaign_outlined, 'Laporan & Kejadian', 'Status laporan yang kamu buat.'),
    (Icons.alt_route_rounded, 'Pengingat Rute', 'Pengingat perjalanan & aktivitas.'),
    (Icons.mail_outline_rounded, 'Pesan dari Tim AmanJalan', 'Informasi dan promo terbaru.'),
  ];

  final List<bool> _on = [true, true, true, true, true];

  @override
  Widget build(BuildContext context) {
    return PfScaffold(
      title: 'Notifikasi',
      footer: const PfBanner(
        owl: pfOwlPhone,
        title: 'Tetap terhubung',
        sub: 'dengan informasi penting demi keamanan perjalananmu.',
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
          child: Text('Pilih Jenis Notifikasi', style: Aj.h(15)),
        ),
        PfGroup(
          children: [
            for (var i = 0; i < _items.length; i++)
              PfSwitchTile(
                icon: _items[i].$1,
                title: _items[i].$2,
                sub: _items[i].$3,
                value: _on[i],
                onChanged: (v) => setState(() => _on[i] = v),
              ),
            // Darurat: wajib aktif demi keselamatan
            PfSwitchTile(
              icon: Icons.notifications_active_outlined,
              iconBg: Aj.sosSoft,
              color: Aj.sos,
              title: 'Notifikasi Darurat',
              sub: 'Peringatan kondisi darurat.',
              value: true,
              onChanged: (_) => ajSnack(context, 'Notifikasi darurat selalu aktif demi keselamatanmu', icon: Icons.lock_outline_rounded),
            ),
          ],
        ),
      ],
    );
  }
}