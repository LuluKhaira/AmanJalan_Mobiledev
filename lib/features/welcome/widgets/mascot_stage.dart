import 'dart:math' as math;
import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';

import 'package:amanjalan/core/theme/aj_theme.dart';
import 'package:amanjalan/features/welcome/widgets/circle_mascot.dart';

/// Panggung maskot: cincin halo berdenyut + maskot melayang + lencana melayang.
class MascotStage extends StatefulWidget {
  final String asset;
  final double size;

  const MascotStage({super.key, required this.asset, required this.size});

  @override
  State<MascotStage> createState() => _MascotStageState();
}

class _MascotStageState extends State<MascotStage>
    with TickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3600),
  )..repeat();

  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    final owl = s * 0.70;

    return SizedBox(
      width: s,
      height: s,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Glow lembut statis
          Container(
            width: s * 0.92,
            height: s * 0.92,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Aj.blushDeep.withValues(alpha: 0.55),
                  Aj.blush.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
          // Cincin berdenyut
          AnimatedBuilder(
            animation: _pulse,
            builder: (context, _) {
              return Stack(
                alignment: Alignment.center,
                children: List.generate(3, (i) {
                  final t = (_pulse.value + i / 3) % 1.0;
                  final d = lerpDouble(owl * 0.95, s, t)!;
                  return Container(
                    width: d,
                    height: d,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Aj.berry.withValues(alpha: (1 - t) * 0.22),
                        width: 1.6,
                      ),
                    ),
                  );
                }),
              );
            },
          ),
          // Maskot: melayang + goyang
          AnimatedBuilder(
            animation: _float,
            child: CircleMascot(asset: widget.asset, size: owl, ring: true),
            builder: (context, child) {
              final t = Curves.easeInOut.transform(_float.value);
              return Transform.translate(
                offset: Offset(0, lerpDouble(-7, 7, t)!),
                child: Transform.rotate(
                  angle: lerpDouble(-0.03, 0.03, t)!,
                  alignment: Alignment.bottomCenter,
                  child: child,
                ),
              );
            },
          ),
          // Lencana melayang
          _Badge(
            controller: _float,
            phase: 0.0,
            alignment: const Alignment(-0.98, -0.42),
            icon: Icons.verified_user_rounded,
            color: Aj.mintDeep,
            bg: Aj.mint,
          ),
          _Badge(
            controller: _float,
            phase: 0.4,
            alignment: const Alignment(0.98, -0.12),
            icon: Icons.location_on_rounded,
            color: Aj.sos,
            bg: Aj.sosSoft,
          ),
          _Badge(
            controller: _float,
            phase: 0.7,
            alignment: const Alignment(-0.72, 0.78),
            icon: Icons.favorite_rounded,
            color: Aj.berry,
            bg: Aj.blush,
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final AnimationController controller;
  final double phase;
  final Alignment alignment;
  final IconData icon;
  final Color color;
  final Color bg;

  const _Badge({
    required this.controller,
    required this.phase,
    required this.alignment,
    required this.icon,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final dy = math.sin((controller.value + phase) * math.pi) * 6;
          return Transform.translate(
            offset: Offset(0, dy),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: Aj.softShadow,
              ),
              child: Center(
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
                  child: Icon(icon, size: 19, color: color),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}