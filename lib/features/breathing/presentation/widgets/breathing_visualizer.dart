import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../domain/models/breathing_pattern.dart';

class BreathingVisualizer extends StatelessWidget {
  final BreathingPhaseType phaseType;
  final double phaseProgress; // 0.0 to 1.0 during current phase
  final double pulseValue; // continuous 0.0 to 1.0 animation ticker
  final Color themeColor;

  const BreathingVisualizer({
    super.key,
    required this.phaseType,
    required this.phaseProgress,
    required this.pulseValue,
    required this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(260, 260),
            painter: BreathingVisualizerPainter(
              phaseType: phaseType,
              phaseProgress: phaseProgress,
              pulseValue: pulseValue,
              themeColor: themeColor,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                phaseType.icon,
                size: 38,
                color: themeColor.withValues(alpha: 0.95),
              ),
              const SizedBox(height: 6),
              Text(
                phaseType.label.toUpperCase(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: themeColor,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BreathingVisualizerPainter extends CustomPainter {
  final BreathingPhaseType phaseType;
  final double phaseProgress;
  final double pulseValue;
  final Color themeColor;

  BreathingVisualizerPainter({
    required this.phaseType,
    required this.phaseProgress,
    required this.pulseValue,
    required this.themeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final double maxRadius = size.width / 2 - 16;
    final double minRadius = maxRadius * 0.45;

    // Calculate dynamic radius based on phase
    double currentRadius;
    switch (phaseType) {
      case BreathingPhaseType.inhale:
        // Expand smoothly with easeInOut
        final double curve = _easeInOut(phaseProgress);
        currentRadius = minRadius + (maxRadius - minRadius) * curve;
        break;
      case BreathingPhaseType.holdIn:
        // Stay at max radius with subtle bio-pulse
        currentRadius = maxRadius - (math.sin(pulseValue * 2 * math.pi) * 4);
        break;
      case BreathingPhaseType.exhale:
        // Contract smoothly
        final double curve = _easeInOut(1.0 - phaseProgress);
        currentRadius = minRadius + (maxRadius - minRadius) * curve;
        break;
      case BreathingPhaseType.holdOut:
        // Stay at min radius with subtle quiet resting pulse
        currentRadius = minRadius + (math.sin(pulseValue * 2 * math.pi) * 2);
        break;
    }

    // Outer soft aura / glow
    final Paint auraPaint = Paint()
      ..color = themeColor.withValues(alpha: 0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(center, currentRadius + 18, auraPaint);

    // Main breathing sphere (with organic petals/ripples)
    final Paint fillPaint = Paint()
      ..color = themeColor.withValues(alpha: 0.22)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, currentRadius, fillPaint);

    // Inner core sphere
    final Paint corePaint = Paint()
      ..color = themeColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, currentRadius * 0.7, corePaint);

    // Rotating geometric lotus rings around the sphere
    final Paint ringPaint = Paint()
      ..color = themeColor.withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(center, currentRadius, ringPaint);

    // Draw delicate orbit particles / petals
    final int numPetals = 8;
    final Paint petalPaint = Paint()
      ..color = themeColor.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < numPetals; i++) {
      final double angle = (i * 2 * math.pi / numPetals) + (pulseValue * 2 * math.pi);
      final double petalDist = currentRadius * 0.86;
      final Offset pos = center + Offset(math.cos(angle) * petalDist, math.sin(angle) * petalDist);
      canvas.drawCircle(pos, 4.5, petalPaint);
    }

    // Inner breathing ripple ring during hold phases
    if (phaseType == BreathingPhaseType.holdIn || phaseType == BreathingPhaseType.holdOut) {
      final Paint holdRipplePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.4 * (1.0 - pulseValue))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8;
      canvas.drawCircle(center, currentRadius * (0.6 + 0.4 * pulseValue), holdRipplePaint);
    }
  }

  double _easeInOut(double t) {
    return t < 0.5 ? 2 * t * t : -1 + (4 - 2 * t) * t;
  }

  @override
  bool shouldRepaint(covariant BreathingVisualizerPainter oldDelegate) => true;
}
