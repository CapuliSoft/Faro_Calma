import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:gtc6/core/theme/colors.dart';

class Ball {
  Offset position;
  Offset velocity;
  double radius;
  Color color;
  double opacity;

  Ball({
    required this.position,
    required this.velocity,
    required this.radius,
    required this.color,
    this.opacity = 1.0,
  });

  void updatePhysics(Size bounds, double gravity, double friction) {
    // Apply gravity
    velocity = Offset(velocity.dx, velocity.dy + gravity);

    // Apply friction/air resistance
    velocity = Offset(velocity.dx * friction, velocity.dy * friction);

    // Update position
    position += velocity;

    // Collision with left and right walls
    if (position.dx - radius < 0) {
      position = Offset(radius, position.dy);
      velocity = Offset(-velocity.dx * 0.8, velocity.dy); // Bounce with energy loss
    } else if (position.dx + radius > bounds.width) {
      position = Offset(bounds.width - radius, position.dy);
      velocity = Offset(-velocity.dx * 0.8, velocity.dy);
    }

    // Collision with top and bottom walls
    if (position.dy - radius < 0) {
      position = Offset(position.dx, radius);
      velocity = Offset(velocity.dx, -velocity.dy * 0.8);
    } else if (position.dy + radius > bounds.height) {
      position = Offset(position.dx, bounds.height - radius);
      velocity = Offset(velocity.dx, -velocity.dy * 0.8);
      
      // Stop ball from sinking due to gravity
      if (velocity.dy.abs() < 0.2) {
        velocity = Offset(velocity.dx, 0);
      }
    }
  }
}

class BouncingBallsCanvas extends StatefulWidget {
  const BouncingBallsCanvas({super.key});

  @override
  State<BouncingBallsCanvas> createState() => _BouncingBallsCanvasState();
}

