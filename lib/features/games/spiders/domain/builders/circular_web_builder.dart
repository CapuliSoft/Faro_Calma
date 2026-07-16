import 'dart:math';
import 'dart:ui';

import '../models/web_thread.dart';

/// Builds a classic circular garden-spider web.
///
/// Generates [spokes] radial lines from the [center] and [rings]
/// concentric polygon rings connecting them.
List<WebThread> buildCircularWeb({
  required Offset center,
  required Size canvasSize,
  int spokes = 12,
  int rings = 6,
}) {
  final threads = <WebThread>[];
  final double maxRadius = min(canvasSize.width, canvasSize.height) * 0.42;

  final List<List<Offset>> spokePoints = [];

  for (int s = 0; s < spokes; s++) {
    final double angle = (s / spokes) * 2 * pi;
    final List<Offset> points = [center];

    for (int r = 1; r <= rings; r++) {
      final double radius = (r / rings) * maxRadius;
      points.add(center + Offset(cos(angle) * radius, sin(angle) * radius));
    }

    spokePoints.add(points);

    // Spoke threads
    for (int i = 0; i < points.length - 1; i++) {
      threads.add(WebThread(p1: points[i], p2: points[i + 1]));
    }
  }

  // Concentric ring threads
  for (int r = 1; r <= rings; r++) {
    for (int s = 0; s < spokes; s++) {
      final Offset a = spokePoints[s][r];
      final Offset b = spokePoints[(s + 1) % spokes][r];
      threads.add(WebThread(p1: a, p2: b));
    }
  }

  return threads;
}
