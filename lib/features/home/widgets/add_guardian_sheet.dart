import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:amanjalan/core/theme/app_colors.dart';

class AddGuardianSheet extends StatelessWidget {
  final VoidCallback onAddFromContact;
  final VoidCallback onShareLink;

  const AddGuardianSheet({
    super.key,
    required this.onAddFromContact,
    required this.onShareLink,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tambah Guardian',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pilih cara mengundang orang terdekatmu untuk memantau perjalananmu.',
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.softPink,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.contacts_rounded, color: AppColors.plum),
            ),
            title: Text('Pilih dari Kontak', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
            subtitle: Text('Undang via SMS atau WhatsApp', style: GoogleFonts.nunito(fontSize: 12)),
            onTap: onAddFromContact,
          ),
          const Divider(),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.softPink,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.share_rounded, color: AppColors.plum),
            ),
            title: Text('Bagikan Link Undangan', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
            subtitle: Text('Kirim link via aplikasi lain', style: GoogleFonts.nunito(fontSize: 12)),
            onTap: onShareLink,
          ),
        ],
      ),
    );
  }
}