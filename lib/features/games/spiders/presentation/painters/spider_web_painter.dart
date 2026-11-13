import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gtc6/core/theme/colors.dart';

import '../../domain/models/spider_model.dart';
import '../../domain/models/web_thread.dart';

/// [CustomPainter] responsible for drawing the spider web threads and the
/// animated spider character on the canvas.
///
/// Receives immutable snapshot data so it can be used efficiently with
/// [CustomPaint.painter].
class SpiderWebPainter extends CustomPainter {
  final List<WebThread> threads;
  final SpiderModel? spider;
  final bool isDark;
  final double animTime;

  const SpiderWebPainter({
    required this.threads,
    required this.spider,
    required this.isDark,
    required this.animTime,
  });

  // ─── PAINT ENTRY ────────────────────────────────────────────────

  @override
  void paint(Canvas canvas, Size size) {
    _drawThreads(canvas);
    final s_ = spider;
    if (s_ == null) return;
    _drawSilk(canvas, s_);
    _drawSpider(canvas, s_);
  }

  // ─── THREADS ────────────────────────────────────────────────────

  void _drawThreads(Canvas canvas) {
    final Color baseColor = isDark
        ? Colors.white.withValues(alpha: 0.75)
        : Colors.blueGrey.shade900.withValues(alpha: 0.7);

    final Paint intactPaint = Paint()
      ..color = baseColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    final Paint repairingPaint = Paint()
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    for (final thread in threads) {
      if (thread.broken) {
        if (thread.repairProgress <= 0.01) {
          _drawBrokenEnds(canvas, thread);
        } else {
          _drawPartialRepair(canvas, thread, repairingPaint);
          _drawBrokenEnds(canvas, thread);
        }
      } else {
        _drawSagThread(canvas, thread, intactPaint);
      }
    }
  }

  /// Draws a thread with a subtle downward sag for realism.
  void _drawSagThread(Canvas canvas, WebThread thread, Paint paint) {
    final mid = thread.midpoint;
    final len = thread.length;
    final sag = (len * 0.04).clamp(0.0, 8.0);

    final dx = thread.p2.dx - thread.p1.dx;
    final dy = thread.p2.dy - thread.p1.dy;
    final len2 = sqrt(dx * dx + dy * dy);
    final px = -dy / (len2 == 0 ? 1 : len2);
    final py = dx / (len2 == 0 ? 1 : len2);

    final control = Offset(mid.dx + px * sag, mid.dy + py * sag);
    final path = Path()
      ..moveTo(thread.p1.dx, thread.p1.dy)
      ..quadraticBezierTo(control.dx, control.dy, thread.p2.dx, thread.p2.dy);
    canvas.drawPath(path, paint);
  }

  /// Draws a broken thread partially repaired from [p1] up to [repairProgress].
  void _drawPartialRepair(Canvas canvas, WebThread thread, Paint paint) {
    final Offset partial = Offset(
      thread.p1.dx + (thread.p2.dx - thread.p1.dx) * thread.repairProgress,
      thread.p1.dy + (thread.p2.dy - thread.p1.dy) * thread.repairProgress,
    );
    paint.color = SensoryColors.primary.withValues(
      alpha: 0.5 + thread.repairProgress * 0.5,
    );
    canvas.drawLine(thread.p1, partial, paint);
  }

  /// Draws the two dangling broken ends of a severed thread.
  void _drawBrokenEnds(Canvas canvas, WebThread thread) {
    final wobble = sin(animTime * 4) * 3.0;
    final Paint dangPaint = Paint()
      ..color = Colors.redAccent.withValues(alpha: 0.55)
      ..strokeWidth = 1.3
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    final dx = thread.p2.dx - thread.p1.dx;
    final dy = thread.p2.dy - thread.p1.dy;
    final len2 = sqrt(dx * dx + dy * dy);
    if (len2 == 0) return;
    final nx = dx / len2;
    final ny = dy / len2;

    canvas.drawLine(
      thread.p1,
      thread.p1 + Offset(nx * 10 + wobble, ny * 10 + wobble),
      dangPaint,
    );
    canvas.drawLine(
      thread.p2,
      thread.p2 - Offset(nx * 10 + wobble, ny * 10 + wobble),
      dangPaint,
    );
  }

  // ─── SILK + SPIDER ──────────────────────────────────────────────

