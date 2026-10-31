import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';

import 'package:amanjalan/core/theme/app_colors.dart';

// ====== Palet mode darurat ======
const _bgTop = Color(0xFF2B0F1D);
const _bgMid = Color(0xFF1C1228);
const _bgBottom = Color(0xFF2A1426);
const _card = Color(0x1FFFFFFF);
const _cardBorder = Color(0x1AFFFFFF);
const _muted = Color(0xFFC9BDD0);
const _label = Color(0xFFA899B3);
const _alert = Color(0xFFFF4D6D);
const _ok = Color(0xFF7FD6A0);

/// Data penerima peringatan yang ditampilkan di kartu.
class EmergencyRecipient {
  final String name;
  final String detail;
  const EmergencyRecipient(this.name, this.detail);
}

/// Pengaman keluar dari mode darurat.
///
/// Sambungkan SEKALI (mis. di main.dart atau setelah login) ke pengecekan
/// kata sandi akun yang sebenarnya, contoh:
///   EmergencySecurity.passwordVerifier =
///       (p) => AuthService.instance.verifyPassword(p);
///
/// Kalau belum disambungkan: mode debug menerima kata sandi apa saja (untuk uji),
/// mode rilis MENOLAK semua (aman: SOS tidak bisa dimatikan sembarangan).
class EmergencySecurity {
  static Future<bool> Function(String password)? passwordVerifier;
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
  late final AnimationController _radar;
  late final AnimationController _hold;
  Timer? _ticker;

  int _elapsed = 0; // detik sejak SOS aktif
  bool _sent = false;

  @override
  void initState() {
    super.initState();
    HapticFeedback.heavyImpact();

    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    _radar = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();

    _hold = AnimationController(vsync: this, duration: _holdDuration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _openSafeExit();
      });

