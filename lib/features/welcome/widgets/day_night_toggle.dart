import 'package:flutter/material.dart';

import 'package:amanjalan/core/theme/aj_theme.dart';
import 'package:amanjalan/features/welcome/widgets/welcome_palette.dart';

/// Saklar siang/malam dengan bola yang bergeser.
class DayNightToggle extends StatelessWidget {
  final Animation<double> t;
  final VoidCallback onTap;

  const DayNightToggle({super.key, required this.t, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: t,
      builder: (context, _) {
        final v = t.value;
        final p = WelcomePalette(v);

        return Semantics(
          button: true,
          label: 'Ganti mode siang atau malam',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: Container(
              width: 70,
              height: 38,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: p.toggleTrack,
                borderRadius: BorderRadius.circular(22),
                boxShadow: Aj.softShadow,
              ),
              child: Stack(
                children: [
                  // Hiasan di dalam saklar
                  Positioned(
                    left: 10,
                    top: 8,
                    child: Opacity(
                      opacity: v,
                      child: const Icon(Icons.auto_awesome, size: 9, color: Colors.white70),
                    ),
                  ),
                  Positioned(
                    right: 9,
                    bottom: 8,
                    child: Opacity(
                      opacity: 1 - v,
                      child: Icon(Icons.cloud_rounded, size: 14, color: Colors.white.withValues(alpha: 0.9)),
                    ),
                  ),
                  // Bola
                  Align(
                    alignment: Alignment(-1 + 2 * v, 0),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: p.toggleKnob,
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(color: Color(0x33000000), blurRadius: 6, offset: Offset(0, 2)),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Opacity(
                            opacity: 1 - v,
                            child: const Icon(Icons.wb_sunny_rounded, size: 19, color: Color(0xFFFF9F1C)),
                          ),
                          Opacity(
                            opacity: v,
                            child: const Icon(Icons.nightlight_round, size: 18, color: Aj.plum),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}