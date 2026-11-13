import 'dart:math' as math;
import 'package:flutter/material.dart';

class DrawingStroke {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;
  final double strokeOpacity;
  final double strokeBlur;
  final bool isEraser;

  DrawingStroke({
    required this.points,
    required this.color,
    required this.strokeWidth,
    this.strokeOpacity = 1.0,
    this.strokeBlur = 0.0,
    this.isEraser = false,
  });
}

enum TemplateType {
  blank(
    'Lienzo Libre',
    'Dibuja con total libertad en un lienzo limpio',
    Icons.draw_rounded,
  ),
  mandala(
    'Mandala Zen',
    'Simetría circular relajante con pétalos y anillos para colorear',
    Icons.filter_vintage_rounded,
  ),
  mountains(
    'Paisaje de Montañas',
    'Cumbres tranquilas con sol naciente y nubes suaves',
    Icons.landscape_rounded,
  ),
  lotus(
    'Flor de Loto',
    'Pétalos sagrados flotando sobre agua serena',
    Icons.spa_rounded,
  ),
  waves(
    'Olas de Mar',
    'Fluidez oceánica al estilo tradicional zen',
    Icons.water_rounded,
  );

  final String title;
  final String description;
  final IconData icon;
  const TemplateType(this.title, this.description, this.icon);
}

class ArtTemplate {
  final TemplateType type;
  const ArtTemplate({required this.type});

  void paintTemplate(Canvas canvas, Size size, Color outlineColor) {
    if (type == TemplateType.blank) return;

    final Paint outlinePaint = Paint()
      ..color = outlineColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    final center = Offset(size.width / 2, size.height / 2);

    switch (type) {
      case TemplateType.mandala:
        _drawMandala(canvas, center, size.width * 0.42, outlinePaint);
        break;
      case TemplateType.mountains:
        _drawMountains(canvas, size, outlinePaint);
        break;
      case TemplateType.lotus:
        _drawLotus(canvas, center, size.width * 0.38, outlinePaint);
        break;
      case TemplateType.waves:
        _drawWaves(canvas, size, outlinePaint);
        break;
      case TemplateType.blank:
        break;
    }
  }

  void _drawMandala(Canvas canvas, Offset center, double radius, Paint paint) {
    // Concentric rings
    canvas.drawCircle(center, radius, paint);
    canvas.drawCircle(center, radius * 0.75, paint);
    canvas.drawCircle(center, radius * 0.5, paint);
    canvas.drawCircle(center, radius * 0.25, paint);

    // Flower petals around outer ring
    final int petals = 12;
    for (int i = 0; i < petals; i++) {
      final double angle = i * 2 * math.pi / petals;
      final double nextAngle = (i + 1) * 2 * math.pi / petals;

      final Offset p1 =
          center +
          Offset(
            math.cos(angle) * radius * 0.5,
            math.sin(angle) * radius * 0.5,
          );
      final Offset p3 =
          center +
          Offset(
            math.cos(nextAngle) * radius * 0.5,
            math.sin(nextAngle) * radius * 0.5,
          );

      final Path petalPath = Path()
        ..moveTo(p1.dx, p1.dy)
        ..quadraticBezierTo(
          center.dx + math.cos((angle + nextAngle) / 2) * radius * 1.1,
          center.dy + math.sin((angle + nextAngle) / 2) * radius * 1.1,
          p3.dx,
          p3.dy,
        );
      canvas.drawPath(petalPath, paint);

      // Inner petals
      final Path innerPath = Path()
        ..moveTo(center.dx, center.dy)
        ..quadraticBezierTo(
          center.dx + math.cos((angle + nextAngle) / 2) * radius * 0.6,
          center.dy + math.sin((angle + nextAngle) / 2) * radius * 0.6,
          p3.dx,
          p3.dy,
        );
      canvas.drawPath(innerPath, paint);
    }
  }

  void _drawMountains(Canvas canvas, Size size, Paint paint) {
    final Path sunPath = Path()
      ..addOval(
        Rect.fromCircle(
          center: Offset(size.width * 0.75, size.height * 0.28),
          radius: 45,
        ),
      );
    canvas.drawPath(sunPath, paint);

    // Mountain 1 (Left background)
    final Path m1 = Path()
      ..moveTo(0, size.height * 0.65)
      ..lineTo(size.width * 0.35, size.height * 0.35)
      ..lineTo(size.width * 0.7, size.height * 0.65);
    canvas.drawPath(m1, paint);

    // Mountain 2 (Right background)
    final Path m2 = Path()
      ..moveTo(size.width * 0.45, size.height * 0.65)
      ..lineTo(size.width * 0.75, size.height * 0.38)
      ..lineTo(size.width, size.height * 0.65);
    canvas.drawPath(m2, paint);

    // Foreground Mountain
    final Path m3 = Path()
      ..moveTo(size.width * 0.1, size.height * 0.65)
      ..lineTo(size.width * 0.5, size.height * 0.42)
      ..lineTo(size.width * 0.9, size.height * 0.65);
    canvas.drawPath(m3, paint);

    // Horizon line
    canvas.drawLine(
      Offset(0, size.height * 0.65),
      Offset(size.width, size.height * 0.65),
      paint,
    );

    // Water ripples below horizon
    for (int i = 1; i <= 4; i++) {
      final double y = size.height * 0.65 + (i * 25);
      canvas.drawLine(
        Offset(size.width * 0.15 * i, y),
        Offset(size.width * (1 - 0.15 * i), y),
        paint,
      );
    }
  }

