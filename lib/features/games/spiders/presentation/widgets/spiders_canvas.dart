import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gtc6/core/theme/colors.dart';

import '../../domain/builders/chaotic_web_builder.dart';
import '../../domain/builders/circular_web_builder.dart';
import '../../domain/builders/funnel_web_builder.dart';
import '../../domain/models/spider_model.dart';
import '../../domain/models/web_thread.dart';
import '../../domain/models/web_type.dart';
import '../painters/spider_web_painter.dart';
import 'web_type_button.dart';

/// Geometry helpers ──────────────────────────────────────────────────────────

/// Returns true when segment (p1→p2) and segment (p3→p4) intersect.
bool _segmentsIntersect(Offset p1, Offset p2, Offset p3, Offset p4) {
  final d1 = p2 - p1;
  final d2 = p4 - p3;
  final cross = d1.dx * d2.dy - d1.dy * d2.dx;
  if (cross.abs() < 1e-9) return false;
  final t = ((p3.dx - p1.dx) * d2.dy - (p3.dy - p1.dy) * d2.dx) / cross;
  final u = ((p3.dx - p1.dx) * d1.dy - (p3.dy - p1.dy) * d1.dx) / cross;
  return t >= 0 && t <= 1 && u >= 0 && u <= 1;
}

/// Distance from point [p] to segment (a→b).
double _pointToSegmentDist(Offset p, Offset a, Offset b) {
  final ab = b - a;
  final len2 = ab.dx * ab.dx + ab.dy * ab.dy;
  if (len2 == 0) return (p - a).distance;
  final t = ((p - a).dx * ab.dx + (p - a).dy * ab.dy) / len2;
  final proj = a + Offset(ab.dx * t.clamp(0.0, 1.0), ab.dy * t.clamp(0.0, 1.0));
  return (p - proj).distance;
}

// ─────────────────────────────────────────────────────────────────────────────
// SpidersCanvas
// ─────────────────────────────────────────────────────────────────────────────

/// Main interactive canvas widget for the spider web destruction & repair game.
///
/// Delegates geometry building to the [builders] package,
/// rendering to [SpiderWebPainter], and UI pieces to [WebTypeButton].
class SpidersCanvas extends StatefulWidget {
  const SpidersCanvas({super.key});

  @override
  State<SpidersCanvas> createState() => _SpidersCanvasState();
}

