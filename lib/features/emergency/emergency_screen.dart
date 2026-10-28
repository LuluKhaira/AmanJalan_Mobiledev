import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:amanjalan/core/theme/app_colors.dart';

// Warna khusus mode darurat (latar gelap + merah SOS)
const _bgTop = Color(0xFF4A1F30);
const _bgMid = Color(0xFF2F2540);
const _bgBottom = Color(0xFF47283D);
const _cardColor = Color(0x33FFFFFF);
const _mutedText = Color(0xFFC9BDD0);
const _labelText = Color(0xFFB5A8BD);

/// Data penerima peringatan yang ditampilkan di kartu.
class EmergencyRecipient {
  final String name;
  final String detail;
  const EmergencyRecipient(this.name, this.detail);
}

class EmergencyScreen extends StatefulWidget {
  final String address;
  final String coordinates;
  final String accuracy;
  final List<EmergencyRecipient> recipients;

  const EmergencyScreen({
    super.key,
    this.address = 'Jl. Sudirman No. 42, Batam',
    this.coordinates = '1.129° N, 104.053° E',
    this.accuracy = '±4m',
    this.recipients = const [
      EmergencyRecipient('Ibu Nurhayati (Wali Utama)', '+62 812-3456-7890'),
      EmergencyRecipient('Layanan Polisi Terpadu', 'Panggilan 110'),
    ],
  });

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen>
    with TickerProviderStateMixin {
  static const _holdDuration = Duration(seconds: 3);

  late final AnimationController _pulse;
  late final AnimationController _hold;
  Timer? _sentTimer;

  bool _sent = false;

  @override
  void initState() {
    super.initState();
    HapticFeedback.heavyImpact();

    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    _hold = AnimationController(vsync: this, duration: _holdDuration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _onCancelled();
      });

    // TODO: kirim sinyal darurat sungguhan di sini:
    // 1) ambil lokasi live, 2) kirim notifikasi (FCM) ke semua Guardian,
    // 3) simpan log kejadian. Sementara disimulasikan 3 detik.
    _sentTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      setState(() => _sent = true);
    });
  }

  @override
  void dispose() {
    _sentTimer?.cancel();
    _pulse.dispose();
    _hold.dispose();
    super.dispose();
  }

  // ---------- Aksi ----------
  void _callEmergency() {
    HapticFeedback.mediumImpact();
    // TODO: buka dialer dengan paket `url_launcher`:
    // launchUrl(Uri.parse('tel:112'));
    _snack('Menghubungi 112...');
  }

  void _onCancelled() {
    HapticFeedback.heavyImpact();
    _sentTimer?.cancel();

    // TODO: kirim notifikasi "Aman" ke Guardian (false alarm)
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.plum,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(
          'Darurat dibatalkan. Guardian diberi tahu kamu aman.',
          style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _holdStart() {
    HapticFeedback.selectionClick();
    _hold.forward();
  }

  void _holdEnd() {
    if (_hold.status != AnimationStatus.completed) _hold.reverse();
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF3A2D45),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(
          message,
          style: GoogleFonts.nunito(
              fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
    );
  }

  // ---------- Build ----------
  @override
  Widget build(BuildContext context) {
    // Tombol kembali sistem diblokir agar mode darurat tidak tertutup tak sengaja.
    return PopScope(
      canPop: false,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: _bgMid,
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_bgTop, _bgMid, _bgBottom],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
                child: Column(
                  children: [
                    _buildSosButton(),
                    const SizedBox(height: 10),
                    _buildStatusChip(),
                    const SizedBox(height: 16),
                    _buildStatusText(),
                    const SizedBox(height: 28),
                    _buildLocationCard(),
                    const SizedBox(height: 14),
                    _buildRecipientsCard(),
                    const SizedBox(height: 30),
                    _buildCallButton(),
                    const SizedBox(height: 14),
                    _buildCancelButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------- Tombol SOS berdenyut ----------
  Widget _buildSosButton() {
    return SizedBox(
      height: 320,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (context, _) {
          Widget ring(double t) {
            final scale = 1 + 0.42 * t;
            final opacity = (1 - t) * 0.32;
            return Transform.scale(
              scale: scale,
              child: Container(
                width: 215,
                height: 215,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromRGBO(198, 40, 40, opacity),
                ),
              ),
            );
          }

          return Stack(
            alignment: Alignment.center,
            children: [
              ring(_pulse.value),
              ring((_pulse.value + 0.5) % 1.0),
              Container(
                width: 178,
                height: 178,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.emergencyRed,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x66C62828),
                      blurRadius: 40,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.crisis_alert_rounded,
                        size: 44, color: Colors.white),
                    Text(
                      'SOS',
                      style: GoogleFonts.poppins(
                        fontSize: 42,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0x26FFFFFF),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: const BoxDecoration(
              color: Color(0xFFA9CDB4),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            // TODO: rekam audio hanya dengan izin eksplisit pengguna
            'Mic aktif • Sirene diam-diam',
            style: GoogleFonts.nunito(
              fontSize: 13.5,
              color: const Color(0xFFA9CDB4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusText() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      child: Column(
        key: ValueKey(_sent),
        children: [
          Text(
            _sent ? 'Sinyal darurat terkirim' : 'Mengirim sinyal darurat...',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 26,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _sent
                ? 'Guardian dan layanan terdekat sudah diberi tahu. Tetap tenang, bantuan sedang dihubungi.'
                : 'Mohon tunggu, tim penjaga dan jaringan terdekat sedang dihubungi secara otomatis.',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 16,
              height: 1.5,
              color: _mutedText,
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Kartu lokasi ----------
  Widget _buildLocationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: Color(0x40FFC9D9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_on_rounded,
                color: Color(0xFFFFC9D9), size: 26),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LOKASI TERKUNCI',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    letterSpacing: 1.2,
                    color: _labelText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.address,
                  style: GoogleFonts.nunito(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Akurasi GPS ${widget.accuracy} (${widget.coordinates})',
                  style: GoogleFonts.nunito(
                    fontSize: 13.5,
                    color: const Color(0xFFFF9FB8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Kartu penerima peringatan ----------
  Widget _buildRecipientsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: Color(0xFF2D3A36),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.phone_in_talk_rounded,
                color: AppColors.sage, size: 24),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'PENERIMA PERINGATAN',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          letterSpacing: 1.1,
                          color: _labelText,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _sent
                            ? '${widget.recipients.length} Terhubung'
                            : 'Menghubungi...',
                        key: ValueKey(_sent),
                        style: GoogleFonts.nunito(
                          fontSize: 13.5,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                for (final r in widget.recipients)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            r.name,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.nunito(
                              fontSize: 16.5,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          r.detail,
                          style: GoogleFonts.nunito(
                            fontSize: 13.5,
                            color: _mutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Tombol bawah ----------
  Widget _buildCallButton() {
    return SizedBox(
      width: double.infinity,
      height: 62,
      child: ElevatedButton(
        onPressed: _callEmergency,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.emergencyRed,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: const StadiumBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.phone_forwarded_rounded, size: 22),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                'Hubungi Call Center Darurat (112)',
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.nunito(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Tombol batal: harus ditekan dan ditahan 3 detik (mencegah batal tak sengaja).
  Widget _buildCancelButton() {
    return GestureDetector(
      onTapDown: (_) => _holdStart(),
      onTapUp: (_) => _holdEnd(),
      onTapCancel: _holdEnd,
      child: AnimatedBuilder(
        animation: _hold,
        builder: (context, _) {
          final holding = _hold.value > 0;
          return ClipRRect(
            borderRadius: BorderRadius.circular(31),
            child: Container(
              width: double.infinity,
              height: 62,
              color: const Color(0x33FFFFFF),
              child: Stack(
                children: [
                  // isi progres
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: _hold.value,
                      heightFactor: 1,
                      child: Container(color: const Color(0x59FFFFFF)),
                    ),
                  ),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lock_reset_rounded,
                            size: 22, color: Color(0xFFE6DCEB)),
                        const SizedBox(width: 12),
                        Text(
                          holding
                              ? 'Terus tahan...'
                              : 'Batalkan (Tekan & Tahan 3 Detik)',
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            color: const Color(0xFFE6DCEB),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}