import 'package:flutter/material.dart';

import 'package:amanjalan/core/theme/aj_theme.dart';
import 'package:amanjalan/core/widgets/aj_common.dart';
import 'package:amanjalan/features/profile/profile_store.dart';
import 'package:amanjalan/features/profile/widgets/profile_kit.dart';

/// SETTINGS (10/10). Pengaturan disimpan di ProfileStore (sementara di memori).
class AppSettingsScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const AppSettingsScreen({super.key, required this.onLogout});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  void _reset() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Reset pengaturan?', style: Aj.h(17)),
        content: Text('Semua pengaturan aplikasi akan kembali ke bawaan. Data akun dan Guardian tidak terhapus.', style: Aj.b(13.5, color: Aj.muted, height: 1.4)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Batal', style: Aj.b(14, color: Aj.muted, w: FontWeight.w800))),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Aj.plum),
            onPressed: () {
              Navigator.pop(ctx);
              setState(ProfileStore.resetPrefs);
              ajSnack(context, 'Pengaturan dikembalikan ke bawaan', icon: Icons.restart_alt_rounded);
            },
            child: Text('Reset', style: Aj.b(14, color: Colors.white, w: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  Widget _value(String v) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(v, style: Aj.b(12, color: Aj.muted, w: FontWeight.w700)),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right_rounded, color: Aj.muted, size: 22),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return PfScaffold(
      title: 'Settings',
      children: [
        PfGroup(
          children: [
            PfTile(
              icon: Icons.language_rounded,
              title: 'Bahasa',
              sub: ProfileStore.language,
              trailing: const Icon(Icons.chevron_right_rounded, color: Aj.muted, size: 22),
              onTap: () => pfPickOne(
                context,
                title: 'Bahasa',
                options: const ['Bahasa Indonesia', 'English'],
                current: ProfileStore.language,
                onPick: (v) => setState(() => ProfileStore.language = v),
              ),
            ),
            PfTile(
              icon: Icons.wb_sunny_outlined,
              title: 'Mode Tampilan',
              sub: ProfileStore.themeMode,
              trailing: const Icon(Icons.chevron_right_rounded, color: Aj.muted, size: 22),
              onTap: () => pfPickOne(
                context,
                title: 'Mode Tampilan',
                options: const ['Terang', 'Gelap', 'Ikuti Sistem'],
                current: ProfileStore.themeMode,
                onPick: (v) => setState(() => ProfileStore.themeMode = v),
              ),
            ),
            PfTile(
              icon: Icons.text_fields_rounded,
              title: 'Ukuran Teks',
              sub: ProfileStore.textSize,
              trailing: const Icon(Icons.chevron_right_rounded, color: Aj.muted, size: 22),
              onTap: () => pfPickOne(
                context,
                title: 'Ukuran Teks',
                options: const ['Kecil', 'Normal', 'Besar'],
                current: ProfileStore.textSize,
                onPick: (v) => setState(() => ProfileStore.textSize = v),
              ),
            ),
            PfSwitchTile(
              icon: Icons.volume_up_outlined,
              title: 'Suara & Getaran',
              sub: ProfileStore.sound ? 'Aktif' : 'Nonaktif',
              value: ProfileStore.sound,
              onChanged: (v) => setState(() => ProfileStore.sound = v),
            ),
            PfSwitchTile(
              icon: Icons.data_saver_on_rounded,
              title: 'Hemat Data',
              sub: ProfileStore.dataSaver ? 'Aktif' : 'Nonaktif',
              value: ProfileStore.dataSaver,
              onChanged: (v) => setState(() => ProfileStore.dataSaver = v),
            ),
            PfTile(
              icon: Icons.restart_alt_rounded,
              title: 'Reset Aplikasi',
              sub: 'Kembalikan ke pengaturan awal.',
              trailing: const Icon(Icons.chevron_right_rounded, color: Aj.muted, size: 22),
              onTap: _reset,
            ),
            PfTile(
              icon: Icons.logout_rounded,
              iconBg: Aj.sosSoft,
              iconFg: Aj.sos,
              titleColor: Aj.sos,
              title: 'Keluar',
              sub: 'Logout dari akun.',
              onTap: () => pfConfirmLogout(context, widget.onLogout),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.fromLTRB(10, 12, 18, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(colors: [Color(0xFFFBE3EB), Color(0xFFFFF1F5)]),
            border: Border.all(color: const Color(0xFFF6D3DE)),
          ),
          child: Row(
            children: [
              const PfOwl(pfOwlLogo, size: 70, fallback: Icons.pets_rounded),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AmanJalan', style: Aj.h(15, color: Aj.plum)),
                    Text('v2.4.1 • Jalan Aman, Jaga Bersama', style: Aj.b(11.5, color: Aj.muted)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}