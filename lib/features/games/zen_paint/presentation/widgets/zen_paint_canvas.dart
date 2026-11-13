import 'dart:ui';
import 'package:flutter/material.dart';
import '../../domain/models/paint_models.dart';

class ZenPaintCanvas extends StatelessWidget {
  final List<DrawingStroke> completedStrokes;
  final DrawingStroke? currentStroke;
  final ArtTemplate selectedTemplate;
  final Color templateOutlineColor;
  final Color backgroundColor;
  final void Function(Offset point) onPanStart;
  final void Function(Offset point) onPanUpdate;
  final VoidCallback onPanEnd;
  final GlobalKey? repaintBoundaryKey;

  const ZenPaintCanvas({
    super.key,
    required this.completedStrokes,
    required this.currentStroke,
    required this.selectedTemplate,
    required this.templateOutlineColor,
    required this.backgroundColor,
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
    this.repaintBoundaryKey,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) => onPanStart(details.localPosition),
      onPanUpdate: (details) => onPanUpdate(details.localPosition),
      onPanEnd: (_) => onPanEnd(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: RepaintBoundary(
          key: repaintBoundaryKey,
          child: Container(
            color: backgroundColor,
            width: double.infinity,
            height: double.infinity,
            child: CustomPaint(
              painter: _ZenPaintPainter(
                completedStrokes: completedStrokes,
                currentStroke: currentStroke,
                selectedTemplate: selectedTemplate,
                templateOutlineColor: templateOutlineColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ZenPaintPainter extends CustomPainter {
  final List<DrawingStroke> completedStrokes;
  final DrawingStroke? currentStroke;
  final ArtTemplate selectedTemplate;
  final Color templateOutlineColor;

  _ZenPaintPainter({
    required this.completedStrokes,
    required this.currentStroke,
    required this.selectedTemplate,
    required this.templateOutlineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Save transparent stroke layer so eraser only erases painted strokes
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    // Paint completed strokes
    for (final stroke in completedStrokes) {
      _paintStroke(canvas, stroke);
    }

    // Paint active stroke
    if (currentStroke != null) {
      _paintStroke(canvas, currentStroke!);
    }

    canvas.restore();

    // 2. Paint template outline on top so coloring outlines stay crisp & visible
    selectedTemplate.paintTemplate(canvas, size, templateOutlineColor);
  }

  void _paintStroke(Canvas canvas, DrawingStroke stroke) {
    if (stroke.points.isEmpty) return;

    final Paint paint = Paint()
      ..color = stroke.isEraser
          ? Colors.transparent
          : stroke.color.withValues(alpha: stroke.strokeOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke.strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = stroke.isEraser ? StrokeJoin.miter : StrokeJoin.round
      ..blendMode = stroke.isEraser ? BlendMode.clear : BlendMode.srcOver
      ..isAntiAlias = true;

    if (stroke.strokeBlur > 0.5 && !stroke.isEraser) {
      paint.maskFilter = MaskFilter.blur(BlurStyle.normal, stroke.strokeBlur);
    }

    if (stroke.points.length == 1) {
      // Draw single point / tap dot
      canvas.drawPoints(PointMode.points, stroke.points, paint);
      return;
    }

    final Path path = Path();
    path.moveTo(stroke.points.first.dx, stroke.points.first.dy);

    for (int i = 1; i < stroke.points.length - 1; i++) {
      final Offset p0 = stroke.points[i];
      final Offset p1 = stroke.points[i + 1];
      path.quadraticBezierTo(
        p0.dx,
        p0.dy,
        (p0.dx + p1.dx) / 2,
        (p0.dy + p1.dy) / 2,
      );
    }

    if (stroke.points.length > 1) {
      path.lineTo(stroke.points.last.dx, stroke.points.last.dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ZenPaintPainter oldDelegate) => true;
}
