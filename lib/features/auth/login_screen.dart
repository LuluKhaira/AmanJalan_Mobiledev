import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:amanjalan/core/services/auth_service.dart';
import 'package:amanjalan/core/theme/aj_theme.dart';
import 'package:amanjalan/features/auth/register_screen.dart';
import 'package:amanjalan/features/auth/widgets/auth_palette.dart';
import 'package:amanjalan/features/auth/widgets/auth_shell.dart';
import 'package:amanjalan/features/auth/widgets/auth_widgets.dart';
import 'package:amanjalan/features/home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _idFocus = FocusNode();
  final _passFocus = FocusNode();
  final _mood = ValueNotifier<OwlMood>(OwlMood.idle);

  bool _obscure = true;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _idFocus.addListener(_syncMood);
    _passFocus.addListener(_syncMood);
  }

  @override
  void dispose() {
    _idCtrl.dispose();
    _passCtrl.dispose();
    _idFocus.dispose();
    _passFocus.dispose();
    _mood.dispose();
    super.dispose();
  }

  void _syncMood() {
    if (_passFocus.hasFocus) {
      _mood.value = _obscure ? OwlMood.shy : OwlMood.look;
    } else if (_idFocus.hasFocus) {
      _mood.value = OwlMood.look;
    } else {
      _mood.value = OwlMood.idle;
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      return;
    }
    HapticFeedback.lightImpact();
    setState(() => _loading = true);

    final result = await AuthService.instance.login(
      id: _idCtrl.text.trim(),
      password: _passCtrl.text,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (!result.ok) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFFB83A5E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Text(
            result.message ?? 'Gagal masuk.',
            style: Aj.b(14, color: Colors.white, w: FontWeight.w700),
          ),
        ),
      );
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
      (route) => false,
    );
  }

  void _goToRegister() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) => const RegisterScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  String? _validateId(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return 'Nomor HP atau email wajib diisi';
    if (value.contains('@')) {
      final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
      return ok ? null : 'Format email tidak valid';
    }
    final digits = value.replaceAll(RegExp(r'\D'), '');
    return digits.length >= 9 ? null : 'Nomor HP tidak valid';
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      title: 'Selamat datang\nkembali',
      subtitle: 'Masuk untuk mengaktifkan kembali perlindungan perjalananmu.',
      mood: _mood,
      cardBuilder: (context, p) => Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AuthField(
              p: p,
              label: 'Nomor HP atau Email',
              hint: '+62 812... atau email kamu',
              icon: Icons.alternate_email_rounded,
              controller: _idCtrl,
              focusNode: _idFocus,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.username],
              validator: _validateId,
            ),
            const SizedBox(height: 16),
            AuthField(
              p: p,
              label: 'Kata Sandi',
              hint: 'Masukkan kata sandi',
              icon: Icons.lock_outline_rounded,
              controller: _passCtrl,
              focusNode: _passFocus,
              obscure: _obscure,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
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
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: p.link,
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Lupa kata sandi?',
                  style: Aj.b(13.5, color: p.link, w: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(height: 6),
            AuthPrimaryButton(
              p: p,
              label: 'Masuk',
              loading: _loading,
              onTap: _submit,
            ),
            const SizedBox(height: 22),
            AuthDivider(p: p),
            const SizedBox(height: 18),
            AuthSocialRow(p: p),
          ],
        ),
      ),
      footerBuilder: (context, p) => AuthFooterLink(
        p: p,
        text: 'Belum punya akun?',
        action: 'Daftar',
        onTap: _goToRegister,
      ),
    );
  }
}