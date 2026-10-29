import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Langit animasi: matahari ↔ bulan, awan, bintang, bintang jatuh.
class SkyScene extends StatefulWidget {
  /// 0 = siang, 1 = malam
  final Animation<double> t;
  const SkyScene({super.key, required this.t});

  @override
  State<SkyScene> createState() => _SkySceneState();
}

class _SkySceneState extends State<SkyScene> with TickerProviderStateMixin {
  late final AnimationController _twinkle = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat();

  late final AnimationController _drift = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 70),
  )..repeat();

  @override
  void dispose() {
    _twinkle.dispose();
    _drift.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: Listenable.merge([widget.t, _twinkle, _drift]),
          builder: (context, _) => CustomPaint(
            size: Size.infinite,
            painter: _SkyPainter(
              t: widget.t.value,
              twinkle: _twinkle.value,
              drift: _drift.value,
            ),
          ),
        ),
      ),
    );
  }
}

class _SkyPainter extends CustomPainter {
  final double t;
  final double twinkle;
  final double drift;

  _SkyPainter({required this.t, required this.twinkle, required this.drift});

  // x, y (pecahan tinggi langit), ukuran, fase
  static const _stars = <List<double>>[
    [0.08, 0.10, 3.0, 0.00], [0.20, 0.30, 2.0, 0.20], [0.30, 0.08, 4.0, 0.45],
    [0.42, 0.34, 2.0, 0.70], [0.58, 0.07, 3.0, 0.10], [0.70, 0.30, 4.5, 0.55],
    [0.82, 0.12, 2.5, 0.35], [0.92, 0.28, 3.5, 0.80], [0.14, 0.52, 2.0, 0.60],
    [0.88, 0.52, 2.0, 0.25], [0.50, 0.50, 2.0, 0.90], [0.05, 0.38, 2.5, 0.40],
    [0.96, 0.08, 2.0, 0.15], [0.35, 0.60, 2.0, 0.75],
  ];

  // x, y (pecahan tinggi layar), skala, kecepatan (bilangan bulat agar mulus)
  static const _clouds = <List<double>>[
    [0.10, 0.125, 1.0, 1],
    [0.62, 0.235, 0.8, 2],
    [0.35, 0.315, 0.65, 1],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final skyH = size.height * 0.46;
    final bodyR = (w * 0.11).clamp(34.0, 46.0).toDouble();
    final cx = w * 0.5;
    final baseY = size.height * 0.20;
    final drop = bodyR * 3.6;

    _paintStars(canvas, w, skyH);
    _paintShootingStar(canvas, w, skyH);
    _paintSun(canvas, Offset(cx, baseY + drop * t), bodyR, 1 - t);
    _paintMoon(canvas, Offset(cx, baseY + drop * (1 - t)), bodyR, t);
    _paintClouds(canvas, size);
  }

