import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:amanjalan/core/theme/app_colors.dart';
import 'package:amanjalan/core/widgets/press_scale.dart';

class ActiveTripScreen extends StatefulWidget {
  const ActiveTripScreen({super.key});

  @override
  State<ActiveTripScreen> createState() => _ActiveTripScreenState();
}

class _ActiveTripScreenState extends State<ActiveTripScreen> {
  // Timer untuk simulasi perjalanan
  Timer? _timer;
  int _secondsElapsed = 0;

  @override
  void initState() {
    super.initState();
    // Simulasi waktu berjalan
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() => _secondsElapsed++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final minutes = 7 - (_secondsElapsed ~/ 60);
    if (minutes <= 0) return 'Tiba di Tujuan';
    return '$minutes Menit Lagi';
  }

  void _endTrip() {
    _timer?.cancel();
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(
          'Perjalanan Selesai. Guardian diberitahu bahwa kamu sudah sampai dengan aman!',
          style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4F9), // Background agak ungu
      body: Stack(
        children: [
          // ==========================================
          // 1. BACKGROUND PETA (Mock)
          // ==========================================
          Positioned.fill(
            child: CustomPaint(painter: _ActiveMapPainter()),
          ),

          // ==========================================
          // 2. HEADER ATAS
          // ==========================================
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 10, 
                left: 20, right: 20, bottom: 20
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.95),
                    Colors.white.withOpacity(0.0),
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                      ),
                      child: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark),
                    ),
                  ),
                  Text(
                    'Active Escort Walk',
                    style: GoogleFonts.poppins(
                      fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark,
                    ),
                  ),
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.softPink,
                    child: Icon(Icons.person, color: AppColors.plum),
                  ),
                ],
              ),
            ),
          ),

          // ==========================================
          // 3. KARTU BAWAH (Info Perjalanan)
          // ==========================================
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Waktu & Jarak
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formattedTime,
                        style: GoogleFonts.poppins(
                          fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.plum,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '480 m',
                            style: GoogleFonts.poppins(
                              fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark,
                            ),
                          ),
                          Text(
                            'JARAK SISA',
                            style: GoogleFonts.nunito(
                              fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: 0.75, // Statis di 75% untuk demo
                      minHeight: 8,
                      backgroundColor: const Color(0xFFF0EDF2),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.plum),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Keberangkatan (Stasiun MRT)', style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textMuted)),
                      Text('Rumah', style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Guardian yang memantau
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '3 Wali Terhubung Langsung',
                        style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark),
                      ),
                      const Icon(Icons.wifi_tethering_rounded, color: AppColors.plum, size: 20),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildGuardianChip('Mama', 'MENONTON', const Color(0xFFF4E6F0)),
                      const SizedBox(width: 8),
                      _buildGuardianChip('Ayah', 'AKTIF', const Color(0xFFE6F0F4)),
                      const SizedBox(width: 8),
                      _buildGuardianChip('Dinda', 'AKTIF', const Color(0xFFF0F4E6)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Tombol Aksi (Panggilan Palsu & SOS)
                  Row(
                    children: [
                      Expanded(
                        child: PressScale(
                          child: SizedBox(
                            height: 54,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Panggilan Palsu diaktifkan...')),
                                );
                              },
                              icon: const Icon(Icons.phone_in_talk_rounded, size: 20),
                              label: Text('Panggilan Palsu', style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.softPink,
                                foregroundColor: AppColors.plum,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: PressScale(
                          child: SizedBox(
                            height: 54,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(backgroundColor: Colors.red, content: Text('SOS Darurat Dikirim!')),
                                );
                              },
                              icon: const Icon(Icons.warning_rounded, size: 20),
                              label: Text('SOS DARURAT', style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD32F2F),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Tombol Selesai
                  PressScale(
                    child: SizedBox(
                      width: double.infinity, height: 54,
                      child: ElevatedButton(
                        onPressed: _endTrip,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.plum,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text('Sampai dengan Aman!', style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuardianChip(String name, String status, Color bgColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFCFAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF0EDF2)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: bgColor,
              child: Text(name[0], style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                Text(status, style: GoogleFonts.nunito(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.green)),
              ],
            )
          ],
        ),
      ),
    );
  }
}

// ==========================================
// MOCK PETA UNTUK ACTIVE TRIP
// ==========================================
class _ActiveMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Tanah
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = const Color(0xFFE8ECEF));

    // Jalan
    final roadPaint = Paint()..color = Colors.white..strokeWidth = 20..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(size.width * 0.2, 0), Offset(size.width * 0.8, size.height), roadPaint);
    canvas.drawLine(Offset(0, size.height * 0.4), Offset(size.width, size.height * 0.6), roadPaint);

    // Rute Perjalanan (Garis tebal)
    final routePaint = Paint()
      ..color = AppColors.plum..strokeWidth = 8..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(size.width * 0.5, size.height * 0.8);
    path.quadraticBezierTo(size.width * 0.5, size.height * 0.5, size.width * 0.6, size.height * 0.4);
    canvas.drawPath(path, routePaint);

    // Titik Posisi User
    final pinPaint = Paint()..color = AppColors.plum;
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.8), 24, Paint()..color = AppColors.plum.withOpacity(0.2));
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.8), 12, pinPaint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.8), 5, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}