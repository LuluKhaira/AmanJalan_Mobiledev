import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:amanjalan/features/proteksi/map/map_constants.dart';

/// Lapisan dasar peta: blok bangunan, taman, danau, jalan, dan nama jalan.
class BaseMapPainter extends CustomPainter {
  const BaseMapPainter();

  static final Path _lake = lakePath();
  static final Path _pond = pondPath();
  static final Path _water = Path.combine(PathOperation.union, _lake, _pond);
  static final Path _dry = Path.combine(
    PathOperation.difference,
    Path()..addRect(const Rect.fromLTWH(0, 0, kWorldW, kWorldH)),
    _water,
  );

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, kWorldW, kWorldH),
      Paint()..color = const Color(0xFFF1F8F1),
    );

    _drawBlocks(canvas);

    canvas.drawPath(_water, Paint()..color = const Color(0xFFD4E8F0));
    canvas.drawPath(
      _water,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..color = const Color(0xFFBFDCE8),
    );

    canvas.save();
    canvas.clipPath(_dry);
    _drawRoads(canvas);
    canvas.restore();

    final alley = fastRoutePath();
    canvas.drawPath(
      alley,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 15
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFD9D9D9),
    );
    canvas.drawPath(
      alley,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9
        ..strokeCap = StrokeCap.round
        ..color = Colors.white,
    );

    const road = Color(0xFF8E998E);
    _label(canvas, 'Jl. Jenderal Sudirman', const Offset(960, 1140), color: road);
    _label(canvas, 'Jl. Imam Bonjol', const Offset(480, 700), color: road);
    _label(canvas, 'Jl. Ahmad Yani', const Offset(700, 420), color: road);
    _label(canvas, 'Jl. Engku Putri', const Offset(380, 1000),
        angle: -math.pi / 2, color: road);
    _label(canvas, 'Jl. Raja Ali Haji', const Offset(1040, 1010),
        angle: -math.pi / 2, color: road);
    _label(canvas, 'Jl. Pramuka', const Offset(820, 1260),
        angle: -math.pi / 2, color: road);
    _label(canvas, 'Danau', const Offset(1230, 140),
        size: 20, color: const Color(0xFF7FA9BA));
  }

  void _drawRoads(Canvas canvas) {
    final majorX = {380.0, 600.0, 820.0, 1040.0};
    final majorY = {420.0, 700.0, 920.0, 1140.0, 1380.0};

    Paint outline(double w) => Paint()
      ..color = const Color(0xFFD4D4D4)
      ..strokeWidth = w
      ..strokeCap = StrokeCap.butt;
    Paint fill(double w) => Paint()
      ..color = Colors.white
      ..strokeWidth = w
      ..strokeCap = StrokeCap.butt;

    final lines = <MapEntry<Offset, Offset>>[];
    final widths = <double>[];

    for (final x in kGridX) {
      lines.add(MapEntry(Offset(x, 0), Offset(x, kWorldH)));
      widths.add(majorX.contains(x) ? 22 : 12);
    }
    for (final y in kGridY) {
      lines.add(MapEntry(Offset(0, y), Offset(kWorldW, y)));
      widths.add(majorY.contains(y) ? 22 : 12);
    }

    for (var i = 0; i < lines.length; i++) {
      canvas.drawLine(lines[i].key, lines[i].value, outline(widths[i] + 7));
    }
    for (var i = 0; i < lines.length; i++) {
      canvas.drawLine(lines[i].key, lines[i].value, fill(widths[i]));
    }
  }

  void _drawBlocks(Canvas canvas) {
    final xs = [0.0, ...kGridX, kWorldW];
    final ys = [0.0, ...kGridY, kWorldH];
    const gap = 30.0;
    const palette = [Color(0xFFE2E8E2), Color(0xFFE6E3DD), Color(0xFFDDE5E0)];
    final parkPaint = Paint()..color = const Color(0xFFD2E8D2);
    final treePaint = Paint()..color = const Color(0xFFBFDDBF);

    for (var i = 0; i < xs.length - 1; i++) {
      for (var j = 0; j < ys.length - 1; j++) {
        final left = xs[i] + (i == 0 ? 14 : gap);
        final right = xs[i + 1] - (i == xs.length - 2 ? 14 : gap);
        final top = ys[j] + (j == 0 ? 14 : gap);
        final bottom = ys[j + 1] - (j == ys.length - 2 ? 14 : gap);
        if (right - left < 40 || bottom - top < 40) continue;

        final rect = Rect.fromLTRB(left, top, right, bottom);
        final rng = math.Random(i * 31 + j * 17 + 5);
        final kind = rng.nextDouble();
        final color = palette[rng.nextInt(palette.length)];
        final paint = Paint()..color = color;

        if (kind < 0.16) {
          canvas.drawRRect(
              RRect.fromRectAndRadius(rect, const Radius.circular(22)),
              parkPaint);
          for (var t = 0; t < 7; t++) {
            canvas.drawCircle(
              Offset(
                rect.left + 20 + rng.nextDouble() * (rect.width - 40),
                rect.top + 20 + rng.nextDouble() * (rect.height - 40),
              ),
              8 + rng.nextDouble() * 6,
              treePaint,
            );
          }
        } else if (kind < 0.55) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
                rect.deflate(12), const Radius.circular(14)),
            paint,
          );
        } else {
          final horizontal = rng.nextBool();
          final a = horizontal
              ? Rect.fromLTRB(rect.left, rect.top, rect.center.dx - 8, rect.bottom)
              : Rect.fromLTRB(rect.left, rect.top, rect.right, rect.center.dy - 8);
          final b = horizontal
              ? Rect.fromLTRB(rect.center.dx + 8, rect.top, rect.right, rect.bottom)
              : Rect.fromLTRB(rect.left, rect.center.dy + 8, rect.right, rect.bottom);
          canvas.drawRRect(
              RRect.fromRectAndRadius(a.deflate(10), const Radius.circular(12)),
              paint);
          canvas.drawRRect(
              RRect.fromRectAndRadius(b.deflate(10), const Radius.circular(12)),
              paint);
        }
      }
    }
  }

  void _label(
    Canvas canvas,
    String text,
    Offset center, {
    double angle = 0,
    double size = 15,
    Color color = const Color(0xFF8E998E),
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: size,
          color: color,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant BaseMapPainter oldDelegate) => false;
}
