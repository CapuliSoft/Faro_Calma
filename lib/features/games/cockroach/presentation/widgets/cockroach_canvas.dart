import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class Cockroach {
  final int id;
  Offset position;
  Offset target;
  double angle;
  double speed;
  bool isSquashed;
  double squashedScale;
  double legTime;
  final Color splatColor;
  final double scaleFactor;

  Cockroach({
    required this.id,
    required this.position,
    required this.target,
    this.angle = 0.0,
    this.speed = 2.5,
    this.isSquashed = false,
    this.squashedScale = 1.0,
    this.legTime = 0.0,
    required this.splatColor,
    required this.scaleFactor,
  });
}

class CockroachSplat {
  final Offset position;
  final Color color;
  final double radius;
  double opacity;

  CockroachSplat({
    required this.position,
    required this.color,
    required this.radius,
    this.opacity = 0.8,
  });
}

class CockroachCanvas extends StatefulWidget {
  final int maxRoaches;
  final double baseSpeed;
  final ValueChanged<int> onSquashChanged;

  const CockroachCanvas({
    super.key,
    required this.maxRoaches,
    required this.baseSpeed,
    required this.onSquashChanged,
  });

  @override
  State<CockroachCanvas> createState() => CockroachCanvasState();
}

class CockroachCanvasState extends State<CockroachCanvas>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  final List<Cockroach> _roaches = [];
  final List<CockroachSplat> _splats = [];
  final math.Random _random = math.Random();
  final AudioPlayer _audioPlayer = AudioPlayer();

  int _squashCount = 0;
  int _idCounter = 0;
  String? _squishSoundUri;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_gameLoop);
    _animController.repeat();

    _squishSoundUri = 'data:audio/wav;base64,${_generateSquishSound()}';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _spawnInitialRoaches();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CockroachCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Adjust speed on the fly
    for (final r in _roaches) {
      if (!r.isSquashed) {
        r.speed = widget.baseSpeed * (0.8 + _random.nextDouble() * 0.4);
      }
    }
  }

  void _spawnInitialRoaches() {
    final size = MediaQuery.of(context).size;
    final count = widget.maxRoaches;
    for (int i = 0; i < count; i++) {
      _spawnRoach(size);
    }
  }

  void _spawnRoach(Size size) {
    // Spawn from edge of screen
    double x, y;
    final edge = _random.nextInt(4);
    switch (edge) {
      case 0: // Top
        x = _random.nextDouble() * size.width;
        y = -30;
        break;
      case 1: // Right
        x = size.width + 30;
        y = _random.nextDouble() * size.height;
        break;
      case 2: // Bottom
        x = _random.nextDouble() * size.width;
        y = size.height + 30;
        break;
      case 3: // Left
      default:
        x = -30;
        y = _random.nextDouble() * size.height;
        break;
    }

    final targetX = _random.nextDouble() * (size.width - 60) + 30;
    final targetY = _random.nextDouble() * (size.height - 120) + 60;
    final splatColors = [
      const Color(0xFFC0CA33), // Acid lime
      const Color(0xFF7CB342), // Green
      const Color(0xFFFBC02D), // Yellow splat
    ];

    _roaches.add(
      Cockroach(
        id: _idCounter++,
        position: Offset(x, y),
        target: Offset(targetX, targetY),
        speed: widget.baseSpeed * (0.8 + _random.nextDouble() * 0.4),
        splatColor: splatColors[_random.nextInt(splatColors.length)],
        scaleFactor: 0.95 + _random.nextDouble() * 0.2, // Slightly diff sizes
      ),
    );
  }

  void _gameLoop() {
    if (!mounted) return;
    final size = MediaQuery.of(context).size;

    setState(() {
      // 1. Update Splats opacity
      for (final splat in _splats) {
        if (splat.opacity > 0.1) {
          splat.opacity -= 0.002;
        }
      }
      _splats.removeWhere((s) => s.opacity <= 0.1);

      // 2. Update Cockroaches position
      for (int i = _roaches.length - 1; i >= 0; i--) {
        final r = _roaches[i];
        if (r.isSquashed) {
          // If squashed, scale down and remove
          r.squashedScale -= 0.04;
          if (r.squashedScale <= 0.0) {
            _roaches.removeAt(i);
            _spawnRoach(size);
          }
          continue;
        }

        // Move towards target
        final dir = r.target - r.position;
        final dist = dir.distance;
        if (dist < 10) {
          // New target
          r.target = Offset(
            _random.nextDouble() * (size.width - 60) + 30,
            _random.nextDouble() * (size.height - 150) + 60,
          );
        } else {
          // Scurry movement
          r.legTime += 0.2;
          final step = (dir / dist) * r.speed;
          r.position += step;
          // Smooth rotation towards target
          final targetAngle = math.atan2(dir.dy, dir.dx);
          r.angle = targetAngle;
        }
      }
    });
  }

  void _handleTap(TapUpDetails details) {
    final tapPos = details.localPosition;

    for (final r in _roaches) {
      if (r.isSquashed) continue;

      final double dist = (tapPos - r.position).distance;
      if (dist < 32.0 * r.scaleFactor) {
        setState(() {
          r.isSquashed = true;
          _squashCount++;
          widget.onSquashChanged(_squashCount);

          // Add a splat mark at the position
          _splats.add(
            CockroachSplat(
              position: r.position,
              color: r.splatColor,
              radius: 40.0 * r.scaleFactor,
            ),
          );
        });

        _playSquish();
        HapticFeedback.heavyImpact();
        break; // Squash only one cockroach per tap
      }
    }
  }

  void _playSquish() {
    if (_squishSoundUri != null) {
      _audioPlayer.play(UrlSource(_squishSoundUri!));
    }
  }

  String _generateSquishSound() {
    const sampleRate = 44100;
    final double duration = 0.14; // 140ms crunch + wet splat
    final numSamples = (sampleRate * duration);

    final dataSize = (numSamples * 2).toInt();
    final bytes = BytesBuilder();

    // RIFF header
    bytes.add(utf8.encode('RIFF'));
    bytes.add(_int32ToBytes(36 + dataSize));
    bytes.add(utf8.encode('WAVE'));

    // fmt subchunk
    bytes.add(utf8.encode('fmt '));
    bytes.add(_int32ToBytes(16));
    bytes.add(_int16ToBytes(1));
    bytes.add(_int16ToBytes(1)); // Mono
    bytes.add(_int32ToBytes(sampleRate));
    bytes.add(_int32ToBytes(sampleRate * 2));
    bytes.add(_int16ToBytes(2));
    bytes.add(_int16ToBytes(16));

    // data subchunk
    bytes.add(utf8.encode('data'));
    bytes.add(_int32ToBytes(dataSize));

    final math.Random random = math.Random();

    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;

      // High frequency crunchy crunch (first 30ms)
      double crunch = 0.0;
      if (t < 0.035) {
        final double noise = random.nextDouble() * 2.0 - 1.0;
        final double pitch = math.sin(2 * math.pi * 3200 * t);
        crunch = (noise * 0.45 + pitch * 0.55) * (1.0 - t / 0.035);
      }

      // Wet low pitch sliding frequency splat
      final double splatFreq = 340.0 - (240.0 * (t / duration));
      final double splatWave = math.sin(2 * math.pi * splatFreq * t);
      final double envelope = math.exp(-9.0 * t);

      final double finalVal = (crunch * 0.65 + splatWave * envelope * 0.55);
      final sample = (finalVal.clamp(-1.0, 1.0) * 32767).toInt();

      bytes.add(_int16ToBytes(sample));
    }

    return base64Encode(bytes.takeBytes());
  }

  Uint8List _int32ToBytes(int value) {
    return Uint8List(4)..buffer.asByteData().setInt32(0, value, Endian.little);
  }

  Uint8List _int16ToBytes(int value) {
    return Uint8List(2)..buffer.asByteData().setInt16(0, value, Endian.little);
  }

  void resetGame() {
    setState(() {
      _roaches.clear();
      _splats.clear();
      _squashCount = 0;
      widget.onSquashChanged(0);
      _spawnInitialRoaches();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: _handleTap,
      child: CustomPaint(
        size: Size.infinite,
        painter: CockroachPainter(
          roaches: _roaches,
          splats: _splats,
          isDark: Theme.of(context).brightness == Brightness.dark,
        ),
      ),
    );
  }
}

