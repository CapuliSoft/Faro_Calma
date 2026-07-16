import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:gtc6/core/theme/colors.dart';
import '../../domain/models/rmp_models.dart';
import 'package:gtc6/features/progress/domain/services/progress_service.dart';
import 'package:gtc6/l10n/app_localizations.dart';

class RmpSessionScreen extends StatefulWidget {
  final RmpSessionConfig config;

  const RmpSessionScreen({super.key, required this.config});

  @override
  State<RmpSessionScreen> createState() => _RmpSessionScreenState();
}

class _RmpSessionScreenState extends State<RmpSessionScreen>
    with SingleTickerProviderStateMixin {
  int _groupIndex = 0;
  bool _isTension = true;
  bool _isPaused = false;
  late int _secondsLeft;
  late int _secondsPerPhase;

  Timer? _timer;
  late AnimationController _pulseController;
  final AudioPlayer _audioPlayer = AudioPlayer();
  late final DateTime _startTime;
  bool _sessionLogged = false;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _secondsPerPhase = widget.config.secondsPerPhase;
    _secondsLeft = _secondsPerPhase;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _startTimer();
    _playPhaseSound();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _audioPlayer.dispose();
    if (!_sessionLogged) {
      final double elapsedMinutes = DateTime.now().difference(_startTime).inSeconds / 60.0;
      if (elapsedMinutes >= 0.05) {
        Future.microtask(() {
          ProgressService.instance.recordSession('rmp', elapsedMinutes);
        });
      }
    }
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_isPaused) return;

      setState(() {
        if (_secondsLeft > 1) {
          _secondsLeft--;
        } else {
          _advancePhase();
        }
      });
    });
  }

  void _advancePhase() {
    if (_isTension) {
      // Transition to relaxation phase
      _isTension = false;
      _secondsLeft = _secondsPerPhase;
      _playPhaseSound();
    } else if (_groupIndex < widget.config.activeGroups.length - 1) {
      // Go to next muscle group
      _groupIndex++;
      _isTension = true;
      _secondsLeft = _secondsPerPhase;
      _playPhaseSound();
    } else {
      // Session finished
      _timer?.cancel();
      _playFinishedSound();
      _sessionLogged = true;
      ProgressService.instance.recordSession('rmp', widget.config.totalDurationSeconds / 60.0);
      _showFinishedDialog();
    }
  }

  void _playPhaseSound() {
    if (!widget.config.soundEnabled) return;
    _audioPlayer.play(AssetSource('sounds/platillo.wav'));
  }

  void _playFinishedSound() {
    if (!widget.config.soundEnabled) return;
    _audioPlayer.play(AssetSource('sounds/platillo.wav'));
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _skipNext() {
    if (_groupIndex < widget.config.activeGroups.length - 1) {
      setState(() {
        _groupIndex++;
        _isTension = true;
        _secondsLeft = _secondsPerPhase;
      });
      _playPhaseSound();
    }
  }

  void _skipPrev() {
    if (_groupIndex > 0) {
      setState(() {
        _groupIndex--;
        _isTension = true;
        _secondsLeft = _secondsPerPhase;
      });
      _playPhaseSound();
    }
  }



  void _showFinishedDialog() {
    final theme = Theme.of(context);
    final cardColor = theme.cardTheme.color ?? theme.colorScheme.surface;

    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Center(
          child: Text(
            l10n?.rmpSessionFinished ?? '¡Relajación Completada! 🎉',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n?.rmpSessionFinishedDesc ?? 'Has completado con éxito tu rutina de Relajación Muscular Progresiva.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: SensoryColors.calmGreen.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: SensoryColors.calmGreen.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_outline_rounded, color: SensoryColors.calmGreen),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.config.activeGroups.length} ${l10n?.rmpZones ?? "zonas"}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: SensoryColors.calmGreen),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: SizedBox(
              width: 140,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Exit session screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: SensoryColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(l10n?.rmpSessionFinishedBtn ?? 'Entendido', style: const TextStyle(color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final currentGroup = widget.config.activeGroups[_groupIndex];
    final progress = 1.0 - (_secondsLeft / _secondsPerPhase);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          '${AppLocalizations.of(context)?.rmpIntroTitle ?? "Sesión"}: ${_groupIndex + 1}/${widget.config.activeGroups.length}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(_isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded),
            onPressed: _togglePause,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Muscle group info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Column(
                children: [
                  Text(
                    currentGroup.getLocalizedName(context),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currentGroup.getLocalizedCategory(context).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: SensoryColors.secondary,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),

            // Animated Sensory Visualizer Canvas
            Expanded(
              child: Center(
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, _) {
                    return RmpVisualizer(
                      isTension: _isTension,
                      progress: progress,
                      pulseValue: _pulseController.value,
                      emoji: currentGroup.emoji(_isTension),
                    );
                  },
                ),
              ),
            ),

            // Step by step guide card
            _buildGuideCard(currentGroup, isDark),

            // Progress Bar and Controls
            _buildBottomControlsBar(progress),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideCard(MuscleGroup group, bool isDark) {
    final theme = Theme.of(context);
    final cardColor = theme.cardTheme.color ?? theme.colorScheme.surface;
    final activeColor = _isTension ? Colors.orangeAccent : SensoryColors.calmGreen;
    final activeBg = _isTension 
        ? Colors.orangeAccent.withValues(alpha: 0.12)
        : SensoryColors.calmGreen.withValues(alpha: 0.15);
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03);

    final l10n = AppLocalizations.of(context);
    final steps = _isTension ? group.getLocalizedTensionSteps(context) : group.getLocalizedRelaxationSteps(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.02),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: activeBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: activeColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  _isTension 
                      ? 'FASE: ${l10n?.rmpSessionPhaseTension ?? "TENSIÓN"} ✊' 
                      : 'FASE: ${l10n?.rmpSessionPhaseRelaxation ?? "RELAJACIÓN"} 🍃',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: activeColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '$_secondsLeft s',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: activeColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...steps.asMap().entries.map((entry) {
            final idx = entry.key;
            final stepText = entry.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    margin: const EdgeInsets.only(right: 10, top: 1),
                    decoration: BoxDecoration(
                      color: activeBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        '${idx + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: activeColor,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      stepText,
                      style: TextStyle(
                        fontSize: 13.5,
                        color: theme.colorScheme.onSurface,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBottomControlsBar(double progress) {
    final theme = Theme.of(context);
    final activeColor = _isTension ? SensoryColors.zenAmber : SensoryColors.calmGreen;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      child: Column(
        children: [
          // Visual timeline progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: theme.scaffoldBackgroundColor,
              valueColor: AlwaysStoppedAnimation<Color>(activeColor),
            ),
          ),
          const SizedBox(height: 12),
          // Skip controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
                onPressed: _groupIndex > 0 ? _skipPrev : null,
                tooltip: 'Grupo Anterior',
              ),
              Text(
                'Fase ${_isTension ? "Tensión" : "Relajación"}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios_rounded, size: 20),
                onPressed: _groupIndex < widget.config.activeGroups.length - 1 ? _skipNext : null,
                tooltip: 'Siguiente Grupo',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Sensory Visualizer Widget ──

class RmpVisualizer extends StatelessWidget {
  final bool isTension;
  final double progress;
  final double pulseValue;
  final String emoji;

  const RmpVisualizer({
    super.key,
    required this.isTension,
    required this.progress,
    required this.pulseValue,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Canvas Painter
          CustomPaint(
            size: const Size(220, 220),
            painter: RmpVisualizerPainter(
              isTension: isTension,
              progress: progress,
              pulseValue: pulseValue,
            ),
          ),
          // Large floating emoji
          Text(
            emoji,
            style: const TextStyle(fontSize: 54),
          ),
        ],
      ),
    );
  }
}

class RmpVisualizerPainter extends CustomPainter {
  final bool isTension;
  final double progress;
  final double pulseValue;

  RmpVisualizerPainter({
    required this.isTension,
    required this.progress,
    required this.pulseValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final double maxRadius = size.width / 2 - 12;

    if (isTension) {
      // ✊ Tension: Contracting, spikey orange/amber sphere.
      // As progress approaches 1.0, it contracts more and spikes shake faster.
      final double progressScale = 1.0 - (progress * 0.25); // shrinks up to 75% size
      final double currentRadius = maxRadius * progressScale;

      final Paint corePaint = Paint()
        ..color = SensoryColors.zenAmber.withValues(alpha: 0.15)
        ..style = PaintingStyle.fill;

      // Draw vibrating spikes
      final Path spikePath = Path();
      const int numSpikes = 36;
      final double vibrationSpeed = 10.0 + (progress * 15.0); // shakes faster as tension builds
      final double vibrationAmp = 3.0 + (progress * 5.0);

      for (int i = 0; i <= numSpikes; i++) {
        final double angle = (i * 2 * math.pi / numSpikes);
        final double offset = math.sin(angle * 6 + pulseValue * vibrationSpeed) * vibrationAmp;
        final double r = currentRadius + offset;

        final double x = center.dx + math.cos(angle) * r;
        final double y = center.dy + math.sin(angle) * r;

        if (i == 0) {
          spikePath.moveTo(x, y);
        } else {
          spikePath.lineTo(x, y);
        }
      }
      spikePath.close();
      canvas.drawPath(spikePath, corePaint);

      // Spikes border line
      final Paint borderPaint = Paint()
        ..color = SensoryColors.zenAmber.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(spikePath, borderPaint);

      // Inward arrows (imploding force)
      final Paint arrowPaint = Paint()
        ..color = SensoryColors.zenAmber.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8;

      for (int i = 0; i < 8; i++) {
        final double angle = i * math.pi / 4;
        final double arrowLength = 12.0;
        final double startDist = maxRadius * 0.9;
        final double endDist = currentRadius + 6;

        final Offset start = center + Offset(math.cos(angle) * startDist, math.sin(angle) * startDist);
        final Offset end = center + Offset(math.cos(angle) * endDist, math.sin(angle) * endDist);

        canvas.drawLine(start, end, arrowPaint);

        // Arrow head pointing inward
        final double headAngle1 = angle + math.pi - 0.45;
        final double headAngle2 = angle + math.pi + 0.45;
        canvas.drawLine(end, end + Offset(math.cos(headAngle1) * arrowLength * 0.6, math.sin(headAngle1) * arrowLength * 0.6), arrowPaint);
        canvas.drawLine(end, end + Offset(math.cos(headAngle2) * arrowLength * 0.6, math.sin(headAngle2) * arrowLength * 0.6), arrowPaint);
      }
    } else {
      // 🍃 Relaxation: Expanding, breathing mint/blue sphere with floating particles.
      // Pulse value (0.0 to 1.0 reverse) controls the smooth slow breathing scale.
      final double breathScale = 0.8 + (pulseValue * 0.15); // breaths between 80% and 95%
      final double currentRadius = maxRadius * breathScale;

      final Paint corePaint = Paint()
        ..color = SensoryColors.calmGreen.withValues(alpha: 0.18)
        ..style = PaintingStyle.fill;

      // Soft circular path
      canvas.drawCircle(center, currentRadius, corePaint);

      final Paint borderPaint = Paint()
        ..color = SensoryColors.calmGreen.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2;
      canvas.drawCircle(center, currentRadius, borderPaint);

      // Outward waves (expanding energy)
      final Paint wavePaint = Paint()
        ..color = SensoryColors.calmGreen.withValues(alpha: 0.25 - (pulseValue * 0.15))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(center, currentRadius + 14 * pulseValue, wavePaint);
      canvas.drawCircle(center, currentRadius + 28 * pulseValue, wavePaint);

      // Floating particles (bubbles rising up)
      final Paint bubblePaint = Paint()
        ..color = SensoryColors.calmBlue.withValues(alpha: 0.4)
        ..style = PaintingStyle.fill;

      for (int i = 0; i < 6; i++) {
        final double angle = (i * 2 * math.pi / 6) + (pulseValue * 0.5);
        final double bubbleDist = currentRadius * 0.75 + (i * 4 * pulseValue);
        final Offset bubblePos = center + Offset(math.cos(angle) * bubbleDist, math.sin(angle) * bubbleDist - (10 * pulseValue));
        canvas.drawCircle(bubblePos, 3.5 + (i % 3), bubblePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant RmpVisualizerPainter oldDelegate) => true;
}
