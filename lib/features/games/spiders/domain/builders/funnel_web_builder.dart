import 'dart:ui';

import '../models/web_thread.dart';

/// Builds a funnel-web spider pattern with triangular converging layers.
///
/// Layers narrow from full width at the top toward the [center] at the
/// bottom, creating a funnel / tube shape.
List<WebThread> buildFunnelWeb({
  required Offset center,
  required Size canvasSize,
  int layers = 5,
  int cols = 8,
}) {
  final threads = <WebThread>[];
  final double w = canvasSize.width;
  final double h = canvasSize.height;

  final List<List<Offset>> grid = [];

  for (int layer = 0; layer < layers; layer++) {
    final double t = layer / (layers - 1); // 0 = top, 1 = narrowest
    final double y = h * 0.08 + t * (h * 0.55);
    final double xStart = w * 0.05 + t * (w * 0.35);
    final double xEnd = w * 0.95 - t * (w * 0.35);

    final List<Offset> row = [];
    for (int col = 0; col < cols; col++) {
      final double x = xStart + (col / (cols - 1)) * (xEnd - xStart);
      row.add(Offset(x, y));
    }
    grid.add(row);

    // Horizontal threads within row
    for (int c = 0; c < cols - 1; c++) {
      threads.add(WebThread(p1: row[c], p2: row[c + 1]));
    }
  }

  // Vertical / diagonal threads between layers
  for (int layer = 0; layer < layers - 1; layer++) {
    for (int c = 0; c < cols; c++) {
      threads.add(WebThread(p1: grid[layer][c], p2: grid[layer + 1][c]));
      if (c < cols - 1) {
        threads.add(
          WebThread(p1: grid[layer][c], p2: grid[layer + 1][c + 1]),
        );
      }
    }
  }

  // Funnel tube from bottom row to a single convergence point
  final List<Offset> bottomRow = grid.last;
  final Offset tubeBottom = Offset(center.dx, h * 0.92);
  for (int c = 1; c < cols - 1; c += 2) {
    threads.add(WebThread(p1: bottomRow[c], p2: tubeBottom));
  }

  return threads;
}
