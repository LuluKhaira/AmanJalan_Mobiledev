import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:amanjalan/core/theme/app_colors.dart';
import 'package:amanjalan/features/proteksi/data/proteksi_dummy_data.dart';
import 'package:amanjalan/features/proteksi/models/route_models.dart';

/// Layar cari tujuan ala Gojek ("Mau ke mana hari ini?").
/// Mengembalikan [Place] lewat Navigator.pop saat salah satu dipilih.
class DestinationSearchScreen extends StatefulWidget {
  const DestinationSearchScreen({super.key, required this.current});

  final Place current;

  @override
  State<DestinationSearchScreen> createState() =>
      _DestinationSearchScreenState();
}

class _DestinationSearchScreenState extends State<DestinationSearchScreen> {
  final TextEditingController _ctrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  List<Place> get _results {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return kPlaces;
    return kPlaces
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.address.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    color: AppColors.textDark,
                  ),
                  Text(
                    'Mau ke mana hari ini?',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Kartu dari -> tujuan
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F4F8),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.my_location_rounded,
                          size: 22, color: AppColors.plum),
                      for (var i = 0; i < 3; i++)
                        Container(
                          width: 3,
                          height: 3,
                          margin: const EdgeInsets.symmetric(vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                            shape: BoxShape.circle,
                          ),
                        ),
                      Icon(Icons.location_on_rounded,
                          size: 22, color: Colors.orange.shade700),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Posisi Anda (lokasi saat ini)',
                          style: GoogleFonts.nunito(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const Divider(height: 16, color: Color(0xFFE9E2ED)),
                        TextField(
                          controller: _ctrl,
                          autofocus: true,
                          textInputAction: TextInputAction.search,
                          onChanged: (v) => setState(() => _query = v),
                          style: GoogleFonts.nunito(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 4),
                            hintText: 'Cari lokasi tujuan',
                            hintStyle: GoogleFonts.nunito(
                              fontSize: 15,
                              color: Colors.grey.shade500,
                            ),
                            suffixIcon: _query.isEmpty
                                ? null
                                : GestureDetector(
                                    onTap: () {
                                      _ctrl.clear();
                                      setState(() => _query = '');
                                    },
                                    child: const Icon(Icons.cancel_rounded,
                                        size: 20, color: Colors.grey),
                                  ),
                            suffixIconConstraints:
                                const BoxConstraints(minWidth: 28, minHeight: 28),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Pilih lewat peta
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.map_rounded, size: 18, color: AppColors.plum),
                label: Text(
                  'Pilih lewat peta',
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFE6DDEB)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1, color: Color(0xFFF0EDF2)),

            // Hasil
            Expanded(
              child: results.isEmpty
                  ? Center(
                      child: Text(
                        'Tempat tidak ditemukan',
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMuted,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.only(bottom: 24),
                      itemCount: results.length,
                      separatorBuilder: (_, __) => const Divider(
                          height: 1, indent: 72, color: Color(0xFFF0EDF2)),
                      itemBuilder: (context, i) {
                        final p = results[i];
                        final isCurrent = p.name == widget.current.name;
                        return InkWell(
                          onTap: () => Navigator.of(context).pop(p),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: isCurrent
                                        ? AppColors.plum.withAlpha(25)
                                        : const Color(0xFFF2EFF4),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.location_on_rounded,
                                    size: 22,
                                    color: isCurrent
                                        ? AppColors.plum
                                        : Colors.grey.shade500,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        p.name,
                                        style: GoogleFonts.poppins(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        p.address,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.nunito(
                                          fontSize: 12.5,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  p.distance,
                                  style: GoogleFonts.nunito(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
