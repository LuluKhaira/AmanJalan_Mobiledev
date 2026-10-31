import 'package:flutter/material.dart';
import 'package:amanjalan/core/theme/app_colors.dart';
import 'package:amanjalan/features/proteksi/map/map_constants.dart';
import 'package:amanjalan/features/proteksi/models/route_models.dart';

/// Lapisan rute: garis rute, titik penting, marker awal & tujuan.
/// Jalan kaki digambar putus-putus (titik), moda lain berupa garis penuh.
class RoutePainter extends CustomPainter {
  final RouteOption option;
  final String destinationName;
  final Animation<double> draw;
  final Animation<double> pulse;
  final TransformationController tc;

  static final Path _safePath = safeRoutePath();
  static final Path _fastPath = fastRoutePath();

  RoutePainter({
    required this.option,
    required this.destinationName,
    required this.draw,
    required this.pulse,
    required this.tc,
  }) : super(repaint: Listenable.merge([draw, pulse, tc]));

  Path _pathOf(RouteKind k) => k == RouteKind.safest ? _safePath : _fastPath;

  @override
  void paint(Canvas canvas, Size size) {
    final zoom = tc.value.storage[0];
    // Skala penanda: dijaga supaya tetap terbaca saat peta di-zoom out.
    final k = (0.9 / zoom).clamp(1.0, 2.2).toDouble();

    final color = option.color;
    final otherKind = option.isSafest ? RouteKind.fastest : RouteKind.safest;
    final dotted = option.mode == TransportMode.jalanKaki;

    // Rute lain (samar)
    _drawRoute(
      canvas,
      _pathOf(otherKind),
      kindColor(otherKind).withAlpha(90),
      1.0,
      dotted: dotted,
      faded: true,
    );

    // Rute terpilih
    final mid = _drawRoute(
      canvas,
      _pathOf(option.kind),
      color,
      draw.value,
      dotted: dotted,
      faded: false,
    );

    // Gelembung durasi di tengah rute
    if (mid != null && draw.value > 0.7) {
      _drawBubble(canvas, mid, option.mode.icon, option.duration, color, k);
    }

    // Titik penting
    final poiOpacity = ((draw.value - 0.6) / 0.4).clamp(0.0, 1.0);
    if (poiOpacity > 0) {
      for (final poi in option.pois) {
        _drawPoi(canvas, poi, poiOpacity, zoom, k);
      }
    }

    // Titik awal
    final p = pulse.value;
    canvas.save();
    canvas.translate(kStartPoint.dx, kStartPoint.dy);
    canvas.scale(k);
    canvas.drawCircle(
      Offset.zero,
      26 + 30 * p,
      Paint()..color = color.withAlpha((90 * (1 - p)).round()),
    );
    canvas.drawCircle(Offset.zero, 24, Paint()..color = Colors.white);
    canvas.drawCircle(Offset.zero, 19, Paint()..color = color);
    canvas.drawCircle(Offset.zero, 8, Paint()..color = Colors.white);
    _drawPill(canvas, 'Posisi Anda', const Offset(0, 52), color);
    canvas.restore();

    // Titik tujuan
    if (draw.value > 0.8) {
      final endColor = option.isSafest ? AppColors.textDark : Colors.orange.shade900;
      canvas.save();
      canvas.translate(kEndPoint.dx, kEndPoint.dy);
      canvas.scale(1.2 * k);
      canvas.drawCircle(
          Offset.zero, 20, Paint()..color = Colors.black.withAlpha(30));
      final pin = Path()
        ..moveTo(0, 12)
        ..quadraticBezierTo(-16, -12, -10, -20)
        ..quadraticBezierTo(0, -30, 10, -20)
        ..quadraticBezierTo(16, -12, 0, 12);
      canvas.drawPath(pin, Paint()..color = endColor);
      canvas.drawCircle(const Offset(0, -15), 6, Paint()..color = Colors.white);
      _drawPill(canvas, destinationName, const Offset(0, -46), endColor);
      canvas.restore();
    }
  }

