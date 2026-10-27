import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:amanjalan/core/theme/app_colors.dart';
import 'package:amanjalan/features/permission/location_permission_screen.dart';

const _fieldFill = Color(0xFFF6F5F8);
const _lineColor = Color(0xFFE6E3EA);

class OtpScreen extends StatefulWidget {
  /// Nomor yang ditampilkan, contoh: "+62 812 3456 7890"
  final String phone;

  const OtpScreen({super.key, this.phone = '+62 812 3456 7890'});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen>
    with SingleTickerProviderStateMixin {
  static const _length = 6;
  static const _resendSeconds = 45;

  late final AnimationController _intro;
  late final Animation<double> _fade;
  Timer? _timer;

  String _code = '';
  int _secondsLeft = _resendSeconds;
  bool _loading = false;

  bool get _complete => _code.length == _length;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fade = CurvedAnimation(parent: _intro, curve: Curves.easeOut);
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _intro.dispose();
    super.dispose();
  }

  // ---------- Logic ----------
  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = _resendSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        t.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  void _onDigit(String d) {
    if (_loading || _code.length >= _length) return;
    HapticFeedback.selectionClick();
    setState(() => _code += d);
  }

  void _onDelete() {
    if (_loading || _code.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() => _code = _code.substring(0, _code.length - 1));
  }

  void _resend() {
    if (_secondsLeft > 0) return;
    // TODO: panggil API kirim ulang kode
    setState(() => _code = '');
    _startTimer();
    _showSnack('Kode baru sudah dikirim');
  }

  Future<void> _verify() async {
    if (!_complete || _loading) return;
    HapticFeedback.lightImpact();
    setState(() => _loading = true);

    // TODO: verifikasi kode ke Firebase Auth / API
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;
    setState(() => _loading = false);

    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) => const LocationPermissionScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
      (route) => false,
    );
  }

  void _showSnack(String message) {
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

  String get _timeText =>
      '00:${_secondsLeft.toString().padLeft(2, '0')}';

  // ---------- Build ----------
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: FadeTransition(
            opacity: _fade,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(26, 48, 26, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLogo(),
                  const SizedBox(height: 32),
                  _buildHeading(),
                  const SizedBox(height: 32),
                  _buildCodeBoxes(),
                  const SizedBox(height: 22),
                  _buildResend(),
                  const SizedBox(height: 26),
                  _buildPrimaryButton(),
                  const SizedBox(height: 26),
                  _buildKeypad(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------- Bagian layar ----------
  Widget _buildLogo() {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.softPink,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.sms_outlined, size: 26, color: AppColors.plum),
    );
  }

  Widget _buildHeading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Verifikasi\nnomor HP',
          style: GoogleFonts.poppins(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
            height: 1.2,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 10),
        Text.rich(
          TextSpan(
            style: GoogleFonts.nunito(
              fontSize: 15,
              height: 1.5,
              color: AppColors.textMuted,
            ),
            children: [
              const TextSpan(text: 'Kode 6 digit dikirim ke '),
              TextSpan(
                text: widget.phone,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () => Navigator.of(context).maybePop(),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.edit_outlined,
                    size: 16, color: AppColors.plum),
                const SizedBox(width: 6),
                Text(
                  'Ubah nomor',
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.plum,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCodeBoxes() {
    return Row(
      children: List.generate(_length, (i) {
        final filled = i < _code.length;
        final active = i == _code.length && !_loading;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == _length - 1 ? 0 : 9),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              height: 60,
              decoration: BoxDecoration(
                color: active ? Colors.white : _fieldFill,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: active ? AppColors.plum : Colors.transparent,
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                filled ? _code[i] : '',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildResend() {
    return Center(
      child: Column(
        children: [
          if (_secondsLeft > 0)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.schedule_rounded,
                    size: 18, color: AppColors.textMuted),
                const SizedBox(width: 8),
                Text.rich(
                  TextSpan(
                    style: GoogleFonts.nunito(
                      fontSize: 14.5,
                      color: AppColors.textMuted,
                    ),
                    children: [
                      const TextSpan(text: 'Kirim ulang kode '),
                      TextSpan(
                        text: _timeText,
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          else
            GestureDetector(
              onTap: _resend,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  'Kirim ulang kode',
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.plum,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () {
              // TODO: kirim kode lewat WhatsApp
              _showSnack('Pengiriman via WhatsApp belum diaktifkan');
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                'Belum terima SMS? Kirim via WhatsApp',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.plum,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.plum,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton() {
    final enabled = _complete && !_loading;
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: enabled ? _verify : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.plum,
          disabledBackgroundColor:
              _loading ? AppColors.plum : const Color(0xFFD5C9DC),
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _loading
              ? const SizedBox(
                  key: ValueKey('loading'),
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Text(
                  'Lanjut',
                  key: const ValueKey('label'),
                  style: GoogleFonts.nunito(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
        ),
      ),
    );
  }

  // ---------- Keypad angka ----------
  Widget _buildKeypad() {
    const rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
    ];

    return Column(
      children: [
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                for (var i = 0; i < row.length; i++)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: i == 2 ? 0 : 10),
                      child: _key(row[i]),
                    ),
                  ),
              ],
            ),
          ),
        Row(
          children: [
            const Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: 10),
                child: SizedBox(height: 56),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: _key('0'),
              ),
            ),
            Expanded(child: _deleteKey()),
          ],
        ),
      ],
    );
  }

  Widget _keyShell({
    required Widget child,
    required VoidCallback onTap,
    VoidCallback? onLongPress,
  }) {
    return Material(
      color: _fieldFill,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        onLongPress: onLongPress,
        child: SizedBox(height: 56, child: Center(child: child)),
      ),
    );
  }

  Widget _key(String digit) {
    return _keyShell(
      onTap: () => _onDigit(digit),
      child: Text(
        digit,
        style: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
      ),
    );
  }

  Widget _deleteKey() {
    return _keyShell(
      onTap: _onDelete,
      onLongPress: () {
        if (_loading) return;
        HapticFeedback.mediumImpact();
        setState(() => _code = '');
      },
      child: const Icon(Icons.backspace_outlined,
          size: 22, color: AppColors.textDark),
    );
  }
}