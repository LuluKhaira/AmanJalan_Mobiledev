import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:amanjalan/core/theme/aj_theme.dart';
import 'package:amanjalan/features/auth/login_screen.dart';
import 'package:amanjalan/features/auth/otp_screen.dart';
import 'package:amanjalan/features/auth/widgets/auth_palette.dart';
import 'package:amanjalan/features/auth/widgets/auth_shell.dart';
import 'package:amanjalan/features/auth/widgets/auth_widgets.dart';
import 'package:amanjalan/features/welcome/widgets/welcome_palette.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passFocus = FocusNode();
  final _mood = ValueNotifier<OwlMood>(OwlMood.idle);

  bool _obscure = true;
  bool _agreed = false;
  bool _showAgreeError = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    for (final f in [_nameFocus, _emailFocus, _phoneFocus, _passFocus]) {
      f.addListener(_syncMood);
    }
    _passCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passFocus.dispose();
    _mood.dispose();
    super.dispose();
  }

  void _syncMood() {
    if (_passFocus.hasFocus) {
      _mood.value = _obscure ? OwlMood.shy : OwlMood.look;
    } else if (_nameFocus.hasFocus || _emailFocus.hasFocus || _phoneFocus.hasFocus) {
      _mood.value = OwlMood.look;
    } else {
      _mood.value = OwlMood.idle;
    }
  }

  // ---------- Logika ----------
  int get _strength {
    final p = _passCtrl.text;
    if (p.isEmpty) return 0;
    var s = 0;
    if (p.length >= 8) s++;
    if (RegExp(r'[A-Z]').hasMatch(p) && RegExp(r'[a-z]').hasMatch(p)) s++;
    if (RegExp(r'\d').hasMatch(p)) s++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(p)) s++;
    return s;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final valid = _formKey.currentState!.validate();
    setState(() => _showAgreeError = !_agreed);

    if (!valid || !_agreed) {
      HapticFeedback.mediumImpact();
      return;
    }

    HapticFeedback.lightImpact();
    setState(() => _loading = true);

    // TODO: sambungkan ke Firebase Auth / API
    await Future.delayed(const Duration(milliseconds: 1400));

    if (!mounted) return;
    setState(() => _loading = false);

    // Format nomor untuk ditampilkan di halaman OTP
    var digits = _phoneCtrl.text.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('0')) digits = digits.substring(1);

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => OtpScreen(phone: '+62 $digits')),
    );
  }

  void _goToLogin() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  // ---------- Tampilan ----------
  @override
  Widget build(BuildContext context) {
    return AuthShell(
      title: 'Buat akun\nbaru',
      subtitle: 'Daftar untuk mulai bepergian lebih tenang bersama Guardian terpercayamu.',
      mood: _mood,
      cardBuilder: (context, p) => Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AuthField(
              p: p,
              label: 'Nama Lengkap',
              hint: 'Contoh: Siti Rahma',
              icon: Icons.person_outline_rounded,
              controller: _nameCtrl,
              focusNode: _nameFocus,
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              autofillHints: const [AutofillHints.name],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Nama wajib diisi';
                if (v.trim().length < 3) return 'Nama terlalu pendek';
                return null;
              },
            ),
            const SizedBox(height: 16),
            AuthField(
              p: p,
              label: 'Email',
              hint: 'nama@email.com',
              icon: Icons.mail_outline_rounded,
              controller: _emailCtrl,
              focusNode: _emailFocus,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email wajib diisi';
                final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());
                return ok ? null : 'Format email tidak valid';
              },
            ),
            const SizedBox(height: 16),
            AuthField(
              p: p,
              label: 'Nomor HP',
              hint: '812 3456 7890',
              controller: _phoneCtrl,
              focusNode: _phoneFocus,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.telephoneNumberNational],
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(13),
              ],
              prefix: _CountryChip(p: p),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Nomor HP wajib diisi';
                if (v.length < 9) return 'Nomor HP tidak valid';
                return null;
              },
            ),
            const SizedBox(height: 16),
            AuthField(
              p: p,
              label: 'Kata Sandi',
              hint: 'Minimal 8 karakter',
              icon: Icons.lock_outline_rounded,
              controller: _passCtrl,
              focusNode: _passFocus,
              obscure: _obscure,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.newPassword],
              onSubmitted: (_) => _submit(),
              suffix: IconButton(
                splashRadius: 20,
                onPressed: () {
                  setState(() => _obscure = !_obscure);
                  _syncMood();
                },
                icon: Icon(
                  _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 21,
                  color: p.iconMuted,
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Kata sandi wajib diisi';
                if (v.length < 8) return 'Minimal 8 karakter';
                return null;
              },
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              alignment: Alignment.topCenter,
              child: _passCtrl.text.isEmpty
                  ? const SizedBox(width: double.infinity)
                  : Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: _buildStrengthMeter(p),
                    ),
            ),
            const SizedBox(height: 20),
            _buildTermsCheck(p),
            const SizedBox(height: 22),
            AuthPrimaryButton(p: p, label: 'Daftar', loading: _loading, onTap: _submit),
            const SizedBox(height: 22),
            AuthDivider(p: p),
            const SizedBox(height: 18),
            AuthSocialRow(p: p),
          ],
        ),
      ),
      footerBuilder: (context, p) => AuthFooterLink(
        p: p,
        text: 'Sudah punya akun?',
        action: 'Masuk',
        onTap: _goToLogin,
      ),
    );
  }

  Widget _buildStrengthMeter(WelcomePalette p) {
    final s = _strength;
    const labels = ['', 'Lemah', 'Cukup', 'Kuat', 'Sangat kuat'];
    final colors = [
      p.line,
      const Color(0xFFD98A6C),
      const Color(0xFFE3B34F),
      const Color(0xFF7DB88A),
      const Color(0xFF4E9F6B),
    ];
    final active = colors[s];

    return Row(
      children: [
        Expanded(
          child: Row(
            children: List.generate(4, (i) {
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: 4,
                  margin: EdgeInsets.only(right: i == 3 ? 0 : 5),
                  decoration: BoxDecoration(
                    color: i < s ? active : p.line,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 78,
          child: Text(
            labels[s],
            textAlign: TextAlign.right,
            style: Aj.b(12.5, color: s == 0 ? p.subtitle : active, w: FontWeight.w800),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsCheck(WelcomePalette p) {
    final link = Aj.b(13.5, color: p.link, w: FontWeight.w800, height: 1.5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() {
              _agreed = !_agreed;
              if (_agreed) _showAgreeError = false;
            });
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22,
                height: 22,
                margin: const EdgeInsets.only(top: 1),
                decoration: BoxDecoration(
                  color: _agreed ? p.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                    color: _agreed
                        ? p.primary
                        : (_showAgreeError ? p.error : p.checkBorder),
                    width: 1.5,
                  ),
                ),
                child: _agreed
                    ? Icon(Icons.check_rounded, size: 16, color: p.onPrimary)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: Aj.b(13.5, color: p.subtitle, w: FontWeight.w600, height: 1.5),
                    children: [
                      const TextSpan(text: 'Saya menyetujui '),
                      TextSpan(text: 'Ketentuan Layanan', style: link),
                      const TextSpan(text: ' & '),
                      TextSpan(text: 'Kebijakan Privasi', style: link),
                      const TextSpan(text: ' AmanJalan.'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: _showAgreeError
              ? Padding(
                  padding: const EdgeInsets.only(top: 8, left: 34),
                  child: Text(
                    'Setujui ketentuan untuk melanjutkan',
                    style: Aj.b(12.5, color: p.error, w: FontWeight.w700),
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

// =====================================================================
// Chip kode negara (+62)
// =====================================================================
class _CountryChip extends StatelessWidget {
  final WelcomePalette p;
  const _CountryChip({required this.p});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: p.cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: p.fieldBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🇮🇩', style: TextStyle(fontSize: 15)),
          const SizedBox(width: 6),
          Text('+62', style: Aj.b(14.5, color: p.fieldText, w: FontWeight.w800)),
        ],
      ),
    );
  }
}