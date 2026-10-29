import 'package:flutter/material.dart';

import 'package:amanjalan/features/welcome/widgets/welcome_palette.dart';

class WelcomeBackground extends StatelessWidget {
  final WelcomePalette p;
  const WelcomeBackground({super.key, required this.p});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [p.skyTop, p.skyMid, p.skyBottom],
              stops: const [0.0, 0.55, 1.0],
            ),
          ),
        ),
        Positioned(
          left: -100,
          top: -100,
          child: _blob(330, p.blobA),
        ),
        Positioned(
          right: -130,
          top: 330,
          child: _blob(300, p.blobB),
        ),
      ],
    );
  }

  Widget _blob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0.0)],
        ),
      ),
    );
  }
}