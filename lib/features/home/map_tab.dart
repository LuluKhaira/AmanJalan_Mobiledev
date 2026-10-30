import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:amanjalan/core/theme/app_colors.dart';
import 'package:amanjalan/core/widgets/press_scale.dart';
import 'package:amanjalan/core/widgets/app_header.dart';
import 'package:amanjalan/features/perjalanan/perjalanan_actions.dart';

// ==========================================
// PENGATURAN PETA
// ==========================================
const double _worldW = 1400;
const double _worldH = 1800;
const double _headerHeight = 70;
const double _boundaryMargin = 60;
const double _maxZoom = 3.5;

// Jalur jalan (koordinat dunia)
const _gridX = [120.0, 380.0, 600.0, 820.0, 1040.0, 1280.0];
const _gridY = [140.0, 420.0, 700.0, 920.0, 1140.0, 1380.0, 1660.0];

const _startPoint = Offset(600, 1140);
const _endPoint = Offset(1040, 700);
const _routeCenter = Offset(820, 920);

Path _safeRoutePath() {
  return Path()
    ..moveTo(600, 1140)
    ..lineTo(600, 960)
    ..quadraticBezierTo(600, 920, 640, 920)
    ..lineTo(780, 920)
    ..quadraticBezierTo(820, 920, 820, 880)
    ..lineTo(820, 740)
    ..quadraticBezierTo(820, 700, 860, 700)
    ..lineTo(1040, 700);
}

Path _fastRoutePath() {
  const pts = [
    Offset(600, 1140),
    Offset(690, 1040),
    Offset(760, 900),
    Offset(900, 800),
    Offset(1040, 700),
  ];
  final p = Path()..moveTo(pts.first.dx, pts.first.dy);
  for (var i = 1; i < pts.length - 1; i++) {
    final mid = Offset(
      (pts[i].dx + pts[i + 1].dx) / 2,
      (pts[i].dy + pts[i + 1].dy) / 2,
    );
    p.quadraticBezierTo(pts[i].dx, pts[i].dy, mid.dx, mid.dy);
  }
  p.lineTo(pts.last.dx, pts.last.dy);
  return p;
}

Path _lakePath() => Path()
  ..moveTo(1020, 0)
  ..lineTo(_worldW, 0)
  ..lineTo(_worldW, 360)
  ..cubicTo(1300, 400, 1180, 340, 1130, 250)
  ..cubicTo(1090, 180, 1040, 120, 1020, 0)
  ..close();

Path _pondPath() => Path()
  ..addOval(Rect.fromCenter(
      center: const Offset(250, 1560), width: 260, height: 170));

class _Poi {
  final Offset pos;
  final IconData icon;
  final Color color;
  final String label;

  const _Poi(this.pos, this.icon, this.color, this.label);
}

const _safeColor = Color(0xFF2E7D32);
const _warnColor = Color(0xFFEF6C00);

const _safePois = [
  _Poi(Offset(600, 1030), Icons.local_police_rounded, _safeColor, 'Pos Satpam'),
  _Poi(Offset(710, 920), Icons.videocam_rounded, _safeColor, 'CCTV'),
  _Poi(Offset(820, 810), Icons.groups_rounded, _safeColor, 'Ramai'),
  _Poi(Offset(930, 700), Icons.lightbulb_rounded, _safeColor, 'Lampu LED'),
];

const _fastPois = [
  _Poi(Offset(690, 1040), Icons.warning_amber_rounded, _warnColor, 'Gang sempit'),
  _Poi(Offset(765, 890), Icons.visibility_off_rounded, _warnColor, 'Minim penerangan'),
  _Poi(Offset(900, 800), Icons.person_off_rounded, _warnColor, 'Sepi saat malam'),
];

class MapTab extends StatefulWidget {
  final VoidCallback? onBackToHome;

  final VoidCallback? onProfileTap;

