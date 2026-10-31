import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:amanjalan/core/theme/app_colors.dart';
import 'package:amanjalan/features/emergency/emergency_screen.dart';

// ====== Palet: meniru aplikasi Telepon iPhone (gradasi ungu-navy + kaca) ======
const _bgTop = Color(0xFF47447E);
const _bgMid = Color(0xFF2B2950);
const _bgBottom = Color(0xFF141226);
const _green = Color(0xFF30D158);
const _red = Color(0xFFFF453A);
const _dim = Color(0xFFB4B0CC);
const _silhouette = Color(0xFFD3D3DA);

enum _CallPhase { ringing, inCall }

enum _InCallView { main, keypad, contacts }

/// Satu langkah percakapan: kalimat "lawan bicara" + contekan jawaban pengguna.
class _ScriptStep {
  final String line;
  final List<String> replies;
  const _ScriptStep(this.line, this.replies);
}

/// Layar panggilan palsu bergaya aplikasi Telepon iPhone.
///
/// Sengaja TANPA logo / tulisan aplikasi di layar utama supaya orang di sekitar
/// tidak curiga. Contekan jawaban disembunyikan di laci kecil di bawah.
class FakeCallScreen extends StatefulWidget {
  final String callerName;
  final String callerEmoji;
  final String callerLabel; // hanya tampil di laci contekan
  final String callerNumber; // nomor yang tampil
  final String callType; // keterangan di bawah nama, mis. "seluler"
  final String myName; // nama pemilik HP (daftar Kontak)
  final String location; // posisi terpantau (laci contekan)
  final int guardianCount; // jumlah wali (laci contekan)
  final String scenarioTitle;
  final List<EmergencyRecipient>? emergencyRecipients;

  const FakeCallScreen({
    super.key,
    this.callerName = 'Ibu Nurhayati',
    this.callerEmoji = '❤️',
    this.callerLabel = 'Wali Utama (Panggilan Rumah)',
    this.callerNumber = '+62 812-3456-7890',
    this.callType = 'seluler',
    this.myName = 'Saya',
    this.location = 'Jl. Senopati Raya',
    this.guardianCount = 3,
    this.scenarioTitle = 'Dijemput di Depan Gang',
    this.emergencyRecipients,
  });

  @override
  State<FakeCallScreen> createState() => _FakeCallScreenState();
}

