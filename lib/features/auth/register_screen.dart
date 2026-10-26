import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:amanjalan/core/theme/app_colors.dart';
import 'package:amanjalan/core/services/auth_service.dart';
import 'package:amanjalan/core/widgets/animated_entrance.dart';
import 'package:amanjalan/core/widgets/press_scale.dart';
import 'package:amanjalan/features/auth/login_screen.dart';
import 'package:amanjalan/features/auth/otp_screen.dart';

const _errorColor = Color(0xFFB83A5E);
const _fieldFill = Color(0xFFF6F5F8);
const _lineColor = Color(0xFFE6E3EA);

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

  bool _obscure = true;
  bool _agreed = false;
  bool _showAgreeError = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _passCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

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

    final result = await AuthService.instance.register(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      password: _passCtrl.text,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (!result.ok) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating, backgroundColor: _errorColor,
        content: Text('Gagal mendaftar.', style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
      ));
      return;
    }

    final phone = '+62 ${_phoneCtrl.text.trim()}';
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (_, __, ___) => OtpScreen(phone: phone),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  void _goToLogin() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
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
                  
                  AnimatedEntrance(index: 2, child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Nama Lengkap'),
                      _CleanField(
                        controller: _nameCtrl,
                        hint: 'Contoh: Siti Rahma',
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.words,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Nama wajib diisi';
                          if (v.trim().length < 3) return 'Nama terlalu pendek';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _label('Email'),
                      _CleanField(
                        controller: _emailCtrl,
                        hint: 'nama@email.com',
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Email wajib diisi';
                          final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());
                          return ok ? null : 'Format email tidak valid';
                        },
                      ),
                      const SizedBox(height: 20),
                      _label('Nomor HP'),
                      _CleanField(
                        controller: _phoneCtrl,
                        hint: '812 3456 7890',
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(13),
                        ],
                        prefix: const _CountryChip(),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Nomor HP wajib diisi';
                          if (v.length < 9) return 'Nomor HP tidak valid';
                          return null;
                        },
                      ),
                    ],
                  )),
                  
                  const SizedBox(height: 20),

                  AnimatedEntrance(index: 3, child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Kata Sandi'),
                      _CleanField(
                        controller: _passCtrl,
                        hint: 'Minimal 8 karakter',
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
                      AnimatedSize(
                        duration: const Duration(milliseconds: 200),
                        alignment: Alignment.topCenter,
                        child: _passCtrl.text.isEmpty
                            ? const SizedBox(width: double.infinity)
                            : Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: _buildStrengthMeter(),
                              ),
                      ),
                    ],
                  )),

                  const SizedBox(height: 22),
                  AnimatedEntrance(index: 4, child: _buildTermsCheck()),
                  const SizedBox(height: 24),
                  AnimatedEntrance(index: 5, child: _buildPrimaryButton()),
                  const SizedBox(height: 30),
                  AnimatedEntrance(index: 6, child: _buildDivider()),
                  const SizedBox(height: 24),
                  AnimatedEntrance(index: 7, child: _buildSocialRow()),
                  const SizedBox(height: 36),
                  AnimatedEntrance(index: 8, child: _buildLoginLink()),
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
        Text('Buat akun\nbaru', style: GoogleFonts.poppins(fontSize: 30, fontWeight: FontWeight.w700, color: AppColors.textDark, height: 1.2, letterSpacing: -0.6)),
        const SizedBox(height: 10),
        Text('Daftar untuk mulai bepergian lebih tenang bersama Guardian terpercayamu.', style: GoogleFonts.nunito(fontSize: 15, height: 1.5, color: AppColors.textMuted)),
      ],
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: GoogleFonts.nunito(fontSize: 14.5, fontWeight: FontWeight.w700, color: AppColors.textDark)),
      );

  Widget _buildStrengthMeter() {
    final s = _strength;
    const labels = ['', 'Lemah', 'Cukup', 'Kuat', 'Sangat kuat'];
    const colors = [_lineColor, Color(0xFFD98A6C), Color(0xFFE3B34F), Color(0xFF7DB88A), Color(0xFF4E9F6B)];
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
                    color: i < s ? active : _lineColor,
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
          child: Text(labels[s], textAlign: TextAlign.right,
              style: GoogleFonts.nunito(fontSize: 12.5, fontWeight: FontWeight.w700, color: active == _lineColor ? AppColors.textMuted : active)),
        ),
      ],
    );
  }

  Widget _buildTermsCheck() {
    const link = TextStyle(color: AppColors.plum, fontWeight: FontWeight.w800);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() {
            _agreed = !_agreed;
            if (_agreed) _showAgreeError = false;
          }),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22, height: 22,
                margin: const EdgeInsets.only(top: 1),
                decoration: BoxDecoration(
                  color: _agreed ? AppColors.plum : Colors.white,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                    color: _agreed ? AppColors.plum : (_showAgreeError ? _errorColor : const Color(0xFFC9C3D1)),
                    width: 1.5,
                  ),
                ),
                child: _agreed ? const Icon(Icons.check_rounded, size: 16, color: Colors.white) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text.rich(TextSpan(
                  style: GoogleFonts.nunito(fontSize: 13.5, height: 1.5, color: AppColors.textMuted),
                  children: const [
                    TextSpan(text: 'Saya menyetujui '),
                    TextSpan(text: 'Ketentuan Layanan', style: link),
                    TextSpan(text: ' & '),
                    TextSpan(text: 'Kebijakan Privasi', style: link),
                    TextSpan(text: ' AmanJalan.'),
                  ],
                )),
              ),
            ],
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: _showAgreeError
              ? Padding(
                  padding: const EdgeInsets.only(top: 8, left: 34),
                  child: Text('Setujui ketentuan untuk melanjutkan',
                      style: GoogleFonts.nunito(fontSize: 12.5, fontWeight: FontWeight.w600, color: _errorColor)),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton() {
    return PressScale(
      child: SizedBox(
        width: double.infinity, height: 54,
        child: ElevatedButton(
          onPressed: _loading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.plum, disabledBackgroundColor: AppColors.plum, foregroundColor: Colors.white, elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _loading
                ? const SizedBox(key: ValueKey('loading'), width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                : Text('Daftar', key: const ValueKey('label'), style: GoogleFonts.nunito(fontSize: 17, fontWeight: FontWeight.w800, letterSpacing: 0.3)),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: _lineColor, thickness: 1)),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 14), child: Text('atau', style: GoogleFonts.nunito(fontSize: 13.5, color: AppColors.textMuted))),
        const Expanded(child: Divider(color: _lineColor, thickness: 1)),
      ],
    );
  }

  Widget _buildSocialRow() {
    return Row(
      children: [
        Expanded(child: _socialButton(label: 'Google', leading: Text('G', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: const Color(0xFF4285F4))), onTap: () {})),
        const SizedBox(width: 12),
        Expanded(child: _socialButton(label: 'Apple', leading: const Icon(Icons.apple, size: 23, color: Colors.black), onTap: () {})),
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

  Widget _buildLoginLink() {
    return Center(
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text('Sudah punya akun? ', style: GoogleFonts.nunito(fontSize: 15, color: AppColors.textMuted)),
          GestureDetector(
            onTap: _goToLogin,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text('Masuk', style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.plum)),
            ),
          ),
        ],
      ),
    );
  }
}

