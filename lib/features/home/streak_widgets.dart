import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:amanjalan/core/theme/aj_theme.dart';
import 'package:amanjalan/core/widgets/aj_common.dart';
import 'package:amanjalan/core/widgets/press_scale.dart';
import 'package:amanjalan/features/home/streak_store.dart';

const _owlAsset = 'assets/images/owl_fire.png';

// Palet api
const _flameTop = Color(0xFFFFC21A);
const _flameMid = Color(0xFFFF8A1F);
const _flameLow = Color(0xFFFF4D2E);
const _fireDeep = Color(0xFFE8590C);
const _fireSoft = Color(0xFFFFF1DE);

// ─────────────────────────────────────────────────────────────
// API (CustomPainter) — berkedip, bergoyang, ada percikan
// ─────────────────────────────────────────────────────────────

class StreakFlame extends StatefulWidget {
  final double size;
  final bool lit;
  final bool animate;

  const StreakFlame({super.key, this.size = 72, this.lit = true, this.animate = true});

  @override
  State<StreakFlame> createState() => _StreakFlameState();
}

class _StreakFlameState extends State<StreakFlame> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(covariant StreakFlame old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    if (widget.lit && widget.animate) {
      if (!_c.isAnimating) _c.repeat();
    } else {
      _c.stop();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size * 1.12,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => CustomPaint(painter: _FlamePainter(_c.value, widget.lit)),
      ),
    );
  }
}

class _FlamePainter extends CustomPainter {
  final double t;
  final bool lit;

  _FlamePainter(this.t, this.lit);

  Path _path(double w, double h) {
    double x(double v) => v * w;
    double y(double v) => v * h;
    return Path()
      ..moveTo(x(.50), y(.02))
      ..cubicTo(x(.62), y(.22), x(.93), y(.38), x(.89), y(.66))
      ..cubicTo(x(.86), y(.89), x(.69), y(.99), x(.50), y(.99))
      ..cubicTo(x(.31), y(.99), x(.14), y(.89), x(.11), y(.66))
      ..cubicTo(x(.09), y(.50), x(.21), y(.40), x(.30), y(.30))
      ..cubicTo(x(.32), y(.42), x(.38), y(.47), x(.43), y(.47))
      ..cubicTo(x(.40), y(.30), x(.44), y(.12), x(.50), y(.02))
      ..close();
  }

  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width;
    final h = s.height;
    final sway = lit ? math.sin(t * 2 * math.pi) * 0.05 : 0.0;
    final pulse = lit ? 1 + math.sin(t * 4 * math.pi) * 0.035 : 1.0;

