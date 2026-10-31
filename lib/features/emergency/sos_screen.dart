import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:amanjalan/features/emergency/emergency_screen.dart';

// ====== Palet gelap & redup (tidak mencolok di keramaian) ======
const _bgTop = Color(0xFF150C1B);
const _bgBottom = Color(0xFF0C0710);
const _sosLight = Color(0xFF9B2339);
const _sosMid = Color(0xFF731A2C);
const _sosDark = Color(0xFF4A111D);
const _textDim = Color(0xFF8E7F98);
const _textSoft = Color(0xFFD9B8C2);

/// Layar SOS mode senyap: gelap, minim teks, SEKALI KETUK langsung kirim.
/// Pembatalan tersedia di EmergencyScreen (tahan 3 detik) kalau salah pencet.
class SosScreen extends StatefulWidget {
  final String address;
  final String accuracy;
  final List<EmergencyRecipient> recipients;

  const SosScreen({
    super.key,
    this.address = 'Jl. Sudirman No. 42, Batam',
    this.accuracy = '±4m',
    this.recipients = const [
      EmergencyRecipient('Ibu Nurhayati (Wali Utama)', '+62 812-3456-7890'),
      EmergencyRecipient('Layanan Polisi Terpadu', 'Panggilan 110'),
    ],
  });

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glow;
  bool _pressed = false;
  bool _fired = false;

  @override
  void initState() {
    super.initState();
    // denyut sangat pelan & redup, hanya penanda tombol hidup
    _glow = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glow.dispose();
    super.dispose();
  }

  void _trigger() {
    if (_fired) return;
    _fired = true;
    HapticFeedback.heavyImpact(); // hanya getar, tanpa suara
    // TODO: kirim sinyal darurat di sini (lokasi live + FCM ke Guardian).
    // Default mode senyap: sirene mati, rekam audio & lokasi live aktif.
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 150),
        pageBuilder: (_, __, ___) => EmergencyScreen(
          address: widget.address,
          accuracy: widget.accuracy,
          recipients: widget.recipients,
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              colors: [_bgTop, _bgBottom],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Header minimal: hanya tombol kembali yang redup
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 20, color: _textDim),
                    ),
                  ),
                ),
                Expanded(child: Center(child: _buildButton())),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- Tombol besar, mudah kena jempol ----------
  Widget _buildButton() {
    return AnimatedBuilder(
      animation: _glow,
      builder: (context, _) {
        final t = Curves.easeInOut.transform(_glow.value);
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: (_) => setState(() => _pressed = false),
          onTap: _trigger,
          child: SizedBox(
            width: 320,
            height: 320,
            child: Center(
              child: AnimatedScale(
                scale: _pressed ? 0.94 : 1.0,
                duration: const Duration(milliseconds: 90),
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      center: Alignment(-0.25, -0.35),
                      radius: 1.0,
                      colors: [_sosLight, _sosMid, _sosDark],
                      stops: [0.0, 0.6, 1.0],
                    ),
                    border: Border.all(
                      color: const Color(0xFFFFFFFF).withOpacity(0.08),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _sosMid.withOpacity(0.18 + 0.14 * t),
                        blurRadius: 40 + 20 * t,
                        spreadRadius: 4 + 6 * t,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shield_moon_rounded,
                          size: 48, color: _textSoft.withOpacity(0.85)),
                      const SizedBox(height: 4),
                      Text(
                        'SOS',
                        style: GoogleFonts.poppins(
                          fontSize: 54,
                          fontWeight: FontWeight.w700,
                          height: 1.05,
                          color: _textSoft.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------- Footer: satu baris info, redup ----------
  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
      child: Column(
        children: [
          Text(
            'Ketuk sekali · terkirim diam-diam',
            style: GoogleFonts.nunito(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: _textDim,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Color(0xFF4F8A68),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Lokasi live aktif · ${widget.recipients.length} penerima',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunito(
                    fontSize: 12.5,
                    color: _textDim.withOpacity(0.8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}