import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:amanjalan/core/theme/aj_theme.dart';
import 'package:amanjalan/features/auth/login_screen.dart';
import 'package:amanjalan/features/auth/register_screen.dart';
import 'package:amanjalan/features/auth/widgets/auth_mode.dart';
import 'package:amanjalan/features/welcome/widgets/day_night_toggle.dart';
import 'package:amanjalan/features/welcome/widgets/sky_scene.dart';
import 'package:amanjalan/features/welcome/widgets/welcome_background.dart';
import 'package:amanjalan/features/welcome/widgets/welcome_buttons.dart';
import 'package:amanjalan/features/welcome/widgets/welcome_hill.dart';
import 'package:amanjalan/features/welcome/widgets/welcome_palette.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  static const _owl = 'assets/images/onboarding/owl_welcome.png';

  /// Awal mengikuti jam perangkat (malam = 18.00 – 05.00) atau pilihan terakhir.
  late bool _night = AuthMode.resolve();

  late final AnimationController _mode = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
    value: _night ? 1.0 : 0.0,
  );
  late final Animation<double> _t =
      CurvedAnimation(parent: _mode, curve: Curves.easeInOut);

  late final AnimationController _enter = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1700),
  )..forward();

  @override
  void dispose() {
    _mode.dispose();
    _enter.dispose();
    super.dispose();
  }

  void _toggle() {
    HapticFeedback.selectionClick();
    setState(() => _night = !_night);
    AuthMode.night = _night;
    _night ? _mode.forward() : _mode.reverse();
  }

  Animation<double> _interval(double a, double b, [Curve c = Curves.easeOutCubic]) =>
      CurvedAnimation(parent: _enter, curve: Interval(a, b, curve: c));

  Widget _reveal(Animation<double> a, Widget child) {
    return AnimatedBuilder(
      animation: a,
      child: child,
      builder: (context, child) => Opacity(
        opacity: a.value.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, (1 - a.value) * 24),
          child: child,
        ),
      ),
    );
  }

  void _open(Widget screen) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 420),
        pageBuilder: (_, __, ___) => screen,
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween(begin: const Offset(0, 0.04), end: Offset.zero).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final hillH = (size.height * 0.28).clamp(180.0, 250.0).toDouble();

    final titleA = _interval(0.10, 0.50);
    final subA = _interval(0.20, 0.60);
    final chipA = _interval(0.30, 0.70);
    final btn1A = _interval(0.45, 0.85);
    final btn2A = _interval(0.55, 0.95);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: _night ? Brightness.light : Brightness.dark,
        statusBarBrightness: _night ? Brightness.dark : Brightness.light,
      ),
      child: AnimatedBuilder(
        animation: _t,
        builder: (context, _) {
          final p = WelcomePalette(_t.value);

          return Scaffold(
            backgroundColor: p.skyMid,
            body: Stack(
              children: [
                Positioned.fill(child: WelcomeBackground(p: p)),
                Positioned.fill(child: SkyScene(t: _t)),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: WelcomeHill(height: hillH, asset: _owl, t: _t),
                ),
                SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      _buildTopBar(p),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(28, 0, 28, hillH + 10),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.bottomCenter,
                              child: SizedBox(
                                width: size.width - 56,
                                child: _buildContent(p, titleA, subA, chipA, btn1A, btn2A),
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
          );
        },
      ),
    );
  }

  Widget _buildTopBar(WelcomePalette p) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text('AmanJalan', style: Aj.h(19, color: p.title, w: FontWeight.w800)),
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(left: 3, top: 8),
                decoration: const BoxDecoration(
                  color: Color(0xFFF2A7BE),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          DayNightToggle(t: _t, onTap: _toggle),
        ],
      ),
    );
  }

  Widget _buildContent(
    WelcomePalette p,
    Animation<double> titleA,
    Animation<double> subA,
    Animation<double> chipA,
    Animation<double> btn1A,
    Animation<double> btn2A,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _reveal(
          titleA,
          Text(
            'Jalan Aman,\nJaga Bersama.',
            textAlign: TextAlign.center,
            style: Aj.h(32, color: p.title, w: FontWeight.w800, height: 1.18),
          ),
        ),
        const SizedBox(height: 10),
        _reveal(
          subA,
          Text(
            'Teman perjalananmu di kampus, dari pagi sampai larut malam.',
            textAlign: TextAlign.center,
            style: Aj.b(14.5, color: p.subtitle, w: FontWeight.w600, height: 1.45),
          ),
        ),
        const SizedBox(height: 16),
        _reveal(chipA, _buildStatusChip(p)),
        const SizedBox(height: 22),
        _reveal(
          btn1A,
          WelcomePrimaryButton(
            label: 'Daftar',
            p: p,
            onTap: () => _open(const RegisterScreen()),
          ),
        ),
        const SizedBox(height: 14),
        _reveal(
          btn2A,
          WelcomeOutlineButton(
            label: 'Masuk',
            p: p,
            onTap: () => _open(const LoginScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(WelcomePalette p) {
    final night = _night;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: Container(
        key: ValueKey(night),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: p.statusBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: p.statusBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              night ? Icons.shield_moon_rounded : Icons.wb_sunny_rounded,
              size: 16,
              color: p.statusIcon,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                night
                    ? 'Malam hari? Pengawalan aktif menemanimu'
                    : 'Siang cerah, perjalananmu tetap terpantau',
                style: Aj.b(12.5, color: p.statusText, w: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}