    if (lit) {
      canvas.drawCircle(
        Offset(w / 2, h * 0.62),
        w * 0.46 * (1 + math.sin(t * 4 * math.pi) * 0.06),
        Paint()
          ..color = _flameMid.withValues(alpha: 0.30)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.16),
      );
    }

    canvas.save();
    canvas.translate(w / 2, h);
    canvas.rotate(sway);
    canvas.scale(1, pulse);
    canvas.translate(-w / 2, -h);

    final rect = Rect.fromLTWH(0, 0, w, h);
    final outer = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: lit
            ? const [_flameTop, _flameMid, _flameLow]
            : const [Color(0xFFD9D0DE), Color(0xFFBDB1C4), Color(0xFFA698AF)],
      ).createShader(rect);
    canvas.drawPath(_path(w, h), outer);

    // inti api
    canvas.save();
    canvas.translate(w / 2, h * 0.965);
    canvas.scale(0.56, 0.56 * (1 + (lit ? math.sin(t * 6 * math.pi) * 0.05 : 0)));
    canvas.translate(-w / 2, -h * 0.965);
    final inner = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: lit
            ? const [Color(0xFFFFF3A8), Color(0xFFFFD43B)]
            : const [Color(0xFFEFE9F2), Color(0xFFDCD3E1)],
      ).createShader(rect);
    canvas.drawPath(_path(w, h), inner);
    canvas.restore();

    canvas.restore();

    // percikan
    if (lit) {
      for (var k = 0; k < 3; k++) {
        final p = (t + k / 3) % 1;
        final cx = w * (0.32 + 0.18 * k) + math.sin(p * 6 + k) * w * 0.04;
        final cy = h * (0.30 - p * 0.30);
        canvas.drawCircle(
          Offset(cx, cy),
          w * 0.028 * (1 - p * 0.5),
          Paint()..color = _flameTop.withValues(alpha: (1 - p) * 0.9),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FlamePainter old) => old.t != t || old.lit != lit;
}

// ─────────────────────────────────────────────────────────────
// MASKOT BURUNG HANTU API (melayang + aura). Kalau gambar tidak ada,
// otomatis jatuh ke api CustomPainter.
// ─────────────────────────────────────────────────────────────

const _fireOwlAsset = 'assets/images/onboarding/owl_fire.png';

const _grayMatrix = <double>[
  0.2126, 0.7152, 0.0722, 0, 0, //
  0.2126, 0.7152, 0.0722, 0, 0,
  0.2126, 0.7152, 0.0722, 0, 0,
  0, 0, 0, 1, 0,
];

class StreakMascot extends StatefulWidget {
  final double size;
  final bool lit;

  const StreakMascot({super.key, this.size = 86, this.lit = true});

  @override
  State<StreakMascot> createState() => _StreakMascotState();
}

class _StreakMascotState extends State<StreakMascot> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    final lit = widget.lit;

    Widget img = Image.asset(
      _fireOwlAsset,
      width: s,
      height: s,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => StreakFlame(size: s * 0.8, lit: lit),
    );
    if (!lit) {
      img = Opacity(opacity: 0.8, child: ColorFiltered(colorFilter: const ColorFilter.matrix(_grayMatrix), child: img));
    }

    return SizedBox(
      width: s,
      height: s,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, child) {
          final wave = math.sin(_c.value * 2 * math.pi);
          return Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              if (lit)
                Container(
                  width: s * (0.78 + 0.05 * wave),
                  height: s * (0.78 + 0.05 * wave),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: _flameMid.withValues(alpha: 0.38), blurRadius: s * 0.35, spreadRadius: s * 0.02),
                    ],
                  ),
                ),
              Transform.translate(
                offset: Offset(0, -s * 0.035 * wave),
                child: Transform.rotate(angle: wave * 0.025, child: child),
              ),
            ],
          );
        },
        child: img,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// KARTU STREAK (di Beranda)
// ─────────────────────────────────────────────────────────────

class StreakCard extends StatelessWidget {
  final VoidCallback onCheckIn;

  const StreakCard({super.key, required this.onCheckIn});

