import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:amanjalan/core/theme/app_colors.dart';
import 'package:amanjalan/core/widgets/app_header.dart';

class ProfileTab extends StatefulWidget {
  final VoidCallback onLogout;

  const ProfileTab({super.key, required this.onLogout});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  bool _shakeDetect = true;
  bool _autoArrive = true;

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
          
          // KARTU PROFIL UTAMA
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFDF9FB),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 60, height: 60,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage('https://i.pravatar.cc/150?img=47'), // Foto mock
                          fit: BoxFit.cover,
                        )
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('Putri Andini', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                              const SizedBox(width: 4),
                              const Icon(Icons.verified, size: 16, color: AppColors.plum),
                            ],
                          ),
                          Text('Pelindung Diri Aktif • Jakarta Selatan', style: GoogleFonts.nunito(fontSize: 13, color: AppColors.textMuted)),
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          children: [
                            Text('24', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.plum)),
                            Text('Perjalanan', style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          children: [
                            Text('4', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.plum)),
                            Text('Penjaga Aktif', style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 32),

          // LINGKARAN PENJAGA
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Lingkaran Penjaga Terpercaya', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                    Text('3 Prioritas', style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.plum)),
                  ],
                ),
                const SizedBox(height: 12),
                _buildGuardianItem('Ibu Rahmawati', 'Prioritas 1 • WhatsApp, SOS Otomatis', const Color(0xFFF4E6F0)),
                _buildGuardianItem('Ayah Hendra', 'Prioritas 2 • WhatsApp, Panggilan Darurat', const Color(0xFFE6F0F4)),
                _buildGuardianItem('Kak Rian', 'Siaga Malam • Aktif 20.00 - 05.00 WIB', const Color(0xFFF0F4E6)),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity, height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                    label: Text('Tambah Kontak Penjaga Baru', style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w800)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.plum,
                      side: const BorderSide(color: AppColors.softPink, width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // FITUR KEAMANAN OTOMATIS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Fitur Keamanan Pintar Otomatis', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                const SizedBox(height: 4),
                Text('Kecerdasan sensorik untuk perlindungan tanpa rasa panik', style: GoogleFonts.nunito(fontSize: 13, color: AppColors.textMuted)),
                const SizedBox(height: 16),
                
                _buildSwitchItem(
                  icon: Icons.vibration,
                  title: 'Deteksi Guncangan & Jatuh',
                  subtitle: 'Siaga getaran ekstrem ponsel saat berjalan',
                  value: _shakeDetect,
                  onChanged: (v) => setState(() => _shakeDetect = v),
                ),
                const SizedBox(height: 12),
                _buildSwitchItem(
                  icon: Icons.location_on_rounded,
                  title: 'Kabar Tiba di Rumah Otomatis',
                  subtitle: 'Kirim kabar ke wali saat tiba di titik aman',
                  value: _autoArrive,
                  onChanged: (v) => setState(() => _autoArrive = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // PRIVASI & TOMBOL LOGOUT
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F8E9), // Warna hijau pastel
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.lock_outline_rounded, color: Colors.green, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Privasi & Enkripsi Data Penuh', style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.green.shade800)),
                            const SizedBox(height: 4),
                            Text('Semua riwayat pelacakan GPS dienkripsi ujung-ke-ujung dan otomatis terhapus permanen.', style: GoogleFonts.nunito(fontSize: 12, color: Colors.green.shade900)),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Tombol Logout
                InkWell(
                  onTap: widget.onLogout,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
                        const SizedBox(width: 8),
                        Text('Keluar dari Akun', style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.redAccent)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuardianItem(String name, String subtitle, Color bgColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0EDF2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: bgColor,
            child: Text(name[0], style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                const SizedBox(height: 2),
                Text(subtitle, style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
          ),
          const Icon(Icons.more_vert_rounded, color: AppColors.textMuted),
        ],
      ),
    );
  }

  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0EDF2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(color: AppColors.softPink, shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.plum, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                const SizedBox(height: 2),
                Text(subtitle, style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.plum,
          )
        ],
      ),
    );
  }
}