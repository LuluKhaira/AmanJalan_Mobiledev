import 'package:flutter/material.dart';
import 'package:amanjalan/core/theme/aj_theme.dart';
import 'package:amanjalan/core/widgets/aj_common.dart';

/// Komponen bersama untuk layar-layar pengaturan (Sensor Guncang, Sirene,
/// Privasi, Versi Aplikasi, Data Medis, Panggilan Samaran).

const Color kAjBg = Color(0xFFFCF8F6);
const SizedBox kGap = SizedBox(height: 16);

/// Scaffold standar: tombol back, judul, ikon bantuan, avatar.
class AjSubScaffold extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const AjSubScaffold({super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAjBg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(Icons.arrow_back_rounded, color: Aj.plum),
                  ),
                  Expanded(
                    child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: Aj.h(19, color: Aj.plum)),
                  ),
                  IconButton(
                    onPressed: () => ajSnack(context, 'Pusat bantuan segera hadir', icon: Icons.help_outline_rounded),
                    icon: const Icon(Icons.help_outline_rounded, color: Aj.plum),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(color: Aj.plum, shape: BoxShape.circle),
                    child: const Icon(Icons.person_rounded, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 28), children: children),
            ),
          ],
        ),
      ),
    );
  }
}

/// Toggle gelap sesuai Figma.
class AjToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const AjToggle({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52,
        height: 30,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value ? Aj.plum : const Color(0xFFE6DFE2),
          borderRadius: BorderRadius.circular(15),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(width: 24, height: 24, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
        ),
      ),
    );
  }
}

/// Judul blok + subjudul.
class AjBlockTitle extends StatelessWidget {
  final String title;
  final String? sub;
  const AjBlockTitle(this.title, {super.key, this.sub});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Aj.h(17, color: Aj.plum)),
          if (sub != null) ...[const SizedBox(height: 2), Text(sub!, style: Aj.b(12.5, color: Aj.muted, height: 1.3))],
        ],
      ),
    );
  }
}

/// Baris pengaturan dengan toggle (latar sand).
class AjSwitchRow extends StatelessWidget {
  final IconData? icon;
  final Color iconColor;
  final String title;
  final String sub;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool boxed;
  const AjSwitchRow({
    super.key,
    this.icon,
    this.iconColor = Aj.plum,
    required this.title,
    required this.sub,
    required this.value,
    required this.onChanged,
    this.boxed = true,
  });

  @override
  Widget build(BuildContext context) {
    final row = Row(
      children: [
        if (icon != null) ...[Icon(icon, color: iconColor, size: 22), const SizedBox(width: 12)],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Aj.b(14, w: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(sub, style: Aj.b(12, color: Aj.muted, height: 1.3)),
            ],
          ),
        ),
        const SizedBox(width: 12),
        AjToggle(value: value, onChanged: onChanged),
      ],
    );
    if (!boxed) return Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: row);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Aj.sand, borderRadius: BorderRadius.circular(18)),
      child: row,
    );
  }
}

/// Kartu opsi (pilih satu) dengan ikon, judul, deskripsi, dan centang.
class AjOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String sub;
  final bool selected;
  final VoidCallback onTap;
  final String? badge;
  const AjOptionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.sub,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? Aj.sand : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? Aj.plum : Aj.line, width: selected ? 2 : 1.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AjIconBubble(icon, bg: selected ? Aj.plum : Aj.sand, fg: selected ? Colors.white : Aj.muted, size: 44),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(child: Text(title, style: Aj.b(14.5, w: FontWeight.w800))),
                      if (badge != null) ...[const SizedBox(width: 6), AjPill(badge!, bg: Aj.plum, fg: Colors.white, size: 10)],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(sub, style: Aj.b(12.5, color: Aj.muted, height: 1.35)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(selected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, color: selected ? Aj.plum : Aj.line, size: 24),
          ],
        ),
      ),
    );
  }
}

/// Tombol simpan lebar.
class AjSaveButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const AjSaveButton(this.label, {super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        backgroundColor: Aj.plum,
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      icon: const Icon(Icons.check_rounded, size: 20),
      label: Text(label, style: Aj.b(15, color: Colors.white, w: FontWeight.w800)),
    );
  }
}

/// Catatan kecil di bawah layar.
class AjFootnote extends StatelessWidget {
  final IconData icon;
  final String text;
  const AjFootnote(this.icon, this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 14, 8, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Aj.muted),
          const SizedBox(width: 8),
          Flexible(child: Text(text, textAlign: TextAlign.center, style: Aj.b(11.5, color: Aj.muted, height: 1.4))),
        ],
      ),
    );
  }
}

/// Tombol kecil bulat (untuk "Mulai Tes", "Simulasi Goyang", dll).
class AjSoftButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bg;
  final Color fg;
  final bool enabled;
  final VoidCallback onTap;
  const AjSoftButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.bg = Aj.sand,
    this.fg = Aj.ink,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : .45,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: enabled ? onTap : null,
        child: Container(
          height: 48,
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: fg),
              const SizedBox(width: 8),
              Flexible(child: Text(label, overflow: TextOverflow.ellipsis, style: Aj.b(13, color: fg, w: FontWeight.w800))),
            ],
          ),
        ),
      ),
    );
  }
}