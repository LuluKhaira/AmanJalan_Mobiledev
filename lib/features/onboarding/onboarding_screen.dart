import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:amanjalan/core/theme/aj_theme.dart';
import 'package:amanjalan/features/auth/login_screen.dart';
import 'package:amanjalan/features/onboarding/models/onboarding_data.dart';
import 'package:amanjalan/features/onboarding/widgets/onboarding_page.dart';
import 'package:amanjalan/features/onboarding/widgets/page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  bool get _isLast => _index == onboardingPages.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_isLast) {
      _finish();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _back() {
    _controller.previousPage(
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  /// Tandai onboarding sudah dilihat, lalu masuk ke Login.
  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen_onboarding', true);
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Aj.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: onboardingPages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  return AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      final page = _controller.hasClients
                          ? (_controller.page ?? _index.toDouble())
                          : _index.toDouble();
                      return OnboardingPage(
                        data: onboardingPages[i],
                        delta: i - page,
                      );
                    },
                  );
                },
              ),
            ),
            PageIndicator(count: onboardingPages.length, current: _index),
            const SizedBox(height: 24),
            _buildButton(),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AnimatedOpacity(
            duration: const Duration(milliseconds: 250),
            opacity: _index == 0 ? 0 : 1,
            child: IgnorePointer(
              ignoring: _index == 0,
              child: IconButton(
                onPressed: _back,
                icon: const Icon(Icons.arrow_back_rounded, color: Aj.plum),
              ),
            ),
          ),
          TextButton(
            onPressed: _finish,
            child: Text('Lewati', style: Aj.h(13.5, color: Aj.plum)),
          ),
        ],
      ),
    );
  }

  Widget _buildButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Aj.plum.withValues(alpha: 0.28),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _next,
            style: ElevatedButton.styleFrom(
              backgroundColor: Aj.plum,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Text(
                _isLast ? 'Mulai Sekarang' : 'Selanjutnya',
                key: ValueKey(_isLast),
                style: Aj.h(15, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}