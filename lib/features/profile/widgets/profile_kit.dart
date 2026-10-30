import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:amanjalan/core/theme/aj_theme.dart';
import 'package:amanjalan/core/widgets/aj_common.dart';
import 'package:amanjalan/features/profile/profile_store.dart';

// ─────────────────────────────────────────────────────────────
// Aset maskot. Semua dengan fallback ikon bila file belum ada.
// ─────────────────────────────────────────────────────────────

const pfOwlDir = 'assets/images/onboarding/';
const pfOwlAvatar = '${pfOwlDir}owl_compass.png'; // wajah dipotong jadi avatar
const pfOwlShield = '${pfOwlDir}owl_logo.png'; // layar "Akun Terverifikasi"
const pfOwlLogo = '${pfOwlDir}owl_logo.png'; // BARU: burung hantu + tulisan AMANJALAN
const pfOwlPhone = '${pfOwlDir}owl_phone.png'; // BARU: burung hantu pegang HP & melambai
const pfOwlThinking = '${pfOwlDir}owl_thinking.png';

const _border = Color(0xFFF3E1E9);

Future<T?> pfPush<T>(BuildContext c, Widget page) =>
    Navigator.of(c).push<T>(MaterialPageRoute<T>(builder: (_) => page));

// ─────────────────────────────────────────────────────────────
// Maskot & avatar
// ─────────────────────────────────────────────────────────────

class PfOwl extends StatelessWidget {
  final String asset;
  final double size;
  final IconData fallback;

  const PfOwl(this.asset, {super.key, this.size = 80, this.fallback = Icons.pets_rounded});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => SizedBox(
        width: size,
        height: size,
        child: Icon(fallback, size: size * 0.5, color: Aj.plum),
      ),
    );
  }
}

class PfAvatar extends StatelessWidget {
  final double size;
  final bool camera;
  final VoidCallback? onTap;

  const PfAvatar({super.key, this.size = 96, this.camera = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFFDCE8), Color(0xFFF6BBD1)],
                ),
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: Aj.softShadow,
              ),
              child: ClipOval(
                child: Transform.scale(
                  scale: 1.35,
                  alignment: const Alignment(0, -0.45),
                  child: Image.asset(
                    pfOwlAvatar,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Icon(Icons.pets_rounded, size: size * 0.45, color: Aj.plum),
                  ),
                ),
              ),
            ),
            if (camera)
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  width: size * 0.34,
                  height: size * 0.34,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: _border),
                    boxShadow: Aj.softShadow,
                  ),
                  child: Icon(Icons.photo_camera_outlined, size: size * 0.17, color: Aj.plum),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Kerangka halaman (header + latar pink lembut)
// ─────────────────────────────────────────────────────────────

class PfScaffold extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Widget? footer;
  final List<Widget> actions;

  const PfScaffold({
    super.key,
    required this.title,
    required this.children,
    this.footer,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Aj.bg,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFEEF4), Color(0xFFFFFAFC)],
            stops: [0, 0.5],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).maybePop(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: _border),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, size: 17, color: Aj.plum),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: Aj.h(19, color: Aj.plum))),
                    ...actions,
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  children: children,
                ),
              ),
              if (footer != null) Padding(padding: const EdgeInsets.fromLTRB(20, 8, 20, 16), child: footer),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Kartu & grup daftar
// ─────────────────────────────────────────────────────────────

class PfCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color color;

  const PfCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _border),
        boxShadow: Aj.softShadow,
      ),
      child: child,
    );
  }
}

/// Kartu berisi baris-baris (PfTile dsb) dengan pemisah otomatis.
class PfGroup extends StatelessWidget {
  final List<Widget> children;

  const PfGroup({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      items.add(children[i]);
      if (i < children.length - 1) {
        items.add(const Padding(padding: EdgeInsets.only(left: 72), child: Divider(height: 1, color: Color(0xFFF5E9EE))));
      }
    }
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _border),
        boxShadow: Aj.softShadow,
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: Column(children: items),
      ),
    );
  }
}

class PfIcon extends StatelessWidget {
  final IconData icon;
  final Color bg;
  final Color fg;
  final double size;

  const PfIcon(this.icon, {super.key, this.bg = const Color(0xFFF6E8F1), this.fg = Aj.plum, this.size = 42});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(size * 0.34)),
      child: Icon(icon, size: size * 0.5, color: fg),
    );
  }
}

class PfTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? sub;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color iconBg;
  final Color iconFg;
  final Color? titleColor;

  const PfTile({
    super.key,
    required this.icon,
    required this.title,
    this.sub,
    this.onTap,
    this.trailing,
    this.iconBg = const Color(0xFFF6E8F1),
    this.iconFg = Aj.plum,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap == null
          ? null
          : () {
              HapticFeedback.selectionClick();
              onTap!();
            },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            PfIcon(icon, bg: iconBg, fg: iconFg),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Aj.b(14.5, w: FontWeight.w800, color: titleColor ?? Aj.ink)),
                  if (sub != null) ...[
                    const SizedBox(height: 2),
                    Text(sub!, style: Aj.b(11.5, color: Aj.muted, height: 1.3)),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            trailing ?? (onTap != null ? const Icon(Icons.chevron_right_rounded, color: Aj.muted, size: 22) : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}

class PfSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String sub;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color color;
  final Color iconBg;

  const PfSwitchTile({
    super.key,
    required this.icon,
    required this.title,
    required this.sub,
    required this.value,
    required this.onChanged,
    this.color = Aj.plum,
    this.iconBg = const Color(0xFFF6E8F1),
  });

  @override
  Widget build(BuildContext context) {
    return PfTile(
      icon: icon,
      title: title,
      sub: sub,
      iconBg: iconBg,
      iconFg: color,
      onTap: () => onChanged(!value),
      trailing: PfSwitch(value: value, onChanged: onChanged, color: color),
    );
  }
}

class PfSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color color;

  const PfSwitch({super.key, required this.value, required this.onChanged, this.color = Aj.plum});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onChanged(!value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        width: 50,
        height: 30,
        padding: const EdgeInsets.all(3),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        decoration: BoxDecoration(
          color: value ? color : const Color(0xFFDCD3DF),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Color(0x33000000), blurRadius: 4, offset: Offset(0, 1))],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Judul bagian, tombol, banner
// ─────────────────────────────────────────────────────────────

class PfSectionLabel extends StatelessWidget {
  final String text;
  final String? sub;

  const PfSectionLabel(this.text, {super.key, this.sub});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 22, 4, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text, style: Aj.h(15.5)),
          if (sub != null) Padding(padding: const EdgeInsets.only(top: 2), child: Text(sub!, style: Aj.b(12, color: Aj.muted))),
        ],
      ),
    );
  }
}

class PfPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;

  const PfPrimaryButton(this.label, {super.key, required this.onTap, this.icon});

  @override
  Widget build(BuildContext context) {
    final on = onTap != null;
    return GestureDetector(
      onTap: on
          ? () {
              HapticFeedback.mediumImpact();
              onTap!();
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(27),
          gradient: LinearGradient(
            colors: on ? const [Color(0xFF4A1D5C), Color(0xFF6A2E80)] : const [Color(0xFFCDBFD3), Color(0xFFCDBFD3)],
          ),
          boxShadow: on ? const [BoxShadow(color: Color(0x404A1D5C), blurRadius: 14, offset: Offset(0, 6))] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[Icon(icon, size: 20, color: Colors.white), const SizedBox(width: 8)],
            Text(label, style: Aj.h(15, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

/// Banner pink dengan maskot di kiri (dipakai di Profil, Notifikasi, FAQ, Hubungi Kami).
class PfBanner extends StatelessWidget {
  final String owl;
  final String title;
  final String sub;
  final String? button;
  final VoidCallback? onButton;

  const PfBanner({super.key, required this.owl, required this.title, required this.sub, this.button, this.onButton});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 12, 14, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(colors: [Color(0xFFFBE3EB), Color(0xFFFFF1F5)]),
        border: Border.all(color: const Color(0xFFF6D3DE)),
      ),
      child: Row(
        children: [
          PfOwl(owl, size: 76, fallback: Icons.support_agent_rounded),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Aj.h(14)),
                const SizedBox(height: 2),
                Text(sub, style: Aj.b(11.5, color: Aj.muted, height: 1.35)),
              ],
            ),
          ),
          if (button != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onButton,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(color: Aj.plum, borderRadius: BorderRadius.circular(20)),
                child: Text(button!, style: Aj.b(11.5, color: Colors.white, w: FontWeight.w800)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Isian teks bergaya mockup: label di atas, kotak putih membulat.
class PfField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int maxLength;
  final String? hint;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  const PfField({
    super.key,
    required this.label,
    required this.controller,
    required this.maxLength,
    this.hint,
    this.keyboardType,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(label, style: Aj.b(13, w: FontWeight.w800)),
        ),
        TextField(
          controller: controller,
          maxLength: maxLength,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: Aj.b(15, w: FontWeight.w700),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: Aj.b(14, color: Aj.muted),
            filled: true,
            fillColor: Colors.white,
            counterStyle: Aj.b(11, color: Aj.muted),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: _border, width: 1.2)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Aj.plum, width: 1.6)),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Dialog keluar akun (dipakai di Settings)
// ─────────────────────────────────────────────────────────────

void pfConfirmLogout(BuildContext context, VoidCallback onLogout) {
  HapticFeedback.lightImpact();
  showDialog<void>(
    context: context,
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 36),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(color: Color(0xFFFDE8E8), shape: BoxShape.circle),
              child: const Icon(Icons.logout_rounded, color: Aj.sos, size: 26),
            ),
            const SizedBox(height: 14),
            Text('Keluar Akun?', style: Aj.h(17)),
            const SizedBox(height: 8),
            Text(
              'Apakah kamu yakin ingin keluar dari akun AmanJalan?',
              textAlign: TextAlign.center,
              style: Aj.b(13, color: Aj.muted, height: 1.4),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Aj.ink,
                      side: const BorderSide(color: Color(0xFFE0D8DA)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text('Batal', style: Aj.b(13.5, w: FontWeight.w800)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      Navigator.pop(ctx);
                      onLogout();
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Aj.sos,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text('Keluar', style: Aj.b(13.5, color: Colors.white, w: FontWeight.w800)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

/// Pilihan satu-dari-banyak di bottom sheet (bahasa, tema, ukuran teks, jenis kelamin).
Future<void> pfPickOne(
  BuildContext context, {
  required String title,
  required List<String> options,
  required String current,
  required ValueChanged<String> onPick,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => AjSheet(
      title: title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final o in options)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(o, style: Aj.b(14.5, w: o == current ? FontWeight.w800 : FontWeight.w600, color: o == current ? Aj.plum : Aj.ink)),
              trailing: o == current ? const Icon(Icons.check_circle_rounded, color: Aj.plum) : null,
              onTap: () {
                Navigator.pop(ctx);
                onPick(o);
              },
            ),
        ],
      ),
    ),
  );
}

/// Pintasan: ambil profil saat ini.
ProfileData get pfNow => ProfileStore.data.value;