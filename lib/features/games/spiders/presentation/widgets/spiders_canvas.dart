import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gtc6/core/theme/colors.dart';

class Spider {
  Offset position;
  Offset target;
  double angle;
  final double size;
  final Color color;
  bool isClimbing;
  double silkY; // Y position of the silk anchor at the top

  Spider({
    required this.position,
    required this.target,
    required this.size,
    required this.color,
    this.angle = 0.0,
    this.isClimbing = false,
  }) : silkY = position.dy;

  void update(Offset? webTarget, double speed) {
    if (webTarget != null) {
      target = webTarget;
    }

    final double dx = target.dx - position.dx;
    final double dy = target.dy - position.dy;
    final double distance = sqrt(dx * dx + dy * dy);

    if (distance > 5) {
      // Rotate towards target
      angle = atan2(dy, dx);
      // Move towards target
      position += Offset((dx / distance) * speed, (dy / distance) * speed);
    } else if (webTarget == null) {
      // Pick a random new target if not chasing a drawn web
      final Random random = Random();
      isClimbing = random.nextBool();
    }
  }
}

class SpidersCanvas extends StatefulWidget {
  const SpidersCanvas({super.key});

  @override
  State<SpidersCanvas> createState() => _SpidersCanvasState();
}

class _SpidersCanvasState extends State<SpidersCanvas>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Spider> _spiders = [];
  final List<List<Offset>> _webs = []; // User-drawn webs
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_updateAnimation);
    _controller.repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _spawnSpiders();
    });
  }

  void _spawnSpiders() {
    final Size size = MediaQuery.of(context).size;
    final List<Color> colors = SensoryColors.gameColors;

    for (int i = 0; i < 4; i++) {
      final double x = _random.nextDouble() * (size.width - 60) + 30;
      final double y = _random.nextDouble() * (size.height * 0.4) + 100;
      _spiders.add(
        Spider(
          position: Offset(x, y),
          target: Offset(
            _random.nextDouble() * size.width,
            _random.nextDouble() * size.height,
          ),
          size: _random.nextDouble() * 16 + 28,
          color: colors[_random.nextInt(colors.length)],
        ),
      );
    }
  }

  void _updateAnimation() {
    final Size size = MediaQuery.of(context).size;
    setState(() {
      for (final spider in _spiders) {
        Offset? webTarget;
        
        // Find nearest drawn web segment to crawl on
        if (_webs.isNotEmpty && _webs.last.isNotEmpty) {
          webTarget = _webs.last.last;
        }

        // Crawl slowly
        spider.update(webTarget, webTarget != null ? 3.5 : 1.5);

        // Periodically change random targets if there is no web
        if (webTarget == null && _random.nextDouble() < 0.02) {
          spider.target = Offset(
            _random.nextDouble() * (size.width - 60) + 30,
            _random.nextDouble() * (size.height * 0.7) + 50,
          );
        }
      }
    });
  }

  void _handlePanStart(DragStartDetails details) {
    setState(() {
      _webs.add([details.localPosition]);
    });
    HapticFeedback.lightImpact();
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (_webs.isNotEmpty) {
      setState(() {
        _webs.last.add(details.localPosition);
      });
    }
  }

  void _handleTap(TapUpDetails details) {
    final tapPos = details.localPosition;
    
    // Check if user tapped a spider
    bool tappedSpider = false;
    for (final spider in _spiders) {
      final double dx = spider.position.dx - tapPos.dx;
      final double dy = spider.position.dy - tapPos.dy;
      final double dist = sqrt(dx * dx + dy * dy);

      if (dist < spider.size * 2) {
        tappedSpider = true;
        // Make spider drop down or wiggle
        setState(() {
          spider.position = Offset(spider.position.dx, spider.position.dy + 80);
          spider.target = Offset(
            spider.position.dx,
            spider.position.dy - 120, // Move back up
          );
        });
        HapticFeedback.mediumImpact();
        break;
      }
    }

    if (!tappedSpider) {
      // Draw a spider at tap location
      final List<Color> colors = SensoryColors.gameColors;
      setState(() {
        _spiders.add(
          Spider(
            position: tapPos,
            target: Offset(
              _random.nextDouble() * MediaQuery.of(context).size.width,
              _random.nextDouble() * MediaQuery.of(context).size.height,
            ),
            size: _random.nextDouble() * 16 + 28,
            color: colors[_random.nextInt(colors.length)],
          ),
        );
      });
      HapticFeedback.lightImpact();
    }
  }

  void _clearCanvas() {
    setState(() {
      _webs.clear();
      _spiders.clear();
      _spawnSpiders();
    });
    HapticFeedback.heavyImpact();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Controls
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Dibuja una telaraña y observa',
                style: TextStyle(
                  color: SensoryColors.textDark.withValues(alpha: 0.8),
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                color: SensoryColors.textDark,
                onPressed: _clearCanvas,
              ),
            ],
          ),
        ),

        // Web canvas
        Expanded(
          child: GestureDetector(
            onPanStart: _handlePanStart,
            onPanUpdate: _handlePanUpdate,
            onTapUp: _handleTap,
            child: Container(
              color: Colors.transparent,
              child: CustomPaint(
                size: Size.infinite,
                painter: SpidersPainter(
                  spiders: _spiders,
                  webs: _webs,
                  isDark: Theme.of(context).brightness == Brightness.dark,
                ),
              ),
            ),
          ),
        ),

        // Text
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '¡Dibuja líneas para tejer hilos de seda o toca una araña para hacerla saltar!',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class SpidersPainter extends CustomPainter {
  final List<Spider> spiders;
  final List<List<Offset>> webs;
  final bool isDark;

  SpidersPainter({
    required this.spiders,
    required this.webs,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint webPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.7)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw user webs
    for (final web in webs) {
      if (web.length > 1) {
        for (int i = 0; i < web.length - 1; i++) {
          canvas.drawLine(web[i], web[i + 1], webPaint);
        }
      }
    }

    // Draw spiders
    for (final spider in spiders) {
      // Draw silk thread hanging from the top or start position
      final Paint silkPaint = Paint()
        ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.5)
        ..strokeWidth = 1.0;
      canvas.drawLine(
        Offset(spider.position.dx, spider.silkY),
        spider.position,
        silkPaint,
      );

      canvas.save();
      canvas.translate(spider.position.dx, spider.position.dy);
      canvas.rotate(spider.angle);

      // Spider body paint
      final Paint bodyPaint = Paint()
        ..color = spider.color
        ..style = PaintingStyle.fill;

      // Draw legs (8 legs)
      final Paint legPaint = Paint()
        ..color = spider.color.withValues(alpha: 0.8)
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke;

      // Leg offsets
      final double s = spider.size;
      for (int i = 0; i < 4; i++) {
        // Left legs
        canvas.drawLine(
          const Offset(0, 0),
          Offset(-s * 1.2, -s + (i * s * 0.6)),
          legPaint,
        );
        // Right legs
        canvas.drawLine(
          const Offset(0, 0),
          Offset(s * 1.2, -s + (i * s * 0.6)),
          legPaint,
        );
      }

      // Draw head
      canvas.drawCircle(Offset(s * 0.4, 0), s * 0.35, bodyPaint);
      
      // Draw abdomen (main body)
      canvas.drawCircle(Offset(-s * 0.2, 0), s * 0.6, bodyPaint);

      // Eyes (two glowing cute eyes)
      final Paint eyePaint = Paint()..color = Colors.white;
      canvas.drawCircle(Offset(s * 0.5, -s * 0.15), s * 0.1, eyePaint);
      canvas.drawCircle(Offset(s * 0.5, s * 0.15), s * 0.1, eyePaint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant SpidersPainter oldDelegate) => true;
}
