import 'package:flutter/material.dart';
import 'package:amanjalan/core/theme/app_colors.dart';

/// Logo resmi AmanJalan berbentuk pin lokasi plum dengan siluet figur pink
/// dan aksen sage di atas latar belakang lingkaran blush pink.
class AppLogo extends StatelessWidget {
  final double size;
  final VoidCallback? onTap;

  const AppLogo({
    super.key,
    this.size = 44,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget logoWidget = ClipOval(
      child: Image.asset(
        'assets/images/logo.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallbackVector(),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: logoWidget,
      );
    }

    return logoWidget;
  }

  Widget _buildFallbackVector() {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.softPink,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: CustomPaint(
          size: Size(size * 0.65, size * 0.65),
          painter: _LogoMarkPainter(),
        ),
      ),
    );
  }
}

/// Fallback painter jika asset belum ter-cache
class _LogoMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Dark Plum Pin teardrop
    final pinPaint = Paint()
      ..color = const Color(0xFF35203B)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final pinPath = Path();
    pinPath.moveTo(w * 0.5, h * 0.98);
    pinPath.cubicTo(w * 0.05, h * 0.65, 0, h * 0.35, w * 0.5, h * 0.05);
    pinPath.cubicTo(w, h * 0.35, w * 0.95, h * 0.65, w * 0.5, h * 0.98);
    pinPath.close();
    canvas.drawPath(pinPath, pinPaint);

    // Pink Person Head
    final figurePaint = Paint()
      ..color = const Color(0xFFF3C2D0)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    canvas.drawCircle(Offset(w * 0.5, h * 0.35), w * 0.16, figurePaint);

    // Pink Person Body with bottom arch
    final bodyPath = Path();
    bodyPath.moveTo(w * 0.32, h * 0.68);
    bodyPath.cubicTo(w * 0.32, h * 0.48, w * 0.68, h * 0.48, w * 0.68, h * 0.68);
    bodyPath.cubicTo(w * 0.58, h * 0.60, w * 0.42, h * 0.60, w * 0.32, h * 0.68);
    bodyPath.close();
    canvas.drawPath(bodyPath, figurePaint);

    // Bottom Sage Diamond / Triangle Accent
    final accentPaint = Paint()
      ..color = const Color(0xFF8BA59B)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final accentPath = Path();
    accentPath.moveTo(w * 0.5, h * 0.88);
    accentPath.lineTo(w * 0.46, h * 0.78);
    accentPath.lineTo(w * 0.5, h * 0.74);
    accentPath.lineTo(w * 0.54, h * 0.78);
    accentPath.close();
    canvas.drawPath(accentPath, accentPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