class CockroachPainter extends CustomPainter {
  final List<Cockroach> roaches;
  final List<CockroachSplat> splats;
  final bool isDark;

  CockroachPainter({
    required this.roaches,
    required this.splats,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Splat Marks
    for (final splat in splats) {
      final Paint splatPaint = Paint()
        ..color = splat.color.withValues(alpha: splat.opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(splat.position, splat.radius, splatPaint);

      for (int i = 0; i < 6; i++) {
        final double angle = i * math.pi / 3;
        final double offsetDist = splat.radius * 0.9;
        final Offset dropPos =
            splat.position +
            Offset(math.cos(angle) * offsetDist, math.sin(angle) * offsetDist);
        canvas.drawCircle(dropPos, splat.radius * 0.35, splatPaint);
      }
    }

    // 2. Draw Cockroaches
    for (final roach in roaches) {
      canvas.save();
      canvas.translate(roach.position.dx, roach.position.dy);
      canvas.rotate(roach.angle);

      final double scale = roach.isSquashed ? roach.squashedScale : 1.0;
      canvas.scale(scale * roach.scaleFactor);

      final Color bodyColor = isDark
          ? const Color(0xFF8D6E63)
          : const Color(0xFF5D4037);
      final Color wingColor = isDark
          ? const Color(0xFFA1887F)
          : const Color(0xFF4E342E);

      final Paint bodyPaint = Paint()
        ..color = bodyColor
        ..style = PaintingStyle.fill;

      final Paint wingPaint = Paint()
        ..color = wingColor
        ..style = PaintingStyle.fill;

      final Paint detailPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.3)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;

      final double length = 34.0;
      final double width = 16.0;

      // A. Draw Legs
      final Paint legPaint = Paint()
        ..color = bodyColor.withValues(alpha: 0.9)
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      if (!roach.isSquashed) {
        final double time = roach.legTime;
        for (int i = 0; i < 3; i++) {
          final double wiggleL = math.sin(time + i * 1.5) * 0.25;
          final double wiggleR = math.cos(time + i * 1.5) * 0.25;

          final double legDirY = -0.4 + (i * 0.4);

          // Left legs
          final Path legL = Path()
            ..moveTo(0, legDirY * length)
            ..quadraticBezierTo(
              -width * 1.8,
              (legDirY * length) - 6 + wiggleL * 6,
              -width * 1.6,
              (legDirY * length) - 12 + wiggleL * 4,
            );
          canvas.drawPath(legL, legPaint);

          // Right legs
          final Path legR = Path()
            ..moveTo(0, legDirY * length)
            ..quadraticBezierTo(
              width * 1.8,
              (legDirY * length) - 6 + wiggleR * 6,
              width * 1.6,
              (legDirY * length) - 12 + wiggleR * 4,
            );
          canvas.drawPath(legR, legPaint);
        }
      } else {
        // Squashed bent legs
        for (int i = 0; i < 3; i++) {
          final double legDirY = -0.4 + (i * 0.4);
          canvas.drawLine(
            Offset(0, legDirY * length),
            Offset(-width * 1.5, legDirY * length - 18),
            legPaint,
          );
          canvas.drawLine(
            Offset(0, legDirY * length),
            Offset(width * 1.5, legDirY * length - 12),
            legPaint,
          );
        }
      }

      // B. Antennae
      final Paint antPaint = Paint()
        ..color = bodyColor.withValues(alpha: 0.8)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;

      if (!roach.isSquashed) {
        final double antWiggle = math.sin(roach.legTime * 0.5) * 0.15;
        // Left antenna
        final Path antL = Path()
          ..moveTo(0, length * 0.6)
          ..quadraticBezierTo(
            -width * 0.8,
            length * 1.2,
            -width * 1.2 - antWiggle * 8,
            length * 1.5,
          );
        canvas.drawPath(antL, antPaint);

        // Right antenna
        final Path antR = Path()
          ..moveTo(0, length * 0.6)
          ..quadraticBezierTo(
            width * 0.8,
            length * 1.2,
            width * 1.2 + antWiggle * 8,
            length * 1.5,
          );
        canvas.drawPath(antR, antPaint);
      }

      // C. Draw Abdomen (Bottom body oval)
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(0, -length * 0.15),
          width: width,
          height: length * 0.8,
        ),
        bodyPaint,
      );

      // D. Draw Wings
      if (!roach.isSquashed) {
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(0, -length * 0.2),
            width: width * 1.05,
            height: length * 0.8,
          ),
          wingPaint,
        );
        canvas.drawLine(
          Offset(0, -length * 0.6),
          Offset(0, length * 0.15),
          detailPaint,
        );
      } else {
        // Crushed wings spread apart
        canvas.save();
        canvas.rotate(-0.3);
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(-width * 0.25, -length * 0.2),
            width: width * 1.1,
            height: length * 0.8,
          ),
          wingPaint,
        );
        canvas.restore();

        canvas.save();
        canvas.rotate(0.3);
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(width * 0.25, -length * 0.2),
            width: width * 1.1,
            height: length * 0.8,
          ),
          wingPaint,
        );
        canvas.restore();
      }

      // E. Draw Head
      canvas.drawCircle(Offset(0, length * 0.45), width * 0.4, bodyPaint);

      // G. Eyes
      final Paint eyePaint = Paint()
        ..color = isDark ? Colors.white70 : Colors.black87
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(-width * 0.2, length * 0.5), 1.8, eyePaint);
      canvas.drawCircle(Offset(width * 0.2, length * 0.5), 1.8, eyePaint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CockroachPainter oldDelegate) => true;
}
