import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:amanjalan/core/theme/aj_theme.dart';
import 'package:amanjalan/features/auth/widgets/auth_palette.dart';
import 'package:amanjalan/features/welcome/widgets/welcome_palette.dart';

// =====================================================================
// Field input: label di atas, isian berlatar lembut, ikon di kiri
// =====================================================================
class AuthField extends StatelessWidget {
  final WelcomePalette p;
  final String label;
  final String hint;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final IconData? icon;
  final Widget? prefix;
  final Widget? suffix;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onSubmitted;

  const AuthField({
    super.key,
    required this.p,
    required this.label,
    required this.hint,
    required this.controller,
    this.focusNode,
    this.icon,
    this.prefix,
    this.suffix,
    this.obscure = false,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.autofillHints,
    this.validator,
    this.onSubmitted,
  });

  OutlineInputBorder _border(Color c, double w) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: c, width: w),
      );

  @override
  Widget build(BuildContext context) {
    final Widget? leading =
        prefix ?? (icon == null ? null : Icon(icon, size: 20, color: p.iconMuted));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 8),
          child: Text(label, style: Aj.b(13.5, color: p.label, w: FontWeight.w800)),
        ),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscure,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          textCapitalization: textCapitalization,
          inputFormatters: inputFormatters,
          autofillHints: autofillHints,
          validator: validator,
          onFieldSubmitted: onSubmitted,
          cursorColor: p.focus,
          keyboardAppearance: p.isNight ? Brightness.dark : Brightness.light,
          style: Aj.b(15.5, color: p.fieldText, w: FontWeight.w700),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: Aj.b(14.5, color: p.hint, w: FontWeight.w500),
            filled: true,
            fillColor: p.fieldFill,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
            prefixIcon: leading == null
                ? null
                : Padding(
                    padding: const EdgeInsets.only(left: 16, right: 12),
                    child: leading,
                  ),
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            suffixIcon: suffix,
            border: _border(p.fieldBorder, 1.2),
            enabledBorder: _border(p.fieldBorder, 1.2),
            focusedBorder: _border(p.focus, 1.7),
            errorBorder: _border(p.error, 1.3),
            focusedErrorBorder: _border(p.error, 1.7),
            errorStyle: Aj.b(12.5, color: p.error, w: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

// =====================================================================
// Tombol utama (pil) dengan status loading
// =====================================================================
class AuthPrimaryButton extends StatefulWidget {
  final WelcomePalette p;
  final String label;
  final bool loading;
  final VoidCallback onTap;

  const AuthPrimaryButton({
    super.key,
    required this.p,
    required this.label,
    required this.onTap,
    this.loading = false,
  });

  @override
  State<AuthPrimaryButton> createState() => _AuthPrimaryButtonState();
}

class _AuthPrimaryButtonState extends State<AuthPrimaryButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final off = widget.loading;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: off ? null : (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: off ? null : widget.onTap,
      child: AnimatedScale(
        scale: _down ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: p.primary,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(color: p.primaryGlow, blurRadius: 22, offset: const Offset(0, 10)),
            ],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: widget.loading
                ? SizedBox(
                    key: const ValueKey('loading'),
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: p.onPrimary),
                  )
                : Row(
                    key: const ValueKey('label'),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(widget.label, style: Aj.h(15.5, color: p.onPrimary)),
                      const SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 19, color: p.onPrimary),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// Pembatas "atau"
// =====================================================================
class AuthDivider extends StatelessWidget {
  final WelcomePalette p;
  const AuthDivider({super.key, required this.p});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: p.line)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text('atau', style: Aj.b(13, color: p.subtitle, w: FontWeight.w700)),
        ),
        Expanded(child: Container(height: 1, color: p.line)),
      ],
    );
  }
}

// =====================================================================
// Tombol Google / Apple
// =====================================================================
class AuthSocialRow extends StatelessWidget {
  final WelcomePalette p;
  final VoidCallback? onGoogle;
  final VoidCallback? onApple;

  const AuthSocialRow({super.key, required this.p, this.onGoogle, this.onApple});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SocialButton(
            p: p,
            label: 'Google',
            leading: Text(
              'G',
              style: Aj.h(19, color: const Color(0xFF4285F4), w: FontWeight.w800),
            ),
            onTap: onGoogle ?? () {},
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SocialButton(
            p: p,
            label: 'Apple',
            leading: Icon(Icons.apple, size: 23, color: p.title),
            onTap: onApple ?? () {},
          ),
        ),
      ],
    );
  }
}

class _SocialButton extends StatefulWidget {
  final WelcomePalette p;
  final String label;
  final Widget leading;
  final VoidCallback onTap;

  const _SocialButton({
    required this.p,
    required this.label,
    required this.leading,
    required this.onTap,
  });

  @override
  State<_SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<_SocialButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _down ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: p.fieldFill,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: p.fieldBorder, width: 1.3),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 24, child: Center(child: widget.leading)),
              const SizedBox(width: 8),
              Text(widget.label, style: Aj.b(15, color: p.title, w: FontWeight.w800)),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// Tautan di bawah kartu: "Belum punya akun? Daftar"
// =====================================================================
class AuthFooterLink extends StatelessWidget {
  final WelcomePalette p;
  final String text;
  final String action;
  final VoidCallback onTap;

  const AuthFooterLink({
    super.key,
    required this.p,
    required this.text,
    required this.action,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text('$text ', style: Aj.b(14.5, color: p.subtitle, w: FontWeight.w700)),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(action, style: Aj.h(14.5, color: p.link, w: FontWeight.w800)),
          ),
        ),
      ],
    );
  }
}