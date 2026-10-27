import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:amanjalan/core/theme/app_colors.dart';

class ManageGuardianScreen extends StatelessWidget {
  const ManageGuardianScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Data dummy untuk tampilan
    final guardians = [
      {'name': 'Mama', 'relation': 'Ibu', 'phone': '+62 812-3456-7890'},
      {'name': 'Nadia', 'relation': 'Sahabat', 'phone': '+62 813-1111-2222'},
      {'name': 'Kakak', 'relation': 'Keluarga', 'phone': '+62 857-3333-4444'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFCFAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Atur Guardian',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: guardians.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final g = guardians[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF0EDF2), width: 1.5),
            ),
            child: Row(
              children: [
                // Avatar Inisial
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: AppColors.softPink,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      g['name']!.substring(0, 1),
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.plum,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        g['name']!,
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        '${g['relation']} • ${g['phone']}',
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                // Tombol Hapus
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                  onPressed: () {
                    // Simulasi hapus
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${g['name']} dihapus (Simulasi)')),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Bisa memanggil AddGuardianSheet di sini
        },
        backgroundColor: AppColors.plum,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'Tambah',
          style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}