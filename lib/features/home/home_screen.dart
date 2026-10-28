import 'package:amanjalan/features/home/manage_guardian_screen.dart';
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
import 'package:amanjalan/features/profile/screens/profile_tab.dart';
// Import file data/store tempat GuardianStore & model Guardian berada
import 'package:amanjalan/features/home/aj_data.dart';
import 'package:amanjalan/features/home/widgets/add_guardian_sheet.dart';
import 'package:amanjalan/features/home/tambah_guardian_screen.dart';

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
  final String? imageUrl;
  final bool online;

  const _Guardian({
    required this.name,
    required this.relation,
    required this.phone,
    required this.color,
    this.imageUrl,
    this.online = true,
  });
}

class _TravelMode {
  final IconData icon;
  final String label;
  final String badge;

  const _TravelMode(this.icon, this.label, this.badge);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _modes = [
    _TravelMode(Icons.directions_walk_rounded, 'Jalan Kaki', 'Rute Terang'),
    _TravelMode(Icons.two_wheeler_rounded, 'Naik Motor', 'Simpan Plat'),
    _TravelMode(Icons.directions_car_rounded, 'Naik Mobil', 'Deviasi Rute'),
  ];

  // List Guardian
  final List<_Guardian> _guardiansList = [
    const _Guardian(
      name: 'Ibu Nurhayati',
      relation: 'Wali Utama',
      phone: '+62 812-3456-7890',
      color: Color(0xFFF4E6F0),
      imageUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150',
      online: true,
    ),
    const _Guardian(
      name: 'Dinda Permata',
      relation: 'Teman Sekos',
      phone: '+62 813-1111-2222',
      color: Color(0xFFE6F0F4),
      imageUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150',
      online: true,
    ),
    const _Guardian(
      name: 'Salsabila Rahma',
      relation: 'Teman Kos',
      phone: '+62 857-3333-4444',
      color: Color(0xFFF0F4E6),
      imageUrl: 'https://images.unsplash.com/photo-1567532939604-b6b5b0db2604?w=150',
      online: false,
    ),
  ];

  static const _maxGuardians = 5;

  String _name = 'Pengguna';
  int _currentIndex = 0;
  int _modeIndex = 0;
  String _savedPlat = '';

  String get _heroStatusBadge {
    switch (_modeIndex) {
      case 1:
        return 'Proteksi Ojol Aktif • Simpan Plat Siaga';
      case 2:
        return 'Proteksi Mobil Aktif • Anti-Deviasi Rute';
      default:
        return 'Radius Aman Terkendali • Sensor Saku Siaga';
    }
  }

  String get _heroButtonLabel {
    switch (_modeIndex) {
      case 1:
        return 'Pantau Naik Motor';
      case 2:
        return 'Pantau Naik Mobil';
      default:
        return 'Mulai Jalan Bareng';
    }
  }

  IconData get _heroButtonIcon {
    switch (_modeIndex) {
      case 1:
        return Icons.two_wheeler_rounded;
      case 2:
        return Icons.directions_car_rounded;
      default:
        return Icons.directions_walk_rounded;
    }
  }

