import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:amanjalan/core/services/auth_service.dart';
import 'package:amanjalan/core/theme/app_colors.dart';
import 'package:amanjalan/core/widgets/animated_entrance.dart';
import 'package:amanjalan/core/widgets/press_scale.dart';
import 'package:amanjalan/core/widgets/custom_bottom_nav.dart'; // Import nav bar baru
import 'package:amanjalan/features/auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _name = 'Pengguna';
  bool _isSosActive = false;
  
  // State untuk melacak tab yang aktif (0: Beranda, 1: Peta, 2: Riwayat, 3: Profil)
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    AuthService.instance.getUserName().then((v) {
      if (mounted) {
        final firstName = v.split(' ').first;
        setState(() => _name = firstName);
      }
    });
  }

  Future<void> _logout() async {
    await AuthService.instance.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
      (route) => false,
    );
  }

  void _toggleSos() {
    HapticFeedback.heavyImpact();
    setState(() => _isSosActive = !_isSosActive);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: _isSosActive ? const Color(0xFFB83A5E) : AppColors.textDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(
          _isSosActive ? 'SOS Aktif! Guardian sedang dihubungi.' : 'SOS Dimatikan.',
          style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFFCFAFC),
        // Gunakan IndexedStack agar state halaman tidak hilang saat pindah tab
        body: SafeArea(
          child: IndexedStack(
            index: _currentIndex,
            children: [
              _buildBerandaTab(),
              _buildPlaceholderTab('Peta Rute', Icons.explore_rounded),
              _buildPlaceholderTab('Riwayat Perjalanan', Icons.history_rounded),
              _buildPlaceholderTab('Profil Pengguna', Icons.person_rounded),
            ],
          ),
        ),
        // Panggil Custom Navigation Bar di sini
        bottomNavigationBar: CustomBottomNav(
          currentIndex: _currentIndex,
          onTap: (index) {
            HapticFeedback.selectionClick();
            setState(() => _currentIndex = index);
          },
        ),
      ),
    );
  }

  // ==========================================
  // TAB 1: BERANDA (Kode UI yang sebelumnya)
  // ==========================================
  Widget _buildBerandaTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER ---
          AnimatedEntrance(
            index: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AmanJalan',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.plum,
                      ),
                    ),
                    Text(
                      'Halo, $_name 👋',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _circleIcon(Icons.notifications_none_rounded, onTap: () {}),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: _logout,
                      child: const CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.softPink,
                        child: Icon(Icons.person_outline, color: AppColors.plum, size: 22),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // --- KARTU UTAMA (MULAI PERJALANAN) ---
          AnimatedEntrance(
            index: 1,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.plum,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.plum.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mau melangkah ke\nmana hari ini?',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 22),
                        const SizedBox(width: 12),
                        Text(
                          'Cari lokasi atau tujuan...',
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  PressScale(
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.plum,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Mulai Jalan Bareng',
                              style: GoogleFonts.nunito(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_rounded, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // --- MODE PERJALANAN ---
          AnimatedEntrance(
            index: 2,
            child: Text(
              'Pilih Kendaraan',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
          ),
          const SizedBox(height: 12),
          AnimatedEntrance(
            index: 3,
            child: Row(
              children: [
                Expanded(child: _buildModeCard(Icons.directions_walk_rounded, 'Jalan Kaki', true)),
                const SizedBox(width: 12),
                Expanded(child: _buildModeCard(Icons.directions_car_rounded, 'Mobil', false)),
                const SizedBox(width: 12),
                Expanded(child: _buildModeCard(Icons.directions_bus_rounded, 'Transport', false)),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // --- GUARDIAN ---
          AnimatedEntrance(
            index: 4,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Guardian Kamu',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  'Kelola',
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.plum,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AnimatedEntrance(
            index: 5,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                children: [
                  _buildGuardianAvatar('Mama', 'Ibu', const Color(0xFFF4E6F0)),
                  const SizedBox(width: 16),
                  _buildGuardianAvatar('Nadia', 'Sahabat', const Color(0xFFE6F0F4)),
                  const SizedBox(width: 16),
                  _buildGuardianAvatar('Kakak', 'Keluarga', const Color(0xFFF0F4E6)),
                  const SizedBox(width: 16),
                  _buildAddGuardian(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // --- TOMBOL SOS ---
          AnimatedEntrance(
            index: 6,
            child: PressScale(
              child: GestureDetector(
                onTap: _toggleSos,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _isSosActive ? const Color(0xFFB83A5E) : const Color(0xFFFFF0F4),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _isSosActive ? Colors.transparent : const Color(0xFFFFD1DD),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _isSosActive ? Colors.white.withOpacity(0.2) : Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.shield_rounded,
                          color: _isSosActive ? Colors.white : const Color(0xFFB83A5E),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isSosActive ? 'SOS Aktif' : 'Tombol Darurat (SOS)',
                              style: GoogleFonts.nunito(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: _isSosActive ? Colors.white : const Color(0xFFB83A5E),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _isSosActive 
                                ? 'Ketuk untuk mematikan'
                                : 'Butuh bantuan mendesak?',
                              style: GoogleFonts.nunito(
                                fontSize: 13,
                                color: _isSosActive ? Colors.white70 : const Color(0xFFB83A5E).withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!_isSosActive)
                        const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFFB83A5E)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ==========================================
  // TAB LAINNYA (Placeholder Sementara)
  // ==========================================
  Widget _buildPlaceholderTab(String title, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: AppColors.softPink),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Halaman ini sedang dalam pengembangan.',
            style: GoogleFonts.nunito(
              fontSize: 15,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // WIDGET BANTUAN (Sama seperti sebelumnya)
  // ==========================================
  Widget _circleIcon(IconData icon, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFF0EDF2), width: 1),
        ),
        child: Icon(icon, color: AppColors.textDark, size: 22),
      ),
    );
  }

  Widget _buildModeCard(IconData icon, String label, bool isActive) {
    return PressScale(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isActive ? AppColors.softPink : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? AppColors.plum.withOpacity(0.3) : const Color(0xFFF0EDF2),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: isActive ? AppColors.plum : AppColors.textMuted),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                color: isActive ? AppColors.plum : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuardianAvatar(String name, String relation, Color bgColor) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Center(
            child: Text(
              name.substring(0, 1).toUpperCase(),
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: GoogleFonts.nunito(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        Text(
          relation,
          style: GoogleFonts.nunito(
            fontSize: 11,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildAddGuardian() {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFD5C9DC), width: 1.5),
          ),
          child: const Center(
            child: Icon(Icons.add_rounded, color: Color(0xFFD5C9DC), size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tambah',
          style: GoogleFonts.nunito(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}