  const MapTab({super.key, this.onBackToHome, this.onProfileTap});

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> with TickerProviderStateMixin {
  int _selectedRoute = 0;

  // Animasi
  late final AnimationController _mapAnimationController;
  late final Animation<double> _routeAnimation;
  late final AnimationController _pulse;
  late final AnimationController _cam;

  // Kamera peta
  final TransformationController _tc = TransformationController();
  final DraggableScrollableController _sheet = DraggableScrollableController();
  final ValueNotifier<double> _sheetExtent = ValueNotifier<double>(0.45);

  Size _viewport = Size.zero;
  double _screenH = 0;
  bool _didFit = false;
  Offset _doubleTapPos = Offset.zero;

  double _camFromS = 1, _camFromX = 0, _camFromY = 0;
  double _camToS = 1, _camToX = 0, _camToY = 0;

  double get _minScale => math.max(
        math.max(_viewport.width / _worldW, _viewport.height / _worldH),
        0.3,
      );

  @override
  void initState() {
    super.initState();
    
    // INISIALISASI ANIMASI DULU
    _mapAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _routeAnimation = CurvedAnimation(
      parent: _mapAnimationController,
      curve: Curves.easeOutQuart,
    );
    
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _cam = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );

    // BARU JALANKAN ANIMASI & LISTENER
    _mapAnimationController.forward();
    _pulse.repeat();
    _cam.addListener(_onCamTick);
    _sheet.addListener(_onSheetChanged);
    
    // Memaksa peta untuk re-render saat di-zoom/pan
    _tc.addListener(_onCameraChanged);
  }

  @override
  void dispose() {
    _mapAnimationController.dispose();
    _pulse.dispose();
    _cam.dispose();
    _tc.dispose();
    _sheet.dispose();
    _sheetExtent.dispose();
    super.dispose();
  }

  void _onCameraChanged() {
    // Memicu repaint pada RoutePainter saat user menggeser/zoom peta
    setState(() {});
  }

  void _onSheetChanged() {
    if (_sheet.isAttached) _sheetExtent.value = _sheet.size;
  }

  void _selectRoute(int index) {
    if (_selectedRoute == index) return;
    HapticFeedback.selectionClick();
    setState(() => _selectedRoute = index);

    _mapAnimationController.reset();
    _mapAnimationController.forward();
  }

  // ==========================================
  // KAMERA
  // ==========================================
  Matrix4 _matrix(double s, double x, double y) =>
      Matrix4(s, 0, 0, 0, 0, s, 0, 0, 0, 0, 1, 0, x, y, 0, 1);

  List<double> _clampCamera(double s, double x, double y) {
    final cs = s.clamp(_minScale, _maxZoom).toDouble();

    double clampAxis(double v, double view, double world) {
      final lo = view - (world + _boundaryMargin) * cs;
      final hi = _boundaryMargin * cs;
      return lo <= hi ? v.clamp(lo, hi).toDouble() : (lo + hi) / 2;
    }

    return [
      cs,
      clampAxis(x, _viewport.width, _worldW),
      clampAxis(y, _viewport.height, _worldH),
    ];
  }

  void _moveCamera(double s, double x, double y, {bool animate = true}) {
    final t = _clampCamera(s, x, y);
    if (!animate) {
      _cam.stop();
      _tc.value = _matrix(t[0], t[1], t[2]);
      return;
    }
    final m = _tc.value.storage;
    _camFromS = m[0];
    _camFromX = m[12];
    _camFromY = m[13];
    _camToS = t[0];
    _camToX = t[1];
    _camToY = t[2];
    _cam.forward(from: 0);
  }

  void _onCamTick() {
    final t = Curves.easeOutCubic.transform(_cam.value);
    double l(double a, double b) => a + (b - a) * t;
    _tc.value = _matrix(
      l(_camFromS, _camToS),
      l(_camFromX, _camToX),
      l(_camFromY, _camToY),
    );
  }

  double _visibleHeight([double? extent]) {
    final e = extent ?? _sheetExtent.value;
    final h = _viewport.height - e * _screenH;
    return math.min(math.max(h, 160), _viewport.height);
  }

  void _zoomBy(double factor, {Offset? focal}) {
    HapticFeedback.selectionClick();
    final f = focal ?? Offset(_viewport.width / 2, _visibleHeight() / 2);
    final m = _tc.value.storage;
    final s = m[0], x = m[12], y = m[13];
    final newS = (s * factor).clamp(_minScale, _maxZoom).toDouble();
    final k = newS / s;
    _moveCamera(newS, f.dx - (f.dx - x) * k, f.dy - (f.dy - y) * k);
  }

