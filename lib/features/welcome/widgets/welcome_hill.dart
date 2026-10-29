import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'package:amanjalan/core/theme/aj_theme.dart';
import 'package:amanjalan/features/welcome/widgets/welcome_palette.dart';

/// Bagian bawah: gedung kota, bukit, pohon, bunga, lampu jalan, kunang-kunang,
/// dan burung hantu (PNG transparan) yang berdiri di depan bukit.
class WelcomeHill extends StatefulWidget {
  final double height;
  final String asset;
  final Animation<double> t;

  const WelcomeHill({
    super.key,
    required this.height,
    required this.asset,
    required this.t,
  });

  @override
  State<WelcomeHill> createState() => _WelcomeHillState();
}

class _WelcomeHillState extends State<WelcomeHill>
    with TickerProviderStateMixin {
  late final AnimationController _rise = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1900),
  )..forward();

  late final AnimationController _bob = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat(reverse: true);

  late final AnimationController _loop = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 8),
  )..repeat();

  @override
  void dispose() {
    _rise.dispose();
    _bob.dispose();
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final h = widget.height;

    // Ukuran maskot disesuaikan agar proporsional dan tidak melewati tombol Masuk
    final owlH = (h * 0.85).clamp(140.0, 205.0).toDouble();
    final feetY = h * 0.74; // posisi kaki di atas permukaan bukit depan

    return AnimatedBuilder(
      animation: Listenable.merge([widget.t, _rise, _bob, _loop]),
      builder: (context, _) {
        final t = widget.t.value;
        final p = WelcomePalette(t);

        final hillIn = const Interval(0.0, 0.6, curve: Curves.easeOutCubic)
            .transform(_rise.value);
        final owlIn = const Interval(0.3, 1.0, curve: Curves.easeOutBack)
            .transform(_rise.value);
        final bob = Curves.easeInOut.transform(_bob.value);

        final owlTop = feetY - owlH + (1 - owlIn) * owlH * 0.8 - bob * 5;

        return Transform.translate(
          offset: Offset(0, (1 - hillIn) * h),
          child: SizedBox(
            width: width,
            height: h,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Gedung kota
                Positioned.fill(
                  child: CustomPaint(painter: _SkylinePainter(p: p, t: t)),
                ),
                // Bukit belakang
                Positioned.fill(
                  child: CustomPaint(
                    painter: _HillPainter(
                      p: p,
                      t: t,
                      loop: _loop.value,
                      color: p.hillBack,
                      peak: 0.44,
                      center: 0.15,
                    ),
                  ),
                ),
                // Bukit depan + dekorasi
                Positioned.fill(
                  child: CustomPaint(
                    painter: _HillPainter(
                      p: p,
                      t: t,
                      loop: _loop.value,
                      color: p.hillFront,
                      peak: 0.34,
                      center: 0.85,
                      decorate: true,
                    ),
                  ),
                ),
                // Bayangan di tanah (mengecil saat burung naik)
                Positioned(
                  left: (width - owlH * 0.8) / 2,
                  top: feetY - 6,
                  child: Opacity(
                    opacity: owlIn.clamp(0.0, 1.0),
                    child: Container(
                      width: owlH * 0.8,
                      height: 14,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: RadialGradient(colors: [
                          Colors.black.withValues(alpha: 0.18 - bob * 0.05),
                          Colors.black.withValues(alpha: 0.0),
                        ]),
                      ),
                    ),
                  ),
                ),
                // Burung hantu: di DEPAN bukit
                Positioned(
                  left: 0,
                  right: 0,
                  top: owlTop,
                  child: Center(
                    child: Opacity(
                      opacity: owlIn.clamp(0.0, 1.0),
                      child: Transform.rotate(
                        angle: (bob - 0.5) * 0.05,
                        alignment: Alignment.bottomCenter,
                        child: Image.asset(
                          widget.asset,
                          height: owlH,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// =====================================================================
// Gedung kota di belakang bukit
// =====================================================================
class _SkylinePainter extends CustomPainter {
  final WelcomePalette p;
  final double t;

  _SkylinePainter({required this.p, required this.t});

  static const _buildings = <List<double>>[
    [0.02, 0.11, 0.30], [0.12, 0.10, 0.42], [0.22, 0.09, 0.26],
    [0.72, 0.10, 0.34], [0.82, 0.11, 0.46], [0.93, 0.10, 0.28],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final body = Paint()..color = p.skyline;
    final baseY = size.height * 0.64;

    for (var i = 0; i < _buildings.length; i++) {
      final b = _buildings[i];
      final left = size.width * b[0];
      final width = size.width * b[1];
      final height = size.height * b[2];
      final top = baseY - height;

      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(left, top, width, height + 30),
          topLeft: const Radius.circular(3),
          topRight: const Radius.circular(3),
        ),
        body,
      );

      var row = 0;
      for (var y = top + 10; y < baseY - 8; y += 14) {
        for (var c = 0; c < 2; c++) {
          final lit = ((i * 5 + row * 3 + c * 7) % 4) < 2;
          final color = lit
              ? Color.lerp(
                  Colors.white.withValues(alpha: 0.55),
                  const Color(0xFFFFD98A).withValues(alpha: 0.95),
                  t,
                )!
              : Color.lerp(
                  Colors.white.withValues(alpha: 0.35),
                  const Color(0xFF3A2358).withValues(alpha: 0.85),
                  t,
                )!;
          final x = left + width * (0.22 + c * 0.42);
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(x, y, width * 0.22, 7),
              const Radius.circular(1.5),
            ),
            Paint()..color = color,
          );
        }
        row++;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SkylinePainter old) => old.t != t;
}

// =====================================================================
// Bukit + dekorasi
// =====================================================================
class _HillPainter extends CustomPainter {
  final WelcomePalette p;
  final double t;
  final double loop;
  final Color color;
  final double peak;
  final double center;
  final bool decorate;

  _HillPainter({
    required this.p,
    required this.t,
    required this.loop,
    required this.color,
    required this.peak,
    required this.center,
    this.decorate = false,
  });

  double _y(double x, Size size) {
    final u = x / size.width;
    final topY = size.height * (1 - peak);
    final far = math.max(center, 1 - center);
    final k = size.height * 0.20 / (far * far);
    return topY + k * (u - center) * (u - center);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()..moveTo(0, size.height);
    for (double x = 0; x <= size.width; x += 4) {
      path.lineTo(x, _y(x, size));
    }
    path
      ..lineTo(size.width, _y(size.width, size))
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);

    if (!decorate) return;

    final w = size.width;
    _tree(canvas, Offset(w * 0.09, _y(w * 0.09, size)), 1.0);
    _tree(canvas, Offset(w * 0.18, _y(w * 0.18, size) + 4), 0.72);
    _tree(canvas, Offset(w * 0.94, _y(w * 0.94, size)), 0.9);

    _lamp(canvas, Offset(w * 0.80, _y(w * 0.80, size)));

    _flower(canvas, Offset(w * 0.28, _y(w * 0.28, size) + 14), const Color(0xFFF2A7BE));
    _flower(canvas, Offset(w * 0.34, _y(w * 0.34, size) + 22), const Color(0xFFF6D77A));
    _flower(canvas, Offset(w * 0.66, _y(w * 0.66, size) + 14), const Color(0xFFF2A7BE));
    _flower(canvas, Offset(w * 0.88, _y(w * 0.88, size) + 20), Colors.white);

    _fireflies(canvas, size);
  }

  void _tree(Canvas canvas, Offset base, double s) {
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
    canvas.drawCircle(base.translate(0, -11), 1.5, Paint()..color = const Color(0xFFF2B84B).withValues(alpha: a));
  }

  void _lamp(Canvas canvas, Offset base) {
    final head = base.translate(0, -52);
    final pulse = 0.5 + 0.5 * math.sin(2 * math.pi * loop * 2);

    if (t > 0.02) {
      canvas.drawOval(
        Rect.fromCenter(center: base.translate(0, 4), width: 96, height: 20),
        Paint()
          ..shader = RadialGradient(colors: [
            const Color(0xFFFFE08A).withValues(alpha: 0.30 * t),
            const Color(0xFFFFE08A).withValues(alpha: 0.0),
          ]).createShader(Rect.fromCenter(center: base.translate(0, 4), width: 96, height: 20)),
      );
    }

    canvas.drawCircle(
      head,
      24 + 8 * t + 3 * pulse * t,
      Paint()
        ..shader = RadialGradient(colors: [
          const Color(0xFFFFE9A8).withValues(alpha: 0.18 + 0.72 * t),
          const Color(0xFFFFE9A8).withValues(alpha: 0.0),
        ]).createShader(Rect.fromCircle(center: head, radius: 40)),
    );

    final pole = Color.lerp(Aj.plum.withValues(alpha: 0.75), const Color(0xFFB9A3CC), t)!;
    canvas.drawLine(
      base,
      head,
      Paint()
        ..color = pole
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(
      head,
      6,
      Paint()..color = Color.lerp(const Color(0xFFE6DDEA), const Color(0xFFFFE08A), t)!,
    );
    canvas.drawCircle(
      head,
      6,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = pole,
    );
  }

  void _fireflies(Canvas canvas, Size size) {
    if (t < 0.05) return;
    const spots = <List<double>>[
      [0.20, 0.58, 0.00], [0.35, 0.74, 0.30], [0.62, 0.66, 0.55],
      [0.80, 0.52, 0.15], [0.91, 0.64, 0.75], [0.12, 0.80, 0.45],
    ];
    for (final s in spots) {
      final a = 2 * math.pi * (loop + s[2]);
      final pos = Offset(
        size.width * s[0] + math.sin(a) * 9,
        size.height * s[1] + math.cos(a * 2) * 6,
      );
      final glow = (0.4 + 0.6 * math.pow(math.sin(a * 2), 2)) * t;
      canvas.drawCircle(
        pos,
        7,
        Paint()
          ..shader = RadialGradient(colors: [
            const Color(0xFFFFF3A0).withValues(alpha: 0.7 * glow),
            const Color(0xFFFFF3A0).withValues(alpha: 0.0),
          ]).createShader(Rect.fromCircle(center: pos, radius: 7)),
      );
      canvas.drawCircle(pos, 1.7, Paint()..color = const Color(0xFFFFF8C8).withValues(alpha: glow));
    }
  }

  @override
  bool shouldRepaint(covariant _HillPainter old) =>
      old.t != t || old.loop != loop || old.color != color;
}