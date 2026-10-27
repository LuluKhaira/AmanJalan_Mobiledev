import 'dart:async';

import 'package:flutter/material.dart';
import 'package:amanjalan/core/theme/aj_theme.dart';
import 'package:amanjalan/features/home/aj_data.dart';

void ajSnack(BuildContext context, String msg, {IconData icon = Icons.check_circle_rounded}) {
  final m = ScaffoldMessenger.of(context);
  m.hideCurrentSnackBar();
  m.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Aj.plum,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Row(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(msg, style: Aj.b(13, color: Colors.white, w: FontWeight.w700))),
        ],
      ),
    ),
  );
}

/// Header atas: logo + "amanJalan" + subjudul, lonceng, avatar.
class AjHeader extends StatelessWidget {
  final String subtitle;
  final VoidCallback? onProfileTap;
  const AjHeader({super.key, required this.subtitle, this.onProfileTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(color: Aj.blush, shape: BoxShape.circle),
            child: const Icon(Icons.shield_rounded, color: Aj.plum, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('amanJalan', style: Aj.h(18, color: Aj.plum, height: 1.15)),
                Text(subtitle, style: Aj.b(12, color: Aj.berry, w: FontWeight.w700)),
              ],
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => ajSnack(context, 'Tidak ada notifikasi baru', icon: Icons.notifications_none_rounded),
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.notifications_none_rounded, color: Aj.plum, size: 26),
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onProfileTap,
            child: const AjAvatar(name: 'Anindya Putri', size: 38, color: Aj.blushDeep),
          ),
        ],
      ),
    );
  }
}

class AjCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final VoidCallback? onTap;
  final double radius;
  final bool shadow;
  final EdgeInsetsGeometry margin;

  const AjCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color = Aj.card,
    this.onTap,
    this.radius = 24,
    this.shadow = true,
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(radius);
    return Container(
      margin: margin,
      decoration: BoxDecoration(color: color, borderRadius: r, boxShadow: shadow ? Aj.softShadow : null),
      child: Material(
        color: Colors.transparent,
        borderRadius: r,
        child: InkWell(
          borderRadius: r,
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class AjPill extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;
  final IconData? icon;
  final bool dot;
  final double size;

  const AjPill(this.text, {super.key, this.bg = Aj.blush, this.fg = Aj.berry, this.icon, this.dot = false, this.size = 11.5});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(width: 6, height: 6, decoration: BoxDecoration(color: fg, shape: BoxShape.circle)),
            const SizedBox(width: 5),
          ],
          if (icon != null) ...[
            Icon(icon, size: size + 2, color: fg),
            const SizedBox(width: 4),
          ],
          Text(text, maxLines: 1, style: Aj.b(size, color: fg, w: FontWeight.w800)),
        ],
      ),
    );
  }
}

class AjAvatar extends StatelessWidget {
  final String name;
  final double size;
  final Color color;
  final bool? online;

  const AjAvatar({super.key, required this.name, this.size = 44, this.color = Aj.blush, this.online});

