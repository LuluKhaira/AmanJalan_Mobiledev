import 'package:flutter/material.dart';

import 'package:amanjalan/core/theme/aj_theme.dart';
import 'package:amanjalan/features/profile/widgets/profile_kit.dart';

/// AKUN TERVERIFIKASI (3/10)
class AccountVerifiedScreen extends StatelessWidget {
  const AccountVerifiedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = pfNow;

    return PfScaffold(
      title: 'Akun Terverifikasi',
      footer: PfPrimaryButton('Selesai', onTap: () => Navigator.pop(context)),
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFBDDE8), Color(0xFFFFF1F5)],
            ),
            border: Border.all(color: const Color(0xFFF6D3DE)),
          ),
          child: Column(
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.6, end: 1),
                duration: const Duration(milliseconds: 700),
                curve: Curves.elasticOut,
                builder: (_, v, child) => Transform.scale(scale: v, child: child),
                child: Container(
                  width: 190,
                  height: 190,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.7),
                    boxShadow: Aj.softShadow,
                  ),
                  alignment: Alignment.center,
                  child: const PfOwl(pfOwlShield, size: 170, fallback: Icons.verified_user_rounded),
                ),
              ),
              const SizedBox(height: 18),
              Text('Akun Kamu\nSudah Terverifikasi!', textAlign: TextAlign.center, style: Aj.h(23, color: Aj.plum, height: 1.25)),
              const SizedBox(height: 10),
              Text(
                'Terima kasih telah melengkapi data diri. Akun kamu sudah terverifikasi dan lebih aman digunakan.',
                textAlign: TextAlign.center,
                style: Aj.b(13, color: Aj.muted, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        PfGroup(
          children: [
            _row('Email terverifikasi', p.email),
            _row('Nomor telepon terverifikasi', p.phone),
            _row('Data diri sesuai', p.fullName),
          ],
        ),
      ],
    );
  }

  Widget _row(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(color: Aj.mint, shape: BoxShape.circle),
            child: const Icon(Icons.check_rounded, size: 19, color: Aj.mintDeep),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Aj.b(14, w: FontWeight.w800)),
                const SizedBox(height: 1),
                Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: Aj.b(12, color: Aj.muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}