class _BouncingBallsCanvasState extends State<BouncingBallsCanvas>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Ball> _balls = [];
  final Random _random = Random();
  
  double _gravity = 0.3;
  final double _friction = 0.99;
  bool _useGravity = true;
  bool _soundEnabled = true;

  late final AudioPlayer _audioPlayer;

  // ── Bubble sound synthesis ──────────────────────────────────────

  /// Generates a short bubble-pop WAV in memory and plays it.
  /// The sound is a sine wave that quickly rises in frequency (like a bubble).
  Future<void> _playBubble() async {
    if (!_soundEnabled) return;
    const int sampleRate = 22050;
    const int durationMs = 80;
    const int numSamples = sampleRate * durationMs ~/ 1000;

    // Random pitch variation: 400 Hz - 900 Hz
    final double baseFreq = 400 + _random.nextDouble() * 500;

    final ByteData pcm = ByteData(numSamples * 2);
    for (int i = 0; i < numSamples; i++) {
      final double t = i / sampleRate;
      // Frequency sweep upward
      final double freq = baseFreq + (baseFreq * 1.5) * (t / (durationMs / 1000));
      // Envelope: quick attack, fast decay
      final double envelope = (1.0 - (i / numSamples)) * (i < numSamples * 0.1
          ? i / (numSamples * 0.1)
          : 1.0);
      final double sample = sin(2 * pi * freq * t) * envelope * 0.6;
      pcm.setInt16(i * 2, (sample * 32767).round().clamp(-32768, 32767), Endian.little);
    }

    // Build a minimal PCM WAV header (44 bytes)
    final int dataSize = numSamples * 2;
    final ByteData header = ByteData(44);
    // RIFF chunk
    header.setUint8(0, 0x52); header.setUint8(1, 0x49); // 'RI'
    header.setUint8(2, 0x46); header.setUint8(3, 0x46); // 'FF'
    header.setUint32(4, 36 + dataSize, Endian.little);  // ChunkSize
    header.setUint8(8, 0x57); header.setUint8(9, 0x41); // 'WA'
    header.setUint8(10, 0x56); header.setUint8(11, 0x45); // 'VE'
    // fmt sub-chunk
    header.setUint8(12, 0x66); header.setUint8(13, 0x6D); // 'fm'
    header.setUint8(14, 0x74); header.setUint8(15, 0x20); // 't '
    header.setUint32(16, 16, Endian.little);            // Subchunk1Size
    header.setUint16(20, 1, Endian.little);             // AudioFormat PCM
    header.setUint16(22, 1, Endian.little);             // NumChannels mono
    header.setUint32(24, sampleRate, Endian.little);    // SampleRate
    header.setUint32(28, sampleRate * 2, Endian.little);// ByteRate
    header.setUint16(32, 2, Endian.little);             // BlockAlign
    header.setUint16(34, 16, Endian.little);            // BitsPerSample
    // data sub-chunk
    header.setUint8(36, 0x64); header.setUint8(37, 0x61); // 'da'
    header.setUint8(38, 0x74); header.setUint8(39, 0x61); // 'ta'
    header.setUint32(40, dataSize, Endian.little);      // Subchunk2Size

    final Uint8List wav = Uint8List(44 + dataSize);
    wav.setRange(0, 44, header.buffer.asUint8List());
    wav.setRange(44, 44 + dataSize, pcm.buffer.asUint8List());

    final String b64 = base64Encode(wav);
    await _audioPlayer.play(BytesSource(base64Decode(b64)), volume: 0.4);
  }

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_updatePhysics);
    _controller.repeat();
    
    // Spawn some initial balls
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _spawnInitialBalls();
    });
  }

  void _spawnInitialBalls() {
    final Size size = MediaQuery.of(context).size;
    final List<Color> colors = SensoryColors.gameColors;
    
    for (int i = 0; i < 15; i++) {
      _balls.add(
        Ball(
          position: Offset(
            _random.nextDouble() * (size.width - 60) + 30,
            _random.nextDouble() * (size.height * 0.5) + 50,
          ),
          velocity: Offset(
            (_random.nextDouble() - 0.5) * 8,
            (_random.nextDouble() - 0.5) * 8,
          ),
          radius: _random.nextDouble() * 20 + 20, // Radius between 20 and 40
          color: colors[_random.nextInt(colors.length)],
        ),
      );
    }
  }

  void _updatePhysics() {
    final Size size = MediaQuery.of(context).size;
    
    setState(() {
      for (int i = 0; i < _balls.length; i++) {
        _balls[i].updatePhysics(
          size,
          _useGravity ? _gravity : 0.0,
          _friction,
        );

        // Handle ball-to-ball collisions
        for (int j = i + 1; j < _balls.length; j++) {
          _checkBallCollision(_balls[i], _balls[j]);
        }
      }
    });
  }

  void _checkBallCollision(Ball b1, Ball b2) {
    final double dx = b2.position.dx - b1.position.dx;
    final double dy = b2.position.dy - b1.position.dy;
    final double distance = sqrt(dx * dx + dy * dy);
    final double minDistance = b1.radius + b2.radius;

    if (distance < minDistance) {
      // Overlap resolution
      final double overlap = minDistance - distance;
      final double divisor = distance == 0 ? 0.001 : distance;
      final Offset normal = Offset(dx / divisor, dy / divisor);
      
      b1.position -= normal * (overlap * 0.5);
      b2.position += normal * (overlap * 0.5);

      // Elastic collision physics
      // Relative velocity
      final Offset relativeVelocity = b2.velocity - b1.velocity;
      // Velocity along normal
      final double velAlongNormal = relativeVelocity.dx * normal.dx + relativeVelocity.dy * normal.dy;

      // Do not resolve if velocities are separating
      if (velAlongNormal < 0) {
        // Restitution (elasticity coefficient)
        const double restitution = 0.85;
        
        // Calculate impulse scalar
        double impulse = -(1 + restitution) * velAlongNormal;
        impulse /= (1 / b1.radius + 1 / b2.radius); // Mass is proportional to radius

        // Apply impulse
        final Offset impulseVector = normal * impulse;
        b1.velocity -= impulseVector * (1 / b1.radius);
        b2.velocity += impulseVector * (1 / b2.radius);
      }
    }
  }

  void _addBall(Offset touchPosition) {
    final List<Color> colors = SensoryColors.gameColors;
    setState(() {
      _balls.add(
        Ball(
          position: touchPosition,
          velocity: Offset(
            (_random.nextDouble() - 0.5) * 12,
            (_random.nextDouble() - 0.5) * 12,
          ),
          radius: _random.nextDouble() * 20 + 20,
          color: colors[_random.nextInt(colors.length)],
        ),
      );

      if (_balls.length > 40) {
        _balls.removeAt(0);
      }
    });
    _playBubble(); // 🫧 bubble pop sound
  }

  void _handleTap(TapUpDetails details) {
    _addBall(details.localPosition);
  }

  void _handleDrag(DragUpdateDetails details) {
    // Only spawn balls occasionally during drag to avoid oversaturation
    if (_random.nextDouble() < 0.25) {
      _addBall(details.localPosition);
    }
  }

  void _clearBalls() {
    setState(() {
      _balls.clear();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEs = Localizations.localeOf(context).languageCode == 'es';
    return Column(
      children: [
        // Controls Column
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        isEs ? 'Gravedad' : 'Gravity',
                        style: TextStyle(
                          color: SensoryColors.textDark.withValues(alpha: 0.8),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Switch(
                        value: _useGravity,
                        activeThumbColor: SensoryColors.primary,
                        onChanged: (value) {
                          setState(() {
                            _useGravity = value;
                          });
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(_soundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded),
                        color: _soundEnabled ? SensoryColors.primary : SensoryColors.textDark.withValues(alpha: 0.5),
                        tooltip: _soundEnabled
                            ? (isEs ? 'Silenciar sonido' : 'Mute sound')
                            : (isEs ? 'Activar sonido' : 'Unmute sound'),
                        onPressed: () => setState(() => _soundEnabled = !_soundEnabled),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh_rounded),
                        color: SensoryColors.textDark,
                        onPressed: _clearBalls,
                      ),
                    ],
                  ),
                ],
              ),
              if (_useGravity)
                Row(
                  children: [
                    Text(
                      isEs ? 'Fuerza: ' : 'Strength: ',
                      style: TextStyle(
                        color: SensoryColors.textDark.withValues(alpha: 0.8),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Slider(
                        value: _gravity,
                        min: 0.1,
                        max: 1.0,
                        activeColor: SensoryColors.primary,
                        inactiveColor: SensoryColors.primary.withValues(alpha: 0.2),
                        onChanged: (value) {
                          setState(() {
                            _gravity = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        
        // Interaction Canvas
        Expanded(
          child: GestureDetector(
            onTapUp: _handleTap,
            onPanUpdate: _handleDrag,
            child: Container(
              color: Colors.transparent,
              child: CustomPaint(
                size: Size.infinite,
                painter: BallsPainter(balls: _balls),
              ),
            ),
          ),
        ),
        
        // Instructional Bottom Sheet / Text
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            isEs
                ? '¡Toca o arrastra el dedo por la pantalla para crear bolitas!'
                : 'Tap or drag your finger on the screen to create balls!',
            style: TextStyle(
              color: SensoryColors.textLight,
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

class BallsPainter extends CustomPainter {
  final List<Ball> balls;

  BallsPainter({required this.balls});

  @override
  void paint(Canvas canvas, Size size) {
    for (final ball in balls) {
      // Glow/Shadow effect
      final Paint shadowPaint = Paint()
        ..color = ball.color.withValues(alpha: 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(ball.position, ball.radius + 4, shadowPaint);

      // Main ball body
      final Paint fillPaint = Paint()
        ..color = ball.color.withValues(alpha: 0.95)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(ball.position, ball.radius, fillPaint);

      // Highlight for 3D look (soft bubble effect)
      final Paint highlightPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.4)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(ball.position.dx - ball.radius * 0.35, ball.position.dy - ball.radius * 0.35),
        ball.radius * 0.25,
        highlightPaint,
      );

      // Outer delicate ring
      final Paint borderPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(ball.position, ball.radius, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant BallsPainter oldDelegate) {
    return true; // Repaint on every tick
  }
}
