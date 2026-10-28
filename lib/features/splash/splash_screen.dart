import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:amanjalan/core/theme/app_colors.dart';
import 'package:amanjalan/core/services/auth_service.dart';
import 'package:amanjalan/core/widgets/app_logo.dart';
import 'package:amanjalan/features/auth/login_screen.dart';
import 'package:amanjalan/features/home/home_screen.dart';
import 'package:amanjalan/features/onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _timer = Timer(const Duration(milliseconds: 2800), _goNext);
  }

  /// Alur:
  /// sudah login                      -> Home
  /// belum login, belum lihat onboarding -> Onboarding -> Login
  /// belum login, sudah lihat onboarding -> Login
  Future<void> _goNext() async {
    if (!mounted) return;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    final loggedIn = await AuthService.instance.isLoggedIn();
    final prefs = await SharedPreferences.getInstance();
    final seenOnboarding = prefs.getBool('seen_onboarding') ?? false;
    if (!mounted) return;

    final Widget next;
    if (loggedIn) {
      next = const HomeScreen();
    } else if (seenOnboarding) {
      next = const LoginScreen();
    } else {
      next = const OnboardingScreen();
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, __, ___) => next,
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4A1D5C), Color(0xFF3A1347)],
          ),
        ),
        child: Stack(
          children: [
            Align(
              alignment: const Alignment(0, -0.28),
              child: Container(
                width: 360,
                height: 360,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Color(0x40E7C6F0), Color(0x00E7C6F0)],
                  ),
                ),
              ),
            ),
            const _Dot(alignment: Alignment(-0.45, -0.38), size: 7, color: Color(0xB3E7C6F0)),
            const _Dot(alignment: Alignment(0.75, -0.18), size: 5, color: Color(0x80E7C6F0)),
            const _Dot(alignment: Alignment(0.85, 0.02), size: 6, color: Color(0xB3B67BCB)),
            const _Dot(alignment: Alignment(-0.85, 0.1), size: 5, color: Color(0x80E7C6F0)),
            const _Dot(alignment: Alignment(-0.3, 0.62), size: 5, color: Color(0xB3B67BCB)),
            const _Dot(alignment: Alignment(0.8, 0.6), size: 4, color: Color(0x80E7C6F0)),
            Positioned(
              left: 0,
              right: 0,
              bottom: 56,
              height: 130,
              child: CustomPaint(painter: _SkylinePainter()),
            ),
            Align(
              alignment: const Alignment(0, -0.2),
              child: FadeTransition(
                opacity: _fade,
                child: ScaleTransition(
                  scale: _scale,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const _LogoBadge(),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'AmanJalan',
                            style: GoogleFonts.poppins(
                              fontSize: 34,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Container(
                            width: 10,
                            height: 10,
                            margin: const EdgeInsets.only(left: 6, bottom: 12),
                            decoration: const BoxDecoration(
                              color: AppColors.softPink,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Jalan Aman, Jaga Bersama',
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          letterSpacing: 1.2,
                          color: const Color(0xFFEBCFE0),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const _ActiveBadge(),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 28,
              child: Text(
                'v2.4 • KEAMANAN BERMARTABAT',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                  color: const Color(0x80EBCFE0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoBadge extends StatelessWidget {
  const _LogoBadge();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 112,
      height: 112,
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [Color(0x66FFFFFF), Color(0x40D9B3E8)],
        ),
        boxShadow: [
          BoxShadow(color: Color(0x40E7C6F0), blurRadius: 40, spreadRadius: 6),
        ],
      ),
      child: const AppLogo(size: 88),
    );
  }
}

class _ActiveBadge extends StatelessWidget {
  const _ActiveBadge();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0x1AFFFFFF),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.sage,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'PERLINDUNGAN AKTIF',
            style: GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.6,
              color: const Color(0xFFEBCFE0),
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final Alignment alignment;
  final double size;
  final Color color;
  const _Dot({required this.alignment, required this.size, required this.color});
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}

class _SkylinePainter extends CustomPainter {
  static const _buildings = [
    [0.03, 0.12, 52.0], [0.15, 0.13, 92.0], [0.30, 0.10, 56.0],
    [0.40, 0.13, 78.0], [0.55, 0.12, 62.0], [0.67, 0.13, 82.0],
    [0.81, 0.11, 56.0], [0.90, 0.12, 70.0],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final body = Paint()..color = const Color(0x8C2A0F36);
    final window = Paint()..color = const Color(0x80EBCFE0);
    final base = Paint()..color = const Color(0xB32A0F36);

    for (var i = 0; i < _buildings.length; i++) {
      final b = _buildings[i];
      final left = size.width * b[0];
      final width = size.width * b[1];
      final height = b[2];
      final top = size.height - height;

      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(left, top, width, height),
          topLeft: const Radius.circular(3),
          topRight: const Radius.circular(3),
        ),
        body,
      );

      if (i == 1 || i == 3 || i == 5 || i == 7) {
        canvas.drawCircle(Offset(left + width * 0.25, top + 18), 2, window);
        canvas.drawCircle(Offset(left + width * 0.6, top + 18), 2, window);
        canvas.drawCircle(Offset(left + width * 0.25, top + 34), 2, window);
      }
    }
    canvas.drawRect(Rect.fromLTWH(0, size.height - 10, size.width, 10), base);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}