class _SpidersCanvasState extends State<SpidersCanvas>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final List<WebThread> _threads = [];
  SpiderModel? _spider;
  final Random _random = Random();

  WebType _currentType = WebType.circular;
  Offset _webCenter = Offset.zero;
  Size _canvasSize = Size.zero;

  Offset? _lastFingerPos;
  double _animTime = 0.0;

  /// How fast the spider repairs each broken thread per tick (0.004–0.04).
  double _repairSpeed = 0.012;

  // ── Life cycle ─────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_tick);
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ── Initialization ─────────────────────────────────────────────

  void _initWeb() {
    _webCenter = Offset(_canvasSize.width / 2, _canvasSize.height / 2 - 30);
    _buildWeb(_currentType);
    _spider = SpiderModel(
      position: _webCenter + const Offset(0, -80),
      target: _webCenter,
      size: 20,
      color: SensoryColors.primary,
    );
  }

  void _buildWeb(WebType type) {
    _threads.clear();
    switch (type) {
      case WebType.circular:
        _threads.addAll(buildCircularWeb(center: _webCenter, canvasSize: _canvasSize));
        break;
      case WebType.chaotic:
        _threads.addAll(buildChaoticWeb(center: _webCenter, canvasSize: _canvasSize, random: _random));
        break;
      case WebType.funnel:
        _threads.addAll(buildFunnelWeb(center: _webCenter, canvasSize: _canvasSize));
        break;
    }
  }

  // ── Game tick ──────────────────────────────────────────────────

  void _tick() {
    if (!mounted || _spider == null) return;
    _animTime += 0.05;
    setState(() => _updateSpider());
  }

  void _updateSpider() {
    final spider = _spider;
    if (spider == null) return;

    switch (spider.state) {
      case SpiderState.idle:
        final broken = _findNearestBroken();
        if (broken != null) {
          spider.repairTarget = broken;
          spider.target = broken.midpoint;
          spider.state = SpiderState.walking;
        } else {
          if ((spider.position - spider.target).distance < 10) {
            spider.target = _randomWebPoint();
          }
          spider.update();
        }
        break;

      case SpiderState.walking:
        final broken = spider.repairTarget;
        if (broken == null || !broken.broken) {
          spider.state = SpiderState.idle;
          break;
        }
        spider.target = broken.midpoint;
        spider.update();
        if ((spider.position - broken.midpoint).distance < 12) {
          spider.state = SpiderState.repairing;
        }
        break;

      case SpiderState.repairing:
        final broken = spider.repairTarget;
        if (broken == null) {
          spider.state = SpiderState.idle;
          break;
        }
        broken.repairProgress = (broken.repairProgress + _repairSpeed).clamp(0.0, 1.0);
        if (broken.repairProgress >= 1.0) {
          broken.broken = false;
          spider.repairTarget = null;
          spider.state = SpiderState.idle;
          HapticFeedback.selectionClick();
        }
        break;
    }
  }

  WebThread? _findNearestBroken() {
    final spider = _spider;
    if (spider == null) return null;
    WebThread? nearest;
    double minDist = double.infinity;
    for (final t in _threads) {
      if (t.broken) {
        final d = (t.midpoint - spider.position).distance;
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

  // ── Gesture handling ────────────────────────────────────────────

  void _handlePanStart(DragStartDetails d) {
    _lastFingerPos = d.localPosition;
  }

  void _handlePanUpdate(DragUpdateDetails d) {
    final current = d.localPosition;
    final last = _lastFingerPos;
    if (last == null) { _lastFingerPos = current; return; }

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

  void _handlePanEnd(DragEndDetails d) => _lastFingerPos = null;

  // ── UI actions ──────────────────────────────────────────────────

  void _selectWebType(WebType type) {
    setState(() {
      _currentType = type;
      _buildWeb(type);
      final spider = _spider;
      if (spider != null) {
        spider.state = SpiderState.idle;
        spider.repairTarget = null;
        spider.position = _webCenter + const Offset(0, -80);
        spider.target = _webCenter;
      }
    });
    HapticFeedback.mediumImpact();
  }

  void _destroyAll() {
    setState(() {
      for (final t in _threads) { t.broken = true; t.repairProgress = 0.0; }
    });
    HapticFeedback.heavyImpact();
  }

  void _resetWeb() {
    setState(() {
      _buildWeb(_currentType);
      final spider = _spider;
      if (spider != null) {
        spider.state = SpiderState.idle;
        spider.repairTarget = null;
        spider.position = _webCenter + const Offset(0, -80);
        spider.target = _webCenter;
      }
    });
    HapticFeedback.heavyImpact();
  }

  // ── Build ───────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    final isEs = Localizations.localeOf(context).languageCode == 'es';
    return Column(
      children: [
        // Web type selector
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
          child: Row(
            children: [
              Expanded(child: WebTypeButton(label: isEs ? '🕸 Circular' : '🕸 Circular', selected: _currentType == WebType.circular, onTap: () => _selectWebType(WebType.circular))),
              const SizedBox(width: 8),
              Expanded(child: WebTypeButton(label: isEs ? '🕷 Caótica' : '🕷 Chaotic', selected: _currentType == WebType.chaotic, onTap: () => _selectWebType(WebType.chaotic))),
              const SizedBox(width: 8),
              Expanded(child: WebTypeButton(label: isEs ? '🔻 Embudo' : '🔻 Funnel', selected: _currentType == WebType.funnel, onTap: () => _selectWebType(WebType.funnel))),
            ],
          ),
        ),

        // Repair speed selector
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 2),
          child: Row(
            children: [
              const Text('🐢', style: TextStyle(fontSize: 14)),
              Expanded(
                child: Slider(
                  value: _repairSpeed.clamp(0.004, 0.04),
                  min: 0.004,
                  max: 0.04,
                  divisions: 6,
                  activeColor: SensoryColors.primary,
                  inactiveColor: SensoryColors.primary.withValues(alpha: 0.2),
                  onChanged: (v) => setState(() => _repairSpeed = v),
                ),
              ),
              const Text('🐇', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(
                isEs ? 'Reparación' : 'Repair',
                style: TextStyle(
                  fontSize: 11,
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ),

        // Canvas
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final newSize = Size(constraints.maxWidth, constraints.maxHeight);
              if (_canvasSize != newSize) {
                _canvasSize = newSize;
                _webCenter = Offset(_canvasSize.width / 2, _canvasSize.height / 2 - 30);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() {
                      _initWeb();
                    });
                  }
                });
              }

              return GestureDetector(
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
              );
            },
          ),
        ),

        // Hint + action buttons
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  isEs ? '✋ Desliza para romper hilos. La araña los reparará.' : '✋ Swipe to break threads. The spider will repair them.',
                  style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 12, fontStyle: FontStyle.italic),
                ),
              ),
              IconButton(tooltip: isEs ? 'Destruir toda la tela' : 'Destroy all web', icon: const Icon(Icons.flash_on_rounded, size: 20), color: SensoryColors.zenAmber, onPressed: _destroyAll),
              IconButton(tooltip: isEs ? 'Reiniciar' : 'Reset', icon: const Icon(Icons.refresh_rounded, size: 20), color: theme.colorScheme.onSurface, onPressed: _resetWeb),
            ],
          ),
        ),
      ],
    );
  }
}
