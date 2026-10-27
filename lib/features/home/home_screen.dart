import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:amanjalan/core/services/auth_service.dart';
import 'package:amanjalan/core/theme/app_colors.dart';
import 'package:amanjalan/core/widgets/animated_entrance.dart';
import 'package:amanjalan/core/widgets/press_scale.dart';
import 'package:amanjalan/core/widgets/custom_bottom_nav.dart';
import 'package:amanjalan/core/widgets/app_header.dart';
import 'package:amanjalan/features/auth/login_screen.dart';
import 'package:amanjalan/features/emergency/emergency_screen.dart';
import 'package:amanjalan/features/home/history_tab.dart';
import 'package:amanjalan/features/home/map_tab.dart';
import 'package:amanjalan/features/home/profile_tab.dart';

// Warna kartu SOS di Beranda (rose lembut; merah penuh hanya di layar darurat)
const _sosRose = Color(0xFFB83A5E);
const _sosBg = Color(0xFFFFF0F4);
const _sosBorder = Color(0xFFFFD1DD);

/// Data sederhana Guardian untuk tampilan Beranda.
/// TODO: ganti dengan data asli dari database / GuardianService.
class _Guardian {
  final String name;
  final String relation;
  final String phone;
  final Color color;

  const _Guardian({
    required this.name,
    required this.relation,
    required this.phone,
    required this.color,
  });
}

/// Mode perjalanan yang bisa dipilih.
class _TravelMode {
  final IconData icon;
  final String label;

  const _TravelMode(this.icon, this.label);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _modes = [
    _TravelMode(Icons.directions_walk_rounded, 'Jalan Kaki'),
    _TravelMode(Icons.directions_car_rounded, 'Mobil'),
    _TravelMode(Icons.directions_bus_rounded, 'Transport'),
  ];

  static const _guardians = [
    _Guardian(
      name: 'Mama',
      relation: 'Ibu',
      phone: '+62 812-3456-7890',
      color: Color(0xFFF4E6F0),
    ),
    _Guardian(
      name: 'Nadia',
      relation: 'Sahabat',
      phone: '+62 813-1111-2222',
      color: Color(0xFFE6F0F4),
    ),
    _Guardian(
      name: 'Kakak',
      relation: 'Keluarga',
      phone: '+62 857-3333-4444',
      color: Color(0xFFF0F4E6),
    ),
  ];

  // Guardian maksimal 5 (sesuai paper konsep)
  static const _maxGuardians = 5;

  String _name = 'Pengguna';
  int _currentIndex = 0;
  int _modeIndex = 0; // default: Jalan Kaki

  @override
  void initState() {
    super.initState();
    AuthService.instance.getUserName().then((v) {
      if (!mounted) return;
      final firstName = v.trim().split(' ').first;
      if (firstName.isNotEmpty) {
        setState(() => _name = firstName);
      }
    });
  }

  // ---------- Aksi ----------
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

  /// Penerima peringatan untuk layar darurat: Guardian utama + layanan polisi.
  List<EmergencyRecipient> get _emergencyRecipients {
    return [
      if (_guardians.isNotEmpty)
        EmergencyRecipient(
          '${_guardians.first.relation} (Kontak Utama)',
          _guardians.first.phone,
        ),
      const EmergencyRecipient('Layanan Polisi Terpadu', 'Panggilan 110'),
    ];
  }

