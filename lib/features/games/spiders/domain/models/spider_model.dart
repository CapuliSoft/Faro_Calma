import 'dart:math';
import 'dart:ui';

import 'web_thread.dart';

/// States the spider can be in during its AI loop.
enum SpiderState { idle, walking, repairing }

/// Represents the animated spider character that patrols and repairs the web.
class SpiderModel {
  Offset position;
  Offset target;
  double angle;
  final double size;
  final Color color;
  SpiderState state;
  WebThread? repairTarget;

  /// Used to animate the 8 legs in a walking motion.
  double legPhase;
  double walkSpeed;

  SpiderModel({
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

  /// Moves the spider one step towards [target] and updates [legPhase].
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
