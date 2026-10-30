import 'package:flutter/material.dart';
import 'package:amanjalan/core/theme/aj_theme.dart';
import 'package:amanjalan/core/widgets/aj_common.dart';

void showRadarSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const AjSheet(title: 'Radar Live • Salsabila', child: _RadarSheet()),
  );
}

class _RadarSheet extends StatefulWidget {
  const _RadarSheet();

  @override
  State<_RadarSheet> createState() => _RadarSheetState();
}

class _RadarSheetState extends State<_RadarSheet> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 240,
          width: double.infinity,
          child: AnimatedBuilder(animation: _c, builder: (_, __) => CustomPaint(painter: _RadarPainter(_c.value))),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.near_me_outlined, color: Aj.berry, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text('Salsa berada 340 m dari Anda, bergerak ke arah Kos Melati', style: Aj.b(13, w: FontWeight.w700, height: 1.3))),
          ],
        ),
      ],
    );
  }
}

class _RadarPainter extends CustomPainter {
  final double t;
  _RadarPainter(this.t);

  @override
  void paint(Canvas canvas, Size s) {
    final c = Offset(s.width / 2, s.height / 2);
    final maxR = s.height / 2;
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0xFFE6D9DE);
    for (final r in [.33, .66, 1.0]) {
      canvas.drawCircle(c, maxR * r, ring);
    }
    for (var i = 0; i < 3; i++) {
      final p = (t + i / 3) % 1;
      canvas.drawCircle(
        c,
        maxR * p,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = Color.fromRGBO(138, 63, 92, (1 - p) * .45),
      );
    }
    canvas.drawCircle(c, 9, Paint()..color = Aj.plum);
    canvas.drawCircle(c, 3.5, Paint()..color = Colors.white);
    final f = Offset(c.dx + maxR * .55, c.dy - maxR * .42);
    canvas.drawCircle(f, 16, Paint()..color = const Color(0x40B6788F));
    canvas.drawCircle(f, 9, Paint()..color = Aj.berry);
    canvas.drawCircle(f, 3.5, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _RadarPainter old) => old.t != t;
}
