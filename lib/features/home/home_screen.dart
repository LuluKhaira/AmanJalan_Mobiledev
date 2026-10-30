import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:amanjalan/core/services/auth_service.dart';
import 'package:amanjalan/core/widgets/custom_bottom_nav.dart';
import 'package:amanjalan/features/auth/login_screen.dart';
import 'package:amanjalan/features/emergency/emergency_screen.dart';
import 'package:amanjalan/features/fake_call/fake_call_screen.dart';
import 'package:amanjalan/features/home/aj_data.dart';
import 'package:amanjalan/features/home/widgets/beranda_tab.dart';
import 'package:amanjalan/features/home/manage_guardian_screen.dart';
import 'package:amanjalan/features/home/map_tab.dart';
import 'package:amanjalan/features/home/perjalanan_tab.dart';
import 'package:amanjalan/features/home/tambah_guardian_screen.dart';
import 'package:amanjalan/features/profile/screens/profile_tab.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _name = 'Pengguna';
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    AuthService.instance.getUserName().then((v) {
      if (!mounted) return;
      final firstName = v.trim().split(' ').first;
      if (firstName.isNotEmpty) setState(() => _name = firstName);
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
    final guardians = GuardianStore.guardians.value;
    return [
      if (guardians.isNotEmpty)
        EmergencyRecipient(
          '${guardians.first.role} (Kontak Utama)',
          guardians.first.phone ?? '+62 812-3456-7890',
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
    final guardians = GuardianStore.guardians.value;
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => FakeCallScreen(
          callerName: guardians.isNotEmpty ? guardians.first.name : 'Ibu Nurhayati',
          guardianCount: guardians.length,
          emergencyRecipients: _emergencyRecipients,
        ),
      ),
    );
  }

  void _openGuardianManager() {
    HapticFeedback.selectionClick();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ManageGuardianScreen()),
    );
  }

  void _openAddGuardian() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const TambahGuardianScreen()),
    );
  }

  void _goToTab(int index) => setState(() => _currentIndex = index);

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
              BerandaTab(
                name: _name,
                onProfileTap: () => _goToTab(3),
                onOpenMap: () => _goToTab(1),
                onOpenEmergency: _openEmergency,
                onOpenFakeCall: _openFakeCall,
                onManageGuardians: _openGuardianManager,
                onAddGuardian: _openAddGuardian,
              ),
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
}