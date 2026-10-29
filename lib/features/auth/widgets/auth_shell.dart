import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:amanjalan/core/theme/aj_theme.dart';
import 'package:amanjalan/features/auth/widgets/auth_mode.dart';
import 'package:amanjalan/features/auth/widgets/auth_palette.dart';
import 'package:amanjalan/features/welcome/widgets/day_night_toggle.dart';
import 'package:amanjalan/features/welcome/widgets/sky_scene.dart';
import 'package:amanjalan/features/welcome/widgets/welcome_background.dart';
import 'package:amanjalan/features/welcome/widgets/welcome_palette.dart';

/// Suasana burung hantu: diam, memperhatikan isian, atau malu (saat sandi diketik).
enum OwlMood { idle, look, shy }

/// Kerangka Login & Daftar: langit siang/malam, bukit, kartu form,
/// dan burung hantu yang mengintip dari balik kartu.
class AuthShell extends StatefulWidget {
  static const owlAsset = 'assets/images/onboarding/owl_thinking.png';

  final String title;
  final String subtitle;
  final ValueListenable<OwlMood> mood;
  final Widget Function(BuildContext context, WelcomePalette p) cardBuilder;
  final Widget Function(BuildContext context, WelcomePalette p) footerBuilder;

  const AuthShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.mood,
    required this.cardBuilder,
    required this.footerBuilder,
  });

  @override
  State<AuthShell> createState() => _AuthShellState();
}

class _AuthShellState extends State<AuthShell> with TickerProviderStateMixin {
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
    duration: const Duration(milliseconds: 1400),
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

  Animation<double> _interval(double a, double b) => CurvedAnimation(
        parent: _enter,
        curve: Interval(a, b, curve: Curves.easeOutCubic),
      );

  Widget _reveal(Animation<double> a, Widget child) {
    return AnimatedBuilder(
      animation: a,
      child: child,
      builder: (context, child) => Opacity(
        opacity: a.value.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, (1 - a.value) * 22),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final keyboardOpen = mq.viewInsets.bottom > 0;

    final headA = _interval(0.05, 0.50);
    final cardA = _interval(0.20, 0.75);
    final footA = _interval(0.40, 0.95);

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
                Positioned(
                  top: mq.padding.top,
                  left: 0,
                  right: 0,
                  height: 250,
                  child: SkyScene(t: _t),
                ),
                if (!keyboardOpen)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 170,
                    child: IgnorePointer(
                      child: CustomPaint(painter: _GroundPainter(p)),
                    ),
                  ),
                SafeArea(
                  child: Column(
                    children: [
                      _buildTopBar(p),
                      Expanded(
                        child: SingleChildScrollView(
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          padding: const EdgeInsets.fromLTRB(24, 58, 24, 28),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _reveal(headA, _buildHeader(p)),
                              const SizedBox(height: 12),
                              _reveal(cardA, _buildCard(context, p)),
                              const SizedBox(height: 14),
                              _reveal(
                                footA,
                                Center(child: widget.footerBuilder(context, p)),
                              ),
                            ],
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
    final canGoBack = Navigator.of(context).canPop();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (canGoBack) ...[
                _BackButton(p: p),
                const SizedBox(width: 12),
              ],
              Text('AmanJalan', style: Aj.h(18, color: p.title, w: FontWeight.w800)),
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

  Widget _buildHeader(WelcomePalette p) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: Aj.h(30, color: p.title, w: FontWeight.w800, height: 1.15),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(right: 112),
                child: Text(
                  widget.subtitle,
                  style: Aj.b(14, color: p.subtitle, w: FontWeight.w600, height: 1.45),
                ),
              ),
            ],
          ),
        ),
        // Burung hantu mengintip dari balik kartu (kartu digambar setelahnya)
        Positioned(
          right: 12,
          bottom: -34,
          child: _OwlPeek(mood: widget.mood, size: 108),
        ),
      ],
    );
  }

  Widget _buildCard(BuildContext context, WelcomePalette p) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
      decoration: BoxDecoration(
        color: p.cardBg,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: p.cardBorder),
        boxShadow: [
          BoxShadow(color: p.cardShadow, blurRadius: 34, offset: const Offset(0, 16)),
        ],
      ),
      child: widget.cardBuilder(context, p),
    );
  }
}

// =====================================================================
// Tombol kembali
// =====================================================================
class _BackButton extends StatefulWidget {
  final WelcomePalette p;
  const _BackButton({required this.p});

  @override
  State<_BackButton> createState() => _BackButtonState();
}

class _BackButtonState extends State<_BackButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    return Semantics(
      button: true,
      label: 'Kembali',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _down = true),
        onTapCancel: () => setState(() => _down = false),
        onTapUp: (_) => setState(() => _down = false),
        onTap: () {
          HapticFeedback.selectionClick();
          Navigator.of(context).maybePop();
        },
        child: AnimatedScale(
          scale: _down ? 0.92 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: p.outlineFill,
              shape: BoxShape.circle,
              border: Border.all(color: p.statusBorder),
              boxShadow: Aj.softShadow,
            ),
            child: Icon(Icons.arrow_back_rounded, size: 21, color: p.title),
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// Burung hantu pengintip: melayang pelan, miring saat memperhatikan,
// turun sedikit (malu) saat kata sandi diketik.
// =====================================================================
class _OwlPeek extends StatefulWidget {
  final ValueListenable<OwlMood> mood;
  final double size;

