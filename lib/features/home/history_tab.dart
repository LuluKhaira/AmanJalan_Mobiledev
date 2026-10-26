import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:amanjalan/core/theme/app_colors.dart';
import 'package:amanjalan/core/widgets/app_header.dart';
import 'package:amanjalan/core/widgets/animated_entrance.dart';

class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          const SafeArea(
            bottom: false,
            child: AppHeader(),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                
                // RINGKASAN
                AnimatedEntrance(
                  index: 0,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDF9FB),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFF0EDF2), width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.shield_outlined, color: AppColors.plum, size: 20),
                                const SizedBox(width: 8),
                                Text('Ringkasan Proteksi', style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.plum)),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: AppColors.softPink, borderRadius: BorderRadius.circular(10)),
                              child: Text('Bulan Ini', style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.plum)),
                            )
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text('28 Perjalanan Selesai Aman', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                        const SizedBox(height: 4),
                        Text('Semua jejak langkahmu sampai tujuan tanpa hambatan.', style: GoogleFonts.nunito(fontSize: 13, color: AppColors.textMuted)),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(color: const Color(0xFFF7F4F9), borderRadius: BorderRadius.circular(12)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(children: [
                                      const Icon(Icons.check_circle_outline, size: 14, color: AppColors.textDark),
                                      const SizedBox(width: 6),
                                      Text('Skor Aman', style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                                    ]),
                                    const SizedBox(height: 6),
                                    Text('100% ', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(color: const Color(0xFFF7F4F9), borderRadius: BorderRadius.circular(12)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(children: [
                                      const Icon(Icons.group_outlined, size: 14, color: AppColors.textDark),
                                      const SizedBox(width: 6),
                                      Text('Pendampingan', style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                                    ]),
                                    const SizedBox(height: 6),
                                    Text('14 Jam ', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                                  ],
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // FILTER TAB (Mock)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Semua (28)', true),
                      _buildFilterChip('Minggu Ini (4)', false),
                      _buildFilterChip('Bulan Ini (12)', false),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // LIST RIWAYAT
                AnimatedEntrance(
                  index: 1,
                  child: _buildHistoryCard(
                    date: 'Kemarin, 21:48 WIB',
                    type: 'Jalan Kaki • 14 mnt (850 m)',
                    icon: Icons.directions_walk,
                    startPoint: 'Stasiun MRT Blok M (Pintu B)',
                    endPoint: 'Kosan Kemang No. 42',
                    footer: 'Mama & Kak Dimas mendampingi',
                  ),
                ),
                const SizedBox(height: 12),
                AnimatedEntrance(
                  index: 2,
                  child: _buildHistoryCard(
                    date: '18 Mei 2024, 22:15 WIB',
                    type: 'Naik Ojol • 8 mnt (2.4 km)',
                    icon: Icons.two_wheeler,
                    startPoint: 'Grand Indonesia (Lobby Rama)',
                    endPoint: 'Apartemen Menteng Park',
                    footer: 'Ayah Hendra mendampingi',
                  ),
                ),
                
                const SizedBox(height: 24),
                // FOOTER QUOTE
                AnimatedEntrance(
                  index: 3,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDF9FB),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.favorite_rounded, color: AppColors.plum, size: 30),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Langkahmu Berharga', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                              const SizedBox(height: 4),
                              Text('Terima kasih telah menjaga diri dan saling melindungi bersama.', style: GoogleFonts.nunito(fontSize: 13, color: AppColors.textMuted)),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String text, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? AppColors.plum : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isActive ? AppColors.plum : const Color(0xFFF0EDF2)),
      ),
      child: Text(
        text,
        style: GoogleFonts.nunito(
          fontSize: 13,
          fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
          color: isActive ? Colors.white : AppColors.textMuted,
        ),
      ),
    );
  }

  Widget _buildHistoryCard({
    required String date,
    required String type,
    required IconData icon,
    required String startPoint,
    required String endPoint,
    required String footer,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0EDF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(color: AppColors.softPink, shape: BoxShape.circle),
                child: Icon(icon, color: AppColors.plum, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(date, style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                    Text(type, style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textMuted)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    const Icon(Icons.check, size: 12, color: Colors.green),
                    const SizedBox(width: 4),
                    Text('Sampai Aman', style: GoogleFonts.nunito(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.green.shade800)),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFFAF9FB), borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.circle, size: 10, color: AppColors.plum),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('TITIK AWAL', style: GoogleFonts.nunito(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
                          Text(startPoint, style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                        ],
                      ),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 4.5),
                  child: Row(
                    children: [
                      Container(width: 1.5, height: 16, color: Colors.grey.shade300),
                    ],
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.flag_rounded, size: 12, color: AppColors.plum),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('TUJUAN AKHIR', style: GoogleFonts.nunito(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
                          Text(endPoint, style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(footer, style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textMuted)),
              Text('Detail >', style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.plum)),
            ],
          )
        ],
      ),
    );
  }
}