    // TODO: kirim sinyal darurat sungguhan di sini:
    // 1) ambil lokasi live, 2) kirim notifikasi (FCM) ke semua Guardian,
    // 3) simpan log kejadian. Sementara disimulasikan.
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _elapsed++);
      if (_elapsed == 3 && !_sent) {
        HapticFeedback.mediumImpact();
        setState(() => _sent = true);
      }
      if (_elapsed % 5 == 0) _pushLocation();
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _pulse.dispose();
    _radar.dispose();
    _hold.dispose();
    super.dispose();
  }

  // ---------- Lokasi live ke keluarga ----------
  void _pushLocation() {
    // TODO: ambil posisi GPS terbaru (geolocator) lalu kirim ke backend/FCM
    // supaya Guardian melihat posisi bergerak secara real-time.
  }

  // ---------- Aksi ----------
  void _callEmergency() {
    HapticFeedback.mediumImpact();
    // TODO: buka dialer dengan paket `url_launcher`:
    // launchUrl(Uri.parse('tel:112'));
    _snack('Menghubungi 112...');
  }

  Future<bool> _verifyPassword(String password) async {
    final verifier = EmergencySecurity.passwordVerifier;
    if (verifier != null) return verifier(password);
    return kDebugMode && password.isNotEmpty; // demo; rilis = ditolak
  }

  /// Keluar dari SOS = 3 detik tahan + biometrik + kata sandi.
  Future<void> _openSafeExit() async {
    HapticFeedback.mediumImpact();
    _hold.reset();
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SafeExitSheet(verifyPassword: _verifyPassword),
    );
    if (ok == true) _finishSafely();
  }

  void _finishSafely() {
    HapticFeedback.heavyImpact();
    _ticker?.cancel();

    // TODO: kirim notifikasi "Aman" ke Guardian + hentikan pelacakan live
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.plum,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(
          'SOS dimatikan. Guardian diberi tahu kamu aman.',
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

  String get _timer {
    final m = (_elapsed ~/ 60).toString().padLeft(2, '0');
    final s = (_elapsed % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // ---------- Build ----------
  @override
  Widget build(BuildContext context) {
    // Tombol kembali sistem diblokir: mode darurat hanya bisa dimatikan
    // lewat verifikasi biometrik + kata sandi.
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
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_bgTop, _bgMid, _bgBottom],
                stops: [0.0, 0.55, 1.0],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                child: Column(
                  children: [
                    _buildTopBar(),
                    _buildRadar(),
                    _buildStatusText(),
                    const SizedBox(height: 22),
                    _buildProgressCard(),
                    const SizedBox(height: 14),
                    _buildLocationCard(),
                    const SizedBox(height: 14),
                    _buildRecipientsCard(),
                    const SizedBox(height: 22),
                    _buildCallButton(),
                    const SizedBox(height: 12),
                    _buildLockedExitButton(),
                    const SizedBox(height: 10),
                    _buildSecurityNote(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------- Bar atas: status + timer ----------
  Widget _buildTopBar() {
    return Row(
      children: [
        AnimatedBuilder(
          animation: _pulse,
          builder: (_, __) {
            final glow = 0.5 + 0.5 * math.sin(_pulse.value * 2 * math.pi);
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _alert.withOpacity(0.16),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _alert.withOpacity(0.35)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _alert,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: _alert.withOpacity(0.6 * glow),
                            blurRadius: 8,
                            spreadRadius: 2 * glow),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('SOS AKTIF',
                      style: GoogleFonts.nunito(
                          fontSize: 12.5,
                          letterSpacing: 1.3,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFFFB3C0))),
                ],
              ),
            );
          },
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.timer_outlined, size: 16, color: _muted),
              const SizedBox(width: 6),
              Text(_timer,
                  style: GoogleFonts.poppins(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
            ],
          ),
        ),
      ],
    );
  }

  // ---------- Radar + tombol SOS ----------
  Widget _buildRadar() {
    return SizedBox(
      height: 330,
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulse, _radar]),
        builder: (context, _) {
          Widget ring(double t) {
            return Transform.scale(
              scale: 1 + 0.7 * t,
              child: Container(
                width: 170,
                height: 170,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: _alert.withOpacity((1 - t) * 0.5), width: 2),
                ),
              ),
            );
          }

          return Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 310,
                height: 310,
                child: CustomPaint(painter: _RadarPainter(_radar.value)),
              ),
              ring(_pulse.value),
              ring((_pulse.value + 0.33) % 1.0),
              ring((_pulse.value + 0.66) % 1.0),
              Container(
                width: 168,
                height: 168,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    center: Alignment(-0.3, -0.4),
                    radius: 1.0,
                    colors: [Color(0xFFFF6B80), Color(0xFFD7263D), Color(0xFF8E1230)],
                    stops: [0.0, 0.6, 1.0],
                  ),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.18), width: 4),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.emergencyRed.withOpacity(0.55),
                        blurRadius: 46,
                        spreadRadius: 4),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.crisis_alert_rounded,
                        size: 40, color: Colors.white),
                    Text('SOS',
                        style: GoogleFonts.poppins(
                            fontSize: 42,
                            fontWeight: FontWeight.w700,
                            height: 1.05,
                            color: Colors.white)),
                  ],
                ),
              ),
            ],
          );
        },
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
            _sent ? 'Keluargamu melihat lokasimu' : 'Mengirim sinyal darurat...',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
                fontSize: 25, fontWeight: FontWeight.w800, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            _sent
                ? 'Posisimu dibagikan live ke Guardian. Tetap tenang dan cari tempat ramai.'
                : 'Mohon tunggu, Guardian dan layanan terdekat sedang dihubungi.',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(fontSize: 15, height: 1.5, color: _muted),
          ),
        ],
      ),
    );
  }

  // ---------- Kartu progres ----------
  Widget _buildProgressCard() {
    final steps = [
      ('Lokasi terkunci', 'GPS akurat ${widget.accuracy}', Icons.my_location_rounded),
      ('Guardian diberi tahu', 'Notifikasi prioritas terkirim', Icons.notifications_active_rounded),
      ('Lokasi live dibagikan', 'Diperbarui ${_elapsed % 5} dtk lalu', Icons.share_location_rounded),
      ('Merekam bukti audio', 'Tersimpan aman di server', Icons.mic_rounded),
    ];
    return _glass(
      child: Column(
        children: [
          for (var i = 0; i < steps.length; i++)
            Padding(
              padding: EdgeInsets.only(bottom: i == steps.length - 1 ? 0 : 14),
              child: _stepRow(
                steps[i].$3,
                steps[i].$1,
                steps[i].$2,
                _elapsed >= i + 1,
              ),
            ),
        ],
      ),
    );
  }

  Widget _stepRow(IconData icon, String title, String sub, bool done) {
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done ? _ok.withOpacity(0.18) : Colors.white.withOpacity(0.07),
          ),
          child: Icon(icon, size: 21, color: done ? _ok : _label),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: GoogleFonts.nunito(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: done ? Colors.white : _label)),
              Text(done ? sub : 'Menunggu...',
                  style: GoogleFonts.nunito(fontSize: 12.5, color: _muted)),
            ],
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: done
              ? const Icon(Icons.check_circle_rounded,
                  key: ValueKey('ok'), size: 22, color: _ok)
              : const SizedBox(
                  key: ValueKey('wait'),
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.2, color: _label),
                ),
        ),
      ],
    );
  }

  // ---------- Kartu lokasi dengan peta ----------
  Widget _buildLocationCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _cardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          SizedBox(
            height: 150,
            width: double.infinity,
            child: AnimatedBuilder(
              animation: _pulse,
              builder: (_, __) =>
                  CustomPaint(painter: _MapPainter(_pulse.value)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
            child: Row(
              children: [
                const Icon(Icons.location_on_rounded, color: _alert, size: 26),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('LOKASI TERKUNCI',
                          style: GoogleFonts.nunito(
                              fontSize: 11.5,
                              letterSpacing: 1.2,
                              color: _label)),
                      const SizedBox(height: 2),
                      Text(widget.address,
                          style: GoogleFonts.nunito(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white)),
                      Text('${widget.coordinates} • ${widget.accuracy}',
                          style: GoogleFonts.nunito(
                              fontSize: 12.5,
                              color: const Color(0xFFFF9FB8))),
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

  // ---------- Penerima ----------
  Widget _buildRecipientsCard() {
    return _glass(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('PENERIMA PERINGATAN',
                    style: GoogleFonts.nunito(
                        fontSize: 12, letterSpacing: 1.2, color: _label)),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _sent
                      ? '${widget.recipients.length} Terhubung'
                      : 'Menghubungi...',
                  key: ValueKey(_sent),
                  style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _sent ? _ok : Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final r in widget.recipients)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                    ),
                    child: Text(
                      r.name.isEmpty ? '?' : r.name.substring(0, 1).toUpperCase(),
                      style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.name,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.nunito(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                        Text(r.detail,
                            style: GoogleFonts.nunito(
                                fontSize: 12.5, color: _muted)),
                      ],
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: (_sent ? _ok : Colors.white).withOpacity(0.14),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(_sent ? 'Terkirim' : '...',
                        style: GoogleFonts.nunito(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _sent ? _ok : _muted)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _glass({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _cardBorder),
      ),
      child: child,
    );
  }

  // ---------- Tombol bawah ----------
  Widget _buildCallButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
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
              child: Text('Hubungi Call Center Darurat (112)',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunito(
                      fontSize: 16.5, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  /// Matikan SOS: tahan 3 detik -> biometrik -> kata sandi.
  Widget _buildLockedExitButton() {
    return GestureDetector(
      onTapDown: (_) => _holdStart(),
      onTapUp: (_) => _holdEnd(),
      onTapCancel: _holdEnd,
      child: AnimatedBuilder(
        animation: _hold,
        builder: (context, _) {
          final holding = _hold.value > 0;
          return ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Container(
              width: double.infinity,
              height: 60,
              color: const Color(0x1FFFFFFF),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: _hold.value,
                      heightFactor: 1,
                      child: Container(color: const Color(0x40FFFFFF)),
                    ),
                  ),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lock_rounded,
                            size: 20, color: Color(0xFFE6DCEB)),
                        const SizedBox(width: 10),
                        Text(
                          holding
                              ? 'Terus tahan...'
                              : 'Matikan SOS (Tahan 3 Detik)',
                          style: GoogleFonts.nunito(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFE6DCEB)),
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

  Widget _buildSecurityNote() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.fingerprint_rounded, size: 18, color: _label),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            'Dikunci: perlu sidik jari / Face ID + kata sandi',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(fontSize: 12.5, color: _label),
          ),
        ),
      ],
    );
  }
}

// =====================================================================
// SHEET KELUAR AMAN: langkah 1 biometrik, langkah 2 kata sandi
// =====================================================================
class _SafeExitSheet extends StatefulWidget {
  final Future<bool> Function(String password) verifyPassword;
  const _SafeExitSheet({required this.verifyPassword});

  @override
  State<_SafeExitSheet> createState() => _SafeExitSheetState();
}

class _SafeExitSheetState extends State<_SafeExitSheet> {
  final _auth = LocalAuthentication();
  final _pwCtrl = TextEditingController();

  int _step = 0; // 0 = biometrik, 1 = kata sandi
  bool _busy = false;
  bool _obscure = true;
  bool _bioUnavailable = false;
  String? _error;
  int _attempts = 0;
  int _lockLeft = 0;
  Timer? _lockTimer;

  @override
  void initState() {
    super.initState();
    Future.microtask(_runBiometric);
  }

  @override
  void dispose() {
    _lockTimer?.cancel();
    _pwCtrl.dispose();
    super.dispose();
  }

  Future<void> _runBiometric() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final available = await _auth.canCheckBiometrics;
      final types = available ? await _auth.getAvailableBiometrics() : [];
      if (types.isEmpty) {
        // Perangkat tanpa biometrik terdaftar: lanjut ke kata sandi saja.
        if (!mounted) return;
        setState(() {
          _bioUnavailable = true;
          _step = 1;
          _busy = false;
        });
        return;
      }
      final ok = await _auth.authenticate(
        localizedReason: 'Verifikasi identitasmu untuk mematikan SOS',
        options: const AuthenticationOptions(
          biometricOnly: true, // PIN layar HP tidak diterima
          stickyAuth: true,
        ),
      );
      if (!mounted) return;
      setState(() {
        _busy = false;
        if (ok) {
          HapticFeedback.mediumImpact();
          _step = 1;
        } else {
          _error = 'Biometrik tidak cocok. Coba lagi.';
        }
      });
    } on PlatformException {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = 'Biometrik gagal dibaca. Coba lagi.';
      });
    } catch (_) {
      // Mis. di web / plugin tidak tersedia -> hanya kata sandi.
      if (!mounted) return;
      setState(() {
        _bioUnavailable = true;
        _step = 1;
        _busy = false;
      });
    }
  }

  Future<void> _submitPassword() async {
    if (_busy || _lockLeft > 0 || _pwCtrl.text.isEmpty) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final ok = await widget.verifyPassword(_pwCtrl.text);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop(true);
      return;
    }
    HapticFeedback.heavyImpact();
    _attempts++;
    _pwCtrl.clear();
    setState(() {
      _busy = false;
      _error = 'Kata sandi salah.';
    });
    if (_attempts >= 3) _startLock();
  }

  void _startLock() {
    setState(() {
      _lockLeft = 30;
      _attempts = 0;
      _error = 'Terlalu banyak percobaan. SOS tetap berjalan.';
    });
    _lockTimer?.cancel();
    _lockTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _lockLeft--);
      if (_lockLeft <= 0) {
        t.cancel();
        setState(() => _error = null);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      margin: const EdgeInsets.all(12),
      padding: EdgeInsets.fromLTRB(22, 14, 22, 22 + bottom),
      decoration: BoxDecoration(
        color: const Color(0xFF241830),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: _cardBorder),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 18),
            Text('Matikan SOS',
                style: GoogleFonts.nunito(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white)),
            const SizedBox(height: 4),
            Text('Verifikasi 2 langkah agar tidak bisa dimatikan orang lain.',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(fontSize: 13.5, color: _muted)),
            const SizedBox(height: 18),
            _stepIndicator(),
            const SizedBox(height: 20),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _step == 0 ? _biometricBody() : _passwordBody(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _lockLeft > 0 ? '$_error Coba lagi ${_lockLeft}s' : _error!,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFFF8FA3)),
              ),
            ],
            const SizedBox(height: 14),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Batal, biarkan SOS tetap aktif',
                  style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w700, color: _muted)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepIndicator() {
    Widget chip(int i, String label, IconData icon) {
      final active = _step == i;
      final done = _step > i;
      return Expanded(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: done
                ? _ok.withOpacity(0.16)
                : active
                    ? _alert.withOpacity(0.18)
                    : Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: done
                  ? _ok.withOpacity(0.5)
                  : active
                      ? _alert.withOpacity(0.5)
                      : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(done ? Icons.check_circle_rounded : icon,
                  size: 18, color: done ? _ok : (active ? Colors.white : _label)),
              const SizedBox(width: 8),
              Text(label,
                  style: GoogleFonts.nunito(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: done || active ? Colors.white : _label)),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        chip(0, '1 Biometrik', Icons.fingerprint_rounded),
        const SizedBox(width: 10),
        chip(1, '2 Kata Sandi', Icons.password_rounded),
      ],
    );
  }

  Widget _biometricBody() {
    return Column(
      key: const ValueKey('bio'),
      children: [
        GestureDetector(
          onTap: _runBiometric,
          child: Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _alert.withOpacity(0.14),
              border: Border.all(color: _alert.withOpacity(0.4), width: 2),
            ),
            child: _busy
                ? const Padding(
                    padding: EdgeInsets.all(28),
                    child: CircularProgressIndicator(
                        strokeWidth: 3, color: _alert),
                  )
                : const Icon(Icons.fingerprint_rounded,
                    size: 52, color: Colors.white),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _busy ? 'Menunggu verifikasi...' : 'Ketuk untuk memindai sidik jari / wajah',
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(fontSize: 14, color: _muted),
        ),
      ],
    );
  }

  Widget _passwordBody() {
    final locked = _lockLeft > 0;
    return Column(
      key: const ValueKey('pw'),
      children: [
        if (_bioUnavailable)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Biometrik tidak tersedia di perangkat ini, cukup kata sandi.',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(fontSize: 12.5, color: _label),
            ),
          ),
        TextField(
          controller: _pwCtrl,
          obscureText: _obscure,
          enabled: !locked,
          autofocus: true,
          onSubmitted: (_) => _submitPassword(),
          style: GoogleFonts.nunito(fontSize: 16, color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Kata sandi akun',
            hintStyle: GoogleFonts.nunito(color: _label),
            filled: true,
            fillColor: Colors.white.withOpacity(0.08),
            prefixIcon: const Icon(Icons.lock_outline_rounded, color: _label),
            suffixIcon: IconButton(
              onPressed: () => setState(() => _obscure = !_obscure),
              icon: Icon(
                  _obscure
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: _label),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(22),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: (_busy || locked) ? null : _submitPassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: _alert,
              disabledBackgroundColor: Colors.white12,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: const StadiumBorder(),
            ),
            child: _busy
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.white),
                  )
                : Text('Matikan SOS',
                    style: GoogleFonts.nunito(
                        fontSize: 16.5, fontWeight: FontWeight.w800)),
          ),
        ),
      ],
    );
  }
}

