import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gtc6/core/theme/colors.dart';

// ═══════════════════════════════════════════════════════════════════
// MODELS
// ═══════════════════════════════════════════════════════════════════

enum WebType { circular, chaotic, funnel }

class WebThread {
  final Offset p1;
  final Offset p2;
  bool broken;
  double repairProgress; // 0.0 = fully broken, 1.0 = fully repaired

  WebThread({
    required this.p1,
    required this.p2,
    this.broken = false,
    this.repairProgress = 1.0,
  });

  /// Midpoint of this thread
  Offset get midpoint => Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);

  /// Length of the thread
  double get length {
    final dx = p2.dx - p1.dx;
    final dy = p2.dy - p1.dy;
    return sqrt(dx * dx + dy * dy);
  }
}

enum SpiderState { idle, walking, repairing }

class Spider {
  Offset position;
  Offset target;
  double angle;
  final double size;
  final Color color;
  SpiderState state;
  WebThread? repairTarget;
  double walkSpeed;

  // Leg animation
  double legPhase;

  Spider({
    required this.position,
    required this.target,
    required this.size,
    required this.color,
    this.state = SpiderState.idle,
    this.repairTarget,
    this.angle = 0.0,
    this.legPhase = 0.0,
    double? walkSpeed,
  }) : walkSpeed = walkSpeed ?? (1.5 + Random().nextDouble() * 1.0);

