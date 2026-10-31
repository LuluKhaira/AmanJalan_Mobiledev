import 'package:flutter/material.dart';
import 'package:amanjalan/core/theme/aj_theme.dart';
import 'package:amanjalan/core/widgets/aj_common.dart';

/// Pintu masuk ke "Tambah Teman Pantau".
///
/// QR Saya, Pindai, Kode, dan daftar teman sudah ada lengkap di layar
/// "QR Saling Pantau" (Profil), jadi di sini cukup satu baris ringkas
/// yang membuka layar itu, tidak menduplikasi isinya.
class TukarProteksiCard extends StatelessWidget {
  /// Dipanggil saat kartu diketuk. Isi dengan push ke layar QR Saling Pantau.
  final VoidCallback? onOpen;
  const TukarProteksiCard({super.key, this.onOpen});

  @override
  Widget build(BuildContext context) {
    return AjCard(
      color: const Color(0xFFEFE9E5),
      shadow: false,
      radius: 20,
      padding: const EdgeInsets.all(14),
      onTap: onOpen ??
          () => ajSnack(context, 'Buka lewat Profil → QR Saling Pantau', icon: Icons.qr_code_2_rounded),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(color: Aj.plum, borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.qr_code_2_rounded, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tambah Teman Pantau', style: Aj.h(15)),
                const SizedBox(height: 2),
                Text('3 teman terhubung • QR, kode & undangan', style: Aj.b(12, color: Aj.muted)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Aj.plum),
        ],
      ),
    );
  }
}