// =====================================================================
// PAINTER
// =====================================================================

/// Radar berputar di belakang tombol SOS.
class _RadarPainter extends CustomPainter {
  final double t;
  _RadarPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;

    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withOpacity(0.07);
    for (var k = 1; k <= 3; k++) {
      canvas.drawCircle(c, r * k / 3, line);
    }
    canvas.drawLine(Offset(c.dx - r, c.dy), Offset(c.dx + r, c.dy), line);
    canvas.drawLine(Offset(c.dx, c.dy - r), Offset(c.dx, c.dy + r), line);

    final rect = Rect.fromCircle(center: c, radius: r);
    final sweep = Paint()
      ..shader = SweepGradient(
        colors: const [Color(0x00FF4D6D), Color(0x66FF4D6D)],
        stops: const [0.72, 1.0],
        transform: GradientRotation(t * 2 * math.pi),
      ).createShader(rect);
    canvas.drawCircle(c, r, sweep);
  }

  @override
  bool shouldRepaint(covariant _RadarPainter old) => old.t != t;
}

/// Peta bergaya gelap dengan titik lokasi berdenyut.
class _MapPainter extends CustomPainter {
  final double t;
  _MapPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF2A2036), Color(0xFF1F1829)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, bg);

    final grid = Paint()
      ..strokeWidth = 1
      ..color = Colors.white.withOpacity(0.05);
    for (double x = 0; x < size.width; x += 28) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y < size.height; y += 28) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final road = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 10
      ..color = Colors.white.withOpacity(0.08);
    final p1 = Path()
      ..moveTo(-10, size.height * 0.72)
      ..quadraticBezierTo(size.width * 0.45, size.height * 0.35,
          size.width + 10, size.height * 0.5);
    final p2 = Path()
      ..moveTo(size.width * 0.3, -10)
      ..quadraticBezierTo(size.width * 0.55, size.height * 0.5,
          size.width * 0.7, size.height + 10);
    canvas.drawPath(p1, road);
    canvas.drawPath(p2, road);

    final c = Offset(size.width * 0.5, size.height * 0.5);
    canvas.drawCircle(
        c,
        18 + 38 * t,
        Paint()..color = const Color(0xFFFF4D6D).withOpacity((1 - t) * 0.28));
    canvas.drawCircle(c, 9, Paint()..color = Colors.white);
    canvas.drawCircle(c, 6, Paint()..color = const Color(0xFFFF4D6D));
  }

  @override
  bool shouldRepaint(covariant _MapPainter old) => old.t != t;
}