  void _openEmergency() {
    HapticFeedback.heavyImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => EmergencyScreen(recipients: _emergencyRecipients),
      ),
    );
  }

  void _selectMode(int index) {
    if (index == _modeIndex) return;
    HapticFeedback.selectionClick();
    setState(() => _modeIndex = index);
  }

  void _goToTab(int index) => setState(() => _currentIndex = index);

  void _openGuardianManager() {
    HapticFeedback.selectionClick();
    // TODO: buka halaman Atur Guardian (daftar, tambah, hapus, status undangan)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.plum,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(
          _guardians.length >= _maxGuardians
              ? 'Guardian sudah mencapai batas $_maxGuardians orang.'
              : 'Halaman Atur Guardian segera hadir.',
          style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // ---------- Build ----------
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFFCFAFC),
        body: SafeArea(
          child: IndexedStack(
            index: _currentIndex,
            children: [
              _buildBerandaTab(),
              MapTab(onBackToHome: () => _goToTab(0)),
              const HistoryTab(),
              ProfileTab(onLogout: _logout),
            ],
          ),
        ),
        bottomNavigationBar: CustomBottomNav(
          currentIndex: _currentIndex,
          onTap: (index) {
            HapticFeedback.selectionClick();
            _goToTab(index);
          },
        ),
      ),
    );
  }

  // ==========================================
  // TAB 1: BERANDA
  // ==========================================
  Widget _buildBerandaTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppHeader(
            onProfileTap: () => _goToTab(3),
            onNotificationTap: () {},
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                AnimatedEntrance(index: 1, child: _buildHeroCard()),
                const SizedBox(height: 32),
                AnimatedEntrance(
                  index: 2,
                  child: _sectionTitle('Pilih Kendaraan'),
                ),
                const SizedBox(height: 12),
                AnimatedEntrance(index: 3, child: _buildModeRow()),
                const SizedBox(height: 32),
                AnimatedEntrance(index: 4, child: _buildGuardianHeader()),
                const SizedBox(height: 12),
                AnimatedEntrance(index: 5, child: _buildGuardianList()),
                const SizedBox(height: 32),
                AnimatedEntrance(index: 6, child: _buildSosCard()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
      );

  // ---------- Kartu utama (cari tujuan + mulai) ----------
  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.plum,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.plum.withAlpha(51),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mau melangkah ke\nmana hari ini, $_name?',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),

          // Kolom pencarian: ketuk untuk membuka peta dan memilih tujuan
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _goToTab(1),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded,
                      color: AppColors.textMuted, size: 22),
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
          ),
          const SizedBox(height: 20),

          PressScale(
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => _goToTab(1),
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
    );
  }

  // ---------- Pilih kendaraan ----------
  Widget _buildModeRow() {
    return Row(
      children: [
        for (var i = 0; i < _modes.length; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          Expanded(child: _buildModeCard(i)),
        ],
      ],
    );
  }

  Widget _buildModeCard(int index) {
    final mode = _modes[index];
    final isActive = index == _modeIndex;

    return PressScale(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _selectMode(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isActive ? AppColors.softPink : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive
                  ? AppColors.plum.withAlpha(77)
                  : const Color(0xFFF0EDF2),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                mode.icon,
                size: 28,
                color: isActive ? AppColors.plum : AppColors.textMuted,
              ),
              const SizedBox(height: 8),
              Text(
                mode.label,
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                  color: isActive ? AppColors.plum : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Guardian ----------
  Widget _buildGuardianHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _sectionTitle('Guardian Kamu'),
        GestureDetector(
          onTap: _openGuardianManager,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            child: Text(
              'Kelola',
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.plum,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGuardianList() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final g in _guardians) ...[
            _buildGuardianAvatar(g),
            const SizedBox(width: 16),
          ],
          if (_guardians.length < _maxGuardians) _buildAddGuardian(),
        ],
      ),
    );
  }

  Widget _buildGuardianAvatar(_Guardian g) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: g.color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              g.name.substring(0, 1).toUpperCase(),
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
          g.name,
          style: GoogleFonts.nunito(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        Text(
          g.relation,
          style: GoogleFonts.nunito(
            fontSize: 11,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildAddGuardian() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _openGuardianManager,
      child: Column(
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
              child: Icon(Icons.add_rounded,
                  color: Color(0xFFD5C9DC), size: 28),
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
        ],
      ),
    );
  }

  // ---------- Kartu SOS ----------
  Widget _buildSosCard() {
    return PressScale(
      child: GestureDetector(
        onTap: _openEmergency,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _sosBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _sosBorder, width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shield_rounded,
                  color: _sosRose,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tombol Darurat (SOS)',
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _sosRose,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Butuh bantuan mendesak?',
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        color: _sosRose.withAlpha(179),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: _sosRose,
              ),
            ],
          ),
        ),
      ),
    );
  }
}