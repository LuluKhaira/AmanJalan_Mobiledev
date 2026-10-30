import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:amanjalan/core/theme/aj_theme.dart';
import 'package:amanjalan/core/widgets/aj_common.dart';
import 'package:amanjalan/features/profile/profile_store.dart';
import 'package:amanjalan/features/profile/widgets/profile_kit.dart';

/// QR SALING PANTAU — tukar kode dengan teman lewat 3 cara:
/// tampilkan QR sendiri, pindai QR teman (kamera), atau ketik kode manual.
class QrBuddyScreen extends StatefulWidget {
  /// 0 = QR Saya, 1 = Pindai, 2 = Kode
  final int initialTab;

  const QrBuddyScreen({super.key, this.initialTab = 0});

  @override
  State<QrBuddyScreen> createState() => _QrBuddyScreenState();
}

class _QrBuddyScreenState extends State<QrBuddyScreen> {
  late int _tab = widget.initialTab;

  static const _tabs = <(IconData, String)>[
    (Icons.qr_code_2_rounded, 'QR Saya'),
    (Icons.qr_code_scanner_rounded, 'Pindai'),
    (Icons.keyboard_alt_outlined, 'Kode'),
  ];

  /// Dipakai oleh tab Pindai & Kode. Mengembalikan true bila berhasil terhubung.
  Future<bool> _submit(String raw) async {
    final r = ProfileStore.addBuddy(raw);
    switch (r) {
      case BuddyResult.added:
        HapticFeedback.mediumImpact();
        final code = ProfileStore.parseCode(raw)!;
        await _showSuccess(code);
        return true;
      case BuddyResult.invalid:
        ajSnack(context, 'Kode tidak dikenali. Contoh: AJ-12345', icon: Icons.error_outline_rounded);
        return false;
      case BuddyResult.self:
        ajSnack(context, 'Itu kodemu sendiri. Minta kode temanmu ya', icon: Icons.info_outline_rounded);
        return false;
      case BuddyResult.duplicate:
        ajSnack(context, 'Kalian sudah saling terhubung', icon: Icons.group_rounded);
        return false;
    }
  }

