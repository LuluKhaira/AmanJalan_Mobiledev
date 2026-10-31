import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:amanjalan/core/theme/app_colors.dart';
import 'package:amanjalan/features/proteksi/models/route_models.dart';

/// Tab moda transportasi: Motor | Mobil | Bus | Jalan Kaki.
class ModeTabs extends StatelessWidget {
  const ModeTabs({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final TransportMode selected;
  final ValueChanged<TransportMode> onChanged;

  @override
  Widget build(BuildContext context) {
    const modes = TransportMode.values;
    final n = modes.length;
    final idx = modes.indexOf(selected);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            for (final m in modes)
              Expanded(
                child: InkWell(
                  onTap: () => onChanged(m),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            m.icon,
                            key: ValueKey('${m.name}_${m == selected}'),
                            size: m == selected ? 26 : 24,
                            color: m == selected
                                ? AppColors.plum
                                : Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          m.label,
                          style: GoogleFonts.nunito(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: m == selected
                                ? AppColors.plum
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
        SizedBox(
          height: 3,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(height: 1.5, color: const Color(0xFFF0EDF2)),
              ),
              AnimatedAlign(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                alignment: Alignment(-1 + 2 * idx / (n - 1), 0),
                child: FractionallySizedBox(
                  widthFactor: 1 / n,
                  child: Container(
                    height: 3,
                    margin: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppColors.plum,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