class _CountryChip extends StatelessWidget {
  const _CountryChip();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(9), border: Border.all(color: _lineColor)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🇮🇩', style: TextStyle(fontSize: 15)),
          const SizedBox(width: 6),
          Text('+62', style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
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
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final bool obscure;
  final Widget? prefix;
  final Widget? suffix;
  final ValueChanged<String>? onSubmitted;

  const _CleanField({
    required this.controller, required this.hint,
    this.keyboardType, this.textInputAction, this.textCapitalization = TextCapitalization.none,
    this.inputFormatters, this.validator, this.obscure = false, this.prefix, this.suffix, this.onSubmitted,
  });

  OutlineInputBorder _border(Color color, double width) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: width == 0 ? BorderSide.none : BorderSide(color: color, width: width),
      );

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller, obscureText: obscure, keyboardType: keyboardType,
      textInputAction: textInputAction, textCapitalization: textCapitalization,
      inputFormatters: inputFormatters, validator: validator, onFieldSubmitted: onSubmitted,
      cursorColor: AppColors.plum,
      style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.nunito(fontSize: 15, color: const Color(0xFF9A95A6)),
        filled: true, fillColor: _fieldFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        prefixIcon: prefix == null ? null : Padding(padding: const EdgeInsets.only(left: 12, right: 10), child: prefix),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        suffixIcon: suffix,
        border: _border(Colors.transparent, 0), enabledBorder: _border(Colors.transparent, 0),
        focusedBorder: _border(AppColors.plum, 1.5), errorBorder: _border(_errorColor, 1.2), focusedErrorBorder: _border(_errorColor, 1.5),
        errorStyle: GoogleFonts.nunito(fontSize: 12.5, fontWeight: FontWeight.w600, color: _errorColor),
      ),
    );
  }
}