  // ---------------- Matahari ----------------
  void _paintSun(Canvas canvas, Offset c, double r, double o) {
    if (o <= 0.01) return;

    canvas.drawCircle(
      c,
      r * 3.2,
      Paint()
        ..shader = RadialGradient(colors: [
          const Color(0xFFFFD27A).withValues(alpha: 0.55 * o),
          const Color(0xFFFFD27A).withValues(alpha: 0.0),
        ]).createShader(Rect.fromCircle(center: c, radius: r * 3.2)),
    );

    final ray = Paint()
      ..color = const Color(0xFFFFC857).withValues(alpha: 0.85 * o)
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;
    final spin = drift * 2 * math.pi * 3;
    for (var i = 0; i < 12; i++) {
      final a = spin + i * math.pi / 6;
      final d = Offset(math.cos(a), math.sin(a));
      final len = i.isEven ? 1.82 : 1.62;
      canvas.drawLine(c + d * (r * 1.36), c + d * (r * len), ray);
    }

    final rect = Rect.fromCircle(center: c, radius: r);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.3),
          colors: [
            const Color(0xFFFFF3B0).withValues(alpha: o),
            const Color(0xFFFFB347).withValues(alpha: o),
          ],
        ).createShader(rect),
    );
  }

  // ---------------- Bulan ----------------
  void _paintMoon(Canvas canvas, Offset c, double r, double o) {
    if (o <= 0.01) return;

    canvas.drawCircle(
      c,
      r * 3.4,
      Paint()
        ..shader = RadialGradient(colors: [
          const Color(0xFFD9B8FF).withValues(alpha: 0.42 * o),
          const Color(0xFFD9B8FF).withValues(alpha: 0.0),
        ]).createShader(Rect.fromCircle(center: c, radius: r * 3.4)),
    );

    // Cincin halus
    canvas.drawCircle(
      c,
      r * 1.55,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = const Color(0xFFE9D5FF).withValues(alpha: 0.22 * o),
    );

    final crescent = Path.combine(
      PathOperation.difference,
      Path()..addOval(Rect.fromCircle(center: c, radius: r)),
      Path()
        ..addOval(Rect.fromCircle(
          center: c.translate(r * 0.52, -r * 0.2),
          radius: r * 0.86,
        )),
    );
    canvas.drawPath(
      crescent,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFFF8E1).withValues(alpha: o),
            const Color(0xFFF1DFAE).withValues(alpha: o),
          ],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );

    // Kilau kecil di dekat bulan
    final sp = Paint()..color = Colors.white.withValues(alpha: 0.9 * o);
    _sparkle(canvas, c.translate(r * 1.25, -r * 0.7), 5, sp);
    _sparkle(canvas, c.translate(-r * 1.5, r * 0.3), 3.5, sp);
  }

  // ---------------- Bintang ----------------
  void _paintStars(Canvas canvas, double w, double skyH) {
    if (t <= 0.01) return;
    for (final s in _stars) {
      final tw = 0.5 + 0.5 * math.sin(2 * math.pi * (twinkle + s[3]));
      final alpha = t * (0.30 + 0.70 * tw);
      final paint = Paint()..color = Colors.white.withValues(alpha: alpha);
      final pos = Offset(w * s[0], skyH * s[1]);
      if (s[2] >= 3) {
        _sparkle(canvas, pos, s[2] * (0.8 + 0.3 * tw), paint);
      } else {
        canvas.drawCircle(pos, s[2] * 0.6, paint);
      }
    }
  }

  void _sparkle(Canvas canvas, Offset c, double s, Paint paint) {
    final path = Path()
      ..moveTo(c.dx, c.dy - s)
      ..quadraticBezierTo(c.dx, c.dy, c.dx + s, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + s)
      ..quadraticBezierTo(c.dx, c.dy, c.dx - s, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - s)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _paintShootingStar(Canvas canvas, double w, double skyH) {
    if (t < 0.5) return;
    final q = (drift * 7) % 1.0;
    const span = 0.16;
    if (q > span) return;

    final k = q / span;
    final head = Offset(w * (0.96 - 0.5 * k), skyH * (0.04 + 0.42 * k));
    final tail = head + const Offset(54, -28);
    final fade = math.sin(math.pi * k) * ((t - 0.5) * 2);

    canvas.drawLine(
      head,
      tail,
      Paint()
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round
        ..shader = LinearGradient(colors: [
          Colors.white.withValues(alpha: fade),
          Colors.white.withValues(alpha: 0.0),
        ]).createShader(Rect.fromPoints(head, tail)),
    );
  }

  // ---------------- Awan ----------------
  void _paintClouds(Canvas canvas, Size size) {
    final color = Color.lerp(
      Colors.white.withValues(alpha: 0.92),
      const Color(0xFF6A3F8E).withValues(alpha: 0.42),
      t,
    )!;
    final paint = Paint()..color = color;

    for (final c in _clouds) {
      final x = ((c[0] + drift * c[3]) % 1.0) * (size.width + 180) - 110;
      final y = size.height * c[1];
      final s = c[2];

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, 86 * s, 24 * s),
          Radius.circular(12 * s),
        ),
        paint,
      );
      canvas.drawCircle(Offset(x + 28 * s, y + 4 * s), 17 * s, paint);
      canvas.drawCircle(Offset(x + 50 * s, y), 22 * s, paint);
      canvas.drawCircle(Offset(x + 68 * s, y + 8 * s), 13 * s, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SkyPainter old) =>
      old.t != t || old.twinkle != twinkle || old.drift != drift;
}