import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:amanjalan/core/theme/app_colors.dart';
import 'package:amanjalan/features/emergency/emergency_screen.dart';

// ---- Warna layar panggilan ----
const _darkTop = Color(0xFF4A3445);
const _darkBottom = Color(0xFF2F2540);
const _pageBg = Color(0xFFFCFAFC);
const _panelBg = Color(0xFFF7F3F1);
const _tileBg = Color(0xFFEFEBEA);
const _declineColor = Color(0xFF8B3A4A);
const _acceptColor = Color(0xFF2D4A3A);

enum _CallPhase { ringing, inCall }

/// Satu langkah percakapan: kalimat "Mama" + contekan jawaban pengguna.
class _ScriptStep {
  final String line;
  final List<String> replies;
  const _ScriptStep(this.line, this.replies);
}

class FakeCallScreen extends StatefulWidget {
  final String callerName;
  final String callerEmoji;
  final String callerLabel; // keterangan di layar panggilan masuk
  final String callerNumber; // nomor yang tampil saat panggilan berlangsung
  final String location; // posisi terpantau
  final int guardianCount;
  final String scenarioTitle;
  final List<EmergencyRecipient>? emergencyRecipients;

  const FakeCallScreen({
    super.key,
    this.callerName = 'Mama',
    this.callerEmoji = '❤️',
    this.callerLabel = 'Nomor Rumah (Batam center)',
    this.callerNumber = '0812-9843-XXXX',
    this.location = 'Jl. Senopati Raya',
    this.guardianCount = 3,
    this.scenarioTitle = 'Dijemput di Depan Gang',
    this.emergencyRecipients,
  });

  @override
  State<FakeCallScreen> createState() => _FakeCallScreenState();
}

