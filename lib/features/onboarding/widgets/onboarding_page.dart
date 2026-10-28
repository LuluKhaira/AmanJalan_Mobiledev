import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'package:amanjalan/core/theme/aj_theme.dart';
import 'package:amanjalan/features/onboarding/models/onboarding_data.dart';
import 'package:amanjalan/features/onboarding/widgets/floating_mascot.dart';

class OnboardingPage extends StatelessWidget {
  final OnboardingData data;

  /// 0 = tepat di tengah, -1 = keluar ke kiri, 1 = menunggu di kanan.
  final double delta;

  const OnboardingPage({super.key, required this.data, required this.delta});

  @override
  Widget build(BuildContext context) {
    final d = delta.abs().clamp(0.0, 1.0);
    final width = MediaQuery.sizeOf(context).width;
    final mascotSize = math.min(width * 0.88, 340.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Opacity(
                opacity: 1 - d,
                child: Transform.scale(
                  scale: 1 - 0.12 * d,
                  child: FloatingMascot(asset: data.image, size: mascotSize),
                ),
              ),
            ),
          ),
          Opacity(
            opacity: 1 - d,
            child: Transform.translate(
              offset: Offset(delta * 40, 0),
              child: Column(
                children: [
                  Text(
                    data.title,
                    textAlign: TextAlign.center,
                    style: Aj.h(26, color: Aj.plum, height: 1.25),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    data.subtitle,
                    textAlign: TextAlign.center,
                    style: Aj.b(14.5, color: Aj.muted, w: FontWeight.w500, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}