  const _OwlPeek({required this.mood, required this.size});

  @override
  State<_OwlPeek> createState() => _OwlPeekState();
}

class _OwlPeekState extends State<_OwlPeek> with SingleTickerProviderStateMixin {
  late final AnimationController _bob = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _bob.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;

    return ValueListenableBuilder<OwlMood>(
      valueListenable: widget.mood,
      builder: (context, m, child) {
        return AnimatedSlide(
          offset: Offset(0, m == OwlMood.shy ? 0.34 : 0.0),
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOutBack,
          child: AnimatedRotation(
            turns: m == OwlMood.look
                ? -0.018
                : m == OwlMood.shy
                    ? 0.022
                    : 0.0,
            alignment: Alignment.bottomCenter,
            duration: const Duration(milliseconds: 420),
            curve: Curves.easeOut,
            child: child,
          ),
        );
      },
      child: AnimatedBuilder(
        animation: _bob,
        builder: (context, child) {
          final b = Curves.easeInOut.transform(_bob.value);
          return Transform.translate(
            offset: Offset(0, -4 * b),
            child: Transform.rotate(
              angle: (b - 0.5) * 0.04,
              alignment: Alignment.bottomCenter,
              child: child,
            ),
          );
        },
        child: Image.asset(
          AuthShell.owlAsset,
          width: s,
          height: s,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => SizedBox(
            width: s,
            height: s,
            child: const Icon(Icons.pets_rounded, size: 48, color: Aj.plum),
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// Bukit kecil di dasar halaman
// =====================================================================
class _GroundPainter extends CustomPainter {
  final WelcomePalette p;
  _GroundPainter(this.p);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final back = Path()
      ..moveTo(0, h * 0.50)
      ..quadraticBezierTo(w * 0.28, h * 0.10, w * 0.62, h * 0.42)
      ..quadraticBezierTo(w * 0.84, h * 0.62, w, h * 0.36)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(back, Paint()..color = p.hillBack);

    final front = Path()
      ..moveTo(0, h * 0.70)
      ..quadraticBezierTo(w * 0.42, h * 0.34, w, h * 0.66)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(front, Paint()..color = p.hillFront);

    _tree(canvas, Offset(w * 0.07, h * 0.80), 0.95);
    _tree(canvas, Offset(w * 0.15, h * 0.86), 0.65);
    _tree(canvas, Offset(w * 0.93, h * 0.78), 0.85);

    _flower(canvas, Offset(w * 0.36, h * 0.86), const Color(0xFFF2A7BE));
    _flower(canvas, Offset(w * 0.62, h * 0.82), const Color(0xFFF6D77A));
    _flower(canvas, Offset(w * 0.80, h * 0.90), Colors.white);

    if (p.t > 0.05) {
      const spots = <List<double>>[
        [0.22, 0.60], [0.48, 0.74], [0.72, 0.62], [0.88, 0.70],
      ];
      for (final s in spots) {
        final pos = Offset(w * s[0], h * s[1]);
        canvas.drawCircle(
          pos,
          8,
          Paint()
            ..shader = RadialGradient(colors: [
              const Color(0xFFFFF3A0).withValues(alpha: 0.6 * p.t),
              const Color(0xFFFFF3A0).withValues(alpha: 0.0),
            ]).createShader(Rect.fromCircle(center: pos, radius: 8)),
        );
        canvas.drawCircle(
          pos,
          1.6,
          Paint()..color = const Color(0xFFFFF8C8).withValues(alpha: p.t),
        );
      }
    }
  }

  void _tree(Canvas canvas, Offset base, double s) {
    final t = p.t;
    final trunk = Paint()..color = Color.lerp(const Color(0xFF8C6A55), const Color(0xFF3B2548), t)!;
    final dark = Paint()..color = Color.lerp(const Color(0xFF8DBB7C), const Color(0xFF2F2650), t)!;
    final light = Paint()..color = Color.lerp(const Color(0xFFA9D49A), const Color(0xFF41346A), t)!;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: base.translate(0, -8 * s), width: 5 * s, height: 16 * s),
        Radius.circular(2 * s),
      ),
      trunk,
    );
    canvas.drawCircle(base.translate(0, -26 * s), 16 * s, dark);
    canvas.drawCircle(base.translate(-5 * s, -30 * s), 9 * s, light);
  }

  void _flower(Canvas canvas, Offset base, Color petal) {
    final t = p.t;
    final a = 1 - 0.7 * t;
    canvas.drawLine(
      base,
      base.translate(0, -9),
      Paint()
        ..color = Color.lerp(const Color(0xFF7FAE70), const Color(0xFF3A2D5E), t)!
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(base.translate(0, -11), 3.6, Paint()..color = petal.withValues(alpha: a));
    canvas.drawCircle(
      base.translate(0, -11),
      1.5,
      Paint()..color = const Color(0xFFF2B84B).withValues(alpha: a),
    );
  }

  @override
  bool shouldRepaint(covariant _GroundPainter old) => old.p.t != p.t;
}