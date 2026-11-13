import 'dart:math';
import 'dart:ui';

import '../models/web_thread.dart';

/// Builds a chaotic house-spider web using random nodes connected by threads.
///
/// Nodes are scattered across the [canvasSize] and connected to their
/// 2–3 nearest neighbors. Anchor threads are added to the canvas edges.
List<WebThread> buildChaoticWeb({
  required Offset center,
  required Size canvasSize,
  int nodeCount = 14,
  Random? random,
}) {
  final rng = random ?? Random();
  final threads = <WebThread>[];
  final double w = canvasSize.width;
  final double h = canvasSize.height;

  final List<Offset> nodes = [center];
  for (int i = 0; i < nodeCount - 1; i++) {
    nodes.add(
      Offset(
        w * 0.08 + rng.nextDouble() * (w * 0.84),
        h * 0.05 + rng.nextDouble() * (h * 0.88),
      ),
    );
  }

  // Connect each node to 2–3 nearest others
  for (int i = 0; i < nodes.length; i++) {
    final List<int> sorted = List.generate(nodes.length, (j) => j)
      ..remove(i)
      ..sort(
        (a, b) => (nodes[i] - nodes[a]).distance.compareTo(
          (nodes[i] - nodes[b]).distance,
        ),
      );

    final int connections = 2 + rng.nextInt(2);
    for (int k = 0; k < connections && k < sorted.length; k++) {
      final int j = sorted[k];
      final bool exists = threads.any(
        (t) =>
            (t.p1 == nodes[i] && t.p2 == nodes[j]) ||
            (t.p1 == nodes[j] && t.p2 == nodes[i]),
      );
      if (!exists) {
        threads.add(WebThread(p1: nodes[i], p2: nodes[j]));
      }
    }
  }

  // Anchor threads to canvas edges
  for (final node in nodes.take(6)) {
    final edges = [
      Offset(node.dx, 0),
      Offset(node.dx, h),
      Offset(0, node.dy),
      Offset(w, node.dy),
    ];
    threads.add(WebThread(p1: node, p2: edges[rng.nextInt(edges.length)]));
  }

  return threads;
}
