import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:amanjalan/core/theme/app_colors.dart';

class AppHeader extends StatelessWidget {
  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationTap;

  // Parameter showBackButton & onBackTap DIHAPUS total

  const AppHeader({
    super.key,
    this.onProfileTap,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          // Logo Kiri
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.softPink,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_on_rounded, color: AppColors.plum, size: 26),
          ),
          const SizedBox(width: 12),

          // Teks
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'AmanJalan',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.plum,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'PETA RUTE AMAN',
                  style: GoogleFonts.nunito(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textMuted,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),

          // Ikon Kanan (Lonceng & Profil)
          GestureDetector(
            onTap: onNotificationTap,
            child: Stack(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFF0EDF2), width: 1.5),
                  ),
                  child: const Icon(Icons.notifications_none_rounded, color: AppColors.textDark, size: 22),
                ),
                Positioned(
                  top: 8,
                  right: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          
          // Profil (Menggunakan Icon User, bukan gambar internet agar tidak pernah blank)
          GestureDetector(
            onTap: onProfileTap,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.softPink,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.plum, width: 1.5),
              ),
              child: const Icon(Icons.person, color: AppColors.plum, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}