  /// Menggambar satu rute. Mengembalikan titik tengah rute.
  Offset? _drawRoute(
    Canvas canvas,
    Path path,
    Color color,
    double progress, {
    required bool dotted,
    required bool faded,
  }) {
    Offset? mid;
    for (final m in path.computeMetrics()) {
      final len = m.length * progress;

      if (dotted) {
        final white = Paint()
          ..color = faded ? Colors.white.withAlpha(140) : Colors.white;
        final fill = Paint()..color = color;
        for (double d = 0; d <= len; d += 22) {
          final t = m.getTangentForOffset(d);
          if (t == null) continue;
          canvas.drawCircle(t.position, faded ? 7 : 10.5, white);
          canvas.drawCircle(t.position, faded ? 5 : 7.5, fill);
        }
      } else {
        final part = m.extractPath(0, len);
        if (!faded) {
          canvas.drawPath(
            part,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 19
              ..strokeCap = StrokeCap.round
              ..strokeJoin = StrokeJoin.round
              ..color = Colors.white,
          );
        }
        canvas.drawPath(
          part,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = faded ? 9 : 12
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..color = color,
        );
      }

      mid = m.getTangentForOffset(m.length * 0.45)?.position;
    }
    return mid;
  }

  void _drawBubble(Canvas canvas, Offset pos, IconData icon, String text,
      Color color, double k) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    const iconSize = 20.0;
    const gap = 6.0;
    final contentW = iconSize + gap + tp.width;

    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.scale(k * 0.9);
    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: contentW + 26,
      height: tp.height + 14,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          rect.shift(const Offset(0, 3)), const Radius.circular(14)),
      Paint()..color = Colors.black.withAlpha(45),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.inflate(3), const Radius.circular(16)),
      Paint()..color = Colors.white,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(13)),
      Paint()..color = color,
    );
    final left = -contentW / 2;
    _paintIcon(canvas, icon, Offset(left + iconSize / 2, 0), iconSize, Colors.white);
    tp.paint(canvas, Offset(left + iconSize + gap, -tp.height / 2));
    canvas.restore();
  }

  void _drawPill(Canvas canvas, String text, Offset center, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final pill = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center,
        width: tp.width + 20,
        height: tp.height + 10,
      ),
      const Radius.circular(12),
    );
    canvas.drawRRect(
      pill.shift(const Offset(0, 2)),
      Paint()..color = Colors.black.withAlpha(30),
    );
    canvas.drawRRect(pill, Paint()..color = Colors.white);
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  void _drawPoi(
      Canvas canvas, MapPoi poi, double opacity, double zoom, double k) {
    final a = (255 * opacity).round();

    canvas.save();
    canvas.translate(poi.pos.dx, poi.pos.dy);
    canvas.scale(k);

    canvas.drawCircle(
      const Offset(0, 3),
      24,
      Paint()..color = Colors.black.withAlpha((40 * opacity).round()),
    );
    canvas.drawCircle(Offset.zero, 22, Paint()..color = Colors.white.withAlpha(a));
    canvas.drawCircle(
      Offset.zero,
      22,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..color = poi.color.withAlpha(a),
    );
    _paintIcon(canvas, poi.icon, Offset.zero, 24, poi.color.withAlpha(a));

    if (zoom >= 0.8) {
      final tp = TextPainter(
        text: TextSpan(
          text: poi.label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: poi.color.withAlpha(a),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      const center = Offset(0, 44);
      final pill = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center,
          width: tp.width + 18,
          height: tp.height + 8,
        ),
        const Radius.circular(12),
      );
      canvas.drawRRect(pill, Paint()..color = Colors.white.withAlpha(a));
      tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
    }
    canvas.restore();
  }

  void _paintIcon(
      Canvas canvas, IconData icon, Offset center, double size, Color color) {
    final tp = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: size,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: color,
        ),
      ),
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant RoutePainter oldDelegate) =>
      oldDelegate.option != option ||
      oldDelegate.destinationName != destinationName;
}