  String get _initials {
    final p = name.trim().split(RegExp(r'\s+'));
    if (p.length == 1) return p.first.substring(0, 1).toUpperCase();
    return (p[0][0] + p[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Text(_initials, style: Aj.h(size * 0.34, color: Aj.plum)),
          ),
          if (online != null)
            Positioned(
              right: -1,
              bottom: -1,
              child: Container(
                width: size * 0.3,
                height: size * 0.3,
                decoration: BoxDecoration(
                  color: online! ? const Color(0xFF1F6B45) : Colors.grey.shade400,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class AjIconBubble extends StatelessWidget {
  final IconData icon;
  final Color bg;
  final Color fg;
  final double size;

  const AjIconBubble(this.icon, {super.key, this.bg = Aj.blush, this.fg = Aj.berry, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Icon(icon, color: fg, size: size * 0.5),
    );
  }
}

class AjSectionTitle extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final String? subtitle;

  const AjSectionTitle(this.title, {super.key, this.trailing, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Aj.h(17)),
                if (subtitle != null) Text(subtitle!, style: Aj.b(12.5, color: Aj.muted)),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// PETA MINI (digambar dengan CustomPainter, tanpa API peta)
// ─────────────────────────────────────────────────────────────

class RouteMap extends StatelessWidget {
  final double height;
  final double progress; // 0..1 posisi titik pengguna di rute
  final bool showHavens;
  final BorderRadius radius;

  const RouteMap({
    super.key,
    this.height = 140,
    this.progress = 0.55,
    this.showHavens = true,
    this.radius = const BorderRadius.all(Radius.circular(18)),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(painter: _RouteMapPainter(progress, showHavens)),
      ),
    );
  }
}

class _RouteMapPainter extends CustomPainter {
  final double progress;
  final bool havens;
  _RouteMapPainter(this.progress, this.havens);

  @override
  void paint(Canvas canvas, Size s) {
    // latar
    canvas.drawRect(Offset.zero & s, Paint()..color = const Color(0xFFF1ECE9));

    // blok taman
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(s.width * .06, s.height * .08, s.width * .2, s.height * .3), const Radius.circular(10)),
      Paint()..color = const Color(0xFFDCEBDD),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(s.width * .7, s.height * .6, s.width * .24, s.height * .28), const Radius.circular(10)),
      Paint()..color = const Color(0xFFDCEBDD),
    );

    // jalan
    final road = Paint()
      ..color = Colors.white
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    for (final y in [.22, .52, .82]) {
      canvas.drawLine(Offset(0, s.height * y), Offset(s.width, s.height * y + (y == .52 ? 10 : 0)), road);
    }
    for (final x in [.18, .42, .66, .88]) {
      canvas.drawLine(Offset(s.width * x, 0), Offset(s.width * x - 8, s.height), road);
    }

    // rute
    final pts = <Offset>[
      Offset(s.width * .12, s.height * .84),
      Offset(s.width * .30, s.height * .80),
      Offset(s.width * .42, s.height * .54),
      Offset(s.width * .64, s.height * .50),
      Offset(s.width * .70, s.height * .26),
      Offset(s.width * .88, s.height * .22),
    ];
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (final p in pts.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0x33B6788F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 11
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = Aj.plum
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.5
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );

    final metric = path.computeMetrics().first;

    // titik aman
    if (havens) {
      for (final t in [.28, .55, .82]) {
        final pos = metric.getTangentForOffset(metric.length * t)!.position;
        canvas.drawCircle(pos, 8, Paint()..color = Aj.mint);
        canvas.drawCircle(pos, 4.5, Paint()..color = Aj.mintDeep);
      }
    }

    // tujuan
    canvas.drawCircle(pts.last, 8, Paint()..color = Aj.berry);
    canvas.drawCircle(pts.last, 3, Paint()..color = Colors.white);

    // posisi pengguna
    final cur = metric.getTangentForOffset(metric.length * progress.clamp(0.0, 1.0))!.position;
    canvas.drawCircle(cur, 15, Paint()..color = const Color(0x40B6788F));
    canvas.drawCircle(cur, 8, Paint()..color = Colors.white);
    canvas.drawCircle(cur, 5.5, Paint()..color = Aj.berry);
  }

  @override
  bool shouldRepaint(covariant _RouteMapPainter old) => old.progress != progress || old.havens != havens;
}

// ─────────────────────────────────────────────────────────────
// KARTU PERJALANAN AKTIF (dipakai di Beranda & tab Perjalanan)
// ─────────────────────────────────────────────────────────────

class ActiveTripCard extends StatefulWidget {
  final ActiveTrip trip;
  const ActiveTripCard({super.key, required this.trip});

  @override
  State<ActiveTripCard> createState() => _ActiveTripCardState();
}

class _ActiveTripCardState extends State<ActiveTripCard> {
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  // Simulasi: 1 detik nyata ≈ 10 detik perjalanan supaya demo terasa hidup.
  double get _progress {
    final sec = DateTime.now().difference(widget.trip.startedAt).inSeconds * 10;
    return (sec / (widget.trip.etaMin * 60)).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.trip;
    final p = _progress;
    final remain = ((1 - p) * t.etaMin).ceil();

    return AjCard(
      color: Aj.plum,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AjPill('PERJALANAN AKTIF', bg: Color(0x33FFFFFF), fg: Colors.white, dot: true, size: 10.5),
              const Spacer(),
              Text(p >= 1 ? 'Sudah sampai' : '$remain mnt lagi', style: Aj.b(13, color: Colors.white, w: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 12),
          Text('${t.from} → ${t.to}', style: Aj.h(16, color: Colors.white)),
          const SizedBox(height: 4),
          Text('Dipantau ${t.guardians.length} guardian • ${t.havens} titik aman dilewati', style: Aj.b(12.5, color: const Color(0xCCFFFFFF))),
          const SizedBox(height: 12),
          RouteMap(height: 120, progress: p),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: p,
              minHeight: 7,
              backgroundColor: const Color(0x33FFFFFF),
              valueColor: const AlwaysStoppedAnimation(Aj.blushDeep),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    TripStore.finish();
                    ajSnack(context, 'Tiba dengan aman. Perjalanan tersimpan di Profil › Riwayat.');
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Aj.plum,
                    minimumSize: const Size.fromHeight(46),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                  label: Text('Saya Sudah Sampai', style: Aj.b(14, color: Aj.plum, w: FontWeight.w800)),
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: () {
                  TripStore.finish(status: TripStatus.batal);
                  ajSnack(context, 'Perjalanan dibatalkan', icon: Icons.close_rounded);
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(color: const Color(0x26FFFFFF), borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.close_rounded, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// KARTU SOS: tahan 3 detik
// ─────────────────────────────────────────────────────────────

class SosHoldCard extends StatefulWidget {
  /// Dipanggil setelah ditahan 3 detik (mis. buka EmergencyScreen).
  final VoidCallback? onTrigger;
  const SosHoldCard({super.key, this.onTrigger});

  @override
  State<SosHoldCard> createState() => _SosHoldCardState();
}

class _SosHoldCardState extends State<SosHoldCard> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 3))
    ..addStatusListener((s) {
      if (s == AnimationStatus.completed) _fire();
    });

  void _fire() {
    _c.reset();
    if (widget.onTrigger != null) {
      widget.onTrigger!();
      return;
    }
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        icon: const AjIconBubble(Icons.sos_rounded, bg: Aj.sosSoft, fg: Aj.sos, size: 56),
        title: Text('SOS terkirim', style: Aj.h(18)),
        content: Text(
          'Sinyal darurat beserta lokasi live dikirim ke 2 guardian dan Hotline 112.\n\n(Simulasi — belum terhubung backend)',
          textAlign: TextAlign.center,
          style: Aj.b(13.5, color: Aj.muted),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Saya Aman, Batalkan', style: Aj.b(14, color: Aj.berry, w: FontWeight.w800))),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFC62828), Color(0xFF9F1717)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Color(0x40B71C1C), blurRadius: 18, offset: Offset(0, 8))],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: Aj.sosSoft, shape: BoxShape.circle),
            child: Text('SOS', style: Aj.h(14, color: Aj.sos, w: FontWeight.w800)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tekan SOS Mendesak', style: Aj.h(15, color: Colors.white)),
                const SizedBox(height: 2),
                Text('Kirim sinyal darurat ke 2 Guardian & Hotline 112', style: Aj.b(12, color: const Color(0xDDFFFFFF), height: 1.25)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTapDown: (_) => _c.forward(),
            onTapUp: (_) => _c.reverse(),
            onTapCancel: () => _c.reverse(),
            child: AnimatedBuilder(
              animation: _c,
              builder: (_, __) {
                final secs = (3 - (_c.value * 3)).ceil().clamp(1, 3);
                return Container(
                  width: 86,
                  height: 56,
                  decoration: BoxDecoration(color: const Color(0x2EFFFFFF), borderRadius: BorderRadius.circular(18)),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(widthFactor: _c.value, child: Container(color: const Color(0x66FFFFFF))),
                      ),
                      Text(
                        _c.value == 0 ? 'TAHAN\n3 DTIK' : 'LEPAS\n$secs…',
                        textAlign: TextAlign.center,
                        style: Aj.b(11.5, color: Colors.white, w: FontWeight.w800, height: 1.25),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SHEET & QR (dipakai Beranda dan Profil)
// ─────────────────────────────────────────────────────────────

class AjSheet extends StatelessWidget {
  final String title;
  final Widget child;
  const AjSheet({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(22, 12, 22, 24 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(color: Aj.bg, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFDCD3D6), borderRadius: BorderRadius.circular(4)))),
          const SizedBox(height: 16),
          Text(title, style: Aj.h(18)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class AjQrBox extends StatelessWidget {
  const AjQrBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 200,
          height: 200,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: Aj.softShadow),
          child: CustomPaint(painter: _QrPainter(), size: const Size.square(172)),
        ),
        const SizedBox(height: 14),
        Text('Minta temanmu memindai kode ini untuk saling menjaga.', textAlign: TextAlign.center, style: Aj.b(13, color: Aj.muted)),
        const SizedBox(height: 4),
        Text('ID PROTEKSI  #AJ-94821', style: Aj.b(12.5, color: Aj.berry, w: FontWeight.w800)),
      ],
    );
  }
}

/// Pola QR dekoratif (dummy, bukan QR sungguhan).
class _QrPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    const n = 21;
    final cell = s.width / n;
    final p = Paint()..color = Aj.plum;
    bool finder(int x, int y) => (x < 7 && y < 7) || (x > n - 8 && y < 7) || (x < 7 && y > n - 8);

    for (var y = 0; y < n; y++) {
      for (var x = 0; x < n; x++) {
        if (finder(x, y)) continue;
        final v = (x * 7 + y * 13 + x * y * 3) % 5;
        if (v < 2) canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x * cell + .5, y * cell + .5, cell - 1, cell - 1), const Radius.circular(2)), p);
      }
    }
    void eye(int ox, int oy) {
      final r = Rect.fromLTWH(ox * cell, oy * cell, cell * 7, cell * 7);
      canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(6)), p);
      canvas.drawRRect(RRect.fromRectAndRadius(r.deflate(cell), const Radius.circular(4)), Paint()..color = Colors.white);
      canvas.drawRRect(RRect.fromRectAndRadius(r.deflate(cell * 2), const Radius.circular(3)), p);
    }

    eye(0, 0);
    eye(n - 7, 0);
    eye(0, n - 7);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}