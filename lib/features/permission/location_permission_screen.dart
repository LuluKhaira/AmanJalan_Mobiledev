import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:amanjalan/core/theme/app_colors.dart';
import 'package:amanjalan/core/widgets/animated_entrance.dart';
import 'package:amanjalan/core/widgets/press_scale.dart';
import 'package:amanjalan/features/home/home_screen.dart';

const _fieldFill = Color(0xFFF6F5F8);
const _lineColor = Color(0xFFE6E3EA);

class LocationPermissionScreen extends StatefulWidget {
  const LocationPermissionScreen({super.key});
  @override
  State<LocationPermissionScreen> createState() => _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen> {
  bool _loading = false;

  Future<void> _allow() async {
    HapticFeedback.lightImpact();
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _loading = false);
    _next();
  }

  void _skip() {
    HapticFeedback.selectionClick();
    _next();
  }

  void _next() {
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(26, 48, 26, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedEntrance(index: 0, child: _buildLogo()),
                const SizedBox(height: 32),
                AnimatedEntrance(index: 1, child: _buildHeading()),
                const SizedBox(height: 34),
                const AnimatedEntrance(index: 2, child: _InfoRow(
                  icon: Icons.home_outlined, iconBg: AppColors.sage,
                  title: 'Hanya aktif saat kamu bepergian', desc: 'Lokasi otomatis nonaktif begitu tiba di rumah.',
                )),
                const _Separator(),
                const AnimatedEntrance(index: 3, child: _InfoRow(
                  icon: Icons.visibility_outlined, iconBg: AppColors.softPink,
                  title: 'Transparansi penuh', desc: 'Kamu selalu melihat siapa saja Guardian yang memantau.',
                )),
                const _Separator(),
                const AnimatedEntrance(index: 4, child: _InfoRow(
                  icon: Icons.lock_outline_rounded, iconBg: _fieldFill,
                  title: 'Enkripsi berlapis', desc: 'Data rute tidak dijual atau dibagikan ke pihak ketiga.',
                )),
                const SizedBox(height: 40),
                AnimatedEntrance(index: 5, child: _buildAllowButton()),
                const SizedBox(height: 12),
                AnimatedEntrance(index: 6, child: _buildSkipButton()),
                const SizedBox(height: 22),
                AnimatedEntrance(index: 7, child: _buildFootnote()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 52, height: 52,
      decoration: BoxDecoration(color: AppColors.softPink, borderRadius: BorderRadius.circular(16)),
      child: const Icon(Icons.location_on_rounded, size: 28, color: AppColors.plum),
    );
  }

  Widget _buildHeading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Izinkan akses\nlokasi', style: GoogleFonts.poppins(fontSize: 30, fontWeight: FontWeight.w700, color: AppColors.textDark, height: 1.2, letterSpacing: -0.6)),
        const SizedBox(height: 10),
        Text('AmanJalan butuh lokasimu untuk membagikan perjalanan ke Guardian.', style: GoogleFonts.nunito(fontSize: 15, height: 1.5, color: AppColors.textMuted)),
      ],
    );
  }

  Widget _buildAllowButton() {
    return PressScale(
      child: SizedBox(
        width: double.infinity, height: 54,
        child: ElevatedButton(
          onPressed: _loading ? null : _allow,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.plum, disabledBackgroundColor: AppColors.plum, foregroundColor: Colors.white, elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _loading
                ? const SizedBox(key: ValueKey('loading'), width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                : Row(
                    key: const ValueKey('label'), mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on_outlined, size: 21),
                      const SizedBox(width: 10),
                      Text('Izinkan Lokasi', style: GoogleFonts.nunito(fontSize: 17, fontWeight: FontWeight.w800, letterSpacing: 0.3)),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkipButton() {
    return PressScale(
      child: SizedBox(
        width: double.infinity, height: 52,
        child: OutlinedButton(
          onPressed: _loading ? null : _skip,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: _lineColor, width: 1.2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: Text('Nanti Saja', style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        ),
      ),
    );
  }

  Widget _buildFootnote() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.settings_outlined, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 8),
        Flexible(
          child: Text('Dapat diubah kapan saja di Pengaturan Ponsel',
              textAlign: TextAlign.center, style: GoogleFonts.nunito(fontSize: 13, color: AppColors.textMuted)),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String title;
  final String desc;
  const _InfoRow({required this.icon, required this.iconBg, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 46, height: 46,
          decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
          child: Icon(icon, size: 22, color: AppColors.plum),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.nunito(fontSize: 15.5, fontWeight: FontWeight.w800, color: AppColors.textDark)),
              const SizedBox(height: 3),
              Text(desc, style: GoogleFonts.nunito(fontSize: 14, height: 1.45, color: AppColors.textMuted)),
            ],
          ),
        ),
      ],
    );
  }
}

class _Separator extends StatelessWidget {
  const _Separator();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Divider(height: 1, color: _lineColor),
    );
  }
}