import 'package:flutter/material.dart';

/// Memotong gambar maskot tepat di lingkaran pink-nya (tanpa sudut putih).
class CircleMascot extends StatelessWidget {
  final String asset;
  final double size;
  final bool ring;

  const CircleMascot({
    super.key,
    required this.asset,
    required this.size,
    this.ring = false,
  });

  /// Lingkaran pink memenuhi sekitar 70% lebar gambar asli.
  static const double _zoom = 1.42;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: ring ? Border.all(color: Colors.white, width: 5) : null,
        boxShadow: const [
          BoxShadow(
            color: Color(0x262B1B33),
            blurRadius: 28,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: ClipOval(
        child: Transform.scale(
          scale: _zoom,
          child: Image.asset(asset, width: size, height: size, fit: BoxFit.cover),
        ),
      ),
    );
  }
}