  /// Draws the silk thread from the spider to the thread it is repairing.
  void _drawSilk(Canvas canvas, SpiderModel s_) {
    if (s_.state == SpiderState.repairing && s_.repairTarget != null) {
      final target = s_.repairTarget!;
      final Paint silkPaint = Paint()
        ..color = SensoryColors.primary.withValues(alpha: 0.45)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke
        ..isAntiAlias = true;
      canvas.drawLine(
        Offset(s_.position.dx, s_.position.dy),
        target.p1,
        silkPaint,
      );
    }
  }

  /// Draws the full spider body: 8 animated legs, abdomen, head and eyes.
  void _drawSpider(Canvas canvas, SpiderModel s_) {
    canvas.save();
    canvas.translate(s_.position.dx, s_.position.dy);
    canvas.rotate(s_.angle + pi / 2);

    final double s = s_.size;
    final Color color = s_.color;
    final legPhase = s_.legPhase;

    _drawLegs(canvas, s, color, legPhase);
    _drawBody(canvas, s, color);
    _drawEyes(canvas, s);

    canvas.restore();

    _drawRepairGlow(canvas, s_, s);
  }

  void _drawLegs(Canvas canvas, double s, Color color, double legPhase) {
    final Paint legPaint = Paint()
      ..color = color.withValues(alpha: 0.85)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    for (int i = 0; i < 4; i++) {
      final double wave = sin(legPhase + i * 0.9) * s * 0.25;
      final double baseAngle = (-pi * 0.2) + i * (pi * 0.13);

      final Offset legEnd1 = Offset(
        cos(-pi * 0.3 + baseAngle) * s * 1.5,
        sin(-pi * 0.3 + baseAngle) * s * 1.5 + wave,
      );
      final Offset legEnd2 = Offset(
        -cos(-pi * 0.3 + baseAngle) * s * 1.5,
        sin(-pi * 0.3 + baseAngle) * s * 1.5 - wave,
      );

      canvas.drawPath(
        Path()
          ..moveTo(0, 0)
          ..quadraticBezierTo(
            legEnd1.dx * 0.5,
            legEnd1.dy * 0.4,
            legEnd1.dx,
            legEnd1.dy,
          ),
        legPaint,
      );
      canvas.drawPath(
        Path()
          ..moveTo(0, 0)
          ..quadraticBezierTo(
            legEnd2.dx * 0.5,
            legEnd2.dy * 0.4,
            legEnd2.dx,
            legEnd2.dy,
          ),
        legPaint,
      );
    }
  }

  void _drawBody(Canvas canvas, double s, Color color) {
    final Paint bodyPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Abdomen
    canvas.drawCircle(Offset(0, s * 0.35), s * 0.62, bodyPaint);

    // Abdomen shine
    canvas.drawCircle(
      Offset(-s * 0.18, s * 0.18),
      s * 0.22,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.25)
        ..style = PaintingStyle.fill
        ..isAntiAlias = true,
    );

    // Abdomen pattern dots
    final Paint patternPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawCircle(Offset(0, s * 0.3), s * 0.12, patternPaint);
    canvas.drawCircle(Offset(0, s * 0.55), s * 0.1, patternPaint);

    // Cephalothorax
    canvas.drawCircle(Offset(0, -s * 0.28), s * 0.38, bodyPaint);
  }

  void _drawEyes(Canvas canvas, double s) {
    final Paint eyePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    final Paint pupilPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    canvas.drawCircle(Offset(-s * 0.14, -s * 0.34), s * 0.1, eyePaint);
    canvas.drawCircle(Offset(s * 0.14, -s * 0.34), s * 0.1, eyePaint);
    canvas.drawCircle(Offset(-s * 0.14, -s * 0.34), s * 0.05, pupilPaint);
    canvas.drawCircle(Offset(s * 0.14, -s * 0.34), s * 0.05, pupilPaint);
  }

  void _drawRepairGlow(Canvas canvas, SpiderModel s_, double s) {
    if (s_.state == SpiderState.repairing) {
      canvas.drawCircle(
        s_.position,
        s * 1.5,
        Paint()
          ..color = SensoryColors.primary.withValues(
            alpha: 0.15 + sin(animTime * 6).abs() * 0.1,
          )
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14)
          ..isAntiAlias = true,
      );
    }
  }

  @override
  bool shouldRepaint(covariant SpiderWebPainter old) => true;
}
