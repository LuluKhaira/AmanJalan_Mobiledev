import 'package:flutter/material.dart';

import 'package:amanjalan/core/theme/aj_theme.dart';

class PageIndicator extends StatelessWidget {
  final int count;
  final int current;

  const PageIndicator({super.key, required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? Aj.plum : Aj.plum.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(8),
          ),
        );
      }),
    );
  }
}