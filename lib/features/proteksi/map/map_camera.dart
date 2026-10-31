import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:amanjalan/features/proteksi/map/map_constants.dart';

/// Mengatur kamera peta: zoom, geser, animasi, dan "fit ke rute".
class MapCamera {
  MapCamera({required TickerProvider vsync})
      : _anim = AnimationController(
          vsync: vsync,
          duration: const Duration(milliseconds: 420),
        ) {
    _anim.addListener(_onTick);
  }

  final TransformationController tc = TransformationController();
  final AnimationController _anim;

  /// Area peta yang terlihat (di atas panel bawah).
  Size viewport = Size.zero;

  double _fromS = 1, _fromX = 0, _fromY = 0;
  double _toS = 1, _toX = 0, _toY = 0;

  double get minScale => math.max(
        math.max(viewport.width / kWorldW, viewport.height / kWorldH),
        0.3,
      );

  void dispose() {
    _anim.dispose();
    tc.dispose();
  }

  Matrix4 _matrix(double s, double x, double y) =>
      Matrix4(s, 0, 0, 0, 0, s, 0, 0, 0, 0, 1, 0, x, y, 0, 1);

  List<double> _clamp(double s, double x, double y) {
    final cs = s.clamp(minScale, kMaxZoom).toDouble();

    double axis(double v, double view, double world) {
      final lo = view - (world + kBoundaryMargin) * cs;
      final hi = kBoundaryMargin * cs;
      return lo <= hi ? v.clamp(lo, hi).toDouble() : (lo + hi) / 2;
    }

    return [
      cs,
      axis(x, viewport.width, kWorldW),
      axis(y, viewport.height, kWorldH),
    ];
  }

  void moveTo(double s, double x, double y, {bool animate = true}) {
    final t = _clamp(s, x, y);
    if (!animate) {
      _anim.stop();
      tc.value = _matrix(t[0], t[1], t[2]);
      return;
    }
    final m = tc.value.storage;
    _fromS = m[0];
    _fromX = m[12];
    _fromY = m[13];
    _toS = t[0];
    _toX = t[1];
    _toY = t[2];
    _anim.forward(from: 0);
  }

  void _onTick() {
    final t = Curves.easeOutCubic.transform(_anim.value);
    double l(double a, double b) => a + (b - a) * t;
    tc.value = _matrix(
      l(_fromS, _toS),
      l(_fromX, _toX),
      l(_fromY, _toY),
    );
  }

  void zoomBy(double factor, {Offset? focal}) {
    HapticFeedback.selectionClick();
    final f = focal ?? Offset(viewport.width / 2, viewport.height / 2);
    final m = tc.value.storage;
    final s = m[0], x = m[12], y = m[13];
    final newS = (s * factor).clamp(minScale, kMaxZoom).toDouble();
    final k = newS / s;
    moveTo(newS, f.dx - (f.dx - x) * k, f.dy - (f.dy - y) * k);
  }

  /// Pas-kan kamera supaya seluruh rute terlihat di area peta.
  void fitRoute({
    bool animate = true,
    double topOverlay = 0,
    double bottomOverlay = 0,
  }) {
    if (viewport.isEmpty) return;
    const bw = 500.0, bh = 500.0;
    final usableH = math.max(viewport.height - topOverlay - bottomOverlay, 120.0);
    final s = math.min((viewport.width - 40) / bw, (usableH - 20) / bh);
    moveTo(
      s,
      viewport.width / 2 - kRouteCenter.dx * s,
      topOverlay + usableH / 2 - kRouteCenter.dy * s,
      animate: animate,
    );
  }
}
