import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:amanjalan/core/theme/aj_theme.dart';
import 'package:amanjalan/core/theme/app_colors.dart';
import 'package:amanjalan/core/widgets/aj_common.dart';
import 'package:amanjalan/features/home/aj_data.dart';
import 'package:amanjalan/features/home/tambah_guardian_screen.dart';

class ManageGuardianScreen extends StatelessWidget {
  const ManageGuardianScreen({super.key});

  static const int _maxSlot = 5;

  void _confirmDelete(BuildContext context, int index, String name) {
    HapticFeedback.lightImpact();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFFFDE8E8),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_outline_rounded, color: Aj.sos, size: 20),
            ),
            const SizedBox(width: 10),
            Text('Hapus Guardian?', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus $name dari daftar guardian? Guardian ini tidak akan lagi menerima notifikasi pemantauan.',
          style: GoogleFonts.nunito(fontSize: 13, color: AppColors.textMuted, height: 1.35),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, color: AppColors.textMuted)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Aj.sos,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              GuardianStore.removeGuardian(index);
              ajSnack(context, '$name berhasil dihapus dari daftar Guardian', icon: Icons.delete_outline_rounded);
            },
            child: Text('Ya, Hapus', style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  void _setAsPrimary(BuildContext context, int index, Guardian g) {
    HapticFeedback.mediumImpact();
    if (index == 0) return;

    final current = [...GuardianStore.guardians.value];
    final target = current.removeAt(index);
    final promoted = Guardian(
      name: target.name,
      role: 'Wali Utama',
      note: 'Kontak Prioritas #1',
      online: target.online,
      color: target.color,
      imageUrl: target.imageUrl,
      phone: target.phone,
    );
    current.insert(0, promoted);
    GuardianStore.guardians.value = current;

    ajSnack(
      context,
      '${g.name} dijadikan sebagai Wali Utama (Kontak Prioritas #1)',
      icon: Icons.star_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Kelola Guardian',
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        centerTitle: true,
      ),
      body: ValueListenableBuilder<List<Guardian>>(
        valueListenable: GuardianStore.guardians,
        builder: (context, guardians, _) {
          final slotRatio = (guardians.length / _maxSlot).clamp(0.0, 1.0);

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Kartu Ringkasan Slot & Proteksi
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8F9),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFFF6D9E1), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(6),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.softPink,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.shield_rounded, color: AppColors.plum, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Lingkar Keamanan Aktif',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${guardians.length} dari $_maxSlot Slot Guardian Terpakai',
                                  style: GoogleFonts.nunito(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: guardians.isNotEmpty ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              guardians.isNotEmpty ? 'Siaga' : 'Kosong',
                              style: GoogleFonts.nunito(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: guardians.isNotEmpty ? const Color(0xFF2E7D4F) : Aj.sos,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: slotRatio,
                          minHeight: 7,
                          backgroundColor: const Color(0xFFEFE8EB),
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.plum),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, size: 15, color: AppColors.plum),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Guardian akan menerima live lokasi dan sinyal SOS bila Anda dalam keadaan darurat.',
                              style: GoogleFonts.nunito(
                                fontSize: 11.5,
                                color: AppColors.textMuted,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // 2. Info Prioritas Kontak Utama
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF0EAE6)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Color(0xFFE6A700), size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Kontak teratas (#1) adalah Wali Utama yang diprioritaskan saat sinyal SOS ditekan.',
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // 3. Header Daftar Guardian
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Daftar Guardian (${guardians.length})',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      'Maksimal 5 Orang',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 4. List Kartu Guardian
                if (guardians.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFF0EDF2)),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.people_outline_rounded, size: 48, color: AppColors.textMuted),
                        const SizedBox(height: 10),
                        Text(
                          'Belum Ada Guardian',
                          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tambahkan orang terpercaya (ibu, teman, saudara) untuk saling memantau.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.nunito(fontSize: 12.5, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  )
                else
                  for (int i = 0; i < guardians.length; i++)
                    _buildGuardianCard(context, i, guardians[i]),

                const SizedBox(height: 20),

                // 5. Tombol Tambah Guardian Baru
                if (guardians.length < _maxSlot)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton.icon(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const TambahGuardianScreen(),
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.plum,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: const Icon(Icons.person_add_alt_1_rounded, size: 20),
                      label: Text(
                        'Tambah Guardian Baru',
                        style: GoogleFonts.nunito(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F1EE),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_rounded, size: 18, color: Color(0xFF2E7D4F)),
                        const SizedBox(width: 8),
                        Text(
                          'Slot Guardian Penuh (5/5 Aktif)',
                          style: GoogleFonts.nunito(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGuardianCard(BuildContext context, int index, Guardian g) {
    final isPrimary = index == 0 || g.role == 'Wali Utama';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPrimary ? AppColors.plum.withAlpha(90) : const Color(0xFFF0EAE6),
          width: isPrimary ? 1.6 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(7),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row Utama: Avatar, Info, Menu
          Row(
            children: [
              AjAvatar(
                name: g.name,
                size: 50,
                online: g.online,
                color: g.color,
                imageUrl: g.imageUrl,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            g.name,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (isPrimary)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFBF0DB),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star_rounded, size: 12, color: Color(0xFFE6A700)),
                                const SizedBox(width: 3),
                                Text(
                                  'Wali Utama (#1)',
                                  style: GoogleFonts.nunito(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF946200),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          AjPill(g.role, bg: const Color(0xFFF5F1EE), fg: AppColors.textMuted, size: 10.5),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      g.phone ?? g.note,
                      style: GoogleFonts.nunito(
                        fontSize: 12.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              // Menu titik tiga (opsi)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded, color: AppColors.textMuted),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                onSelected: (val) {
                  if (val == 'primary') {
                    _setAsPrimary(context, index, g);
                  } else if (val == 'delete') {
                    _confirmDelete(context, index, g.name);
                  }
                },
                itemBuilder: (_) => [
                  if (!isPrimary)
                    PopupMenuItem(
                      value: 'primary',
                      child: Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Color(0xFFE6A700), size: 18),
                          const SizedBox(width: 10),
                          Text('Jadikan Wali Utama (#1)', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete_outline_rounded, color: Aj.sos, size: 18),
                        const SizedBox(width: 10),
                        Text('Hapus Guardian', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, color: Aj.sos)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF0EAE6)),
          const SizedBox(height: 10),

          // Baris Izin Proteksi & Aksi Cepat
          Row(
            children: [
              // Badge izin
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2E7D4F),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Izin Live & SOS Aktif',
                    style: GoogleFonts.nunito(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2E7D4F),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Tombol WhatsApp
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: 'Chat WhatsApp',
                onPressed: () => ajSnack(context, 'Membuka obrolan WhatsApp dengan ${g.name}', icon: Icons.chat_bubble_rounded),
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 19, color: Color(0xFF25D366)),
              ),
              // Tombol Telepon
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: 'Panggilan Langsung',
                onPressed: () => ajSnack(context, 'Memanggil ${g.name} (${g.phone ?? 'Kontak'})…', icon: Icons.phone_rounded),
                icon: const Icon(Icons.phone_outlined, size: 19, color: AppColors.plum),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
