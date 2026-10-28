import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:amanjalan/core/theme/app_colors.dart';
import 'package:amanjalan/core/widgets/aj_common.dart';
import 'package:amanjalan/features/home/aj_data.dart';

class TambahGuardianScreen extends StatefulWidget {
  final VoidCallback? onGuardianAdded;

  const TambahGuardianScreen({super.key, this.onGuardianAdded});

  @override
  State<TambahGuardianScreen> createState() => _TambahGuardianScreenState();
}

class _TambahGuardianScreenState extends State<TambahGuardianScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  final List<String> _relations = [
    'Orang Tua',
    'Pasangan',
    'Saudara Kandung',
    'Teman Dekat',
    'Lainnya',
  ];
  String _selectedRelation = 'Orang Tua';

  // 0: Guardian Pendamping (Disarankan), 1: Khusus Sinyal SOS Darurat
  int _notificationLevel = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _importContact() {
    HapticFeedback.selectionClick();
    setState(() {
      _nameController.text = 'Ayah (Bambang)';
      _phoneController.text = '812-9876-5432';
      _selectedRelation = 'Orang Tua';
    });
    ajSnack(
      context,
      'Kontak "Ayah (Bambang)" berhasil diimpor otomatis',
      icon: Icons.contacts_rounded,
    );
  }

  void _saveGuardian() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty) {
      ajSnack(
        context,
        'Harap masukkan nama atau panggilan wali',
        icon: Icons.warning_amber_rounded,
      );
      return;
    }

    if (phone.isEmpty) {
      ajSnack(
        context,
        'Harap masukkan nomor WhatsApp aktif wali',
        icon: Icons.warning_amber_rounded,
      );
      return;
    }

    HapticFeedback.mediumImpact();

    final newGuardian = Guardian(
      name: name,
      role: _selectedRelation,
      note: _notificationLevel == 0
          ? 'WhatsApp Realtime Aktif'
          : 'Khusus Panggilan SOS',
      online: true,
      color: const Color(0xFFFBE8F0),
    );

    GuardianStore.addGuardian(newGuardian);
    widget.onGuardianAdded?.call();

    ajSnack(
      context,
      '$name berhasil ditambahkan sebagai Guardian ke-3!',
      icon: Icons.verified_user_rounded,
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCFAFC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textDark, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Tambah Guardian',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 18),
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFF2C243B),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_outline_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Judul Utama
              Text(
                'Tambah Guardian',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Pilih orang terpercaya untuk mengawal setiap langkah perjalananmu secara hening & siaga.',
                style: GoogleFonts.nunito(
                  fontSize: 13.5,
                  color: AppColors.textMuted,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 18),

              // Kartu Pilih Kontak HP (Cepat)
              _buildImportContactCard(),
              const SizedBox(height: 22),

              // Garis Pemisah ATAU ISI MANDIRI
              _buildOrDivider(),
              const SizedBox(height: 20),

              // Form: Nama / Panggilan Wali
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Nama / Panggilan Wali',
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    'Wajib',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _nameController,
                hintText: 'Contoh: Ayah / Mas Reza / Sarah Sahabat',
                prefixIcon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 16),

              // Form: Nomor WhatsApp Aktif
              Text(
                'Nomor WhatsApp Aktif',
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              _buildPhoneField(),
              const SizedBox(height: 18),

              // Form: Hubungan dengan Kamu
              Text(
                'Hubungan dengan Kamu',
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 10),
              _buildRelationChips(),
              const SizedBox(height: 22),

              // Form: Tingkat Notifikasi Perjalanan
              Text(
                'Tingkat Notifikasi Perjalanan',
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 10),
              _buildNotificationLevelOptions(),
              const SizedBox(height: 16),

              // Info Box Privasi
              _buildPrivacyBox(),
              const SizedBox(height: 20),

              // Guardian yang sudah aktif saat ini
              _buildActiveGuardiansStatus(),
              const SizedBox(height: 24),

              // Tombol Simpan
              _buildSaveButton(),
              const SizedBox(height: 12),

              // Tombol Batalkan
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Batalkan',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImportContactCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF0EDF2), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF8EFF5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.import_contacts_rounded,
              color: AppColors.plum,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Pilih Kontak HP',
                      style: GoogleFonts.nunito(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBE8F0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Cepat',
                        style: GoogleFonts.nunito(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF9E3867),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Impor nama & WhatsApp otomatis',
                  style: GoogleFonts.nunito(
                    fontSize: 11.5,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: _importContact,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFEFECEF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Text(
                    'Buka',
                    style: GoogleFonts.nunito(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.textDark),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFE8E5EA), thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'ATAU ISI MANDIRI',
            style: GoogleFonts.nunito(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: const Color(0xFFA59EA8),
              letterSpacing: 1.1,
            ),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFE8E5EA), thickness: 1)),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFECE8F0), width: 1.2),
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          prefixIcon: Icon(prefixIcon, color: const Color(0xFF8A8290), size: 20),
          hintText: hintText,
          hintStyle: GoogleFonts.nunito(fontSize: 13, color: const Color(0xFFAFA7B4), fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFECE8F0), width: 1.2),
      ),
      child: TextField(
        controller: _phoneController,
        keyboardType: TextInputType.phone,
        style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          prefixIcon: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF2E7D32), size: 18),
                SizedBox(width: 8),
                Text(
                  '+62',
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: Color(0xFF4A4450)),
                ),
              ],
            ),
          ),
          hintText: '812-3456-7890',
          hintStyle: GoogleFonts.nunito(fontSize: 13, color: const Color(0xFFAFA7B4), fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildRelationChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _relations.map((relation) {
        final isSelected = _selectedRelation == relation;
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _selectedRelation = relation);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF2C243B) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? const Color(0xFF2C243B) : const Color(0xFFECE8F0),
                width: 1.2,
              ),
            ),
            child: Text(
              relation,
              style: GoogleFonts.nunito(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                color: isSelected ? Colors.white : const Color(0xFF4A4450),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNotificationLevelOptions() {
    return Column(
      children: [
        // Opsi 1: Guardian Pendamping
        _buildNotificationCard(
          index: 0,
          title: 'Guardian Pendamping',
          badgeText: 'Disarankan',
          badgeBg: const Color(0xFFDCEBDD),
          badgeFg: const Color(0xFF2E7D32),
          description:
              'Menerima live map otomatis saat kamu mulai jalan malam, notifikasi saat tiba di tujuan, dan sinyal darurat SOS.',
        ),
        const SizedBox(height: 10),

        // Opsi 2: Khusus Sinyal SOS Darurat
        _buildNotificationCard(
          index: 1,
          title: 'Khusus Sinyal SOS Darurat',
          badgeText: null,
          badgeBg: null,
          badgeFg: null,
          description:
              'Hanya dihubungi saat tombol darurat ditekan atau guncangan benturan keras terdeteksi. Tidak menerima riwayat rute harian.',
        ),
      ],
    );
  }

  Widget _buildNotificationCard({
    required int index,
    required String title,
    required String? badgeText,
    required Color? badgeBg,
    required Color? badgeFg,
    required String description,
  }) {
    final isSelected = _notificationLevel == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _notificationLevel = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFAF4F9) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.plum : const Color(0xFFECE8F0),
            width: isSelected ? 1.5 : 1.2,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.plum : const Color(0xFFC4BEC8),
                    width: isSelected ? 5.5 : 1.8,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: GoogleFonts.nunito(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      if (badgeText != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: badgeBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            badgeText,
                            style: GoogleFonts.nunito(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: badgeFg,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      color: AppColors.textMuted,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyBox() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F4F7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFFBE8F0),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: Color(0xFF9E3867),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tenang, Tanpa Spam & Privasi Terlindungi',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Kontak ini tidak akan menerima pesan promosi. Akses koordinat GPS kamu ditutup otomatis begitu perjalanan berstatus "Tiba dengan Selamat".',
                  style: GoogleFonts.nunito(
                    fontSize: 11.5,
                    color: AppColors.textMuted,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveGuardiansStatus() {
    return ValueListenableBuilder<List<Guardian>>(
      valueListenable: GuardianStore.guardians,
      builder: (context, guardians, _) {
        final count = guardians.length;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFECE8F0), width: 1.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Guardian yang sudah aktif saat ini:',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted,
                    ),
                  ),
                  Text(
                    '$count Terdaftar',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: guardians.take(3).map((g) {
                  final initial = g.name.trim().isNotEmpty ? g.name.trim().substring(0, 1) : 'G';
                  final twoLetters = g.name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join();
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F7FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFECE8F0), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: g.color,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            twoLetters.isNotEmpty ? twoLetters : initial,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.plum,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 120),
                          child: Text(
                            '${g.name} (${g.role.split(' ').first})',
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.nunito(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSaveButton() {
    return ValueListenableBuilder<List<Guardian>>(
      valueListenable: GuardianStore.guardians,
      builder: (context, guardians, _) {
        final slotNumber = guardians.length + 1;
        return SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _saveGuardian,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2C243B),
              foregroundColor: Colors.white,
              elevation: 2,
              shadowColor: Colors.black38,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person_add_alt_1_rounded, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Simpan & Jadikan Guardian (Slot $slotNumber)',
                  style: GoogleFonts.nunito(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
