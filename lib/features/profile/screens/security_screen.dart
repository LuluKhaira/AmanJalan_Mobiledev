import 'package:flutter/material.dart';

import 'package:amanjalan/core/theme/aj_theme.dart';
import 'package:amanjalan/core/widgets/aj_common.dart';
import 'package:amanjalan/features/profile/screens/account_verified_screen.dart';
import 'package:amanjalan/features/profile/screens/app_version_screen.dart';
import 'package:amanjalan/features/profile/screens/fake_call_settings_screen.dart';
import 'package:amanjalan/features/profile/screens/privacy_screen.dart';
import 'package:amanjalan/features/profile/screens/shake_sensor_screen.dart';
import 'package:amanjalan/features/profile/screens/siren_audio_screen.dart';
import 'package:amanjalan/features/profile/widgets/profile_kit.dart';

/// KEAMANAN (5/10) + pintu masuk ke pengaturan proteksi darurat yang sudah ada.
class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const verified = Icon(Icons.check_circle_rounded, color: Color(0xFF2E9E5B), size: 24);

    return PfScaffold(
      title: 'Keamanan',
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(colors: [Color(0xFFFBE3EB), Color(0xFFFFF1F5)]),
            border: Border.all(color: const Color(0xFFF6D3DE)),
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(colors: [Color(0xFF4A1D5C), Color(0xFF6A2E80)]),
                  boxShadow: const [BoxShadow(color: Color(0x404A1D5C), blurRadius: 12, offset: Offset(0, 5))],
                ),
                child: const Icon(Icons.shield_rounded, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Keamanan Akun', style: Aj.h(16)),
                    const SizedBox(height: 2),
                    Text('Jaga akun kamu tetap aman dengan pengaturan keamanan berikut.', style: Aj.b(12, color: Aj.muted, height: 1.35)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        PfGroup(
          children: [
            PfTile(
              icon: Icons.pin_outlined,
              title: 'Ubah PIN',
              sub: 'Atur PIN untuk login aplikasi.',
              onTap: () => _changePin(context),
            ),
            PfTile(
              icon: Icons.mark_email_read_outlined,
              iconBg: Aj.mint,
              iconFg: Aj.mintDeep,
              title: 'Verifikasi Email',
              sub: 'Email sudah terverifikasi',
              trailing: verified,
              onTap: () => pfPush(context, const AccountVerifiedScreen()),
            ),
            PfTile(
              icon: Icons.phone_android_rounded,
              iconBg: Aj.mint,
              iconFg: Aj.mintDeep,
              title: 'Verifikasi Nomor Telepon',
              sub: 'Nomor sudah terverifikasi',
              trailing: verified,
              onTap: () => pfPush(context, const AccountVerifiedScreen()),
            ),
            PfTile(
              icon: Icons.devices_rounded,
              title: 'Login Perangkat',
              sub: 'Kelola perangkat yang terhubung.',
              onTap: () => _devices(context),
            ),
            PfTile(
              icon: Icons.history_rounded,
              title: 'Aktivitas Akun',
              sub: 'Lihat riwayat aktivitas akun.',
              onTap: () => _activity(context),
            ),
            PfTile(
              icon: Icons.verified_user_outlined,
              title: 'Pusat Keamanan',
              sub: 'Tips dan panduan keamanan.',
              onTap: () => _tips(context),
            ),
          ],
        ),
        const PfSectionLabel('Proteksi Darurat', sub: 'Atur cara kamu memanggil bantuan dengan cepat.'),
        PfGroup(
          children: [
            PfTile(
              icon: Icons.vibration_rounded,
              title: 'Sensor Guncang (Shake SOS)',
              sub: 'Guncang HP 3× untuk kirim sinyal darurat.',
              onTap: () => pfPush(context, const ShakeSensorScreen()),
            ),
            PfTile(
              icon: Icons.phone_in_talk_outlined,
              title: 'Panggilan Samaran',
              sub: 'Alasan pamit instan saat situasi canggung.',
              onTap: () => pfPush(context, const FakeCallSettingsScreen()),
            ),
            PfTile(
              icon: Icons.volume_up_outlined,
              iconBg: Aj.sosSoft,
              iconFg: Aj.sos,
              title: 'Sirene & Audio Peringatan',
              sub: 'Atur suara alarm dan uji bunyinya.',
              onTap: () => pfPush(context, const SirenAudioScreen()),
            ),
            PfTile(
              icon: Icons.lock_outline_rounded,
              title: 'Privasi & Enkripsi Riwayat',
              sub: 'Enkripsi E2E • hapus otomatis riwayat.',
              onTap: () => pfPush(context, const PrivacyScreen()),
            ),
          ],
        ),
        const SizedBox(height: 16),
        PfGroup(
          children: [
            PfTile(
              icon: Icons.system_update_alt_rounded,
              title: 'Versi & Diagnostik Sensor',
              sub: 'Cek sensor dan pembaruan aplikasi.',
              onTap: () => pfPush(context, const AppVersionScreen()),
            ),
          ],
        ),
      ],
    );
  }

  // ── Ubah PIN ─────────────────────────────────────────────
  void _changePin(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AjSheet(
        title: 'Ubah PIN',
        child: _PinSheet(
          onDone: () {
            Navigator.pop(ctx);
            ajSnack(context, 'PIN berhasil diperbarui', icon: Icons.check_circle_rounded);
          },
        ),
      ),
    );
  }

  void _devices(BuildContext context) {
    const items = <(IconData, String, String, bool)>[
      (Icons.laptop_windows_rounded, 'Chrome • Windows', 'Perangkat ini • Batam, ID', true),
      (Icons.phone_android_rounded, 'Android • Redmi Note', 'Aktif 2 jam lalu • Batam, ID', false),
    ];
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AjSheet(
        title: 'Login Perangkat',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final d in items)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: PfIcon(d.$1),
                title: Text(d.$2, style: Aj.b(14, w: FontWeight.w800)),
                subtitle: Text(d.$3, style: Aj.b(12, color: Aj.muted)),
                trailing: d.$4 ? const AjPill('Saat ini', bg: Aj.mint, fg: Aj.mintDeep, size: 10) : null,
              ),
            const SizedBox(height: 10),
            PfPrimaryButton('Keluarkan dari perangkat lain', onTap: () {
              Navigator.pop(ctx);
              ajSnack(context, 'Perangkat lain dikeluarkan', icon: Icons.devices_rounded);
            }),
          ],
        ),
      ),
    );
  }

  void _activity(BuildContext context) {
    const items = <(IconData, String, String)>[
      (Icons.login_rounded, 'Login berhasil', 'Hari ini, 08:12 • Chrome Windows'),
      (Icons.local_fire_department_rounded, 'Check-in harian', 'Kemarin, 17:40 • Beranda'),
      (Icons.campaign_outlined, 'Laporan kejadian terkirim', '27 Okt, 21:05 • Area Parkir'),
      (Icons.person_add_alt_1_outlined, 'Guardian ditambahkan', '25 Okt, 10:30'),
    ];
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AjSheet(
        title: 'Aktivitas Akun',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final a in items)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: PfIcon(a.$1, size: 40),
                title: Text(a.$2, style: Aj.b(14, w: FontWeight.w800)),
                subtitle: Text(a.$3, style: Aj.b(12, color: Aj.muted)),
              ),
          ],
        ),
      ),
    );
  }

  void _tips(BuildContext context) {
    const tips = <(IconData, String)>[
      (Icons.lock_outline_rounded, 'Jangan bagikan PIN dan kode OTP ke siapa pun, termasuk yang mengaku tim AmanJalan.'),
      (Icons.groups_outlined, 'Pastikan minimal 2 Guardian aktif supaya sinyal SOS selalu ada yang menerima.'),
      (Icons.update_rounded, 'Perbarui aplikasi secara berkala untuk mendapat perlindungan terbaru.'),
      (Icons.wifi_lock_outlined, 'Hindari login dari Wi-Fi publik yang tidak dikenal.'),
    ];
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AjSheet(
        title: 'Pusat Keamanan',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final t in tips)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PfIcon(t.$1, size: 38),
                    const SizedBox(width: 12),
                    Expanded(child: Text(t.$2, style: Aj.b(13, height: 1.45))),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PinSheet extends StatefulWidget {
  final VoidCallback onDone;

  const _PinSheet({required this.onDone});

  @override
  State<_PinSheet> createState() => _PinSheetState();
}

class _PinSheetState extends State<_PinSheet> {
  final _old = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _old.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit() {
    if (_old.text.length != 6) return setState(() => _error = 'PIN lama harus 6 digit');
    if (_new.text.length != 6) return setState(() => _error = 'PIN baru harus 6 digit');
    if (_new.text != _confirm.text) return setState(() => _error = 'Konfirmasi PIN tidak sama');
    widget.onDone();
  }

  Widget _field(String label, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        obscureText: true,
        keyboardType: TextInputType.number,
        maxLength: 6,
        onChanged: (_) => setState(() => _error = null),
        style: Aj.h(16),
        decoration: InputDecoration(
          labelText: label,
          counterText: '',
          filled: true,
          fillColor: Aj.sand,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Aj.plum, width: 1.5)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _field('PIN lama', _old),
          _field('PIN baru (6 digit)', _new),
          _field('Ulangi PIN baru', _confirm),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, size: 16, color: Aj.sos),
                  const SizedBox(width: 6),
                  Text(_error!, style: Aj.b(12.5, color: Aj.sos, w: FontWeight.w700)),
                ],
              ),
            ),
          PfPrimaryButton('Simpan PIN', onTap: _submit),
        ],
      ),
    );
  }
}