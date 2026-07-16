import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:gtc6/core/theme/colors.dart';
import '../../domain/models/breathing_pattern.dart';
import '../widgets/breathing_visualizer.dart';
import 'package:gtc6/l10n/app_localizations.dart';
import 'package:gtc6/features/progress/domain/services/progress_service.dart';

class BreathingSessionScreen extends StatefulWidget {
  final BreathingPattern pattern;
  final int totalCycles;
  final bool soundEnabled;
  final bool hapticsEnabled;

  const BreathingSessionScreen({
    super.key,
    required this.pattern,
    required this.totalCycles,
    required this.soundEnabled,
    required this.hapticsEnabled,
  });

  @override
  State<BreathingSessionScreen> createState() => _BreathingSessionScreenState();
}

class _BreathingSessionScreenState extends State<BreathingSessionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _timer;

  int _currentCycle = 1;
  int _phaseIndex = 0;
  late int _phaseSecondsLeft;
  late int _phaseTotalSeconds;
  bool _isPaused = false;
  late final DateTime _startTime;
  bool _sessionLogged = false;

  BreathingPhase get _currentPhase => widget.pattern.phases[_phaseIndex];

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _phaseTotalSeconds = _currentPhase.durationSeconds;
    _phaseSecondsLeft = _phaseTotalSeconds;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..repeat();

    _startTimer();
    _triggerPhaseFeedback();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _audioPlayer.dispose();
    if (!_sessionLogged) {
      final double elapsedMinutes =
          DateTime.now().difference(_startTime).inSeconds / 60.0;
      if (elapsedMinutes >= 0.1) {
        Future.microtask(() {
          ProgressService.instance.recordSession('breathing', elapsedMinutes);
        });
      }
    }
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _isPaused) return;

      setState(() {
        if (_phaseSecondsLeft > 1) {
          _phaseSecondsLeft--;
        } else {
          _advancePhase();
        }
      });
    });
  }

  void _advancePhase() {
    if (_phaseIndex < widget.pattern.phases.length - 1) {
      // Next phase in current cycle
      _phaseIndex++;
      _phaseTotalSeconds = _currentPhase.durationSeconds;
      _phaseSecondsLeft = _phaseTotalSeconds;
      _triggerPhaseFeedback();
    } else if (_currentCycle < widget.totalCycles) {
      // Next cycle starts
      _currentCycle++;
      _phaseIndex = 0;
      _phaseTotalSeconds = _currentPhase.durationSeconds;
      _phaseSecondsLeft = _phaseTotalSeconds;
      _triggerPhaseFeedback();
    } else {
      // Session Completed!
      _timer?.cancel();
      _triggerFinishedFeedback();
      _sessionLogged = true;
      final double totalMinutes =
          DateTime.now().difference(_startTime).inSeconds / 60.0;
      ProgressService.instance.recordSession('breathing', totalMinutes);
      _showFinishedDialog();
    }
  }

  void _triggerPhaseFeedback() {
    if (widget.soundEnabled) {
      _audioPlayer.play(AssetSource('sounds/platillo.wav'));
    }
    if (widget.hapticsEnabled) {
      HapticFeedback.lightImpact();
    }
  }

  void _triggerFinishedFeedback() {
    if (widget.soundEnabled) {
      _audioPlayer.play(AssetSource('sounds/platillo.wav'));
    }
    if (widget.hapticsEnabled) {
      HapticFeedback.heavyImpact();
    }
  }

  void _togglePause() {
    setState(() => _isPaused = !_isPaused);
    if (widget.hapticsEnabled) HapticFeedback.selectionClick();
  }

  void _skipNextPhase() {
    setState(() => _advancePhase());
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
            l10n?.breathingSessionFinished ?? '¡Sesión Completada! 🌿',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n?.breathingSessionFinishedDesc ?? 'Has completado la rutina de respiración científica. Tu sistema nervioso está más regulado y en equilibrio.',
              textAlign: TextAlign.center,
              style: const TextStyle(height: 1.4),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: widget.pattern.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: widget.pattern.color.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(widget.pattern.icon, color: widget.pattern.color),
                  const SizedBox(width: 10),
                  Text(
                    'Beneficio Científico Logrado',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: widget.pattern.color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: SizedBox(
              width: 150,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // close dialog
                  Navigator.of(context).pop(); // exit session
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: SensoryColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(l10n?.breathingSessionFinishedBtn ?? 'Volver a Inicio',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
    final l10n = AppLocalizations.of(context);
    final double phaseProgress =
        1.0 - (_phaseSecondsLeft / _phaseTotalSeconds);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          '${l10n?.breathingSessionCycle ?? 'Ciclo'}: $_currentCycle / ${widget.totalCycles}',
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
            tooltip: _isPaused 
                ? (AppLocalizations.of(context)?.localeName == 'es' ? 'Reanudar' : 'Resume') 
                : (AppLocalizations.of(context)?.localeName == 'es' ? 'Pausar' : 'Pause'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Pattern info header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Column(
                children: [
                  Text(
                    widget.pattern.getLocalizedName(context),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.pattern.getLocalizedSubtitle(context).toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: widget.pattern.color,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),

            // Animated Visualizer Canvas
            Expanded(
              child: Center(
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, _) {
                    return BreathingVisualizer(
                      phaseType: _currentPhase.type,
                      phaseProgress: phaseProgress,
                      pulseValue: _pulseController.value,
                      themeColor: widget.pattern.color,
                    );
                  },
                ),
              ),
            ),

            // Numerical seconds display
            Text(
              '$_phaseSecondsLeft s',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: widget.pattern.color,
              ),
            ),
            const SizedBox(height: 10),

            // Scientific Instruction Guide Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: theme.cardTheme.color ?? theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: widget.pattern.color.withValues(alpha: 0.25),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: widget.pattern.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(_currentPhase.type.icon, color: widget.pattern.color),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentPhase.type.getLocalizedLabel(context),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: widget.pattern.color,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _currentPhase.getLocalizedInstruction(context, widget.pattern.id, _phaseIndex),
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Progress bar and skip control
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 6, 24, 20),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: (_phaseIndex + phaseProgress) /
                          widget.pattern.phases.length,
                      minHeight: 8,
                      backgroundColor: theme.scaffoldBackgroundColor,
                      valueColor: AlwaysStoppedAnimation<Color>(widget.pattern.color),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Fase ${_phaseIndex + 1} de ${widget.pattern.phases.length}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      TextButton.icon(
                        onPressed: _skipNextPhase,
                        icon: const Icon(Icons.skip_next_rounded, size: 20),
                        label: const Text('Saltar Fase'),
                        style: TextButton.styleFrom(
                          foregroundColor: widget.pattern.color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
