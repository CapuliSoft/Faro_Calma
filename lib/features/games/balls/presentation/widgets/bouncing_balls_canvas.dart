import 'dart:math';
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
  
  double _gravity = 0.3; // Default gravity
  final double _friction = 0.99; // Air resistance
  bool _useGravity = true;

  @override
  void initState() {
    super.initState();
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
      // Soft spawn animation/position
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

      // Keep maximum 40 balls to prevent performance drops and visual clutter
      if (_balls.length > 40) {
        _balls.removeAt(0);
      }
    });
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                        'Gravedad',
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
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded),
                    color: SensoryColors.textDark,
                    onPressed: _clearBalls,
                  ),
                ],
              ),
              if (_useGravity)
                Row(
                  children: [
                    Text(
                      'Fuerza: ',
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
            '¡Toca o arrastra el dedo por la pantalla para crear bolitas!',
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
