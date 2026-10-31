import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:amanjalan/features/perjalanan/perjalanan_actions.dart';
import 'package:amanjalan/features/proteksi/data/proteksi_dummy_data.dart';
import 'package:amanjalan/features/proteksi/map/base_map_painter.dart';
import 'package:amanjalan/features/proteksi/map/map_camera.dart';
import 'package:amanjalan/features/proteksi/map/map_constants.dart';
import 'package:amanjalan/features/proteksi/map/route_painter.dart';
import 'package:amanjalan/features/proteksi/models/route_models.dart';
import 'package:amanjalan/features/proteksi/screens/destination_search_screen.dart';
import 'package:amanjalan/features/proteksi/widgets/bottom_panel.dart';
import 'package:amanjalan/features/proteksi/widgets/from_to_card.dart';
import 'package:amanjalan/features/proteksi/widgets/map_action_buttons.dart';

/// Tab Proteksi: peta layar penuh + panel pilihan rute ala Gojek.
///
/// Panel bawah punya 2 kondisi: TUTUP (kecil, peta luas) dan BUKA (detail).
///
/// [bottomInset] = ruang tambahan di bawah panel. Default 0 karena navbar
/// berada di luar body. Isi (misalnya 96) hanya kalau navbar kamu menimpa
/// halaman ini (extendBody: true).
class ProteksiTab extends StatefulWidget {
  const ProteksiTab({
    super.key,
    this.onBackToHome,
    this.onProfileTap,
    this.bottomInset = 0,
  });

  final VoidCallback? onBackToHome;
  final VoidCallback? onProfileTap;
  final double bottomInset;

  @override
  State<ProteksiTab> createState() => _ProteksiTabState();
}