  Future<void> _showSuccess(String code) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AjSheet(
        title: 'Berhasil Terhubung!',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.6, end: 1),
              duration: const Duration(milliseconds: 650),
              curve: Curves.elasticOut,
              builder: (_, v, child) => Transform.scale(scale: v, child: child),
              child: const PfOwl(pfOwlShield, size: 120, fallback: Icons.verified_user_rounded),
            ),
            const SizedBox(height: 8),
            Text('Teman #${code.substring(3)}', style: Aj.h(18, color: Aj.plum)),
            const SizedBox(height: 4),
            AjPill(code, bg: Aj.blush, fg: Aj.plum, icon: Icons.shield_rounded, size: 11.5),
            const SizedBox(height: 10),
            Text(
              'Kalian sekarang saling menjaga. Lokasi hanya dibagikan saat kamu mengizinkan.',
              textAlign: TextAlign.center,
              style: Aj.b(12.5, color: Aj.muted, height: 1.45),
            ),
            const SizedBox(height: 16),
            PfPrimaryButton('Siap!', onTap: () => Navigator.pop(ctx), icon: Icons.check_rounded),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PfScaffold(
      title: 'QR Saling Pantau',
      children: [
        _segmented(),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          switchInCurve: Curves.easeOutCubic,
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, 0.03), end: Offset.zero).animate(anim),
              child: child,
            ),
          ),
          child: KeyedSubtree(
            key: ValueKey(_tab),
            child: switch (_tab) {
              0 => const _MyQrTab(),
              1 => _ScanTab(onCode: _submit),
              _ => _CodeTab(onSubmit: _submit),
            },
          ),
        ),
        const PfSectionLabel('Teman Saling Pantau', sub: 'Orang yang sudah terhubung denganmu.'),
        _buddyList(),
      ],
    );
  }

  Widget _segmented() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF3E1E9)),
        boxShadow: Aj.softShadow,
      ),
      child: Row(
        children: [
          for (var i = 0; i < _tabs.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _tab = i);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: _tab == i ? const LinearGradient(colors: [Color(0xFF4A1D5C), Color(0xFF6A2E80)]) : null,
                    boxShadow: _tab == i ? const [BoxShadow(color: Color(0x334A1D5C), blurRadius: 10, offset: Offset(0, 4))] : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_tabs[i].$1, size: 18, color: _tab == i ? Colors.white : Aj.muted),
                      const SizedBox(width: 6),
                      Text(_tabs[i].$2, style: Aj.b(12.5, color: _tab == i ? Colors.white : Aj.muted, w: FontWeight.w800)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buddyList() {
    return ValueListenableBuilder<List<Buddy>>(
      valueListenable: ProfileStore.buddies,
      builder: (context, list, _) {
        if (list.isEmpty) {
          return PfCard(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              children: [
                const PfOwl(pfOwlThinking, size: 90, fallback: Icons.group_add_rounded),
                const SizedBox(height: 6),
                Text('Belum ada teman terhubung', style: Aj.h(14.5)),
                const SizedBox(height: 3),
                Text(
                  'Pindai QR temanmu atau masukkan kodenya untuk mulai saling menjaga.',
                  textAlign: TextAlign.center,
                  style: Aj.b(12, color: Aj.muted, height: 1.4),
                ),
              ],
            ),
          );
        }
        return PfGroup(
          children: [
            for (final b in list)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: [Color(0xFFFFDCE8), Color(0xFFF6BBD1)]),
                      ),
                      child: Text(b.code.substring(3, 5), style: Aj.h(14, color: Aj.plum)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(b.name, style: Aj.b(14, w: FontWeight.w800)),
                          Text(b.code, style: Aj.b(12, color: Aj.muted)),
                        ],
                      ),
                    ),
                    const AjPill('Aktif', bg: Aj.mint, fg: Aj.mintDeep, dot: true, size: 10.5),
                    const SizedBox(width: 6),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Hapus',
                      onPressed: () {
                        ProfileStore.removeBuddy(b.code);
                        ajSnack(context, '${b.name} dihapus dari daftar', icon: Icons.person_remove_alt_1_outlined);
                      },
                      icon: const Icon(Icons.close_rounded, size: 19, color: Aj.muted),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// TAB 1 — QR SAYA
// ─────────────────────────────────────────────────────────────

class _MyQrTab extends StatelessWidget {
  const _MyQrTab();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ProfileData>(
      valueListenable: ProfileStore.data,
      builder: (context, p, _) {
        return Container(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFBDDE8), Color(0xFFFFF1F5)],
            ),
            border: Border.all(color: const Color(0xFFF6D3DE)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const PfAvatar(size: 50),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.displayName, maxLines: 1, overflow: TextOverflow.ellipsis, style: Aj.h(17, color: Aj.plum)),
                        const SizedBox(height: 3),
                        Text('Pindai untuk saling menjaga', style: Aj.b(12, color: Aj.muted)),
                      ],
                    ),
                  ),
                  const AjPill('Siap Dipindai', bg: Aj.mint, fg: Aj.mintDeep, dot: true, size: 10.5),
                ],
              ),
              const SizedBox(height: 18),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.85, end: 1),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (_, v, child) => Transform.scale(scale: v, child: child),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: Aj.softShadow,
                  ),
                  child: QrImageView(
                    data: ProfileStore.myQrPayload,
                    version: QrVersions.auto,
                    size: 210,
                    padding: EdgeInsets.zero,
                    errorCorrectionLevel: QrErrorCorrectLevel.M,
                    backgroundColor: Colors.white,
                    eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Color(0xFF4A1D5C)),
                    dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.circle, color: Color(0xFF4A1D5C)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('ID PROTEKSI', style: Aj.b(11, color: Aj.muted, w: FontWeight.w800)),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () => _copy(context, ProfileStore.myCode, 'Kode disalin'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFF3E1E9)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(ProfileStore.myCode, style: Aj.h(20, color: Aj.plum).copyWith(letterSpacing: 2)),
                      const SizedBox(width: 10),
                      const Icon(Icons.copy_rounded, size: 18, color: Aj.berry),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _SoftBtn(
                      icon: Icons.copy_rounded,
                      label: 'Salin Kode',
                      onTap: () => _copy(context, ProfileStore.myCode, 'Kode disalin'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SoftBtn(
                      icon: Icons.send_rounded,
                      label: 'Salin Undangan',
                      filled: true,
                      onTap: () => _copy(
                        context,
                        'Yuk saling menjaga di AmanJalan! Masukkan kode proteksiku: ${ProfileStore.myCode}',
                        'Pesan undangan disalin',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lock_outline_rounded, size: 15, color: Aj.berry),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Kode hanya untuk menghubungkan. Lokasimu tidak dibagikan sebelum kamu mengizinkan.',
                      style: Aj.b(11.5, color: Aj.muted, height: 1.4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _copy(BuildContext context, String text, String msg) {
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.selectionClick();
    ajSnack(context, msg, icon: Icons.check_circle_outline_rounded);
  }
}

// ─────────────────────────────────────────────────────────────
// TAB 2 — PINDAI (KAMERA)
// ─────────────────────────────────────────────────────────────

class _ScanTab extends StatefulWidget {
  final Future<bool> Function(String raw) onCode;

  const _ScanTab({required this.onCode});

  @override
  State<_ScanTab> createState() => _ScanTabState();
}

class _ScanTabState extends State<_ScanTab> with SingleTickerProviderStateMixin {
  // Kamera hanya menyala saat tab ini dibuka, dan dimatikan saat ditutup.
  final MobileScannerController _c = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
  );
  late final AnimationController _line = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))..repeat(reverse: true);

  bool _locked = false;
  bool _torch = false;

  @override
  void dispose() {
    _line.dispose();
    _c.dispose();
    super.dispose();
  }

  Future<void> _detect(BarcodeCapture cap) async {
    if (_locked) return;
    String? raw;
    for (final b in cap.barcodes) {
      if (b.rawValue != null && b.rawValue!.isNotEmpty) {
        raw = b.rawValue;
        break;
      }
    }
    if (raw == null) return;
    _locked = true;
    await widget.onCode(raw);
    await Future<void>.delayed(const Duration(milliseconds: 1800));
    if (mounted) _locked = false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 380,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: const Color(0xFF2A1233),
            boxShadow: Aj.softShadow,
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              MobileScanner(
                controller: _c,
                onDetect: _detect,
                errorBuilder: (context, error, child) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.no_photography_outlined, color: Colors.white70, size: 44),
                        const SizedBox(height: 10),
                        Text('Kamera tidak bisa dibuka', style: Aj.h(15, color: Colors.white)),
                        const SizedBox(height: 6),
                        Text(
                          'Izinkan akses kamera untuk AmanJalan, atau pakai tab Kode untuk memasukkan kode manual.',
                          textAlign: TextAlign.center,
                          style: Aj.b(12.5, color: Colors.white70, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Bingkai pindai + garis bergerak
              Center(
                child: SizedBox(
                  width: 230,
                  height: 230,
                  child: Stack(
                    children: [
                      Positioned.fill(child: CustomPaint(painter: _CornersPainter())),
                      AnimatedBuilder(
                        animation: _line,
                        builder: (_, __) => Positioned(
                          left: 14,
                          right: 14,
                          top: 14 + (_line.value * 200),
                          child: Container(
                            height: 3,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              gradient: const LinearGradient(colors: [Color(0x00FF8FB8), Color(0xFFFF8FB8), Color(0x00FF8FB8)]),
                              boxShadow: const [BoxShadow(color: Color(0x88FF8FB8), blurRadius: 10)],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Tombol senter & ganti kamera
              Positioned(
                top: 14,
                right: 14,
                child: Column(
                  children: [
                    _CamBtn(
                      icon: _torch ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                      onTap: () async {
                        await _c.toggleTorch();
                        if (mounted) setState(() => _torch = !_torch);
                      },
                    ),
                    const SizedBox(height: 10),
                    _CamBtn(icon: Icons.cameraswitch_rounded, onTap: () => _c.switchCamera()),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 18,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                    decoration: BoxDecoration(color: const Color(0xAA000000), borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.center_focus_strong_rounded, size: 16, color: Colors.white),
                        const SizedBox(width: 8),
                        Text('Arahkan ke QR temanmu', style: Aj.b(12.5, color: Colors.white, w: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'QR akan terbaca otomatis. Pastikan cahaya cukup dan QR berada di dalam bingkai.',
          textAlign: TextAlign.center,
          style: Aj.b(12, color: Aj.muted, height: 1.45),
        ),
      ],
    );
  }
}

class _CamBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CamBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: const BoxDecoration(color: Color(0x88000000), shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 21),
      ),
    );
  }
}

class _CornersPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    const len = 38.0;
    const r = 22.0;
    final w = s.width, h = s.height;

    final path = Path()
      // kiri atas
      ..moveTo(0, len)
      ..lineTo(0, r)
      ..quadraticBezierTo(0, 0, r, 0)
      ..lineTo(len, 0)
      // kanan atas
      ..moveTo(w - len, 0)
      ..lineTo(w - r, 0)
      ..quadraticBezierTo(w, 0, w, r)
      ..lineTo(w, len)
      // kanan bawah
      ..moveTo(w, h - len)
      ..lineTo(w, h - r)
      ..quadraticBezierTo(w, h, w - r, h)
      ..lineTo(w - len, h)
      // kiri bawah
      ..moveTo(len, h)
      ..lineTo(r, h)
      ..quadraticBezierTo(0, h, 0, h - r)
      ..lineTo(0, h - len);
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─────────────────────────────────────────────────────────────
// TAB 3 — MASUKKAN KODE
// ─────────────────────────────────────────────────────────────

class _CodeTab extends StatefulWidget {
  final Future<bool> Function(String raw) onSubmit;

  const _CodeTab({required this.onSubmit});

  @override
  State<_CodeTab> createState() => _CodeTabState();
}

class _CodeTabState extends State<_CodeTab> {
  final TextEditingController _c = TextEditingController();
  bool _busy = false;

  bool get _ready => ProfileStore.parseCode(_c.text) != null;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Future<void> _paste() async {
    final d = await Clipboard.getData(Clipboard.kTextPlain);
    final code = ProfileStore.parseCode(d?.text ?? '');
    if (!mounted) return;
    if (code == null) {
      ajSnack(context, 'Tidak ada kode di clipboard', icon: Icons.content_paste_off_rounded);
      return;
    }
    setState(() => _c.text = code);
  }

  Future<void> _go() async {
    setState(() => _busy = true);
    final ok = await widget.onSubmit(_c.text);
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (ok) _c.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PfCard(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const PfIcon(Icons.keyboard_alt_outlined, size: 46),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Masukkan Kode Teman', style: Aj.h(16)),
                    const SizedBox(height: 2),
                    Text('Ketik ID Proteksi yang dikirim temanmu.', style: Aj.b(12, color: Aj.muted)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _c,
            maxLength: 8,
            textCapitalization: TextCapitalization.characters,
            textAlign: TextAlign.center,
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _ready && !_busy ? _go() : null,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9\-]')),
              TextInputFormatter.withFunction((o, n) => n.copyWith(text: n.text.toUpperCase())),
            ],
            style: Aj.h(24, color: Aj.plum).copyWith(letterSpacing: 3),
            decoration: InputDecoration(
              hintText: 'AJ-12345',
              hintStyle: Aj.h(24, color: const Color(0xFFD9CCDD)).copyWith(letterSpacing: 3),
              counterText: '',
              filled: true,
              fillColor: Aj.sand,
              contentPadding: const EdgeInsets.symmetric(vertical: 20),
              suffixIcon: IconButton(
                tooltip: 'Tempel',
                onPressed: _paste,
                icon: const Icon(Icons.content_paste_rounded, color: Aj.berry, size: 20),
              ),
              prefixIcon: const SizedBox(width: 48),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Aj.plum, width: 1.6)),
            ),
          ),
          const SizedBox(height: 16),
          PfPrimaryButton(
            _busy ? 'Menghubungkan…' : 'Hubungkan',
            icon: Icons.link_rounded,
            onTap: _ready && !_busy ? _go : null,
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.lightbulb_outline_rounded, size: 15, color: Aj.berry),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Kodemu sendiri: ${ProfileStore.myCode}. Bagikan ke teman agar mereka bisa menambahkanmu.',
                  style: Aj.b(11.5, color: Aj.muted, height: 1.4),
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

class _SoftBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool filled;

  const _SoftBtn({required this.icon, required this.label, required this.onTap, this.filled = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: filled ? Aj.plum : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: filled ? Aj.plum : const Color(0xFFF3E1E9)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 17, color: filled ? Colors.white : Aj.plum),
            const SizedBox(width: 7),
            Text(label, style: Aj.b(12.5, color: filled ? Colors.white : Aj.plum, w: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}