  static const _labels = ['S', 'S', 'R', 'K', 'J', 'S', 'M'];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<StreakState>(
      valueListenable: StreakStore.state,
      builder: (context, s, _) {
        final lit = s.checkedToday;
        final n = s.alive;
        final next = s.next;
        final rank = s.rank;

        return PressScale(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              HapticFeedback.selectionClick();
              showStreakSheet(context);
            },
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFFF4E3), Color(0xFFFFE6D2), Color(0xFFFFDCE6)],
                ),
                border: Border.all(color: const Color(0xFFFFC98F), width: 1.4),
                boxShadow: [
                  BoxShadow(
                    color: _flameMid.withValues(alpha: 0.22),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      StreakMascot(size: 92, lit: lit),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0, end: n.toDouble()),
                                  duration: const Duration(milliseconds: 800),
                                  curve: Curves.easeOutCubic,
                                  builder: (_, v, __) => Text(
                                    '${v.round()}',
                                    style: Aj.h(44, color: _fireDeep, height: 1),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 5),
                                  child: Text('hari', style: Aj.h(17, color: _fireDeep)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text('Streak Aman Beruntun', style: Aj.b(13, color: Aj.ink, w: FontWeight.w800)),
                          ],
                        ),
                      ),
                      _FreezeChip(count: s.freezes),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _weekRow(s),
                  const SizedBox(height: 14),
                  _progress(s, next, rank),
                  const SizedBox(height: 14),
                  lit ? _doneBanner() : _ctaButton(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _weekRow(StreakState s) {
    final today = ajDayNum(DateTime.now());
    final monday = today - (ajDayFromNum(today).weekday - 1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (var i = 0; i < 7; i++)
            _DayDot(
              label: _labels[i],
              day: monday + i,
              today: today,
              checked: s.days.contains(monday + i),
              frozen: s.frozen.contains(monday + i),
            ),
        ],
      ),
    );
  }

  Widget _progress(StreakState s, StreakMilestone? next, StreakMilestone? rank) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(next?.icon ?? Icons.emoji_events_rounded, size: 15, color: _fireDeep),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                next == null ? 'Semua lencana terbuka!' : '${next.days - s.alive} hari lagi → ${next.title}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Aj.b(12.5, color: Aj.ink, w: FontWeight.w800),
              ),
            ),
            if (rank != null) AjPill(rank.title, bg: Colors.white, fg: _fireDeep, size: 10),
          ],
        ),
        const SizedBox(height: 8),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: s.progress),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutCubic,
          builder: (_, v, __) => ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                Container(height: 11, color: Colors.white.withValues(alpha: 0.85)),
                FractionallySizedBox(
                  widthFactor: v.clamp(0.04, 1.0),
                  child: Container(
                    height: 11,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [_flameTop, _flameMid, _flameLow]),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _ctaButton() {
    return PressScale(
      child: GestureDetector(
        onTap: onCheckIn,
        child: Container(
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: const LinearGradient(colors: [_flameMid, _flameLow]),
            boxShadow: [BoxShadow(color: _flameLow.withValues(alpha: 0.38), blurRadius: 14, offset: const Offset(0, 6))],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.local_fire_department_rounded, size: 22, color: Colors.white),
              const SizedBox(width: 8),
              Text('Check-in & Jaga Apimu', style: Aj.h(14.5, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _doneBanner() {
    return Container(
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFB7E1C1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified_rounded, size: 20, color: Color(0xFF2E7D4F)),
          const SizedBox(width: 8),
          Text('Api hari ini menyala! Sampai besok ya', style: Aj.b(13, color: const Color(0xFF2E7D4F), w: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _FreezeChip extends StatelessWidget {
  final int count;

  const _FreezeChip({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBFDDF7)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.shield_rounded, size: 22, color: Color(0xFF3B8EDB)),
          const SizedBox(height: 2),
          Text('×$count', style: Aj.h(13, color: const Color(0xFF3B8EDB))),
        ],
      ),
    );
  }
}

class _DayDot extends StatelessWidget {
  final String label;
  final int day;
  final int today;
  final bool checked;
  final bool frozen;

  const _DayDot({
    required this.label,
    required this.day,
    required this.today,
    required this.checked,
    required this.frozen,
  });

  @override
  Widget build(BuildContext context) {
    final isToday = day == today;
    final future = day > today;

    Widget dot;
    if (checked) {
      dot = Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_flameTop, _flameMid],
          ),
          boxShadow: [BoxShadow(color: _flameMid.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: const Icon(Icons.check_rounded, size: 19, color: Colors.white),
      );
    } else if (frozen) {
      dot = Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFDCEEFB)),
        child: const Icon(Icons.shield_rounded, size: 17, color: Color(0xFF3B8EDB)),
      );
    } else if (isToday) {
      dot = Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: _flameMid, width: 2.2),
        ),
        child: const Icon(Icons.local_fire_department_rounded, size: 17, color: _flameMid),
      );
    } else {
      dot = Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: future ? const Color(0xFFF3EEF5) : const Color(0xFFEFE8F2),
        ),
      );
    }

    return Column(
      children: [
        Text(
          label,
          style: Aj.b(11.5, color: isToday ? _fireDeep : Aj.muted, w: isToday ? FontWeight.w900 : FontWeight.w700),
        ),
        const SizedBox(height: 6),
        dot,
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// DETAIL STREAK (bottom sheet)
// ─────────────────────────────────────────────────────────────

void showStreakSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => AjSheet(
      title: 'Streak Aman Kamu',
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.68),
        child: const SingleChildScrollView(child: _StreakDetail()),
      ),
    ),
  );
}

