import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:amanjalan/core/theme/app_colors.dart';
import 'package:amanjalan/core/widgets/press_scale.dart';

class SafeArrivalScreen extends StatelessWidget {
  const SafeArrivalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F9F4), // Sage Green pudar
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ikon Centang Besar
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Color(0xFFDCEBDD), // Sage Green
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, size: 50, color: Colors.green),
              ),
              const SizedBox(height: 24),
              
              // Teks Ucapan
              Text(
                'Alhamdulillah,\nKamu Sudah Tiba!',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Perjalananmu telah selesai dan lokasi terakhirmu sudah dikirim ke Guardian.',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 40),

              // Ringkasan Perjalanan
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFDCEBDD), width: 2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryItem('14 Menit', 'Waktu'),
                    Container(width: 1, height: 40, color: Colors.grey.shade300),
                    _buildSummaryItem('350 m', 'Jarak'),
                    Container(width: 1, height: 40, color: Colors.grey.shade300),
                    _buildSummaryItem('Aman', 'Status'),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Tombol Kembali
              PressScale(
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      // Kembali ke Home (Hapus semua tumpukan route)
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.textDark,
                      elevation: 0,
                      side: const BorderSide(color: Color(0xFFDCEBDD), width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      'Kembali ke Beranda',
                      style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 12,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}