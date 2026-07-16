import 'dart:ui';
import 'dart:math';

/// Represents a single thread (segment) of a spider web.
///
/// A thread connects two points [p1] and [p2]. It can be [broken]
/// by the user and repaired by the spider, tracked via [repairProgress].
class WebThread {
  final Offset p1;
  final Offset p2;
  bool broken;
  double repairProgress; // 0.0 = fully broken, 1.0 = fully intact

  WebThread({
    required this.p1,
    required this.p2,
    this.broken = false,
    this.repairProgress = 1.0,
  });

  /// The midpoint between [p1] and [p2].
  Offset get midpoint => Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);

  /// The euclidean length of this thread.
  double get length {
    final dx = p2.dx - p1.dx;
    final dy = p2.dy - p1.dy;
    return sqrt(dx * dx + dy * dy);
  }
}