class _FakeCallScreenState extends State<FakeCallScreen>
    with TickerProviderStateMixin {
  // Skenario percakapan (TODO: pindahkan ke data/daftar skenario pilihan pengguna)
  static const _script = [
    _ScriptStep(
      'Lagi di mana Sasa? Ini Papa udah di depan gang nungguin ya, cepetan masuk motornya dingin…',
      [
        'Iya Ma, ini udah keliatan kok!',
        'Bentar lagi nyampe depan gang',
        'Iya ini bareng temen kok',
      ],
    ),
    _ScriptStep(
      'Yaudah Papa tunggu di sini ya. Jangan lama-lama, hati-hati jalannya.',
      [
        'Iya Pa, 2 menit lagi',
        'Jangan ke mana-mana ya Pa',
        'Aku udah deket banget',
      ],
    ),
    _ScriptStep(
      'Papa lihat kamu dari sini. Lampu motor Papa udah Papa nyalain ya.',
      [
        'Iya aku lihat kok!',
        'Tunggu sebentar ya',
        'Oke Pa, aku ke situ sekarang',
      ],
    ),
  ];

  static const _keys = [
    ('1', ''),
    ('2', 'ABC'),
    ('3', 'DEF'),
    ('4', 'GHI'),
    ('5', 'JKL'),
    ('6', 'MNO'),
    ('7', 'PQRS'),
    ('8', 'TUV'),
    ('9', 'WXYZ'),
    ('*', ''),
    ('0', '+'),
    ('#', ''),
  ];

  late final AnimationController _ring;
  Timer? _ringTimer;
  Timer? _callTimer;

  _CallPhase _phase = _CallPhase.ringing;
  _InCallView _view = _InCallView.main;
  int _seconds = 0;
  bool _muted = false;
  bool _speaker = false;
  bool _helperOpen = false;
  int _step = 0;
  String _dialed = '';

  @override
  void initState() {
    super.initState();
    _ring = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    // TODO: putar nada dering sungguhan (paket audioplayers / just_audio).
    // Sementara hanya getar berkala seperti panggilan masuk.
    HapticFeedback.vibrate();
    _ringTimer = Timer.periodic(
      const Duration(milliseconds: 1400),
      (_) => HapticFeedback.vibrate(),
    );
  }

  @override
  void dispose() {
    _ringTimer?.cancel();
    _callTimer?.cancel();
    _ring.dispose();
    super.dispose();
  }

  // ---------- Aksi ----------
  void _accept() {
    HapticFeedback.lightImpact();
    _ringTimer?.cancel();
    // TODO: putar suara lawan bicara otomatis (TTS / rekaman) sesuai skenario.
    setState(() => _phase = _CallPhase.inCall);
    _callTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _seconds++);
    });
  }

  void _endCall() {
    HapticFeedback.mediumImpact();
    _ringTimer?.cancel();
    _callTimer?.cancel();
    Navigator.of(context).pop();
  }

  /// Protokol senyap: tekan tombol merah 2x cepat saat panggilan berlangsung.
  void _silentEmergency() {
    HapticFeedback.heavyImpact();
    _ringTimer?.cancel();
    _callTimer?.cancel();
    final recipients = widget.emergencyRecipients;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => recipients == null
            ? const EmergencyScreen()
            : EmergencyScreen(recipients: recipients),
      ),
    );
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF3A3560),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Text(
          message,
          style: GoogleFonts.inter(
              fontWeight: FontWeight.w500, color: Colors.white),
        ),
      ),
    );
  }

  void _setView(_InCallView v) {
    HapticFeedback.selectionClick();
    setState(() => _view = v);
  }

  String get _timeText {
    final m = (_seconds ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // ---------- Build ----------
  @override
  Widget build(BuildContext context) {
    final ringing = _phase == _CallPhase.ringing;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _bgBottom,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_bgTop, _bgMid, _bgBottom],
              stops: [0.0, 0.55, 1.0],
            ),
          ),
          child: SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              child: ringing
                  ? KeyedSubtree(
                      key: const ValueKey('ring'), child: _buildRinging())
                  : KeyedSubtree(
                      key: const ValueKey('call'), child: _buildInCall()),
            ),
          ),
        ),
      ),
    );
  }

  // ---------- Komponen kaca ----------
  Widget _glassCircle({
    required double size,
    required Widget child,
    bool active = false,
    VoidCallback? onTap,
    double opacity = 0.14,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active
                  ? Colors.white.withOpacity(0.92)
                  : Colors.white.withOpacity(opacity),
              border: Border.all(
                  color: Colors.white.withOpacity(active ? 0 : 0.10)),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _glassPill({
    required Widget child,
    VoidCallback? onTap,
    EdgeInsets padding =
        const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.14),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withOpacity(0.10)),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  /// Avatar siluet kaca, sama seperti kontak tanpa foto di iPhone.
  Widget _avatar(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.16),
            Colors.white.withOpacity(0.04),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.22), width: 1.5),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF8E8AD8).withOpacity(0.25),
              blurRadius: 40,
              spreadRadius: 2),
        ],
      ),
      child: ClipOval(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Transform.translate(
            offset: Offset(0, size * 0.08),
            child: Icon(Icons.person_rounded,
                size: size * 0.86, color: _silhouette),
          ),
        ),
      ),
    );
  }

  Widget _callerName({double size = 32}) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: widget.callerName,
            style: GoogleFonts.inter(
              fontSize: size,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.4,
              color: Colors.white,
            ),
          ),
          if (widget.callerEmoji.isNotEmpty)
            TextSpan(
              text: ' ${widget.callerEmoji}',
              style: TextStyle(fontSize: size * 0.88),
            ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  // =====================================================================
  // FASE 1: PANGGILAN MASUK
  // =====================================================================
  Widget _buildRinging() {
    return Column(
      children: [
        const Spacer(flex: 2),
        _buildRingingAvatar(),
        const SizedBox(height: 18),
        _callerName(size: 34),
        const SizedBox(height: 6),
        Text(widget.callerNumber,
            style: GoogleFonts.inter(fontSize: 16, color: _dim)),
        const SizedBox(height: 2),
        Text(widget.callType,
            style: GoogleFonts.inter(
                fontSize: 13, color: _dim.withOpacity(0.75))),
        const Spacer(flex: 3),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _glassPill(
              onTap: () {
                HapticFeedback.selectionClick();
                _snack('Pengingat diatur');
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.alarm_rounded, size: 19, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('Ingatkan Saya',
                      style: GoogleFonts.inter(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                          color: Colors.white)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _glassPill(
              onTap: () {
                HapticFeedback.selectionClick();
                _snack('Pesan cepat dikirim');
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.chat_bubble_rounded,
                      size: 18, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('Pesan',
                      style: GoogleFonts.inter(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                          color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 36),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _declineButton(),
              _acceptButton(),
            ],
          ),
        ),
        const SizedBox(height: 44),
      ],
    );
  }

  Widget _buildRingingAvatar() {
    return SizedBox(
      width: 280,
      height: 280,
      child: AnimatedBuilder(
        animation: _ring,
        builder: (context, _) {
          Widget wave(double t) {
            return Transform.scale(
              scale: 0.68 + 0.32 * t,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity((1 - t) * 0.20),
                    width: 1.5,
                  ),
                ),
              ),
            );
          }

          return Stack(
            alignment: Alignment.center,
            children: [
              wave(_ring.value),
              wave((_ring.value + 0.33) % 1.0),
              wave((_ring.value + 0.66) % 1.0),
              _avatar(190),
            ],
          );
        },
      ),
    );
  }

  Widget _declineButton() {
    return Column(
      children: [
        GestureDetector(
          onTap: _endCall,
          child: Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              color: _red,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: _red.withOpacity(0.45),
                    blurRadius: 24,
                    offset: const Offset(0, 8)),
              ],
            ),
            child: const Icon(Icons.call_end_rounded,
                size: 34, color: Colors.white),
          ),
        ),
        const SizedBox(height: 10),
        Text('Tolak',
            style: GoogleFonts.inter(fontSize: 14.5, color: Colors.white70)),
      ],
    );
  }

  Widget _acceptButton() {
    return Column(
      children: [
        SizedBox(
          width: 108,
          height: 78,
          child: AnimatedBuilder(
            animation: _ring,
            builder: (context, _) {
              final t = _ring.value;
              final wiggle =
                  t < 0.45 ? math.sin(t * 2 * math.pi * 6) * 0.22 : 0.0;
              return Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 78 + 30 * t,
                    height: 78 + 30 * t,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _green.withOpacity((1 - t) * 0.30),
                    ),
                  ),
                  GestureDetector(
                    onTap: _accept,
                    child: Container(
                      width: 78,
                      height: 78,
                      decoration: BoxDecoration(
                        color: _green,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: _green.withOpacity(0.45),
                              blurRadius: 24,
                              offset: const Offset(0, 8)),
                        ],
                      ),
                      child: Transform.rotate(
                        angle: wiggle,
                        child: const Icon(Icons.call_rounded,
                            size: 34, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Text('Terima',
            style: GoogleFonts.inter(fontSize: 14.5, color: Colors.white70)),
      ],
    );
  }

  // =====================================================================
  // FASE 2: PANGGILAN BERLANGSUNG
  // =====================================================================
  Widget _buildInCall() {
    Widget body;
    switch (_view) {
      case _InCallView.keypad:
        body = _buildKeypadView();
        break;
      case _InCallView.contacts:
        body = _buildContactsView();
        break;
      case _InCallView.main:
        body = _buildMainView();
        break;
    }
    return Column(
      children: [
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: KeyedSubtree(key: ValueKey(_view), child: body),
          ),
        ),
        _buildHelper(),
      ],
    );
  }

  // ---------- Tampilan utama ----------
  Widget _buildMainView() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 12),
      child: Column(
        children: [
          _avatar(124),
          const SizedBox(height: 18),
          _callerName(size: 30),
          const SizedBox(height: 6),
          Text(_timeText,
              style: GoogleFonts.inter(
                  fontSize: 19,
                  fontWeight: FontWeight.w400,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  color: _dim)),
          const SizedBox(height: 40),
          _buildControls(),
          const SizedBox(height: 32),
          _buildEndButton(),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Column(
      children: [
        Row(
          children: [
            _control(
              _muted ? Icons.mic_off_rounded : Icons.mic_rounded,
              'Bisukan',
              active: _muted,
              onTap: () => setState(() => _muted = !_muted),
            ),
            _control(
              Icons.dialpad_rounded,
              'Keypad',
              onTap: () => _setView(_InCallView.keypad),
            ),
            _control(
              Icons.volume_up_rounded,
              'Speaker',
              active: _speaker,
              onTap: () => setState(() => _speaker = !_speaker),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            _control(
              Icons.person_add_alt_1_rounded,
              'Tambah',
              onTap: () => _snack('Tidak tersedia saat ini'),
            ),
            _control(Icons.videocam_rounded, 'FaceTime', disabled: true),
            _control(
              Icons.account_circle_rounded,
              'Kontak',
              onTap: () => _setView(_InCallView.contacts),
            ),
          ],
        ),
      ],
    );
  }

  Widget _control(
    IconData icon,
    String label, {
    bool active = false,
    bool disabled = false,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: Opacity(
        opacity: disabled ? 0.4 : 1,
        child: Column(
          children: [
            _glassCircle(
              size: 72,
              active: active,
              onTap: disabled
                  ? null
                  : () {
                      HapticFeedback.selectionClick();
                      onTap?.call();
                    },
              child: Icon(icon,
                  size: 30,
                  color: active ? const Color(0xFF1B1830) : Colors.white),
            ),
            const SizedBox(height: 9),
            Text(label,
                style: GoogleFonts.inter(fontSize: 13, color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  // ---------- Keypad (seperti aplikasi Telepon) ----------
  Widget _buildKeypadView() {
    return Column(
      children: [
        const SizedBox(height: 18),
        SizedBox(
          height: 52,
          child: Center(
            child: Text(
              _dialed,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                  fontSize: 34,
                  fontWeight: FontWeight.w400,
                  color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 1,
            children: [
              for (final k in _keys) _keyButton(k.$1, k.$2),
            ],
          ),
        ),
        const SizedBox(height: 22),
        _buildEndButton(),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 0, 28, 8),
          child: Row(
            children: [
              const Spacer(),
              GestureDetector(
                onTap: () => _setView(_InCallView.main),
                child: Text('Sembunyikan',
                    style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _keyButton(String digit, String letters) {
    return LayoutBuilder(
      builder: (context, c) => _glassCircle(
        size: c.maxWidth,
        opacity: 0.13,
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() {
            if (_dialed.length < 18) _dialed += digit;
          });
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(digit,
                style: GoogleFonts.inter(
                    fontSize: digit == '*' ? 38 : 32,
                    fontWeight: FontWeight.w400,
                    height: 1.0,
                    color: Colors.white)),
            if (letters.isNotEmpty)
              Text(letters,
                  style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                      color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  // ---------- Kontak (seperti aplikasi Telepon) ----------
  Widget _buildContactsView() {
    Widget tile(String name, String sub, {String? trailing}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.14),
                border: Border.all(color: Colors.white.withOpacity(0.10)),
              ),
              child: const Icon(Icons.person_rounded,
                  size: 30, color: _silhouette),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                  if (sub.isNotEmpty)
                    Text(sub,
                        style: GoogleFonts.inter(fontSize: 13, color: _dim)),
                ],
              ),
            ),
            if (trailing != null)
              Text(trailing,
                  style: GoogleFonts.inter(fontSize: 14, color: _dim)),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        children: [
          Row(
            children: [
              _glassCircle(
                size: 44,
                onTap: () => _setView(_InCallView.main),
                child: const Icon(Icons.chevron_left_rounded,
                    size: 30, color: Colors.white),
              ),
              Expanded(
                child: Center(
                  child: Text('Kontak',
                      style: GoogleFonts.inter(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ),
              ),
              _glassCircle(
                size: 44,
                onTap: () => _snack('Tidak tersedia saat panggilan'),
                child: const Icon(Icons.add_rounded,
                    size: 26, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                tile(widget.myName, 'Kartu Saya'),
                Divider(color: Colors.white.withOpacity(0.08), height: 1),
                tile(widget.callerName, widget.callerNumber),
                Divider(color: Colors.white.withOpacity(0.08), height: 1),
                tile(widget.myName, '', trailing: 'saya'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Akhiri panggilan + protokol senyap ----------
  Widget _buildEndButton() {
    return Center(
      child: GestureDetector(
        onTap: _endCall, // ketuk sekali: akhiri panggilan
        onDoubleTap: _silentEmergency, // ketuk 2x cepat: kirim sinyal darurat
        child: Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            color: _red,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: _red.withOpacity(0.45),
                  blurRadius: 24,
                  offset: const Offset(0, 8)),
            ],
          ),
          child:
              const Icon(Icons.call_end_rounded, size: 34, color: Colors.white),
        ),
      ),
    );
  }

  // ---------- Laci contekan (tersembunyi secara default) ----------
  Widget _buildHelper() {
    return AnimatedSize(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF1B1830),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _helperOpen = !_helperOpen);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  children: [
                    Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    AnimatedRotation(
                      turns: _helperOpen ? 0.5 : 0,
                      duration: const Duration(milliseconds: 220),
                      child: Icon(Icons.keyboard_arrow_up_rounded,
                          size: 22, color: Colors.white.withOpacity(0.35)),
                    ),
                  ],
                ),
              ),
            ),
            if (_helperOpen)
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 330),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: _buildHelperBody(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelperBody() {
    final step = _script[_step];
    final isLast = _step == _script.length - 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${widget.scenarioTitle.toUpperCase()} • ${widget.callerLabel}',
            style: GoogleFonts.inter(
                fontSize: 11, letterSpacing: 0.8, color: _dim)),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.record_voice_over_outlined,
                  size: 20, color: Color(0xFFFFB3C0)),
              const SizedBox(width: 12),
              Expanded(
                child: Text('“${step.line}”',
                    style: GoogleFonts.inter(
                        fontSize: 14.5, height: 1.4, color: Colors.white)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text('Jawab santai:',
            style: GoogleFonts.inter(fontSize: 12.5, color: _dim)),
        const SizedBox(height: 8),
        for (final reply in step.replies)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.chat_bubble_outline_rounded,
                      size: 15, color: _dim),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text('“$reply”',
                        style: GoogleFonts.inter(
                            fontSize: 13.5, color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 4),
        Row(
          children: [
            GestureDetector(
              onTap: isLast
                  ? null
                  : () {
                      HapticFeedback.selectionClick();
                      setState(() => _step++);
                    },
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isLast ? 0.35 : 1,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.plum,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.skip_next_rounded,
                          size: 18, color: Colors.white),
                      const SizedBox(width: 6),
                      Text('Kalimat lanjutan',
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
            const Spacer(),
            const Icon(Icons.location_on_outlined, size: 15, color: _dim),
            const SizedBox(width: 4),
            Flexible(
              child: Text('${widget.location} • ${widget.guardianCount} wali',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(fontSize: 12, color: _dim)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _red.withOpacity(0.14),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.shield_outlined,
                  size: 18, color: Color(0xFFFF9FA8)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Darurat senyap: ketuk tombol merah 2x cepat untuk kirim SOS + lokasi live ke wali.',
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      height: 1.4,
                      color: const Color(0xFFFFB3C0)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}