import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:amanjalan/core/theme/aj_theme.dart';
import 'package:amanjalan/core/widgets/aj_common.dart';
import 'package:amanjalan/core/widgets/press_scale.dart';
import 'package:amanjalan/features/home/aj_data.dart';

// ─────────────────────────────────────────────────────────────
// Widget kecil yang dipakai ulang di semua layar Perjalanan.
// ─────────────────────────────────────────────────────────────

const _owlAsset = 'assets/images/owl_fire.png';

/// Maskot burung hantu. Kalau aset tidak ada, jatuh ke ikon.
class PjMascot extends StatelessWidget {
  final double size;
  const PjMascot({super.key, this.size = 88});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _owlAsset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => AjIconBubble(Icons.verified_user_rounded, bg: Aj.blush, fg: Aj.berry, size: size * .7),
    );
  }
}

AppBar pjAppBar(BuildContext context, String title, {List<Widget>? actions}) {
  return AppBar(
    backgroundColor: Aj.bg,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
    titleSpacing: 0,
    iconTheme: const IconThemeData(color: Aj.plum),
    title: Text(title, style: Aj.h(18)),
    actions: actions,
  );
}

enum PjButtonStyle { primary, soft, outline, danger }

class PjButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final PjButtonStyle style;
  final double height;

  const PjButton(
    this.label, {
    super.key,
    this.icon,
    this.onTap,
    this.style = PjButtonStyle.primary,
    this.height = 54,
  });

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg, Color? border) = switch (style) {
      PjButtonStyle.primary => (Aj.plum, Colors.white, null),
      PjButtonStyle.soft => (Aj.blush, Aj.berry, null),
      PjButtonStyle.outline => (Colors.white, Aj.plum, Aj.plum),
      PjButtonStyle.danger => (Aj.sos, Colors.white, null),
    };

    return PressScale(
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap == null
              ? null
              : () {
                  HapticFeedback.selectionClick();
                  onTap!();
                },
          child: Container(
            height: height,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: border == null ? null : Border.all(color: border, width: 1.6),
              boxShadow: style == PjButtonStyle.primary
                  ? const [BoxShadow(color: Color(0x404A1D5C), blurRadius: 14, offset: Offset(0, 6))]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[Icon(icon, size: 20, color: fg), const SizedBox(width: 8)],
                Flexible(child: Text(label, overflow: TextOverflow.ellipsis, style: Aj.h(14.5, color: fg))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Judul langkah bernomor (1, 2, 3 …) supaya alur form mudah diikuti.
class PjStep extends StatelessWidget {
  final int number;
  final String title;
  final String? hint;
  const PjStep(this.number, this.title, {super.key, this.hint});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 6),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: Aj.plum, shape: BoxShape.circle),
            child: Text('$number', style: Aj.h(12, color: Colors.white)),
          ),
          const SizedBox(width: 10),
          Text(title, style: Aj.h(15)),
          if (hint != null) ...[
            const SizedBox(width: 6),
            Text(hint!, style: Aj.b(12, color: Aj.muted)),
          ],
        ],
      ),
    );
  }
}

class PjStatBox extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const PjStatBox(this.icon, this.value, this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: Aj.sand, borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            Icon(icon, size: 18, color: Aj.berry),
            const SizedBox(height: 4),
            FittedBox(fit: BoxFit.scaleDown, child: Text(value, style: Aj.h(14))),
            Text(label, style: Aj.b(10.5, color: Aj.muted)),
          ],
        ),
      ),
    );
  }
}

class PjInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool last;
  const PjInfoRow(this.icon, this.label, this.value, {super.key, this.last = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: last ? null : const Border(bottom: BorderSide(color: Aj.line)),
      ),
      child: Row(
        children: [
          AjIconBubble(icon, bg: Aj.sand, fg: Aj.berry, size: 36),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: Aj.b(12.5, color: Aj.muted))),
          const SizedBox(width: 8),
          Flexible(child: Text(value, textAlign: TextAlign.right, style: Aj.b(13.5, w: FontWeight.w800))),
        ],
      ),
    );
  }
}

/// Barisan avatar Guardian yang memantau perjalanan.
class TripGuardianStrip extends StatelessWidget {
  final bool showTitle;
  const TripGuardianStrip({super.key, this.showTitle = true});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Guardian>>(
      valueListenable: GuardianStore.guardians,
      builder: (context, list, _) {
        final shown = list.take(4).toList();
        final more = list.length - shown.length;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showTitle)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Text('${list.length} Guardian memantau langsung', style: Aj.h(14)),
                    const SizedBox(width: 6),
                    const Icon(Icons.wifi_tethering_rounded, size: 18, color: Aj.plum),
                  ],
                ),
              ),
            if (list.isEmpty)
              Text('Belum ada Guardian. Tambahkan dulu agar ada yang memantau.', style: Aj.b(12.5, color: Aj.muted))
            else
              Row(
                children: [
                  for (final g in shown)
                    Padding(
                      padding: const EdgeInsets.only(right: 14),
                      child: Column(
                        children: [
                          AjAvatar(name: g.name, size: 46, online: g.online, color: g.color, imageUrl: g.imageUrl),
                          const SizedBox(height: 4),
                          SizedBox(
                            width: 56,
                            child: Text(g.name.split(' ').first, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: Aj.b(11, w: FontWeight.w700)),
                          ),
                        ],
                      ),
                    ),
                  if (more > 0)
                    Container(
                      width: 46,
                      height: 46,
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: const BoxDecoration(color: Aj.blush, shape: BoxShape.circle),
                      child: Text('+$more', style: Aj.h(13, color: Aj.berry)),
                    ),
                ],
              ),
          ],
        );
      },
    );
  }
}

/// Tombol aksi kecil bergaya kartu (ikon + label), dipakai di grid.
class PjQuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bg;
  final Color fg;
  final VoidCallback onTap;

  const PjQuickAction({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.bg = Aj.blush,
    this.fg = Aj.berry,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: PressScale(
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(18)),
            child: Column(
              children: [
                Icon(icon, color: fg, size: 24),
                const SizedBox(height: 6),
                Text(label, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: Aj.b(11, color: fg, w: FontWeight.w800, height: 1.15)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
