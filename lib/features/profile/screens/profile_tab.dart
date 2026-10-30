import 'package:flutter/material.dart';

import 'package:amanjalan/core/theme/aj_theme.dart';
import 'package:amanjalan/core/widgets/aj_common.dart';
import 'package:amanjalan/features/home/streak_store.dart';
import 'package:amanjalan/features/profile/profile_store.dart';
import 'package:amanjalan/features/profile/screens/screens.dart';
import 'package:amanjalan/features/profile/widgets/profile_kit.dart';

/// PROFIL — mengikuti mockup "Profil Utama" (1/10).
/// Menu mengarah ke layar-layar di folder yang sama (lihat screens.dart).
class ProfileTab extends StatelessWidget {
  final VoidCallback onLogout;

  const ProfileTab({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFEEF4), Color(0xFFFFFAFC)],
          stops: [0, 0.5],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 16, 6),
                child: Row(
                  children: [
                    Expanded(child: Text('Profil', style: Aj.h(26, color: Aj.plum))),
                    _roundButton(Icons.qr_code_scanner_rounded, () => _qr(context)),
                    const SizedBox(width: 8),
                    _roundButton(Icons.settings_outlined, () => pfPush(context, AppSettingsScreen(onLogout: onLogout))),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  _identity(context),
                  const SizedBox(height: 18),
                  _stats(),
                  const SizedBox(height: 18),
                  PfGroup(
                    children: [
                      PfTile(
                        icon: Icons.person_outline_rounded,
                        title: 'Informasi Akun',
                        sub: 'Data pribadi, email, dan nomor telepon.',
                        onTap: () => pfPush(context, const AccountInfoScreen()),
                      ),
                      PfTile(
                        icon: Icons.shield_outlined,
                        title: 'Keamanan',
                        sub: 'PIN, verifikasi, dan pengaturan keamanan.',
                        onTap: () => pfPush(context, const SecurityScreen()),
                      ),
                      PfTile(
                        icon: Icons.notifications_none_rounded,
                        title: 'Notifikasi',
                        sub: 'Kelola notifikasi yang kamu terima.',
                        onTap: () => pfPush(context, const NotificationSettingsScreen()),
                      ),
                      PfTile(
                        icon: Icons.headset_mic_outlined,
                        title: 'Bantuan & FAQ',
                        sub: 'Temukan jawaban dari pertanyaan yang sering ditanyakan.',
                        onTap: () => pfPush(context, const HelpFaqScreen()),
                      ),
                      PfTile(
                        icon: Icons.info_outline_rounded,
                        title: 'Tentang AmanJalan',
                        sub: 'Versi aplikasi, kebijakan privasi, dan informasi lainnya.',
                        onTap: () => pfPush(context, const AboutScreen()),
                      ),
                      PfTile(
                        icon: Icons.chat_bubble_outline_rounded,
                        title: 'Hubungi Kami',
                        sub: 'Kirim pesan atau saran.',
                        onTap: () => pfPush(context, const ContactUsScreen()),
                      ),
                      PfTile(
                        icon: Icons.settings_outlined,
                        title: 'Settings',
                        sub: 'Pengaturan aplikasi.',
                        onTap: () => pfPush(context, AppSettingsScreen(onLogout: onLogout)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  PfBanner(
                    owl: pfOwlPhone,
                    title: 'Ada pertanyaan?',
                    sub: 'Tim kami siap membantu 24/7 melalui fitur Lapor & Live Chat.',
                    button: 'Hubungi Kami',
                    onButton: () => pfPush(context, const ContactUsScreen()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _roundButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFF3E1E9)),
          boxShadow: Aj.softShadow,
        ),
        child: Icon(icon, size: 21, color: Aj.plum),
      ),
    );
  }

  // ── Identitas ────────────────────────────────────────────
  Widget _identity(BuildContext context) {
    return ValueListenableBuilder<ProfileData>(
      valueListenable: ProfileStore.data,
      builder: (context, p, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                PfAvatar(size: 92, camera: true, onTap: () => pfPush(context, const EditNameScreen())),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(p.fullName, maxLines: 1, overflow: TextOverflow.ellipsis, style: Aj.h(22, color: Aj.plum)),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => pfPush(context, const EditNameScreen()),
                            child: const Icon(Icons.edit_outlined, size: 17, color: Aj.berry),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(p.email, maxLines: 1, overflow: TextOverflow.ellipsis, style: Aj.b(13, color: Aj.muted)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          GestureDetector(
                            onTap: () => pfPush(context, const AccountInfoScreen()),
                            child: AjPill(p.status, bg: Aj.blush, fg: Aj.plum, icon: ProfileStore.statusIcon(p.status), size: 11.5),
                          ),
                          GestureDetector(
                            onTap: () => pfPush(context, const AccountVerifiedScreen()),
                            child: const AjPill('Terverifikasi', bg: Aj.mint, fg: Aj.mintDeep, icon: Icons.verified_rounded, size: 11.5),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: Transform.rotate(
                angle: -0.04,
                child: Text(
                  'Tetap aman, tetap semangat!',
                  style: Aj.b(12.5, color: Aj.berry, w: FontWeight.w800).copyWith(fontStyle: FontStyle.italic),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Statistik ────────────────────────────────────────────
  Widget _stats() {
    return ValueListenableBuilder<StreakState>(
      valueListenable: StreakStore.state,
      builder: (context, st, _) {
        Widget cell(String v, String l) => Expanded(
              child: Column(
                children: [
                  Text(v, style: Aj.h(20, color: Aj.plum)),
                  const SizedBox(height: 2),
                  Text(l, textAlign: TextAlign.center, style: Aj.b(10, color: Aj.muted, w: FontWeight.w700, height: 1.2)),
                ],
              ),
            );
        Widget divider() => Container(width: 1, height: 34, color: const Color(0xFFF1DFE7));

        return PfCard(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Row(
            children: [
              cell('12', 'Riwayat\nPerjalanan'),
              divider(),
              cell('3', 'Laporan\nKejadian'),
              divider(),
              cell('5', 'Rute\nFavorit'),
              divider(),
              cell('${st.total}', 'Hari\nAktif'),
            ],
          ),
        );
      },
    );
  }

  void _qr(BuildContext context) {
    pfPush(context, const QrBuddyScreen());
  }
}