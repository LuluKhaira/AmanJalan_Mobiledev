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
import 'package:amanjalan/features/fake_call/fake_call_screen.dart';
import 'package:amanjalan/features/home/map_tab.dart';
import 'package:amanjalan/features/home/perjalanan_tab.dart';
import 'package:amanjalan/features/home/profile_tab.dart';
// Import file sheet milikmu di sini
import 'package:amanjalan/features/home/widgets/add_guardian_sheet.dart';

const _sosRed = Color(0xFF8E1B1B);
const _sosBadge = Color(0xFFF7D6D9);

// Kartu Fake Call
const _fakeBg = Color(0xFFFFD9E2);
const _fakeIcon = Color(0xFF8B4A5E);
const _fakeChip = Color(0xFFF2BFCB);
const _fakeText = Color(0xFF3E1424);
const _fakeSub = Color(0xFF6B4A55);

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

  // List Guardian
  final List<_Guardian> _guardiansList = [
    _Guardian(
      name: 'Mama',
      relation: 'Ibu',
      phone: '+62 812-3456-7890',
      color: const Color(0xFFF4E6F0),
    ),
    _Guardian(
      name: 'Nadia',
      relation: 'Sahabat',
      phone: '+62 813-1111-2222',
      color: const Color(0xFFE6F0F4),
    ),
    _Guardian(
      name: 'Kakak',
      relation: 'Keluarga',
      phone: '+62 857-3333-4444',
      color: const Color(0xFFF0F4E6),
    ),
  ];

  static const _maxGuardians = 5;

  String _name = 'Pengguna';
  int _currentIndex = 0;
  int _modeIndex = 0;

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

  List<EmergencyRecipient> get _emergencyRecipients {
    return [
      if (_guardiansList.isNotEmpty)
        EmergencyRecipient(
          '${_guardiansList.first.relation} (Kontak Utama)',
          _guardiansList.first.phone,
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

  void _openFakeCall() {
    HapticFeedback.mediumImpact();
    final caller = _guardiansList.isNotEmpty ? _guardiansList.first : null;
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => FakeCallScreen(
          callerName: caller?.name ?? 'Mama',
          guardianCount: _guardiansList.length,
          emergencyRecipients: _emergencyRecipients,
        ),
      ),
    );
  }

  void _selectMode(int index) {
    if (index == _modeIndex) return;
    HapticFeedback.selectionClick();
    setState(() => _modeIndex = index);
  }

  void _goToTab(int index) => setState(() => _currentIndex = index);

  // ==========================================
  // FITUR KELOLA & TAMBAH GUARDIAN
  // ==========================================
  void _openGuardianManager() {
    HapticFeedback.selectionClick();
    
    if (_guardiansList.length >= _maxGuardians) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.plum,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Text(
            'Guardian sudah mencapai batas maksimal $_maxGuardians orang.',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
          ),
        ),
      );
      return;
    }

    // Memanggil file AddGuardianSheet milikmu
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return AddGuardianSheet(
          onAddFromContact: () {
            Navigator.pop(context);
            _simulateAddGuardian('Budi', 'Kontak');
          },
          onShareLink: () {
            Navigator.pop(context);
            _simulateAddGuardian('Siti', 'Menunggu');
          },
        );
      },
    );
  }

  void _simulateAddGuardian(String name, String relation) {
    setState(() {
      _guardiansList.add(
        _Guardian(
          name: name,
          relation: relation, 
          phone: '-',
          color: const Color(0xFFE6F0F4), 
        ),
      );
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.plum,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(
          'Undangan berhasil dikirim ke $name!',
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
              // PERHATIKAN: MapTab kita panggil di sini
              MapTab(onBackToHome: () => _goToTab(0)),
              PerjalananTab(
                onOpenEmergency: _openEmergency,
                onOpenMap: () => _goToTab(1),
                onProfileTap: () => _goToTab(3),
              ),
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
                AnimatedEntrance(index: 6, child: _buildQuickActions()),
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

  // ---------- Kartu utama (Status & Mulai) ----------
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

          // Status Keamanan & Guardian
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(25), 
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withAlpha(50),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.shield_rounded,
                  color: AppColors.softPink,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status: Kamu Aman Saat Ini',
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _guardiansList.isNotEmpty
                            ? '${_guardiansList.length} Guardian siap memantau'
                            : 'Belum ada Guardian terhubung',
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: Colors.white.withAlpha(200),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_guardiansList.isNotEmpty)
                  SizedBox(
                    width: 60,
                    height: 30,
                    child: Stack(
                      children: [
                        for (int i = 0; i < _guardiansList.length; i++)
                          if (i < 3) 
                            Positioned(
                              right: i * 16.0,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: _guardiansList[i].color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.plum,
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    _guardiansList[i].name.isNotEmpty 
                                        ? _guardiansList[i].name.substring(0, 1).toUpperCase()
                                        : '?',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Tombol Mulai
          PressScale(
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => _goToTab(1), // Pindah ke MapTab
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
          for (final g in _guardiansList) ...[
            _buildGuardianAvatar(g),
            const SizedBox(width: 16),
          ],
          if (_guardiansList.length < _maxGuardians) _buildAddGuardian(),
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
              g.name.isNotEmpty ? g.name.substring(0, 1).toUpperCase() : '?',
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

  // ---------- Aksi cepat: Fake Call + SOS berdampingan ----------
  Widget _buildQuickActions() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildFakeCallCard()),
        const SizedBox(width: 12),
        Expanded(child: _buildSosCard()),
      ],
    );
  }

  Widget _miniChip(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: GoogleFonts.nunito(
          fontSize: 9.5,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.3,
          color: fg,
        ),
      ),
    );
  }

  Widget _buildFakeCallCard() {
    return PressScale(
      child: GestureDetector(
        onTap: _openFakeCall,
        child: Container(
          width: double.infinity,
          height: 134,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _fakeBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _fakeIcon,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(Icons.phone_rounded,
                        size: 22, color: Colors.white),
                  ),
                  _miniChip('1 TAP', _fakeChip, _fakeText),
                ],
              ),
              const Spacer(),
              Text(
                'FAKE CALL',
                style: GoogleFonts.nunito(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: _fakeText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Pura-pura telepon',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.nunito(
                  fontSize: 12.5,
                  color: _fakeSub,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSosCard() {
    return PressScale(
      child: GestureDetector(
        onTap: _openEmergency,
        onLongPress: _openEmergency,
        child: Container(
          width: double.infinity,
          height: 134,
          decoration: BoxDecoration(
            color: _sosRed,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _sosRed.withAlpha(70),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Positioned(
                  right: -26,
                  bottom: -26,
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(22),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: _sosBadge,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.notifications_active_rounded,
                              size: 22,
                              color: _sosRed,
                            ),
                          ),
                          _miniChip(
                            'TAHAN 3 DTK',
                            Colors.black.withAlpha(48),
                            const Color(0xFFF3D5D9),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        'SOS',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Bantuan Darurat',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.nunito(
                          fontSize: 12.5,
                          color: const Color(0xFFF3D5D9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}