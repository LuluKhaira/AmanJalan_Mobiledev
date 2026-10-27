import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:amanjalan/core/theme/app_colors.dart';
import 'package:amanjalan/core/widgets/press_scale.dart';
import 'package:amanjalan/core/widgets/app_header.dart'; 
import 'package:amanjalan/features/home/active_trip_screen.dart';

class MapTab extends StatefulWidget {
  final VoidCallback? onBackToHome; 

  const MapTab({super.key, this.onBackToHome});

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {
  int _selectedRoute = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFAFC),
      body: Stack(
        children: [
          // ==========================================
          // 1. VISUALISASI PETA
          // ==========================================
          Positioned.fill(
            top: 70, // Jarak pas di bawah header
            child: CustomPaint(
              painter: _MockMapPainter(),
            ),
          ),

          // ==========================================
          // 2. HEADER BARU DI ATAS
          // ==========================================
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              color: const Color(0xFFFCFAFC),
              child: SafeArea(
                bottom: false,
                child: AppHeader(
                  // showBackButton DIHAPUS
                  onProfileTap: () {},
                ),
              ),
            ),
          ),

          // ==========================================
          // 3. KARTU BAWAH (Bottom Sheet)
          // ==========================================
          DraggableScrollableSheet(
            initialChildSize: 0.45,
            minChildSize: 0.35,
            maxChildSize: 0.8,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5))
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Pilihan Rute Aman',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 6, height: 6,
                                decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Pantauan Live',
                                style: GoogleFonts.nunito(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.green.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Rute terpantau dan dilengkapi penerangan jalan.',
                      style: GoogleFonts.nunito(fontSize: 13, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 20),

                    _buildRouteCard(
                      index: 0,
                      title: 'Rute Teraman',
                      subtitle: '14 Menit • 350 m',
                      badgeText: 'Paling Direkomendasikan',
                      icon: Icons.shield_rounded,
                      features: ['Penerangan LED terang', 'Banyak CCTV', 'Ramai aktivitas warga'],
                    ),
                    const SizedBox(height: 12),

                    _buildRouteCard(
                      index: 1,
                      title: 'Rute Tercepat',
                      subtitle: '10 Menit • 200 m',
                      badgeText: 'Kurang Aman',
                      icon: Icons.speed_rounded,
                      features: ['Gang sempit', 'Minim penerangan', 'Sepi saat malam'],
                    ),
                    const SizedBox(height: 24),

                    PressScale(
                      child: SizedBox(
                        height: 54,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              PageRouteBuilder(
                                transitionDuration: const Duration(milliseconds: 400),
                                pageBuilder: (_, __, ___) => const ActiveTripScreen(),
                                transitionsBuilder: (_, animation, __, child) =>
                                    FadeTransition(opacity: animation, child: child),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.plum,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.play_circle_fill_rounded, size: 22),
                              const SizedBox(width: 10),
                              Text(
                                'Mulai Jalan & Kirim Lokasi',
                                style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRouteCard({
    required int index,
    required String title,
    required String subtitle,
    required String badgeText,
    required IconData icon,
    required List<String> features,
  }) {
    final isSelected = _selectedRoute == index;
    final isSafe = index == 0;

    return GestureDetector(
      onTap: () => setState(() => _selectedRoute = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.softPink.withAlpha(77) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.plum : const Color(0xFFF0EDF2),
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSafe ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: isSafe ? Colors.green : Colors.orange,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? AppColors.plum : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? AppColors.plum : const Color(0xFFD5C9DC),
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isSafe ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                badgeText,
                style: GoogleFonts.nunito(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: isSafe ? Colors.green.shade800 : Colors.red.shade800,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ...features.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Icon(
                        isSafe ? Icons.check_circle_rounded : Icons.info_rounded,
                        size: 16,
                        color: isSafe ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        f,
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _MockMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFFEFEFEF);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(0, size.height * 0.2), Offset(size.width, size.height * 0.3), roadPaint);
    canvas.drawLine(Offset(size.width * 0.2, 0), Offset(size.width * 0.4, size.height), roadPaint);
    canvas.drawLine(Offset(size.width * 0.8, 0), Offset(size.width * 0.6, size.height), roadPaint);
    canvas.drawLine(Offset(0, size.height * 0.6), Offset(size.width, size.height * 0.5), roadPaint);

    final blockPaint = Paint()..color = const Color(0xFFE0E0E0);
    final parkPaint = Paint()..color = const Color(0xFFDCE8D8);

    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(50, size.height * 0.35, 80, 80), const Radius.circular(8)), blockPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width - 100, size.height * 0.2, 70, 100), const Radius.circular(8)), blockPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(30, size.height * 0.7, 100, 60), const Radius.circular(8)), parkPaint);

    final routePaint = Paint()
      ..color = AppColors.plum
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(size.width * 0.25, size.height * 0.8);
    path.lineTo(size.width * 0.4, size.height * 0.6);
    path.lineTo(size.width * 0.5, size.height * 0.65);
    path.lineTo(size.width * 0.6, size.height * 0.4);
    path.lineTo(size.width * 0.7, size.height * 0.3);

    canvas.drawPath(path, routePaint);

    final pinStartPaint = Paint()..color = AppColors.plum;
    canvas.drawCircle(Offset(size.width * 0.25, size.height * 0.8), 14, pinStartPaint);
    canvas.drawCircle(Offset(size.width * 0.25, size.height * 0.8), 6, Paint()..color = Colors.white);

    final pinEndPaint = Paint()..color = AppColors.textDark;
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.3), 14, pinEndPaint);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.3), 6, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}