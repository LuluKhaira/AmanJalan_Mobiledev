import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:amanjalan/core/theme/app_colors.dart';
import 'package:amanjalan/core/widgets/press_scale.dart';
import 'package:amanjalan/core/widgets/animated_entrance.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // 0: Semua (4), 1: Darurat & Sensor (1), 2: Saling Pantau (2)
  int _selectedFilter = 0;
  bool _unread = true;

  void _markAllAsRead() {
    HapticFeedback.lightImpact();
    setState(() => _unread = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.plum,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(
          'Semua notifikasi telah ditandai dibaca',
          style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _openSettings() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                const SizedBox(height: 20),
                Text(
                  'Pengaturan Notifikasi & Suara Darurat',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sesuaikan sensitivitas peringatan sensor dan saluran darurat.',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 20),
                _buildSettingTile(
                  icon: Icons.vibration,
                  title: 'Sensitivitas Sensor Sentakan',
                  subtitle: 'Tinggi (Deteksi jatuh & guncangan keras)',
                ),
                _buildSettingTile(
                  icon: Icons.notifications_active_outlined,
                  title: 'Suara Sirene Sirene Darurat',
                  subtitle: 'Volume Penuh saat SOS Aktif',
                ),
                _buildSettingTile(
                  icon: Icons.location_on_outlined,
                  title: 'Notifikasi Geofence Rumah',
                  subtitle: 'Kirim otomatis ke seluruh Guardian',
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.plum,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Simpan Pengaturan',
                      style: GoogleFonts.nunito(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.softPink,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.plum, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle_rounded, color: AppColors.plum, size: 20),
        ],
      ),
    );
  }

  void _showLocationDialog(String title, String loc) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.plum,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(
          'Membuka peta lokasi: $loc ($title)',
          style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _sendWhatsAppReminder(String name) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1E8256),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(
          'Mengirim pengingat WhatsApp hemat daya ke $name...',
          style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFFBF9FC),
        body: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Banner Sistem Proteksi Aktif
                      AnimatedEntrance(index: 0, child: _buildProtectionBanner()),
                      const SizedBox(height: 18),

                      // Filter Chips
                      AnimatedEntrance(index: 1, child: _buildFilterChips()),
                      const SizedBox(height: 22),

                      // Section Hari Ini
                      if (_shouldShowTodaySection) ...[
                        AnimatedEntrance(
                          index: 2,
                          child: _buildSectionHeader(
                            title: 'HARI INI',
                            subtitle: 'Real-time',
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Card 1: Guncangan Terdeteksi
                        if (_selectedFilter == 0 || _selectedFilter == 1)
                          AnimatedEntrance(
                            index: 3,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: _buildShakeAlertCard(),
                            ),
                          ),

                        // Card 2: Ibu Nurhayati Tiba di Rumah
                        if (_selectedFilter == 0 || _selectedFilter == 1)
                          AnimatedEntrance(
                            index: 4,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 22),
                              child: _buildGeofenceArrivalCard(),
                            ),
                          ),
                      ],

                      // Section Kemarin & Sebelumnya
                      if (_shouldShowYesterdaySection) ...[
                        AnimatedEntrance(
                          index: 5,
                          child: _buildSectionHeader(
                            title: 'KEMARIN & SEBELUMNYA',
                            subtitle: 'Riwayat 48 Jam',
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Card 3: Koneksi Saling Pantau Aktif
                        if (_selectedFilter == 0 || _selectedFilter == 2)
                          AnimatedEntrance(
                            index: 6,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: _buildMutualEscortCard(),
                            ),
                          ),

                        // Card 4: Baterai Rendah
                        if (_selectedFilter == 0 || _selectedFilter == 1)
                          AnimatedEntrance(
                            index: 7,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 24),
                              child: _buildLowBatteryCard(),
                            ),
                          ),
                      ],

                      // Footer Enkripsi & Pengaturan Notifikasi
                      AnimatedEntrance(index: 8, child: _buildFooter()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool get _shouldShowTodaySection {
    if (_selectedFilter == 0) return true;
    if (_selectedFilter == 1) return true; // ada Card 1 & Card 2
    return false;
  }

  bool get _shouldShowYesterdaySection {
    if (_selectedFilter == 0) return true;
    if (_selectedFilter == 1) return true; // ada Card 4
    if (_selectedFilter == 2) return true; // ada Card 3
    return false;
  }

  // ==========================================
  // TOP APP BAR
  // ==========================================
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 16, 10),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark, size: 24),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 4),
          Text(
            'Notifikasi',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(width: 10),
          if (_unread)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF352B42),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                '3 Baru',
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          const Spacer(),
          IconButton(
            splashRadius: 22,
            icon: const Icon(Icons.done_all_rounded, color: AppColors.textDark, size: 22),
            tooltip: 'Tandai Semua Dibaca',
            onPressed: _markAllAsRead,
          ),
          IconButton(
            splashRadius: 22,
            icon: const Icon(Icons.settings_outlined, color: AppColors.textDark, size: 22),
            tooltip: 'Pengaturan Notifikasi',
            onPressed: _openSettings,
          ),
        ],
      ),
    );
  }

  // ==========================================
  // BANNER SISTEM PROTEKSI AKTIF
  // ==========================================
  Widget _buildProtectionBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF7F1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFC7EED9), width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon Perisai dengan Titik Hijau
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFFD2F4E5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: Color(0xFF1E8256),
                  size: 23,
                ),
              ),
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E8256),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),

          // Teks Status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'Sistem Proteksi Aktif',
                      style: GoogleFonts.poppins(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF134E34),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1E8256),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '3 Guardian Terhubung',
                  style: GoogleFonts.nunito(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E8256),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Margonda, Beji & Rute Perjalanan Terpantau',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF4C7561),
                  ),
                ),
              ],
            ),
          ),

          // Badge Live
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFD2F4E5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Live',
              style: GoogleFonts.nunito(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1E8256),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // FILTER CHIPS (Semua, Darurat & Sensor, Saling Pantau)
  // ==========================================
  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildFilterChip(
            index: 0,
            label: 'Semua',
            count: '4',
            badgeBg: _selectedFilter == 0 ? const Color(0x33FFFFFF) : const Color(0xFFE5DFEC),
            badgeTextColor: _selectedFilter == 0 ? Colors.white : AppColors.plum,
          ),
          const SizedBox(width: 10),
          _buildFilterChip(
            index: 1,
            label: 'Darurat & Sensor',
            count: '1',
            badgeBg: _selectedFilter == 1 ? const Color(0x33FFFFFF) : const Color(0xFFFFDDE4),
            badgeTextColor: _selectedFilter == 1 ? Colors.white : const Color(0xFFD32F2F),
          ),
          const SizedBox(width: 10),
          _buildFilterChip(
            index: 2,
            label: 'Saling Pantau',
            count: '2',
            badgeBg: _selectedFilter == 2 ? const Color(0x33FFFFFF) : const Color(0xFFEFE9F6),
            badgeTextColor: _selectedFilter == 2 ? Colors.white : const Color(0xFF6B428A),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required int index,
    required String label,
    required String count,
    required Color badgeBg,
    required Color badgeTextColor,
  }) {
    final isSelected = _selectedFilter == index;
    return PressScale(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _selectedFilter = index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF382947) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected ? const Color(0xFF382947) : const Color(0xFFE6E3EA),
              width: 1.2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF382947).withAlpha(46),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: GoogleFonts.nunito(
                  fontSize: 13.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                  color: isSelected ? Colors.white : const Color(0xFF5A5263),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count,
                  style: GoogleFonts.nunito(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: badgeTextColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // SECTION HEADER
  // ==========================================
  Widget _buildSectionHeader({required String title, required String subtitle}) {
    return Row(
      children: [
        Container(
          width: 5,
          height: 5,
          decoration: const BoxDecoration(
            color: Color(0xFF4A4252),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 7),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF4A4252),
            letterSpacing: 0.6,
          ),
        ),
        const Spacer(),
        Text(
          subtitle,
          style: GoogleFonts.nunito(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  // ==========================================
  // CARD 1: Guncangan Terdeteksi • Salsabila Rahma
  // ==========================================
  Widget _buildShakeAlertCard() {
    return _buildNotificationCardWrapper(
      accentColor: const Color(0xFFE53935), // Garis merah tebal di tepi kiri
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Guncangan / Alarm Merah
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDECEF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.crisis_alert_rounded,
                      color: Color(0xFFD32F2F),
                      size: 24,
                    ),
                  ),
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD32F2F),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),

              // Judul & Waktu
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                                height: 1.3,
                              ),
                              children: const [
                                TextSpan(text: 'Guncangan Terdeteksi • \n'),
                                TextSpan(
                                  text: 'Salsabila Rahma',
                                  style: TextStyle(fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Text(
                          '15 mnt lalu',
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Deskripsi
          Text(
            'Sensor akselerometer mendeteksi sentakan cepat 3x di sekitar Jl. Margonda Raya. Status terkini telah dikonfirmasi aman oleh Salsa.',
            style: GoogleFonts.nunito(
              fontSize: 13,
              height: 1.5,
              color: const Color(0xFF534C5A),
            ),
          ),
          const SizedBox(height: 14),

          // Baris Aksi Bawah
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF8F1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_outline_rounded,
                      size: 14,
                      color: Color(0xFF1E8256),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Dibatalkan Pengguna',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1E8256),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              PressScale(
                child: GestureDetector(
                  onTap: () => _showLocationDialog('Salsabila Rahma', 'Jl. Margonda Raya'),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Cek Lokasi',
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 15,
                        color: AppColors.textDark,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // CARD 2: Ibu Nurhayati Tiba di Rumah
  // ==========================================
  Widget _buildGeofenceArrivalCard() {
    return _buildNotificationCardWrapper(
      accentColor: const Color(0xFF1E8256), // Garis hijau tebal di tepi kiri
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Lokasi Pin Hijau
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F6EE),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.location_on_outlined,
                      color: Color(0xFF1E8256),
                      size: 24,
                    ),
                  ),
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1E8256),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),

              // Judul & Waktu
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        'Ibu Nurhayati Tiba di Rumah',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    Text(
                      '1 jam lalu',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Deskripsi
          Text(
            'Memasuki radius aman geofence Rumah (Jl. Melati No. 4). Rute perjalanan otomatis ditutup dengan aman.',
            style: GoogleFonts.nunito(
              fontSize: 13,
              height: 1.5,
              color: const Color(0xFF534C5A),
            ),
          ),
          const SizedBox(height: 14),

          // Tags Bawah (Geofence + Baterai)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF8F1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.shield_outlined,
                      size: 13,
                      color: Color(0xFF1E8256),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Geofence Rumah (Jl. Melati)',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E8256),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF1F4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.battery_charging_full_rounded,
                      size: 14,
                      color: Color(0xFF1E8256),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '89%',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF495057),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // CARD 3: Koneksi Saling Pantau Aktif • Dinda Kirana
  // ==========================================
  Widget _buildMutualEscortCard() {
    return _buildNotificationCardWrapper(
      accentColor: const Color(0xFFE8E5EE), // Garis halus lavender
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar Inisial DK
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDE5FA),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'DK',
                      style: GoogleFonts.poppins(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF5C2880),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E8256),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),

              // Judul & Waktu
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                            height: 1.3,
                          ),
                          children: const [
                            TextSpan(text: 'Koneksi Saling Pantau Aktif\n'),
                            TextSpan(
                              text: '• Dinda Kirana',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Text(
                      'Kemarin 20:15',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Deskripsi
          Text(
            'Pertukaran akses saling jaga telah disetujui secara timbal balik. Lokasi presisi aktif otomatis selama mode perjalanan malam dinyalakan.',
            style: GoogleFonts.nunito(
              fontSize: 13,
              height: 1.5,
              color: const Color(0xFF534C5A),
            ),
          ),
          const SizedBox(height: 14),

          // Chips Bawah (Timbal Balik + Verifikasi KTP)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4EEFC),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.sync_alt_rounded,
                      size: 14,
                      color: Color(0xFF5C2880),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Aktif Timbal Balik',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF5C2880),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF8F1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1E8256),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Terverifikasi KTP',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E8256),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // CARD 4: Baterai Rendah • Salsabila Rahma (18%)
  // ==========================================
  Widget _buildLowBatteryCard() {
    return _buildNotificationCardWrapper(
      accentColor: const Color(0xFFF59E0B), // Garis oranye kuning di tepi kiri
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Baterai Peringatan
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.battery_alert_rounded,
                  color: Color(0xFFB45309),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),

              // Judul & Waktu
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                            height: 1.3,
                          ),
                          children: const [
                            TextSpan(text: 'Baterai Rendah • '),
                            TextSpan(
                              text: 'Salsabila\nRahma (18%)',
                              style: TextStyle(
                                color: Color(0xFFB45309),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Text(
                      'Kemarin 19:30',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Deskripsi
          Text(
            'Daya ponsel Salsa berada di bawah 20% saat berada 2,4 km di luar kos. Mode hemat daya darurat telah disarankan otomatis.',
            style: GoogleFonts.nunito(
              fontSize: 13,
              height: 1.5,
              color: const Color(0xFF534C5A),
            ),
          ),
          const SizedBox(height: 14),

          // Aksi Bawah: Sisa Daya 18% & Ingatkan via WhatsApp
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF9C3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Sisa Daya 18%',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF854D0E),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              PressScale(
                child: GestureDetector(
                  onTap: () => _sendWhatsAppReminder('Salsabila Rahma'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDE8EE),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 14,
                          color: Color(0xFF9C274E),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Ingatkan via WhatsApp',
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF9C274E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // HELPER CARD CONTAINER WITH LEFT STRIPE ACCENT
  // ==========================================
  Widget _buildNotificationCardWrapper({
    required Widget child,
    required Color accentColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2C243B).withAlpha(10),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFF0ECF4),
          width: 1.2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Garis Aksen Vertikal di Kiri
              Container(
                width: 4.5,
                color: accentColor,
              ),
              // Konten Kartu
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // FOOTER (PRIVASI ENKRIPSI & PENGATURAN SUARA DARURAT)
  // ==========================================
  Widget _buildFooter() {
    return Column(
      children: [
        // Icon Gembok Terkunci
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Color(0xFFEFEBF3),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.lock_outline_rounded,
            size: 20,
            color: Color(0xFF6B6275),
          ),
        ),
        const SizedBox(height: 12),

        // Teks Informasi Enkripsi
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Riwayat terenkripsi & dihapus otomatis setelah 30\nhari demi menjaga privasi penuh Anda.',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 12.5,
              height: 1.45,
              color: const Color(0xFF6B6275),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Link Pengaturan Notifikasi & Suara Darurat
        PressScale(
          child: GestureDetector(
            onTap: _openSettings,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Pengaturan Notifikasi & Suara Darurat',
                  style: GoogleFonts.nunito(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.plum,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: AppColors.plum,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