  void update() {
    final dx = target.dx - position.dx;
    final dy = target.dy - position.dy;
    final dist = sqrt(dx * dx + dy * dy);

    if (dist > 4.0) {
      angle = atan2(dy, dx);
      position += Offset((dx / dist) * walkSpeed, (dy / dist) * walkSpeed);
      legPhase += 0.25;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════
// HELPERS
// ═══════════════════════════════════════════════════════════════════

/// Returns true if segment (p1→p2) and segment (p3→p4) intersect.
bool _segmentsIntersect(Offset p1, Offset p2, Offset p3, Offset p4) {
  final d1 = p2 - p1;
  final d2 = p4 - p3;
  final cross = d1.dx * d2.dy - d1.dy * d2.dx;
  if (cross.abs() < 1e-9) return false;

  final t = ((p3.dx - p1.dx) * d2.dy - (p3.dy - p1.dy) * d2.dx) / cross;
  final u = ((p3.dx - p1.dx) * d1.dy - (p3.dy - p1.dy) * d1.dx) / cross;
  return t >= 0 && t <= 1 && u >= 0 && u <= 1;
}

/// Distance from point p to segment (a→b).
double _pointToSegmentDist(Offset p, Offset a, Offset b) {
  final ab = b - a;
  final len2 = ab.dx * ab.dx + ab.dy * ab.dy;
  if (len2 == 0) return (p - a).distance;
  final t = ((p - a).dx * ab.dx + (p - a).dy * ab.dy) / len2;
  final clamped = t.clamp(0.0, 1.0);
  final proj = a + Offset(ab.dx * clamped, ab.dy * clamped);
  return (p - proj).distance;
}

// ═══════════════════════════════════════════════════════════════════
// CANVAS WIDGET
// ═══════════════════════════════════════════════════════════════════

class SpidersCanvas extends StatefulWidget {
  const SpidersCanvas({super.key});

  @override
  State<SpidersCanvas> createState() => _SpidersCanvasState();
}

class _SpidersCanvasState extends State<SpidersCanvas>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<WebThread> _threads = [];
  late Spider _spider;
  final Random _random = Random();

  WebType _currentType = WebType.circular;
  Offset _webCenter = Offset.zero;
  Size _canvasSize = Size.zero;

  // For swipe destruction
  Offset? _lastFingerPos;

  // Wobble effects for broken threads
  double _animTime = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_tick);
    _controller.repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initWeb();
    });
  }

  void _initWeb() {
    final size = MediaQuery.of(context).size;
    _canvasSize = Size(size.width, size.height * 0.72);
    _webCenter = Offset(_canvasSize.width / 2, _canvasSize.height / 2 - 30);

    _buildWeb(_currentType);

    _spider = Spider(
      position: _webCenter + const Offset(0, -80),
      target: _webCenter,
      size: 20,
      color: SensoryColors.primary,
    );
    setState(() {});
  }

  // ─── WEB BUILDERS ────────────────────────────────────────────────

  void _buildWeb(WebType type) {
    _threads.clear();
    switch (type) {
      case WebType.circular:
        _buildCircularWeb();
        break;
      case WebType.chaotic:
        _buildChaoticWeb();
        break;
      case WebType.funnel:
        _buildFunnelWeb();
        break;
    }
  }

  /// Classic garden spider web: spokes + concentric rings.
  void _buildCircularWeb() {
    const int spokes = 12;
    const int rings = 6;
    final double maxRadius = min(_canvasSize.width, _canvasSize.height) * 0.42;

    final List<List<Offset>> spokePoints = [];
    for (int s = 0; s < spokes; s++) {
      final double angle = (s / spokes) * 2 * pi;
      final List<Offset> points = [_webCenter];
      for (int r = 1; r <= rings; r++) {
        final double radius = (r / rings) * maxRadius;
        points.add(_webCenter + Offset(cos(angle) * radius, sin(angle) * radius));
      }
      spokePoints.add(points);
      // Add spoke threads
      for (int i = 0; i < points.length - 1; i++) {
        _threads.add(WebThread(p1: points[i], p2: points[i + 1]));
      }
    }

    // Concentric ring threads connecting spoke points at each radius level
    for (int r = 1; r <= rings; r++) {
      for (int s = 0; s < spokes; s++) {
        final Offset a = spokePoints[s][r];
        final Offset b = spokePoints[(s + 1) % spokes][r];
        _threads.add(WebThread(p1: a, p2: b));
      }
    }
  }

  /// House spider chaotic web: random nodes connected by threads.
  void _buildChaoticWeb() {
    final double w = _canvasSize.width;
    final double h = _canvasSize.height;
    final int nodeCount = 14;

    final List<Offset> nodes = [_webCenter];
    for (int i = 0; i < nodeCount - 1; i++) {
      nodes.add(Offset(
        w * 0.08 + _random.nextDouble() * (w * 0.84),
        h * 0.05 + _random.nextDouble() * (h * 0.88),
      ));
    }

    // Connect each node to 2-3 nearby others
    for (int i = 0; i < nodes.length; i++) {
      final List<int> sorted = List.generate(nodes.length, (j) => j)
        ..remove(i)
        ..sort((a, b) => (nodes[i] - nodes[a]).distance.compareTo(
              (nodes[i] - nodes[b]).distance,
            ));
      final int connections = 2 + _random.nextInt(2);
      for (int k = 0; k < connections && k < sorted.length; k++) {
        final int j = sorted[k];
        // Avoid duplicates
        final bool exists = _threads.any((t) =>
            (t.p1 == nodes[i] && t.p2 == nodes[j]) ||
            (t.p1 == nodes[j] && t.p2 == nodes[i]));
        if (!exists) {
          _threads.add(WebThread(p1: nodes[i], p2: nodes[j]));
        }
      }
    }

    // Add anchor threads to edges
    for (final node in nodes.take(6)) {
      final edges = [
        Offset(node.dx, 0),
        Offset(node.dx, h),
        Offset(0, node.dy),
        Offset(w, node.dy),
      ];
      final edge = edges[_random.nextInt(edges.length)];
      _threads.add(WebThread(p1: node, p2: edge));
    }
  }

  /// Funnel web: triangular layers converging to center.
  void _buildFunnelWeb() {
    final double w = _canvasSize.width;
    final double h = _canvasSize.height;
    const int layers = 5;
    const int cols = 8;

    final List<List<Offset>> grid = [];
    for (int layer = 0; layer < layers; layer++) {
      final double t = layer / (layers - 1); // 0 = top, 1 = center
      final double y = h * 0.08 + t * (h * 0.55);
      final double xStart = w * 0.05 + t * (w * 0.35);
      final double xEnd = w * 0.95 - t * (w * 0.35);

      final List<Offset> row = [];
      for (int col = 0; col < cols; col++) {
        final double x = xStart + (col / (cols - 1)) * (xEnd - xStart);
        row.add(Offset(x, y));
      }
      grid.add(row);

      // Horizontal threads within row
      for (int c = 0; c < cols - 1; c++) {
        _threads.add(WebThread(p1: row[c], p2: row[c + 1]));
      }
    }

    // Vertical/diagonal threads between layers
    for (int layer = 0; layer < layers - 1; layer++) {
      for (int c = 0; c < cols; c++) {
        _threads.add(WebThread(p1: grid[layer][c], p2: grid[layer + 1][c]));
        if (c < cols - 1) {
          _threads.add(WebThread(p1: grid[layer][c], p2: grid[layer + 1][c + 1]));
        }
      }
    }

    // Funnel tube (vertical lines from bottom layer to center bottom)
    final List<Offset> bottomRow = grid.last;
    final Offset tubeBottom = Offset(_webCenter.dx, h * 0.92);
    for (int c = 1; c < cols - 1; c += 2) {
      _threads.add(WebThread(p1: bottomRow[c], p2: tubeBottom));
    }
  }

  // ─── GAME TICK ───────────────────────────────────────────────────

  void _tick() {
    if (!mounted) return;
    _animTime += 0.05;

    setState(() {
      _updateSpider();
    });
  }

  void _updateSpider() {
    switch (_spider.state) {
      case SpiderState.idle:
        // Find nearest broken thread
        WebThread? broken = _findNearestBroken();
        if (broken != null) {
          _spider.repairTarget = broken;
          _spider.target = broken.midpoint;
          _spider.state = SpiderState.walking;
        } else {
          // Wander slowly along web nodes
          if ((_spider.position - _spider.target).distance < 10) {
            _spider.target = _randomWebPoint();
          }
          _spider.update();
        }
        break;

      case SpiderState.walking:
        final broken = _spider.repairTarget;
        if (broken == null || !broken.broken) {
          _spider.state = SpiderState.idle;
          break;
        }
        _spider.target = broken.midpoint;
        _spider.update();

        if ((_spider.position - broken.midpoint).distance < 12) {
          _spider.state = SpiderState.repairing;
        }
        break;

      case SpiderState.repairing:
        final broken = _spider.repairTarget;
        if (broken == null) {
          _spider.state = SpiderState.idle;
          break;
        }
        // Animate the repair
        broken.repairProgress = (broken.repairProgress + 0.012).clamp(0.0, 1.0);
        if (broken.repairProgress >= 1.0) {
          broken.broken = false;
          broken.repairProgress = 1.0;
          _spider.repairTarget = null;
          _spider.state = SpiderState.idle;
          HapticFeedback.selectionClick();
        }
        break;
    }
  }

  WebThread? _findNearestBroken() {
    WebThread? nearest;
    double minDist = double.infinity;
    for (final t in _threads) {
      if (t.broken) {
        final d = (t.midpoint - _spider.position).distance;
        if (d < minDist) {
          minDist = d;
          nearest = t;
        }
      }
    }
    return nearest;
  }

  Offset _randomWebPoint() {
    if (_threads.isEmpty) return _webCenter;
    final t = _threads[_random.nextInt(_threads.length)];
    return _random.nextBool() ? t.p1 : t.p2;
  }

  // ─── GESTURE HANDLING ────────────────────────────────────────────

  void _handlePanStart(DragStartDetails d) {
    _lastFingerPos = d.localPosition;
  }

  void _handlePanUpdate(DragUpdateDetails d) {
    final current = d.localPosition;
    final last = _lastFingerPos;
    if (last == null) {
      _lastFingerPos = current;
      return;
    }

    // Check every thread for intersection with swipe segment
    bool broke = false;
    for (final thread in _threads) {
      if (thread.broken) continue;
      if (_segmentsIntersect(last, current, thread.p1, thread.p2) ||
          _pointToSegmentDist(current, thread.p1, thread.p2) < 14) {
        thread.broken = true;
        thread.repairProgress = 0.0;
        broke = true;
      }
    }
    if (broke) HapticFeedback.lightImpact();

    _lastFingerPos = current;
  }

  void _handlePanEnd(DragEndDetails d) {
    _lastFingerPos = null;
  }

  // ─── UI ACTIONS ──────────────────────────────────────────────────

  void _selectWebType(WebType type) {
    setState(() {
      _currentType = type;
      _buildWeb(type);
      // Reset spider
      _spider.state = SpiderState.idle;
      _spider.repairTarget = null;
      _spider.position = _webCenter + const Offset(0, -80);
      _spider.target = _webCenter;
    });
    HapticFeedback.mediumImpact();
  }

  void _destroyAll() {
    setState(() {
      for (final t in _threads) {
        t.broken = true;
        t.repairProgress = 0.0;
      }
    });
    HapticFeedback.heavyImpact();
  }

  void _resetWeb() {
    setState(() {
      _buildWeb(_currentType);
      _spider.state = SpiderState.idle;
      _spider.repairTarget = null;
      _spider.position = _webCenter + const Offset(0, -80);
      _spider.target = _webCenter;
    });
    HapticFeedback.heavyImpact();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ─── BUILD ───────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Column(
      children: [
        // ── TYPE SELECTOR ──
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
          child: Row(
            children: [
              Expanded(
                child: _WebTypeButton(
                  label: '🕸 Circular',
                  selected: _currentType == WebType.circular,
                  onTap: () => _selectWebType(WebType.circular),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _WebTypeButton(
                  label: '🕷 Caótica',
                  selected: _currentType == WebType.chaotic,
                  onTap: () => _selectWebType(WebType.chaotic),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _WebTypeButton(
                  label: '🔻 Embudo',
                  selected: _currentType == WebType.funnel,
                  onTap: () => _selectWebType(WebType.funnel),
                ),
              ),
            ],
          ),
        ),

        // ── CANVAS ──
        Expanded(
          child: GestureDetector(
            onPanStart: _handlePanStart,
            onPanUpdate: _handlePanUpdate,
            onPanEnd: _handlePanEnd,
            child: Container(
              color: Colors.transparent,
              child: CustomPaint(
                size: Size.infinite,
                painter: SpiderWebPainter(
                  threads: _threads,
                  spider: _spider,
                  isDark: isDark,
                  animTime: _animTime,
                ),
              ),
            ),
          ),
        ),

        // ── HINT + ACTIONS ──
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '✋ Desliza el dedo para romper los hilos. '
                  'La araña los reparará.',
                  style: TextStyle(
                    color: theme.textTheme.bodySmall?.color,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Destruir toda la tela',
                icon: const Icon(Icons.flash_on_rounded, size: 20),
                color: Colors.orange,
                onPressed: _destroyAll,
              ),
              IconButton(
                tooltip: 'Reiniciar',
                icon: const Icon(Icons.refresh_rounded, size: 20),
                color: theme.colorScheme.onSurface,
                onPressed: _resetWeb,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// TYPE BUTTON WIDGET
// ═══════════════════════════════════════════════════════════════════

class _WebTypeButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _WebTypeButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? SensoryColors.primary.withValues(alpha: 0.18)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected
                ? SensoryColors.primary
                : SensoryColors.primary.withValues(alpha: 0.3),
            width: selected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            color: selected
                ? SensoryColors.primary
                : Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// PAINTER
// ═══════════════════════════════════════════════════════════════════

class SpiderWebPainter extends CustomPainter {
  final List<WebThread> threads;
  final Spider spider;
  final bool isDark;
  final double animTime;

  SpiderWebPainter({
    required this.threads,
    required this.spider,
    required this.isDark,
    required this.animTime,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawThreads(canvas);
    _drawSilk(canvas);
    _drawSpider(canvas);
  }

  void _drawThreads(Canvas canvas) {
    final Color baseColor = isDark
        ? Colors.white.withValues(alpha: 0.75)
        : Colors.blueGrey.shade900.withValues(alpha: 0.7);

    final Paint intactPaint = Paint()
      ..color = baseColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Paint repairingPaint = Paint()
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (final thread in threads) {
      if (thread.broken) {
        if (thread.repairProgress <= 0.01) {
          // Fully broken – skip drawing or show small broken ends
          _drawBrokenEnds(canvas, thread);
        } else {
          // Partially repaired – draw progress from p1
          final Offset partial = Offset(
            thread.p1.dx + (thread.p2.dx - thread.p1.dx) * thread.repairProgress,
            thread.p1.dy + (thread.p2.dy - thread.p1.dy) * thread.repairProgress,
          );
          repairingPaint.color = SensoryColors.primary.withValues(
            alpha: 0.5 + thread.repairProgress * 0.5,
          );
          canvas.drawLine(thread.p1, partial, repairingPaint);
          _drawBrokenEnds(canvas, thread);
        }
      } else {
        // Add subtle droop to horizontal threads for realism
        _drawSagThread(canvas, thread, intactPaint);
      }
    }
  }

  void _drawSagThread(Canvas canvas, WebThread thread, Paint paint) {
    final path = Path();
    path.moveTo(thread.p1.dx, thread.p1.dy);
    final mid = thread.midpoint;
    final len = thread.length;
    final sag = (len * 0.04).clamp(0.0, 8.0);

    // Perpendicular direction for sag
    final dx = thread.p2.dx - thread.p1.dx;
    final dy = thread.p2.dy - thread.p1.dy;
    final len2 = sqrt(dx * dx + dy * dy);
    final px = -dy / (len2 == 0 ? 1 : len2);
    final py = dx / (len2 == 0 ? 1 : len2);

    final control = Offset(mid.dx + px * sag, mid.dy + py * sag);
    path.quadraticBezierTo(control.dx, control.dy, thread.p2.dx, thread.p2.dy);
    canvas.drawPath(path, paint);
  }

  void _drawBrokenEnds(Canvas canvas, WebThread thread) {
    // Show two short dangling ends with wobble
    final wobble = sin(animTime * 4) * 3.0;
    final Paint dangPaint = Paint()
      ..color = Colors.redAccent.withValues(alpha: 0.55)
      ..strokeWidth = 1.3
      ..style = PaintingStyle.stroke;

    final dx = thread.p2.dx - thread.p1.dx;
    final dy = thread.p2.dy - thread.p1.dy;
    final len2 = sqrt(dx * dx + dy * dy);
    if (len2 == 0) return;
    final nx = dx / len2;
    final ny = dy / len2;

    // Dangling from p1
    canvas.drawLine(
      thread.p1,
      thread.p1 + Offset(nx * 10 + wobble, ny * 10 + wobble),
      dangPaint,
    );
    // Dangling from p2
    canvas.drawLine(
      thread.p2,
      thread.p2 - Offset(nx * 10 + wobble, ny * 10 + wobble),
      dangPaint,
    );
  }

  void _drawSilk(Canvas canvas) {
    // Draw silk thread from spider to its repair target (or upward)
    if (spider.state == SpiderState.repairing && spider.repairTarget != null) {
      final target = spider.repairTarget!;
      final Paint silkPaint = Paint()
        ..color = SensoryColors.primary.withValues(alpha: 0.45)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        Offset(spider.position.dx, spider.position.dy),
        target.p1,
        silkPaint,
      );
    }
  }

  void _drawSpider(Canvas canvas) {
    canvas.save();
    canvas.translate(spider.position.dx, spider.position.dy);
    canvas.rotate(spider.angle + pi / 2);

    final double s = spider.size;
    final Color color = spider.color;
    final legPhase = spider.legPhase;

    // Legs (animated alternating)
    final Paint legPaint = Paint()
      ..color = color.withValues(alpha: 0.85)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 4; i++) {
      final double wave = sin(legPhase + i * 0.9) * s * 0.25;
      final double baseAngle = (-pi * 0.2) + i * (pi * 0.13);
      // Left leg
      final Offset legEnd1 = Offset(
        cos(-pi * 0.3 + baseAngle) * s * 1.5,
        sin(-pi * 0.3 + baseAngle) * s * 1.5 + wave,
      );
      // Right leg
      final Offset legEnd2 = Offset(
        -cos(-pi * 0.3 + baseAngle) * s * 1.5,
        sin(-pi * 0.3 + baseAngle) * s * 1.5 - wave,
      );

      final Offset mid1 = Offset(legEnd1.dx * 0.5, legEnd1.dy * 0.4);
      final Offset mid2 = Offset(legEnd2.dx * 0.5, legEnd2.dy * 0.4);

      final path1 = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(mid1.dx, mid1.dy, legEnd1.dx, legEnd1.dy);
      final path2 = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(mid2.dx, mid2.dy, legEnd2.dx, legEnd2.dy);

      canvas.drawPath(path1, legPaint);
      canvas.drawPath(path2, legPaint);
    }

    // Abdomen (big round body)
    final Paint bodyPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(0, s * 0.35), s * 0.62, bodyPaint);

    // Abdomen shine
    final Paint shinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(-s * 0.18, s * 0.18), s * 0.22, shinePaint);

    // Abdomen pattern (two dots)
    final Paint patternPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(0, s * 0.3), s * 0.12, patternPaint);
    canvas.drawCircle(Offset(0, s * 0.55), s * 0.1, patternPaint);

    // Cephalothorax (head+thorax)
    canvas.drawCircle(Offset(0, -s * 0.28), s * 0.38, bodyPaint);

    // Eyes (2 main + 2 small)
    final Paint eyePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final Paint pupilPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(-s * 0.14, -s * 0.34), s * 0.1, eyePaint);
    canvas.drawCircle(Offset(s * 0.14, -s * 0.34), s * 0.1, eyePaint);
    canvas.drawCircle(Offset(-s * 0.14, -s * 0.34), s * 0.05, pupilPaint);
    canvas.drawCircle(Offset(s * 0.14, -s * 0.34), s * 0.05, pupilPaint);

    canvas.restore();

    // Status glow when repairing
    if (spider.state == SpiderState.repairing) {
      final glowPaint = Paint()
        ..color = SensoryColors.primary.withValues(
          alpha: 0.15 + sin(animTime * 6).abs() * 0.1,
        )
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
      canvas.drawCircle(spider.position, s * 1.5, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant SpiderWebPainter old) => true;
}
