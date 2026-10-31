import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:amanjalan/core/theme/app_colors.dart';
import 'package:amanjalan/core/widgets/press_scale.dart';
import 'package:amanjalan/features/proteksi/models/route_models.dart';
import 'package:amanjalan/features/proteksi/widgets/compact_route_picker.dart';
import 'package:amanjalan/features/proteksi/widgets/mode_tabs.dart';
import 'package:amanjalan/features/proteksi/widgets/route_option_card.dart';
import 'package:amanjalan/features/proteksi/widgets/safety_detail.dart';

/// Panel bawah ala Gojek yang bisa dibuka / ditutup.
///
/// - TUTUP  : handle, tab moda, dua kartu rute kecil, tombol mulai (peta luas).
/// - BUKA   : plus detail lengkap (skor, indikator, titik di rute).
class ProteksiBottomPanel extends StatelessWidget {
  const ProteksiBottomPanel({
    super.key,
    required this.height,
    required this.expanded,
    required this.onToggle,
    required this.mode,
    required this.onModeChanged,
    required this.options,
    required this.selectedIndex,
    required this.onSelectRoute,
    required this.bottomInset,
    required this.onStart,
  });

  final double height;
  final bool expanded;
  final VoidCallback onToggle;
  final TransportMode mode;
  final ValueChanged<TransportMode> onModeChanged;
  final List<RouteOption> options;
  final int selectedIndex;
  final ValueChanged<int> onSelectRoute;
  final double bottomInset;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final selected = options[selectedIndex];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 28,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        children: [
          _header(),

          // Tab moda
          ModeTabs(selected: mode, onChanged: onModeChanged),

          // Isi (berubah sesuai buka / tutup)
          Expanded(
            child: ListView(
              physics: expanded
                  ? const ClampingScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16, expanded ? 14 : 12, 16, 12),
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 240),
                  child: expanded
                      ? _expandedBody(selected)
                      : CompactRoutePicker(
                          key: const ValueKey('compact'),
                          options: options,
                          selectedIndex: selectedIndex,
                          onSelect: onSelectRoute,
                        ),
                ),
              ],
            ),
          ),

          // Footer tetap
          _footer(),
        ],
      ),
    );
  }

  /// Handle + tombol "Detail / Tutup".
  Widget _header() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onToggle,
      onVerticalDragEnd: (d) {
        final v = d.primaryVelocity ?? 0;
        if (v < -200 && !expanded) onToggle();
        if (v > 200 && expanded) onToggle();
      },
      child: SizedBox(
        height: 38,
        width: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Positioned(
              right: 14,
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 4, 6, 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E9F7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      expanded ? 'Tutup' : 'Detail',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.plum,
                      ),
                    ),
                    AnimatedRotation(
                      turns: expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 250),
                      child: Icon(Icons.keyboard_arrow_up_rounded,
                          size: 18, color: AppColors.plum),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _expandedBody(RouteOption selected) {
    return Column(
      key: const ValueKey('expanded'),
      mainAxisSize: MainAxisSize.min,
      children: [
        RouteOptionCard(
          options: options,
          selectedIndex: selectedIndex,
          onSelect: onSelectRoute,
        ),
        const SizedBox(height: 14),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          child: KeyedSubtree(
            key: ValueKey('${selected.mode.name}_${selected.kind.name}'),
            child: SafetyDetail(option: selected),
          ),
        ),
      ],
    );
  }

  Widget _footer() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 10, 16, 12 + bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF3EEF5))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Info lokasi dibagikan (hanya saat dibuka)
          if (expanded) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: const Color(0xFFF3E9F7),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(Icons.share_location_rounded,
                      size: 18, color: AppColors.plum),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Lokasimu dibagikan ke tim keamanan',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.nunito(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  Text(
                    'Otomatis',
                    style: GoogleFonts.nunito(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.plum,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Tombol mulai
          PressScale(
            child: SizedBox(
              height: 56,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onStart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.plum,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Mulai Jalan & Kirim Lokasi',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.arrow_forward_rounded,
                          size: 19, color: AppColors.plum),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