class _ProteksiTabState extends State<ProteksiTab>
    with TickerProviderStateMixin {
  // Animasi rute
  late final AnimationController _drawCtrl;
  late final Animation<double> _drawAnim;
  late final AnimationController _pulse;

  // Kamera
  late final MapCamera _camera;

  // State pilihan
  TransportMode _mode = TransportMode.motor;
  int _routeIndex = 0; // 0 = teraman, 1 = tercepat
  bool _expanded = false;
  Place _destination = kPlaces.first;

  // Layout
  Size _viewport = Size.zero;
  double _topOverlay = 0;
  bool _didFit = false;
  Offset _doubleTapPos = Offset.zero;

  @override
  void initState() {
    super.initState();
    _camera = MapCamera(vsync: this);

    _drawCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _drawAnim = CurvedAnimation(parent: _drawCtrl, curve: Curves.easeOutQuart);
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _drawCtrl.forward();
    _pulse.repeat();
  }

  @override
  void dispose() {
    _drawCtrl.dispose();
    _pulse.dispose();
    _camera.dispose();
    super.dispose();
  }

  // ==========================================
  // AKSI
  // ==========================================
  void _replayRoute() {
    _drawCtrl.reset();
    _drawCtrl.forward();
  }

  void _changeMode(TransportMode m) {
    if (m == _mode) return;
    HapticFeedback.selectionClick();
    setState(() => _mode = m);
    _replayRoute();
  }

  void _selectRoute(int i) {
    if (i == _routeIndex) return;
    HapticFeedback.selectionClick();
    setState(() => _routeIndex = i);
    _replayRoute();
  }

  void _togglePanel() {
    HapticFeedback.selectionClick();
    setState(() => _expanded = !_expanded);
  }

  void _fit({bool animate = true}) {
    _camera.fitRoute(
      animate: animate,
      topOverlay: _topOverlay,
      bottomOverlay: 64,
    );
  }

  Future<void> _openSearch() async {
    final picked = await Navigator.of(context).push<Place>(
      MaterialPageRoute(
        builder: (_) => DestinationSearchScreen(current: _destination),
      ),
    );
    if (picked != null && mounted) {
      setState(() => _destination = picked);
      _replayRoute();
    }
  }

  void _goBack() {
    HapticFeedback.selectionClick();
    final cb = widget.onBackToHome;
    if (cb != null) {
      cb();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  // ==========================================
  // BUILD
  // ==========================================
  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final options = kRoutesByMode[_mode]!;
    final selected = options[_routeIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8F1),
      body: LayoutBuilder(
        builder: (context, c) {
          final h = c.maxHeight;
          final w = c.maxWidth;
          final inset = widget.bottomInset;

          // TUTUP: handle + tab moda + 2 kartu kecil + tombol (sekitar 276)
          final collapsedH = math.min(276.0 + inset, h * 0.5);
          // BUKA: detail lengkap
          final expandedH =
              math.max(math.min(h * 0.8, 660.0 + inset), collapsedH + 120);
          final panelH = _expanded ? expandedH : collapsedH;

          _topOverlay = topInset + 12 + 112;

          // Area peta yang terlihat = di atas panel
          final vp = Size(w, h - panelH);
          if (vp != _viewport) {
            _viewport = vp;
            _camera.viewport = vp;
            final animate = _didFit;
            _didFit = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _fit(animate: animate);
            });
          }

          const anim = Duration(milliseconds: 300);

          return Stack(
            children: [
              // 1. PETA (layar penuh)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onDoubleTapDown: (d) => _doubleTapPos = d.localPosition,
                  onDoubleTap: () =>
                      _camera.zoomBy(2.0, focal: _doubleTapPos),
                  child: InteractiveViewer(
                    transformationController: _camera.tc,
                    constrained: false,
                    minScale: _camera.minScale,
                    maxScale: kMaxZoom,
                    boundaryMargin: const EdgeInsets.all(kBoundaryMargin),
                    clipBehavior: Clip.hardEdge,
                    child: SizedBox(
                      width: kWorldW,
                      height: kWorldH,
                      child: Stack(
                        children: [
                          const RepaintBoundary(
                            child: CustomPaint(
                              size: Size(kWorldW, kWorldH),
                              painter: BaseMapPainter(),
                            ),
                          ),
                          CustomPaint(
                            size: const Size(kWorldW, kWorldH),
                            painter: RoutePainter(
                              option: selected,
                              destinationName: _destination.name,
                              draw: _drawAnim,
                              pulse: _pulse,
                              tc: _camera.tc,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 2. KARTU DARI -> TUJUAN
              Positioned(
                top: topInset + 12,
                left: 16,
                right: 16,
                child: FromToCard(
                  destinationName: _destination.name,
                  onTap: _openSearch,
                ),
              ),

              // 3. TOMBOL KIRI BAWAH PETA: kembali
              AnimatedPositioned(
                duration: anim,
                curve: Curves.easeOutCubic,
                left: 16,
                bottom: panelH + 14,
                child: MapRoundButton(
                  icon: Icons.arrow_back_rounded,
                  onTap: _goBack,
                ),
              ),

              // 4. PILL TENGAH: ubah tujuan
              AnimatedPositioned(
                duration: anim,
                curve: Curves.easeOutCubic,
                left: 0,
                right: 0,
                bottom: panelH + 14,
                child: IgnorePointer(
                  ignoring: _expanded,
                  child: AnimatedOpacity(
                    opacity: _expanded ? 0 : 1,
                    duration: const Duration(milliseconds: 200),
                    child: Center(
                      child: ChangeDestinationPill(onTap: _openSearch),
                    ),
                  ),
                ),
              ),

              // 5. TOMBOL KANAN BAWAH: lokasi + zoom
              AnimatedPositioned(
                duration: anim,
                curve: Curves.easeOutCubic,
                right: 16,
                bottom: panelH + 14,
                child: IgnorePointer(
                  ignoring: _expanded,
                  child: AnimatedOpacity(
                    opacity: _expanded ? 0 : 1,
                    duration: const Duration(milliseconds: 200),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MapRoundButton(
                          icon: Icons.my_location_rounded,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            _fit();
                          },
                        ),
                        const SizedBox(height: 12),
                        MapRoundButton(
                          icon: Icons.add_rounded,
                          onTap: () => _camera.zoomBy(1.6),
                        ),
                        const SizedBox(height: 8),
                        MapRoundButton(
                          icon: Icons.remove_rounded,
                          onTap: () => _camera.zoomBy(1 / 1.6),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 6. PANEL BAWAH
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: ProteksiBottomPanel(
                  height: panelH,
                  expanded: _expanded,
                  onToggle: _togglePanel,
                  mode: _mode,
                  onModeChanged: _changeMode,
                  options: options,
                  selectedIndex: _routeIndex,
                  onSelectRoute: _selectRoute,
                  bottomInset: inset,
                  onStart: () => pjStartFromMap(context),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
