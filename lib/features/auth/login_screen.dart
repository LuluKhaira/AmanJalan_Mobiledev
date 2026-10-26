import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:amanjalan/core/theme/app_colors.dart';
import 'package:amanjalan/core/services/auth_service.dart';
import 'package:amanjalan/core/widgets/animated_entrance.dart';
import 'package:amanjalan/core/widgets/press_scale.dart';
import 'package:amanjalan/features/auth/register_screen.dart';
import 'package:amanjalan/features/home/home_screen.dart';

const _errorColor = Color(0xFFB83A5E);
const _fieldFill = Color(0xFFF6F5F8);
const _lineColor = Color(0xFFE6E3EA);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _idCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
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
          backgroundColor: _errorColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Text(result.message ?? 'Gagal masuk.',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
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

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(26, 48, 26, 28),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedEntrance(index: 0, child: _buildLogo()),
                  const SizedBox(height: 32),
                  AnimatedEntrance(index: 1, child: _buildHeading()),
                  const SizedBox(height: 36),
                  AnimatedEntrance(
                    index: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Nomor HP atau Email'),
                        _CleanField(
                          controller: _idCtrl,
                          hint: '+62 812... atau email kamu',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: (v) {
                            final value = v?.trim() ?? '';
                            if (value.isEmpty) return 'Nomor HP atau email wajib diisi';
                            if (value.contains('@')) {
                              final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
                              return ok ? null : 'Format email tidak valid';
                            }
                            final digits = value.replaceAll(RegExp(r'\D'), '');
                            return digits.length >= 9 ? null : 'Nomor HP tidak valid';
                          },
                        ),
                        const SizedBox(height: 20),
                        _label('Kata Sandi'),
                        _CleanField(
                          controller: _passCtrl,
                          hint: 'Masukkan kata sandi (ketik "salah" untuk demo error)',
                          obscure: _obscure,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _submit(),
                          suffix: IconButton(
                            splashRadius: 20,
                            onPressed: () => setState(() => _obscure = !_obscure),
                            icon: Icon(
                              _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              size: 21,
                              color: AppColors.textMuted,
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Kata sandi wajib diisi';
                            if (v.length < 8) return 'Minimal 8 karakter';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  AnimatedEntrance(
                    index: 3,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.plum,
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text('Lupa kata sandi?',
                            style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  AnimatedEntrance(index: 4, child: _buildPrimaryButton()),
                  const SizedBox(height: 30),
                  AnimatedEntrance(index: 5, child: _buildDivider()),
                  const SizedBox(height: 24),
                  AnimatedEntrance(index: 6, child: _buildSocialRow()),
                  const SizedBox(height: 36),
                  AnimatedEntrance(index: 7, child: _buildRegisterLink()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 52, height: 52,
      decoration: BoxDecoration(color: AppColors.softPink, borderRadius: BorderRadius.circular(16)),
      child: const Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.shield_outlined, size: 30, color: AppColors.plum),
          Padding(padding: EdgeInsets.only(top: 2), child: Icon(Icons.person, size: 12, color: AppColors.plum)),
        ],
      ),
    );
  }

  Widget _buildHeading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Selamat datang\nkembali',
            style: GoogleFonts.poppins(
                fontSize: 30, fontWeight: FontWeight.w700, color: AppColors.textDark, height: 1.2, letterSpacing: -0.6)),
        const SizedBox(height: 10),
        Text('Masuk untuk mengaktifkan kembali perlindungan perjalananmu.',
            style: GoogleFonts.nunito(fontSize: 15, height: 1.5, color: AppColors.textMuted)),
      ],
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: GoogleFonts.nunito(fontSize: 14.5, fontWeight: FontWeight.w700, color: AppColors.textDark)),
      );

  Widget _buildPrimaryButton() {
    return PressScale(
      child: SizedBox(
        width: double.infinity, height: 54,
        child: ElevatedButton(
          onPressed: _loading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.plum,
            disabledBackgroundColor: AppColors.plum,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _loading
                ? const SizedBox(
                    key: ValueKey('loading'), width: 22, height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                : Text('Masuk',
                    key: const ValueKey('label'),
                    style: GoogleFonts.nunito(fontSize: 17, fontWeight: FontWeight.w800, letterSpacing: 0.3)),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: _lineColor, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text('atau', style: GoogleFonts.nunito(fontSize: 13.5, color: AppColors.textMuted)),
        ),
        const Expanded(child: Divider(color: _lineColor, thickness: 1)),
      ],
    );
  }

  Widget _buildSocialRow() {
    return Row(
      children: [
        Expanded(
          child: _socialButton(
            label: 'Google',
            leading: Text('G',
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: const Color(0xFF4285F4))),
            onTap: () {},
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _socialButton(
            label: 'Apple',
            leading: const Icon(Icons.apple, size: 23, color: Colors.black),
            onTap: () {},
          ),
        ),
      ],
    );
  }

  Widget _socialButton({required String label, required Widget leading, required VoidCallback onTap}) {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: _lineColor, width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 24, child: Center(child: leading)),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.nunito(fontSize: 15.5, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Center(
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text('Belum punya akun? ', style: GoogleFonts.nunito(fontSize: 15, color: AppColors.textMuted)),
          GestureDetector(
            onTap: _goToRegister,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text('Daftar',
                  style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.plum)),
            ),
          ),
        ],
      ),
    );
  }
}

class _CleanField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final bool obscure;
  final Widget? suffix;
  final ValueChanged<String>? onSubmitted;

  const _CleanField({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.obscure = false,
    this.suffix,
    this.onSubmitted,
  });

  OutlineInputBorder _border(Color color, double width) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: width == 0 ? BorderSide.none : BorderSide(color: color, width: width),
      );

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      onFieldSubmitted: onSubmitted,
      cursorColor: AppColors.plum,
      style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.nunito(fontSize: 15, color: const Color(0xFF9A95A6)),
        filled: true,
        fillColor: _fieldFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        suffixIcon: suffix,
        border: _border(Colors.transparent, 0),
        enabledBorder: _border(Colors.transparent, 0),
        focusedBorder: _border(AppColors.plum, 1.5),
        errorBorder: _border(_errorColor, 1.2),
        focusedErrorBorder: _border(_errorColor, 1.5),
        errorStyle: GoogleFonts.nunito(fontSize: 12.5, fontWeight: FontWeight.w600, color: _errorColor),
      ),
    );
  }
}