import 'package:flutter/material.dart';

// ==========================================
// PENGATURAN PETA
// ==========================================
const double kWorldW = 1400;
const double kWorldH = 1800;
const double kBoundaryMargin = 60;
const double kMaxZoom = 3.5;

// Jalur jalan (koordinat dunia)
const kGridX = [120.0, 380.0, 600.0, 820.0, 1040.0, 1280.0];
const kGridY = [140.0, 420.0, 700.0, 920.0, 1140.0, 1380.0, 1660.0];

const kStartPoint = Offset(600, 1140);
const kEndPoint = Offset(1040, 700);
const kRouteCenter = Offset(820, 920);

Path safeRoutePath() {
  return Path()
    ..moveTo(600, 1140)
    ..lineTo(600, 960)
    ..quadraticBezierTo(600, 920, 640, 920)
    ..lineTo(780, 920)
    ..quadraticBezierTo(820, 920, 820, 880)
    ..lineTo(820, 740)
    ..quadraticBezierTo(820, 700, 860, 700)
    ..lineTo(1040, 700);
}

Path fastRoutePath() {
  const pts = [
    Offset(600, 1140),
    Offset(690, 1040),
    Offset(760, 900),
    Offset(900, 800),
    Offset(1040, 700),
  ];
  final p = Path()..moveTo(pts.first.dx, pts.first.dy);
  for (var i = 1; i < pts.length - 1; i++) {
    final mid = Offset(
      (pts[i].dx + pts[i + 1].dx) / 2,
      (pts[i].dy + pts[i + 1].dy) / 2,
    );
    p.quadraticBezierTo(pts[i].dx, pts[i].dy, mid.dx, mid.dy);
  }
  p.lineTo(pts.last.dx, pts.last.dy);
  return p;
}

Path lakePath() => Path()
  ..moveTo(1020, 0)
  ..lineTo(kWorldW, 0)
  ..lineTo(kWorldW, 360)
  ..cubicTo(1300, 400, 1180, 340, 1130, 250)
  ..cubicTo(1090, 180, 1040, 120, 1020, 0)
  ..close();

Path pondPath() => Path()
  ..addOval(Rect.fromCenter(
      center: const Offset(250, 1560), width: 260, height: 170));