  void _drawLotus(Canvas canvas, Offset center, double radius, Paint paint) {
    // Center petal
    final Path centerPetal = Path()
      ..moveTo(center.dx, center.dy + radius * 0.5)
      ..quadraticBezierTo(
        center.dx - radius * 0.4,
        center.dy,
        center.dx,
        center.dy - radius * 0.8,
      )
      ..quadraticBezierTo(
        center.dx + radius * 0.4,
        center.dy,
        center.dx,
        center.dy + radius * 0.5,
      );
    canvas.drawPath(centerPetal, paint);

    // Left petals
    for (int i = 1; i <= 3; i++) {
      final double spread = i * 0.28;
      final Path leftPetal = Path()
        ..moveTo(center.dx, center.dy + radius * 0.5)
        ..quadraticBezierTo(
          center.dx - radius * (0.5 + spread),
          center.dy + radius * 0.1,
          center.dx - radius * (0.3 + spread),
          center.dy - radius * (0.6 - spread * 0.6),
        )
        ..quadraticBezierTo(
          center.dx - radius * 0.2,
          center.dy,
          center.dx,
          center.dy + radius * 0.5,
        );
      canvas.drawPath(leftPetal, paint);
    }

    // Right petals
    for (int i = 1; i <= 3; i++) {
      final double spread = i * 0.28;
      final Path rightPetal = Path()
        ..moveTo(center.dx, center.dy + radius * 0.5)
        ..quadraticBezierTo(
          center.dx + radius * (0.5 + spread),
          center.dy + radius * 0.1,
          center.dx + radius * (0.3 + spread),
          center.dy - radius * (0.6 - spread * 0.6),
        )
        ..quadraticBezierTo(
          center.dx + radius * 0.2,
          center.dy,
          center.dx,
          center.dy + radius * 0.5,
        );
      canvas.drawPath(rightPetal, paint);
    }

    // Water base curves
    final Path water = Path()
      ..moveTo(center.dx - radius * 1.1, center.dy + radius * 0.55)
      ..quadraticBezierTo(
        center.dx,
        center.dy + radius * 0.7,
        center.dx + radius * 1.1,
        center.dy + radius * 0.55,
      );
    canvas.drawPath(water, paint);
  }

  void _drawWaves(Canvas canvas, Size size, Paint paint) {
    final double w = size.width;
    final double h = size.height;

    for (int row = 0; row < 5; row++) {
      final double y = h * 0.25 + (row * h * 0.12);
      final Path wave = Path()..moveTo(0, y);

      final int segments = 4;
      final double segW = w / segments;
      for (int i = 0; i < segments; i++) {
        wave.cubicTo(
          i * segW + segW * 0.25,
          y - 35,
          i * segW + segW * 0.75,
          y + 35,
          (i + 1) * segW,
          y,
        );
      }
      canvas.drawPath(wave, paint);
    }

    // Sun/Moon
    canvas.drawCircle(Offset(w * 0.8, h * 0.18), 36, paint);
  }
}

final List<ArtTemplate> kArtTemplates = TemplateType.values
    .map((type) => ArtTemplate(type: type))
    .toList();

extension LocalizedTemplateType on TemplateType {
  String getLocalizedTitle(BuildContext context) {
    final isEs = Localizations.localeOf(context).languageCode == 'es';
    if (isEs) return title;
    switch (this) {
      case TemplateType.blank:
        return 'Blank Canvas';
      case TemplateType.mandala:
        return 'Zen Mandala';
      case TemplateType.mountains:
        return 'Mountain Landscape';
      case TemplateType.lotus:
        return 'Lotus Flower';
      case TemplateType.waves:
        return 'Sea Waves';
    }
  }

  String getLocalizedDescription(BuildContext context) {
    final isEs = Localizations.localeOf(context).languageCode == 'es';
    if (isEs) return description;
    switch (this) {
      case TemplateType.blank:
        return 'Draw with total freedom on a clean canvas';
      case TemplateType.mandala:
        return 'Relaxing circular symmetry with petals and rings to color';
      case TemplateType.mountains:
        return 'Peaceful peaks with a rising sun and soft clouds';
      case TemplateType.lotus:
        return 'Sacred petals floating on serene water';
      case TemplateType.waves:
        return 'Ocean fluidity in traditional Zen style';
    }
  }
}