  void _fitRoute({bool animate = true}) {
    if (_viewport.isEmpty) return;
    const bw = 600.0, bh = 600.0;
    final visH = _visibleHeight(math.min(_sheetExtent.value, 0.5));
    final s = math.min(
      (_viewport.width - 40) / bw,
      (visH - 40) / bh,
    );
    _moveCamera(
      s,
      _viewport.width / 2 - _routeCenter.dx * s,
      visH / 2 - _routeCenter.dy * s,
      animate: animate,
    );
  }

  // ==========================================
  // BUILD
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFAFC),
      body: LayoutBuilder(
        builder: (context, constraints) {
          _screenH = constraints.maxHeight;
          _viewport = Size(
            constraints.maxWidth,
            constraints.maxHeight - _headerHeight,
          );

          if (!_didFit) {
            _didFit = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _fitRoute(animate: false);
            });
          }

          return Stack(
            children: [
              // 1. PETA
              Positioned.fill(
                top: _headerHeight,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onDoubleTapDown: (d) => _doubleTapPos = d.localPosition,
                  onDoubleTap: () => _zoomBy(2.0, focal: _doubleTapPos),
                  child: InteractiveViewer(
                    transformationController: _tc,
                    constrained: false,
                    minScale: _minScale,
                    maxScale: _maxZoom,
                    boundaryMargin: const EdgeInsets.all(_boundaryMargin),
                    clipBehavior: Clip.hardEdge,
                    child: SizedBox(
                      width: _worldW,
                      height: _worldH,
                      child: Stack(
                        children: [
                          const RepaintBoundary(
                            child: CustomPaint(
                              size: Size(_worldW, _worldH),
                              painter: _BaseMapPainter(),
                            ),
                          ),
                          CustomPaint(
                            size: const Size(_worldW, _worldH),
                            painter: _RoutePainter(
                              selectedRoute: _selectedRoute,
                              draw: _routeAnimation,
                              pulse: _pulse,
                              tc: _tc,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 2. HEADER
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: const Color(0xFFFCFAFC),
                  child: SafeArea(
                    bottom: false,
                    child: AppHeader(
                      onProfileTap: widget.onProfileTap,
                    ),
                  ),
                ),
              ),

              // 3. TOMBOL KONTROL
              Positioned.fill(child: _buildMapControls()),

              // 4. KARTU BAWAH
              DraggableScrollableSheet(
                controller: _sheet,
                initialChildSize: 0.45,
                snap: true,
                snapSizes: const [0.35, 0.45, 0.85],
                minChildSize: 0.35,
                maxChildSize: 0.85,
                builder: (context, scrollController) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(15), 
                          blurRadius: 30, 
                          offset: const Offset(0, -10)
                        )
                      ],
                    ),
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Pilihan Rute Aman',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 8, height: 8,
                                    decoration: const BoxDecoration(
                                      color: Colors.green, 
                                      shape: BoxShape.circle
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Pantauan Live',
                                    style: GoogleFonts.nunito(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.green.shade800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Geser peta untuk menjelajah. Cubit atau ketuk dua kali untuk zoom.',
                          style: GoogleFonts.nunito(fontSize: 13, color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 24),
                        _buildRouteCard(
                          index: 0,
                          title: 'Rute Teraman',
                          subtitle: '14 Menit • 350 m',
                          badgeText: 'Paling Direkomendasikan',
                          icon: Icons.shield_rounded,
                          features: ['Penerangan LED terang', 'Banyak CCTV', 'Ramai aktivitas warga'],
                        ),
                        const SizedBox(height: 16),
                        _buildRouteCard(
                          index: 1,
                          title: 'Rute Tercepat',
                          subtitle: '10 Menit • 200 m',
                          badgeText: 'Kurang Aman',
                          icon: Icons.speed_rounded,
                          features: ['Gang sempit', 'Minim penerangan', 'Sepi saat malam'],
                        ),
                        const SizedBox(height: 28),
                        PressScale(
                          child: SizedBox(
                            height: 56,
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => pjStartFromMap(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.plum,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.play_circle_fill_rounded, size: 24),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Mulai Jalan & Kirim Lokasi',
                                    style: GoogleFonts.nunito(
                                      fontSize: 16, 
                                      fontWeight: FontWeight.w800
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMapControls() {
    return ValueListenableBuilder<double>(
      valueListenable: _sheetExtent,
      builder: (context, extent, _) {
        final hidden = extent > 0.6;
        return Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: EdgeInsets.only(right: 16, bottom: extent * _screenH + 14),
            child: IgnorePointer(
              ignoring: hidden,
              child: AnimatedOpacity(
                opacity: hidden ? 0 : 1,
                duration: const Duration(milliseconds: 200),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _mapButton(Icons.my_location_rounded, () {
                      HapticFeedback.selectionClick();
                      _fitRoute();
                    }),
                    const SizedBox(height: 12),
                    _mapButton(Icons.add_rounded, () => _zoomBy(1.6)),
                    const SizedBox(height: 8),
                    _mapButton(Icons.remove_rounded, () => _zoomBy(1 / 1.6)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _mapButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 3,
      shadowColor: const Color(0x334A1D5C),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 46,
          height: 46,
          child: Icon(icon, size: 24, color: AppColors.plum),
        ),
      ),
    );
  }

  Widget _buildRouteCard({
    required int index,
    required String title,
    required String subtitle,
    required String badgeText,
    required IconData icon,
    required List<String> features,
  }) {
    final isSelected = _selectedRoute == index;
    final isSafe = index == 0;

    return GestureDetector(
      onTap: () => _selectRoute(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.softPink.withAlpha(51) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.plum : const Color(0xFFF0EDF2),
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors.plum.withAlpha(20),
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
          ] : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSafe ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: isSafe ? Colors.green : Colors.orange,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? AppColors.plum : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? AppColors.plum : const Color(0xFFD5C9DC),
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isSafe ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                badgeText,
                style: GoogleFonts.nunito(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: isSafe ? Colors.green.shade800 : Colors.red.shade800,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...features.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        isSafe ? Icons.check_circle_rounded : Icons.info_rounded,
                        size: 18,
                        color: isSafe ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        f,
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

// =====================================================================
// LAPISAN DASAR PETA
// =====================================================================
class _BaseMapPainter extends CustomPainter {
  const _BaseMapPainter();

  static final Path _lake = _lakePath();
  static final Path _pond = _pondPath();
  static final Path _water = Path.combine(PathOperation.union, _lake, _pond);
  static final Path _dry = Path.combine(
    PathOperation.difference,
    Path()..addRect(const Rect.fromLTWH(0, 0, _worldW, _worldH)),
    _water,
  );

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, _worldW, _worldH),
      Paint()..color = const Color(0xFFF1F8F1),
    );

    _drawBlocks(canvas);

    canvas.drawPath(_water, Paint()..color = const Color(0xFFD4E8F0));
    canvas.drawPath(
      _water,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..color = const Color(0xFFBFDCE8),
    );

    canvas.save();
    canvas.clipPath(_dry);
    _drawRoads(canvas);
    canvas.restore();

    final alley = _fastRoutePath();
    canvas.drawPath(
      alley,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 15
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFD9D9D9),
    );
    canvas.drawPath(
      alley,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9
        ..strokeCap = StrokeCap.round
        ..color = Colors.white,
    );

    const road = Color(0xFF8E998E);
    _label(canvas, 'Jl. Jenderal Sudirman', const Offset(960, 1140), color: road);
    _label(canvas, 'Jl. Imam Bonjol', const Offset(480, 700), color: road);
    _label(canvas, 'Jl. Ahmad Yani', const Offset(700, 420), color: road);
    _label(canvas, 'Jl. Engku Putri', const Offset(380, 1000),
        angle: -math.pi / 2, color: road);
    _label(canvas, 'Jl. Raja Ali Haji', const Offset(1040, 1010),
        angle: -math.pi / 2, color: road);
    _label(canvas, 'Jl. Pramuka', const Offset(820, 1260),
        angle: -math.pi / 2, color: road);
    _label(canvas, 'Danau', const Offset(1230, 140),
        size: 20, color: const Color(0xFF7FA9BA));
  }

  void _drawRoads(Canvas canvas) {
    final majorX = {380.0, 600.0, 820.0, 1040.0};
    final majorY = {420.0, 700.0, 920.0, 1140.0, 1380.0};

    Paint outline(double w) => Paint()
      ..color = const Color(0xFFD4D4D4)
      ..strokeWidth = w
      ..strokeCap = StrokeCap.butt;
    Paint fill(double w) => Paint()
      ..color = Colors.white
      ..strokeWidth = w
      ..strokeCap = StrokeCap.butt;

    final lines = <MapEntry<Offset, Offset>>[];
    final widths = <double>[];

    for (final x in _gridX) {
      lines.add(MapEntry(Offset(x, 0), Offset(x, _worldH)));
      widths.add(majorX.contains(x) ? 22 : 12);
    }
    for (final y in _gridY) {
      lines.add(MapEntry(Offset(0, y), Offset(_worldW, y)));
      widths.add(majorY.contains(y) ? 22 : 12);
    }

    for (var i = 0; i < lines.length; i++) {
      canvas.drawLine(lines[i].key, lines[i].value, outline(widths[i] + 7));
    }
    for (var i = 0; i < lines.length; i++) {
      canvas.drawLine(lines[i].key, lines[i].value, fill(widths[i]));
    }
  }

  void _drawBlocks(Canvas canvas) {
    final xs = [0.0, ..._gridX, _worldW];
    final ys = [0.0, ..._gridY, _worldH];
    const gap = 30.0;
    const palette = [Color(0xFFE2E8E2), Color(0xFFE6E3DD), Color(0xFFDDE5E0)];
    final parkPaint = Paint()..color = const Color(0xFFD2E8D2);
    final treePaint = Paint()..color = const Color(0xFFBFDDBF);

    for (var i = 0; i < xs.length - 1; i++) {
      for (var j = 0; j < ys.length - 1; j++) {
        final left = xs[i] + (i == 0 ? 14 : gap);
        final right = xs[i + 1] - (i == xs.length - 2 ? 14 : gap);
        final top = ys[j] + (j == 0 ? 14 : gap);
        final bottom = ys[j + 1] - (j == ys.length - 2 ? 14 : gap);
        if (right - left < 40 || bottom - top < 40) continue;

        final rect = Rect.fromLTRB(left, top, right, bottom);
        final rng = math.Random(i * 31 + j * 17 + 5);
        final kind = rng.nextDouble();
        final color = palette[rng.nextInt(palette.length)];
        final paint = Paint()..color = color;

        if (kind < 0.16) {
          canvas.drawRRect(
              RRect.fromRectAndRadius(rect, const Radius.circular(22)),
              parkPaint);
          for (var t = 0; t < 7; t++) {
            canvas.drawCircle(
              Offset(
                rect.left + 20 + rng.nextDouble() * (rect.width - 40),
                rect.top + 20 + rng.nextDouble() * (rect.height - 40),
              ),
              8 + rng.nextDouble() * 6,
              treePaint,
            );
          }
        } else if (kind < 0.55) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
                rect.deflate(12), const Radius.circular(14)),
            paint,
          );
        } else {
          final horizontal = rng.nextBool();
          final a = horizontal
              ? Rect.fromLTRB(rect.left, rect.top, rect.center.dx - 8, rect.bottom)
              : Rect.fromLTRB(rect.left, rect.top, rect.right, rect.center.dy - 8);
          final b = horizontal
              ? Rect.fromLTRB(rect.center.dx + 8, rect.top, rect.right, rect.bottom)
              : Rect.fromLTRB(rect.left, rect.center.dy + 8, rect.right, rect.bottom);
          canvas.drawRRect(
              RRect.fromRectAndRadius(a.deflate(10), const Radius.circular(12)),
              paint);
          canvas.drawRRect(
              RRect.fromRectAndRadius(b.deflate(10), const Radius.circular(12)),
              paint);
        }
      }
    }
  }

  void _label(
    Canvas canvas,
    String text,
    Offset center, {
    double angle = 0,
    double size = 15,
    Color color = const Color(0xFF8E998E),
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: size,
          color: color,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BaseMapPainter oldDelegate) => false;
}

// =====================================================================
// LAPISAN RUTE
// =====================================================================
class _RoutePainter extends CustomPainter {
  final int selectedRoute;
  final Animation<double> draw;
  final Animation<double> pulse;
  final TransformationController tc;

  _RoutePainter({
    required this.selectedRoute,
    required this.draw,
    required this.pulse,
    required this.tc,
  }) : super(repaint: Listenable.merge([draw, pulse, tc]));

  @override
  void paint(Canvas canvas, Size size) {
    final zoom = tc.value.storage[0];
    final paths = [_safeRoutePath(), _fastRoutePath()];
    final colors = [AppColors.plum, Colors.orange.shade700];
    final other = 1 - selectedRoute;
    final color = colors[selectedRoute];

    canvas.drawPath(
      paths[other],
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = colors[other].withAlpha(80),
    );

    final casing = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 19
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = Colors.white;
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color;

    for (final metric in paths[selectedRoute].computeMetrics()) {
      final part = metric.extractPath(0, metric.length * draw.value);
      canvas.drawPath(part, casing);
      canvas.drawPath(part, line);
    }

    final pois = selectedRoute == 0 ? _safePois : _fastPois;
    final poiOpacity = ((draw.value - 0.6) / 0.4).clamp(0.0, 1.0);
    if (poiOpacity > 0) {
      for (final poi in pois) {
        _drawPoi(canvas, poi, poiOpacity, zoom);
      }
    }

    final p = pulse.value;
    canvas.drawCircle(
      _startPoint,
      26 + 30 * p,
      Paint()..color = color.withAlpha((90 * (1 - p)).round()),
    );
    canvas.drawCircle(_startPoint, 24, Paint()..color = Colors.white);
    canvas.drawCircle(_startPoint, 19, Paint()..color = color);
    canvas.drawCircle(_startPoint, 8, Paint()..color = Colors.white);

    if (draw.value > 0.8) {
      final endColor =
          selectedRoute == 0 ? AppColors.textDark : Colors.orange.shade900;
      canvas.save();
      canvas.translate(_endPoint.dx, _endPoint.dy);
      canvas.scale(1.5);
      canvas.drawCircle(Offset.zero, 20, Paint()..color = Colors.black.withAlpha(30));
      final pin = Path()
        ..moveTo(0, 12)
        ..quadraticBezierTo(-16, -12, -10, -20)
        ..quadraticBezierTo(0, -30, 10, -20)
        ..quadraticBezierTo(16, -12, 0, 12);
      canvas.drawPath(pin, Paint()..color = endColor);
      canvas.drawCircle(const Offset(0, -15), 6, Paint()..color = Colors.white);
      canvas.restore();
    }
  }

  void _drawPoi(Canvas canvas, _Poi poi, double opacity, double zoom) {
    final a = (255 * opacity).round();

    canvas.drawCircle(
      poi.pos + const Offset(0, 3),
      24,
      Paint()..color = Colors.black.withAlpha((40 * opacity).round()),
    );
    canvas.drawCircle(poi.pos, 22, Paint()..color = Colors.white.withAlpha(a));
    canvas.drawCircle(
      poi.pos,
      22,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..color = poi.color.withAlpha(a),
    );
    _paintIcon(canvas, poi.icon, poi.pos, 24, poi.color.withAlpha(a));

    if (zoom >= 0.95) {
      final tp = TextPainter(
        text: TextSpan(
          text: poi.label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: poi.color.withAlpha(a),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final center = poi.pos + const Offset(0, 44);
      final pill = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center,
          width: tp.width + 18,
          height: tp.height + 8,
        ),
        const Radius.circular(12),
      );
      canvas.drawRRect(pill, Paint()..color = Colors.white.withAlpha(a));
      tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
    }
  }

  void _paintIcon(
      Canvas canvas, IconData icon, Offset center, double size, Color color) {
    final tp = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: size,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: color,
        ),
      ),
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _RoutePainter oldDelegate) =>
      oldDelegate.selectedRoute != selectedRoute;
}