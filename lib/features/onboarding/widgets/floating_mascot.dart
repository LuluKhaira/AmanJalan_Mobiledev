import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';

import 'package:amanjalan/core/theme/aj_theme.dart';

/// Maskot yang melayang naik-turun sambil bergoyang pelan, terus-menerus.
class FloatingMascot extends StatefulWidget {
  final String asset;
  final double size;

  const FloatingMascot({super.key, required this.asset, required this.size});

  @override
  State<FloatingMascot> createState() => _FloatingMascotState();
}

class _FloatingMascotState extends State<FloatingMascot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat(reverse: true);

  late final Animation<double> _t =
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _t,
      child: Image.asset(
        widget.asset,
        width: widget.size,
        height: widget.size,
        fit: BoxFit.contain,
        // Putih di sudut gambar melebur ke warna background.
        // Hapus 2 baris ini kalau PNG sudah transparan.
        color: Aj.bg,
        colorBlendMode: BlendMode.multiply,
      ),
      builder: (context, child) {
        final dy = lerpDouble(-8, 8, _t.value)!;
        final angle = lerpDouble(-0.035, 0.035, _t.value)!;
        return Transform.translate(
          offset: Offset(0, dy),
          child: Transform.rotate(
            angle: angle,
            alignment: Alignment.bottomCenter,
            child: child,
          ),
        );
      },
    );
  }
}