  void _syncGuardiansFromStore() {
    _guardiansList.clear();
    for (var g in GuardianStore.guardians.value) {
      _guardiansList.add(
        _Guardian(
          name: g.name,
          relation: g.role,
          phone: g.phone ?? '+62 812-3456-7890',
          color: g.color,
          imageUrl: g.imageUrl,
          online: g.online,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _syncGuardiansFromStore();
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
          callerName: caller?.name ?? 'Ibu Nurhayati',
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
  // FITUR KELOLA GUARDIAN
  // ==========================================
  void _openGuardianManager() {
    HapticFeedback.selectionClick();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ManageGuardianScreen(),
      ),
    ).then((_) {
      if (mounted) {
        setState(() => _syncGuardiansFromStore());
      }
    });
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
              MapTab(
                onBackToHome: () => _goToTab(0),
                onProfileTap: () => _goToTab(3),
              ),
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
      padding: const EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppHeader(
            onProfileTap: () => _goToTab(3),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                AnimatedEntrance(index: 1, child: _buildHeroCard()),
                const SizedBox(height: 26),
                AnimatedEntrance(
                  index: 2,
                  child: _sectionTitle('Pilih Moda Perjalanan'),
                ),
                const SizedBox(height: 12),
                AnimatedEntrance(index: 3, child: _buildModeRow()),
                const SizedBox(height: 12),
                AnimatedEntrance(index: 4, child: _buildActiveModeCard()),
                const SizedBox(height: 26),
                AnimatedEntrance(index: 5, child: _buildSafeHavensSection()),
                const SizedBox(height: 26),
                AnimatedEntrance(index: 5, child: _buildGuardianHeader()),
                const SizedBox(height: 12),
                AnimatedEntrance(index: 6, child: _buildGuardianList()),
                const SizedBox(height: 24),
                AnimatedEntrance(index: 7, child: _buildSafetyTipBanner()),
                const SizedBox(height: 24),
                AnimatedEntrance(
                  index: 8,
                  child: _sectionTitle('Aksi Tanggap Darurat'),
                ),
                const SizedBox(height: 12),
                AnimatedEntrance(index: 9, child: _buildQuickActions()),
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

  // ---------- Kartu Utama Hero (Status, Quick Search & Mulai) ----------
  Widget _buildHeroCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF38123E),
              Color(0xFF561D5E),
              Color(0xFF7A2E5E),
            ],
          ),
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF38123E).withAlpha(90),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Lingkaran dekoratif abstrak di latar belakang
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(14),
                ),
              ),
            ),
            Positioned(
              bottom: -40,
              left: -20,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFF8FAB).withAlpha(18),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Live safety pulse indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(26),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withAlpha(40)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF4ADE80),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF4ADE80),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _heroStatusBadge,
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(150),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${_guardiansList.length} Guardian',
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            color: Colors.white.withAlpha(220),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  Text(
                    'Mau melangkah ke mana\nhari ini, $_name?',
                    style: GoogleFonts.poppins(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Kolom Pencarian Cepat (Navigasi ke Tab Peta)
                  PressScale(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        _goToTab(1);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(20),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search_rounded, color: AppColors.plum, size: 21),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Cari rute aman (cth: Kos Melati, Kampus UI)...',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.nunito(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: AppColors.softPink,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.near_me_rounded, color: AppColors.plum, size: 15),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Tombol Mulai Jalan Bareng
                  PressScale(
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => _goToTab(1),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFBE8F0),
                          foregroundColor: AppColors.plum,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(_heroButtonIcon, size: 19),
                            const SizedBox(width: 8),
                            Text(
                              _heroButtonLabel,
                              style: GoogleFonts.nunito(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.arrow_forward_rounded, size: 17),
                          ],
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
    );
  }

  // ---------- Pilih Kendaraan ----------
  Widget _buildModeRow() {
    return Row(
      children: [
        for (var i = 0; i < _modes.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
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
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
          decoration: BoxDecoration(
            color: isActive ? AppColors.softPink : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isActive
                  ? AppColors.plum
                  : const Color(0xFFF0EDF2),
              width: isActive ? 1.8 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: isActive ? AppColors.plum.withAlpha(20) : Colors.black.withAlpha(6),
                blurRadius: isActive ? 10 : 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              if (isActive)
                Positioned(
                  top: -6,
                  right: 2,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: AppColors.plum,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_rounded, size: 11, color: Colors.white),
                  ),
                ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    mode.icon,
                    size: 26,
                    color: isActive ? AppColors.plum : AppColors.textMuted,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    mode.label,
                    style: GoogleFonts.nunito(
                      fontSize: 12.5,
                      fontWeight: isActive ? FontWeight.w800 : FontWeight.w700,
                      color: isActive ? AppColors.plum : AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    mode.badge,
                    style: GoogleFonts.nunito(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isActive ? AppColors.plum : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Kartu Proteksi Adaptif Sesuai Moda ----------
  Widget _buildActiveModeCard() {
    switch (_modeIndex) {
      case 1:
        // Moda 1: Naik Motor / Ojol
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE8DCE5), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(6),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFF0D2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.two_wheeler_rounded, color: Color(0xFF9A6200), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Proteksi Naik Motor / Ojol',
                              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: const Color(0xFFFFF0D2), borderRadius: BorderRadius.circular(6)),
                              child: Text('Simpan Plat', style: GoogleFonts.nunito(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFF9A6200))),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Catat plat nomor motor driver agar otomatis terkirim & tersimpan di HP Guardian.',
                          style: GoogleFonts.nunito(fontSize: 11.5, color: AppColors.textMuted, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F3F5),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE5DDD9)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.pin_outlined, size: 16, color: AppColors.plum),
                          const SizedBox(width: 6),
                          Text(
                            _savedPlat.isEmpty ? 'Plat: Belum dicatat' : 'Plat: $_savedPlat',
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _savedPlat.isEmpty ? AppColors.textMuted : AppColors.plum,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _showPlatInputDialog,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.plum,
                      minimumSize: const Size(0, 38),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.edit_rounded, size: 14),
                    label: Text(
                      _savedPlat.isEmpty ? 'Catat Plat' : 'Ubah Plat',
                      style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

      case 2:
        // Moda 2: Naik Mobil / Taksi Online
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE8DCE5), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(6),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Color(0xFFE3F2FD),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.directions_car_rounded, color: Color(0xFF1565C0), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Proteksi Mobil / Taksi Online',
                          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(6)),
                          child: Text('Anti-Deviasi', style: GoogleFonts.nunito(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFF1565C0))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Alarm deviasi rute aktif. Sistem otomatis membunyikan peringatan bila taksi berbelok keluar jalur.',
                      style: GoogleFonts.nunito(fontSize: 11.5, color: AppColors.textMuted, height: 1.3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

      default:
        // Moda 0: Jalan Kaki
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE8DCE5), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(6),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.directions_walk_rounded, color: Color(0xFF2E7D4F), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Proteksi Jalan Kaki Aktif',
                          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(6)),
                          child: Text('Sensor Saku', style: GoogleFonts.nunito(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFF2E7D4F))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Deteksi guncangan saku siaga. Rute peta otomatis memprioritaskan jalan ramai berlampu terang.',
                      style: GoogleFonts.nunito(fontSize: 11.5, color: AppColors.textMuted, height: 1.3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
    }
  }

  void _showPlatInputDialog() {
    final controller = TextEditingController(text: _savedPlat);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: [
            const Icon(Icons.two_wheeler_rounded, color: AppColors.plum),
            const SizedBox(width: 8),
            Text('Catat Plat Motor', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Masukkan nomor plat motor driver (cth: B 4521 SXZ) agar otomatis tersimpan & dibagikan ke Guardian.',
              style: GoogleFonts.nunito(fontSize: 13, color: AppColors.textMuted),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              textCapitalization: TextCapitalization.characters,
              autofocus: true,
              style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 1),
              decoration: InputDecoration(
                hintText: 'Contoh: B 1234 ABC',
                filled: true,
                fillColor: const Color(0xFFF7F3F5),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.plum, width: 1.5)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, color: AppColors.textMuted)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.plum, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () {
              final text = controller.text.trim();
              Navigator.pop(ctx);
              setState(() => _savedPlat = text);
              if (text.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppColors.plum,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    content: Text('Plat $text tersimpan & dibagikan ke Guardian.', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
                  ),
                );
              }
            },
            child: Text('Simpan', style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  // ---------- Safe Haven Terdekat (Pos Aman 24 Jam) ----------
  Widget _buildSafeHavensSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _sectionTitle('Titik Aman Terdekat (Safe Haven)'),
            GestureDetector(
              onTap: () => _goToTab(1),
              child: Text(
                'Lihat Peta',
                style: GoogleFonts.nunito(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.plum,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: [
              _buildSafeHavenCard(
                icon: Icons.storefront_rounded,
                title: 'Minimarket 24 Jam',
                distance: '150 m',
                tag: 'Buka 24 Jam',
                tagColor: const Color(0xFFE8F5E9),
                tagText: const Color(0xFF2E7D4F),
              ),
              const SizedBox(width: 12),
              _buildSafeHavenCard(
                icon: Icons.local_police_rounded,
                title: 'Pos Polisi Subsektor',
                distance: '350 m',
                tag: 'Siaga 24/7',
                tagColor: const Color(0xFFE3F2FD),
                tagText: const Color(0xFF1565C0),
              ),
              const SizedBox(width: 12),
              _buildSafeHavenCard(
                icon: Icons.local_hospital_rounded,
                title: 'Klinik & Apotek Utama',
                distance: '500 m',
                tag: 'Penerangan Baik',
                tagColor: const Color(0xFFFFF3E0),
                tagText: const Color(0xFFE65100),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSafeHavenCard({
    required IconData icon,
    required String title,
    required String distance,
    required String tag,
    required Color tagColor,
    required Color tagText,
  }) {
    return PressScale(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          _goToTab(1);
        },
        child: Container(
          width: 175,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF0EAE6), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.softPink,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: AppColors.plum, size: 20),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: tagColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tag,
                      style: GoogleFonts.nunito(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: tagText,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  const Icon(Icons.near_me_rounded, size: 12, color: AppColors.plum),
                  const SizedBox(width: 4),
                  Text(
                    distance,
                    style: GoogleFonts.nunito(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.plum,
                    ),
                  ),
                  Text(
                    ' • Pos Aman',
                    style: GoogleFonts.nunito(
                      fontSize: 11.5,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
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
        Stack(
          children: [
            Container(
              width: 64,
              height: 64,
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: g.online
                    ? const LinearGradient(
                        colors: [Color(0xFF8A3F5C), Color(0xFFD6738E), Color(0xFFF8C6D2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: g.online ? null : const Color(0xFFD8D2D5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(12),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: g.imageUrl != null
                      ? Image.network(
                          g.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _avatarFallback(g),
                        )
                      : _avatarFallback(g),
                ),
              ),
            ),
            if (g.online)
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D4F),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.2),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 7),
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

  Widget _avatarFallback(_Guardian g) {
    return Container(
      color: g.color,
      child: Center(
        child: Text(
          g.name.isNotEmpty ? g.name.substring(0, 1).toUpperCase() : '?',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.plum,
          ),
        ),
      ),
    );
  }

  Widget _buildAddGuardian() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
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
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TambahGuardianScreen(
              onGuardianAdded: () {
                if (mounted) setState(() => _syncGuardiansFromStore());
              },
            ),
          ),
        ).then((_) {
          if (mounted) setState(() => _syncGuardiansFromStore());
        });
      },
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFD5C9DC), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(8),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.person_add_alt_1_outlined,
                  color: AppColors.plum, size: 24),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'Tambah',
            style: GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
            ),
          ),
          Text(
            'Guardian',
            style: GoogleFonts.nunito(
              fontSize: 11,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Banner Tips Siaga Harian ----------
  Widget _buildSafetyTipBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF7D8E0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.softPink,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.lightbulb_outline_rounded, color: AppColors.plum, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tips Aman Malam Ini',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Sebelum melintas di area sepi, aktifkan sensor guncangan & pantau titik safe haven terdekat.',
                  style: GoogleFonts.nunito(
                    fontSize: 11.5,
                    color: AppColors.textMuted,
                    height: 1.3,
                  ),
                ),
              ],
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