class _FakeCallScreenState extends State<FakeCallScreen>
    with SingleTickerProviderStateMixin {
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

  late final AnimationController _pulse;
  Timer? _ringTimer;
  Timer? _callTimer;

  _CallPhase _phase = _CallPhase.ringing;
  int _seconds = 0;
  bool _muted = false;
  bool _speaker = true;
  bool _scriptOpen = true;
  int _step = 0;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

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
    _pulse.dispose();
    super.dispose();
  }

  // ---------- Aksi ----------
  void _accept() {
    HapticFeedback.lightImpact();
    _ringTimer?.cancel();
    // TODO: putar suara "Mama" otomatis (text-to-speech / rekaman) sesuai skenario.
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
        backgroundColor: AppColors.plum,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(
          message,
          style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
        ),
      ),
    );
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
      value: ringing ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _pageBg,
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: ringing
              ? KeyedSubtree(key: const ValueKey('ring'), child: _buildRinging())
              : KeyedSubtree(
                  key: const ValueKey('call'), child: _buildInCall()),
        ),
      ),
    );
  }

  // =====================================================================
  // FASE 1: PANGGILAN MASUK
  // =====================================================================
  Widget _buildRinging() {
    return Column(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_darkTop, _darkBottom],
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(44)),
            ),
            child: SafeArea(
              bottom: false,
              child: LayoutBuilder(
                builder: (context, c) => SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: c.maxHeight),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(22, 14, 22, 20),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: _networkChip(),
                            ),
                            const SizedBox(height: 14),
                            _buildRingingAvatar(),
                            const SizedBox(height: 14),
                            _callerNameText(color: Colors.white),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.softPink,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Panggilan Suara Masuk...',
                                  style: GoogleFonts.nunito(
                                    fontSize: 17,
                                    color: const Color(0xFFE6D7E2),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.callerLabel,
                              style: GoogleFonts.nunito(
                                fontSize: 14,
                                color: const Color(0xFFB5A8BD),
                              ),
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                Expanded(
                                  child: _quickAction(
                                    Icons.alarm_rounded,
                                    'Ingatkan Nanti',
                                    () => _snack('Pengingat belum diaktifkan'),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: _quickAction(
                                    Icons.sms_outlined,
                                    'Kirim Pesan',
                                    () => _snack('Balasan cepat belum diaktifkan'),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 26),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _declineButton(),
                                _acceptButton(),
                              ],
                            ),
                            const SizedBox(height: 22),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.shield_outlined,
                                    size: 17, color: Color(0xFFB5A8BD)),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'Proteksi Perjalanan Nyata • amanJalan Guard',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.nunito(
                                      fontSize: 13,
                                      color: const Color(0xFFB5A8BD),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        _buildTipsPanel(),
      ],
    );
  }

  Widget _networkChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0x1AFFFFFF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cell_tower_rounded,
              size: 18, color: Color(0xFFD9CCDC)),
          const SizedBox(width: 8),
          Text(
            'ID: 4G-btm',
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: const Color(0xFFD9CCDC),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRingingAvatar() {
    return SizedBox(
      height: 270,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (context, _) {
          final t = Curves.easeInOut.transform(_pulse.value);
          return Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: 1 + 0.05 * t,
                child: Container(
                  width: 262,
                  height: 262,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0x14FFFFFF),
                  ),
                ),
              ),
              Container(
                width: 224,
                height: 224,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x1AFFFFFF),
                ),
              ),
              Container(
                width: 168,
                height: 168,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFE6E2E1),
                ),
                alignment: Alignment.center,
                child: Text(
                  widget.callerName.substring(0, 1).toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 64,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFB9AFB5),
                  ),
                ),
              ),
              Positioned(
                right: 58,
                bottom: 40,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: _acceptColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.phone_in_talk_rounded,
                      size: 22, color: AppColors.sage),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _callerNameText({required Color color}) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: widget.callerName,
            style: GoogleFonts.poppins(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          TextSpan(
            text: ' ${widget.callerEmoji}',
            style: const TextStyle(fontSize: 32),
          ),
        ],
      ),
    );
  }

  Widget _quickAction(IconData icon, String label, VoidCallback onTap) {
    return Material(
      color: const Color(0x26FFFFFF),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            children: [
              Icon(icon, size: 24, color: const Color(0xFFE6DCEB)),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  color: const Color(0xFFE6DCEB),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _declineButton() {
    return Column(
      children: [
        GestureDetector(
          onTap: _endCall,
          child: Container(
            width: 84,
            height: 84,
            decoration: const BoxDecoration(
              color: _declineColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.call_end_rounded,
                size: 36, color: Color(0xFFFFD9E0)),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Tolak',
          style: GoogleFonts.nunito(
            fontSize: 16,
            color: const Color(0xFFE6DCEB),
          ),
        ),
      ],
    );
  }

  Widget _acceptButton() {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _pulse,
          builder: (context, child) {
            final t = Curves.easeInOut.transform(_pulse.value);
            return Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 84 + 22 * t,
                  height: 84 + 22 * t,
                  decoration: const BoxDecoration(
                    color: Color(0x332D4A3A),
                    shape: BoxShape.circle,
                  ),
                ),
                child!,
              ],
            );
          },
          child: GestureDetector(
            onTap: _accept,
            child: Container(
              width: 84,
              height: 84,
              decoration: const BoxDecoration(
                color: _acceptColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.call_rounded,
                  size: 36, color: AppColors.sage),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Terima',
          style: GoogleFonts.nunito(
            fontSize: 16,
            color: const Color(0xFFE6DCEB),
          ),
        ),
      ],
    );
  }

  Widget _buildTipsPanel() {
    return Container(
      width: double.infinity,
      color: _pageBg,
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, 16 + MediaQuery.of(context).padding.bottom),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _panelBg,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.softPink,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.lightbulb_outline_rounded,
                      size: 22, color: AppColors.textDark),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tips Alibi Pelindung Diri',
                        style: GoogleFonts.nunito(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Gunakan panggilan ini sebagai alasan wajar untuk mempercepat langkah menuju tempat ramai, toko berlampu terang, atau pos satpam terdekat.',
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          height: 1.45,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _infoTile(
                    Icons.location_on_outlined,
                    'Posisi Terpantau',
                    widget.location,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _infoTile(
                    Icons.groups_outlined,
                    'Wali Terhubung',
                    '${widget.guardianCount} Kontak Aktif',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: _tileBg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: AppColors.plum),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunito(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================================
  // FASE 2: PANGGILAN BERLANGSUNG
  // =====================================================================
  Widget _buildInCall() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        child: Column(
          children: [
            _activeChip(),
            const SizedBox(height: 18),
            _buildCallAvatar(),
            const SizedBox(height: 10),
            _callerNameText(color: AppColors.plumDeep),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.sage,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.graphic_eq_rounded,
                          size: 16, color: Color(0xFF2E5B3C)),
                      const SizedBox(width: 4),
                      Text(
                        'HD Voice',
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          color: const Color(0xFF2E5B3C),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  widget.callerNumber,
                  style: GoogleFonts.nunito(
                    fontSize: 17,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              _timeText,
              style: GoogleFonts.poppins(
                fontSize: 36,
                fontWeight: FontWeight.w500,
                letterSpacing: 2,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),
            _buildScriptCard(),
            const SizedBox(height: 22),
            _buildControls(),
            const SizedBox(height: 22),
            _buildEndButton(),
            const SizedBox(height: 14),
            _buildProtocolNote(),
          ],
        ),
      ),
    );
  }

  Widget _activeChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFF5B4B5C),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: const BoxDecoration(
              color: Color(0xFFA9E0BC),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              'Panggilan Samaran Aktif • Sinyal Terpantau',
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallAvatar() {
    return SizedBox(
      width: 150,
      height: 150,
      child: Stack(
        children: [
          Container(
            width: 144,
            height: 144,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF3EFEF), Color(0xFFC9C3C4)],
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              widget.callerName.substring(0, 1).toUpperCase(),
              style: GoogleFonts.poppins(
                fontSize: 54,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFA79EA2),
              ),
            ),
          ),
          Positioned(
            right: 8,
            bottom: 6,
            child: Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: Color(0xFF1F2E27),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.favorite_rounded,
                  size: 20, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Kartu contekan skenario ----------
  Widget _buildScriptCard() {
    final step = _script[_step];
    final isLast = _step == _script.length - 1;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x144A1D5C),
            blurRadius: 20,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (ketuk untuk buka/tutup)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() => _scriptOpen = !_scriptOpen),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _tileBg,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      color: AppColors.softPink,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.volume_up_rounded,
                        size: 22, color: Color(0xFFB83A5E)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SUARA ${widget.callerName.toUpperCase()} (OTOMATIS)',
                          style: GoogleFonts.nunito(
                            fontSize: 13,
                            letterSpacing: 1,
                            color: const Color(0xFF8B3A5E),
                          ),
                        ),
                        Text(
                          'Skenario: ${widget.scenarioTitle}',
                          style: GoogleFonts.nunito(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _scriptOpen ? 0 : 0.5,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_up_rounded,
                        size: 26, color: AppColors.textDark),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            alignment: Alignment.topCenter,
            child: !_scriptOpen
                ? const SizedBox(width: double.infinity)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _tileBg,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.record_voice_over_outlined,
                                size: 22, color: Color(0xFF8B3A5E)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '“${step.line}”',
                                style: GoogleFonts.nunito(
                                  fontSize: 16,
                                  height: 1.4,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Bocoran Jawaban Kamu (Ucapkan santai):',
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      for (final reply in step.replies)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 9),
                            decoration: BoxDecoration(
                              color: _tileBg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.chat_bubble_outline_rounded,
                                    size: 16, color: AppColors.textMuted),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    '“$reply”',
                                    style: GoogleFonts.nunito(
                                      fontSize: 15,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: isLast
                            ? null
                            : () {
                                HapticFeedback.selectionClick();
                                setState(() => _step++);
                              },
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: isLast ? 0.4 : 1,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.plumDeep,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.skip_next_rounded,
                                    size: 18, color: Colors.white),
                                const SizedBox(width: 6),
                                Text(
                                  'Kalimat Lanjutan',
                                  style: GoogleFonts.nunito(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // ---------- Tombol kontrol panggilan ----------
  Widget _buildControls() {
    return Column(
      children: [
        Row(
          children: [
            _control(
              _muted ? Icons.mic_off_rounded : Icons.mic_none_rounded,
              'Bisu',
              active: _muted,
              onTap: () => setState(() => _muted = !_muted),
            ),
            _control(
              Icons.dialpad_rounded,
              'Papan Tombol',
              onTap: () => _snack('Papan tombol tidak diperlukan di sini'),
            ),
            _control(
              Icons.volume_up_rounded,
              'Speaker',
              active: _speaker,
              onTap: () => setState(() => _speaker = !_speaker),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _control(
              Icons.add_call,
              'Tambah',
              onTap: () => _snack('Fitur ini tidak tersedia saat panggilan samaran'),
            ),
            _control(Icons.videocam_outlined, 'FaceTime', disabled: true),
            _control(
              Icons.contacts_outlined,
              'Kontak',
              onTap: () => _snack('Fitur ini tidak tersedia saat panggilan samaran'),
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
    final fg = active
        ? Colors.white
        : (disabled ? const Color(0xFF9A95A6) : AppColors.textDark);
    return Expanded(
      child: Column(
        children: [
          GestureDetector(
            onTap: disabled
                ? null
                : () {
                    HapticFeedback.selectionClick();
                    onTap?.call();
                  },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: active ? AppColors.plumDeep : Colors.white,
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x144A1D5C),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, size: 26, color: fg),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: active ? FontWeight.w800 : FontWeight.w500,
              color: disabled
                  ? const Color(0xFF9A95A6)
                  : (active ? AppColors.plumDeep : AppColors.textDark),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Akhiri panggilan + protokol senyap ----------
  Widget _buildEndButton() {
    return GestureDetector(
      onTap: _endCall, // ketuk sekali: akhiri panggilan
      onDoubleTap: _silentEmergency, // ketuk 2x cepat: kirim sinyal darurat
      child: Container(
        width: 66,
        height: 66,
        decoration: const BoxDecoration(
          color: AppColors.emergencyRed,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.call_end_rounded,
            size: 30, color: Color(0xFFFFE0E0)),
      ),
    );
  }

  Widget _buildProtocolNote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _panelBg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shield_outlined,
                  size: 18, color: Color(0xFF8B3A5E)),
              const SizedBox(width: 6),
              Text(
                'Protokol Darurat Senyap',
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  color: const Color(0xFF8B3A5E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text.rich(
            TextSpan(
              style: GoogleFonts.nunito(
                fontSize: 13.5,
                height: 1.4,
                color: AppColors.textMuted,
              ),
              children: const [
                TextSpan(text: 'Tekan tombol merah '),
                TextSpan(
                  text: '2x cepat',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                TextSpan(
                    text:
                        ' untuk kirim sinyal darurat & Live GPS ke Wali amanJalan.'),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}