class _StreakDetail extends StatelessWidget {
  const _StreakDetail();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<StreakState>(
      valueListenable: StreakStore.state,
      builder: (context, s, _) {
        final today = ajDayNum(DateTime.now());
        final monday = today - (ajDayFromNum(today).weekday - 1);
        final start = monday - 21;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _stat(Icons.local_fire_department_rounded, '${s.alive}', 'Saat ini', _flameMid),
                const SizedBox(width: 10),
                _stat(Icons.emoji_events_rounded, '${s.best}', 'Terpanjang', const Color(0xFFB7791F)),
                const SizedBox(width: 10),
                _stat(Icons.shield_rounded, '${s.freezes}', 'Perisai', const Color(0xFF3B8EDB)),
              ],
            ),
            const SizedBox(height: 18),
            Text('4 Minggu Terakhir', style: Aj.h(14.5)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final l in const ['S', 'S', 'R', 'K', 'J', 'S', 'M'])
                  SizedBox(width: 34, child: Center(child: Text(l, style: Aj.b(11.5, color: Aj.muted, w: FontWeight.w800)))),
              ],
            ),
            const SizedBox(height: 8),
            for (var r = 0; r < 4; r++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (var c = 0; c < 7; c++) _calCell(start + r * 7 + c, today, s),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFE8F3FC), borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  const Icon(Icons.shield_rounded, color: Color(0xFF3B8EDB), size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Perisai otomatis menyelamatkan streak kalau kamu lupa check-in 1 hari. Dapat gratis di milestone 7, 30 & 100 hari (maks. ${StreakStore.maxFreezes}).',
                      style: Aj.b(12, color: Aj.ink, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text('Lencana Milestone', style: Aj.h(14.5)),
            const SizedBox(height: 10),
            for (final m in kStreakMilestones) _milestoneTile(m, s),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Widget _stat(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Aj.line),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(value, style: Aj.h(20, color: color)),
            Text(label, style: Aj.b(11, color: Aj.muted, w: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _calCell(int day, int today, StreakState s) {
    final checked = s.days.contains(day);
    final frozen = s.frozen.contains(day);
    final isToday = day == today;
    final future = day > today;
    final date = ajDayFromNum(day);

    Color bg = future ? const Color(0xFFF6F2F8) : const Color(0xFFEFE8F2);
    Color fg = Aj.muted;
    Widget? icon;
    if (checked) {
      bg = _flameMid;
      fg = Colors.white;
      icon = const Icon(Icons.check_rounded, size: 17, color: Colors.white);
    } else if (frozen) {
      bg = const Color(0xFFDCEEFB);
      icon = const Icon(Icons.shield_rounded, size: 15, color: Color(0xFF3B8EDB));
    }

    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: isToday ? Border.all(color: _fireDeep, width: 2) : null,
      ),
      child: icon ?? Text('${date.day}', style: Aj.b(11.5, color: fg, w: FontWeight.w700)),
    );
  }

  Widget _milestoneTile(StreakMilestone m, StreakState s) {
    final done = s.alive >= m.days || s.best >= m.days;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: done ? _fireSoft : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: done ? const Color(0xFFFFC98F) : Aj.line),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: done ? const LinearGradient(colors: [_flameTop, _flameLow], begin: Alignment.topCenter, end: Alignment.bottomCenter) : null,
              color: done ? null : const Color(0xFFEFE8F2),
            ),
            child: Icon(done ? m.icon : Icons.lock_rounded, size: 22, color: done ? Colors.white : Aj.muted),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.title, style: Aj.h(13.5, color: done ? Aj.ink : Aj.muted)),
                const SizedBox(height: 2),
                Text(m.desc, style: Aj.b(11.5, color: Aj.muted, height: 1.3)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${m.days} hari', style: Aj.b(12, color: done ? _fireDeep : Aj.muted, w: FontWeight.w900)),
              if (m.rewardsFreeze)
                const Padding(
                  padding: EdgeInsets.only(top: 3),
                  child: Icon(Icons.shield_rounded, size: 14, color: Color(0xFF3B8EDB)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// PERAYAAN (dialog + confetti)
// ─────────────────────────────────────────────────────────────

Future<void> showStreakCelebration(BuildContext context, StreakResult r) {
  HapticFeedback.heavyImpact();
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Tutup',
    barrierColor: const Color(0xFF1E0A24).withValues(alpha: 0.78),
    transitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (ctx, _, __) => _StreakCelebration(result: r),
    transitionBuilder: (ctx, anim, _, child) =>
        FadeTransition(opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut), child: child),
  );
}

class _Particle {
  final double angle;
  final double speed;
  final double size;
  final double spin;
  final Color color;

  const _Particle(this.angle, this.speed, this.size, this.spin, this.color);
}

class _StreakCelebration extends StatefulWidget {
  final StreakResult result;

  const _StreakCelebration({required this.result});

  @override
  State<_StreakCelebration> createState() => _StreakCelebrationState();
}

class _StreakCelebrationState extends State<_StreakCelebration> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..forward();

  late final List<_Particle> _particles = () {
    final rnd = math.Random(11);
    const colors = [_flameTop, _flameMid, _flameLow, Color(0xFFFF8FAB), Color(0xFF86EFAC), Colors.white];
    return List.generate(
      56,
      (_) => _Particle(
        rnd.nextDouble() * 2 * math.pi,
        150 + rnd.nextDouble() * 260,
        5 + rnd.nextDouble() * 5,
        rnd.nextDouble() * 8,
        colors[rnd.nextInt(colors.length)],
      ),
    );
  }();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.result;
    final m = r.milestone;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _c,
                builder: (_, __) => CustomPaint(painter: _ConfettiPainter(_c.value * 2.6, _particles)),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.elasticOut,
                    builder: (_, v, child) => Transform.scale(scale: v.clamp(0.0, 1.3), child: child),
                    child: const StreakMascot(size: 200),
                  ),
                  const SizedBox(height: 4),
                  AnimatedBuilder(
                    animation: _c,
                    builder: (_, __) {
                      final p = Curves.easeOutCubic.transform((_c.value * 2).clamp(0.0, 1.0));
                      final v = (r.before + (r.after - r.before) * p).round();
                      return Text('$v', style: Aj.h(76, color: Colors.white, height: 1));
                    },
                  ),
                  Text('HARI STREAK AMAN', style: Aj.h(15, color: _flameTop)),
                  const SizedBox(height: 14),
                  Text(
                    m != null
                        ? 'Lencana "${m.title}" terbuka!'
                        : r.usedFreeze
                            ? 'Perisai menyelamatkan streak-mu!'
                            : 'Api kamu makin besar!',
                    textAlign: TextAlign.center,
                    style: Aj.h(19, color: Colors.white, height: 1.25),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    m != null
                        ? m.desc
                        : r.isNewBest
                            ? 'Rekor baru! Ini streak terpanjangmu.'
                            : 'Terus check-in tiap hari supaya Guardian tenang.',
                    textAlign: TextAlign.center,
                    style: Aj.b(13, color: const Color(0xCCFFFFFF), height: 1.4),
                  ),
                  if (r.rewardFreeze || r.usedFreeze) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B8EDB).withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF7DB9EE)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.shield_rounded, size: 18, color: Color(0xFF9CCBF4)),
                          const SizedBox(width: 8),
                          Text(
                            r.usedFreeze ? '1 Perisai terpakai' : '+1 Perisai Streak',
                            style: Aj.b(12.5, color: Colors.white, w: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.fromLTRB(10, 10, 16, 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: Image.asset(
                            _owlAsset,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(Icons.pets_rounded, color: Aj.plum),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            '"Bangga banget sama kamu! Kita jaga api ini bareng-bareng ya."',
                            style: Aj.b(12.5, color: Colors.white, w: FontWeight.w700, height: 1.35),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  PressScale(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        height: 54,
                        width: double.infinity,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(27),
                          gradient: const LinearGradient(colors: [_flameMid, _flameLow]),
                          boxShadow: [BoxShadow(color: _flameLow.withValues(alpha: 0.5), blurRadius: 16, offset: const Offset(0, 7))],
                        ),
                        child: Text('Lanjut', style: Aj.h(16, color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final double sec;
  final List<_Particle> particles;

  _ConfettiPainter(this.sec, this.particles);

  @override
  void paint(Canvas canvas, Size s) {
    final origin = Offset(s.width / 2, s.height * 0.30);
    final fade = (1 - ((sec - 1.6) / 1.0)).clamp(0.0, 1.0);

    for (final p in particles) {
      final dx = math.cos(p.angle) * p.speed * sec * 0.55;
      final dy = math.sin(p.angle) * p.speed * sec * 0.55 + 0.5 * 420 * sec * sec;
      final pos = origin + Offset(dx, dy);

      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(p.spin * sec);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 1.6), const Radius.circular(2)),
        Paint()..color = p.color.withValues(alpha: fade),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => old.sec != sec;
}