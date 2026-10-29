import 'package:flutter/material.dart';

import 'package:amanjalan/core/theme/aj_theme.dart';
import 'package:amanjalan/features/welcome/widgets/welcome_palette.dart';

class WelcomePrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final WelcomePalette p;

  const WelcomePrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    required this.p,
  });

  @override
  Widget build(BuildContext context) {
    return _Pressable(
      onTap: onTap,
      child: Container(
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: p.primary,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(color: p.primaryGlow, blurRadius: 22, offset: const Offset(0, 10)),
          ],
        ),
        child: Text(label, style: Aj.h(15.5, color: p.onPrimary)),
      ),
    );
  }
}

class WelcomeOutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final WelcomePalette p;

  const WelcomeOutlineButton({
    super.key,
    required this.label,
    required this.onTap,
    required this.p,
  });

  @override
  Widget build(BuildContext context) {
    return _Pressable(
      onTap: onTap,
      child: Container(
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: p.outlineFill,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: p.outlineBorder, width: 1.6),
        ),
        child: Text(label, style: Aj.h(15.5, color: p.outlineText)),
      ),
    );
  }
}

class _Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _Pressable({required this.child, required this.onTap});

  @override
  State<_Pressable> createState() => _PressableState();
}

class _PressableState extends State<_Pressable> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}