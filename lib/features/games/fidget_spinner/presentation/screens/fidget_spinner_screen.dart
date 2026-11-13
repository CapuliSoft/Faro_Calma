import 'dart:math' as math;
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:gtc6/core/theme/colors.dart';
import 'package:gtc6/features/progress/domain/services/progress_service.dart';
import 'package:gtc6/l10n/app_localizations.dart';

class FidgetSpinnerScreen extends StatefulWidget {
  const FidgetSpinnerScreen({super.key});

  @override
  State<FidgetSpinnerScreen> createState() => _FidgetSpinnerScreenState();
}

class _FidgetSpinnerScreenState extends State<FidgetSpinnerScreen>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  double _angle = 0.0;
  double _angularVelocity = 0.0;
  final GlobalKey _spinnerKey = GlobalKey();

  late final DateTime _startTime;

  // Stats
  double _maxRpm = 0.0;
  int _totalSpins = 0;

  // Audio
  bool _audioEnabled = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _initAudio();

    _ticker = createTicker((_) {
      if (_angularVelocity.abs() > 0.001) {
        setState(() {
          _angle += _angularVelocity;
          _angularVelocity *= 0.985; // smooth friction

          // Track max RPM (angular velocity -> RPM)
          final currentRpm = (_angularVelocity.abs() / (2 * math.pi)) * 60 * 60;
          if (currentRpm > _maxRpm) _maxRpm = currentRpm;
        });

        _updateAudio();

        // Haptic feedback proportional to speed
        if (_angularVelocity.abs() > 0.3) {
          HapticFeedback.selectionClick();
        }
      } else if (_angularVelocity != 0.0) {
        setState(() => _angularVelocity = 0.0);
        _updateAudio();
      }
    });
    _ticker.start();
  }

  Future<void> _initAudio() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      final wavBytes = _generateSpinnerWavBytes();
      await _audioPlayer.setSource(BytesSource(wavBytes));
    } catch (_) {}
  }

  Uint8List _generateSpinnerWavBytes() {
    const sampleRate = 44100;
    const duration = 1.0;
    const numSamples = (sampleRate * duration);
    const frequency = 120.0; // Frecuencia base del zumbido (Hz)

    final dataSize = (numSamples * 2).toInt();
    final bytes = BytesBuilder();

    // RIFF header
    bytes.add(Uint8List.fromList([82, 73, 70, 70])); // 'RIFF'
    bytes.add(_int32ToBytes(36 + dataSize));
    bytes.add(Uint8List.fromList([87, 65, 86, 69])); // 'WAVE'

    // fmt subchunk
    bytes.add(Uint8List.fromList([102, 109, 116, 32])); // 'fmt '
    bytes.add(_int32ToBytes(16));
    bytes.add(_int16ToBytes(1));
    bytes.add(_int16ToBytes(1)); // Mono
    bytes.add(_int32ToBytes(sampleRate));
    bytes.add(_int32ToBytes(sampleRate * 2));
    bytes.add(_int16ToBytes(2));
    bytes.add(_int16ToBytes(16));

    // data subchunk
    bytes.add(Uint8List.fromList([100, 97, 116, 97])); // 'data'
    bytes.add(_int32ToBytes(dataSize));

    final random = math.Random();

    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      final wave1 = math.sin(2 * math.pi * frequency * t);
      final wave2 = math.sin(2 * math.pi * frequency * 2 * t) * 0.3;
      final noise = (random.nextDouble() * 2 - 1) * 0.15;

      final sample = ((wave1 + wave2 + noise) * 0.4 * 32767).toInt().clamp(
        -32768,
        32767,
      );
      bytes.add(_int16ToBytes(sample));
    }

    return bytes.toBytes();
  }

  List<int> _int32ToBytes(int value) => [
    value & 0xFF,
    (value >> 8) & 0xFF,
    (value >> 16) & 0xFF,
    (value >> 24) & 0xFF,
  ];

  List<int> _int16ToBytes(int value) => [value & 0xFF, (value >> 8) & 0xFF];

  void _updateAudio() {
    final speed = _angularVelocity.abs();

    if (_audioEnabled && speed > 0.02) {
      final pitch = (speed * 1.5).clamp(0.5, 2.0);
      final volume = (speed / 1.2).clamp(0.0, 1.0);

      _audioPlayer.setPlaybackRate(pitch);
      _audioPlayer.setVolume(volume);

      if (_audioPlayer.state != PlayerState.playing) {
        _audioPlayer.resume();
      }
    } else {
      if (_audioPlayer.state == PlayerState.playing) {
        _audioPlayer.pause();
      }
    }
  }

  void _toggleAudio() {
    HapticFeedback.selectionClick();
    setState(() => _audioEnabled = !_audioEnabled);
    _updateAudio();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _audioPlayer.dispose();
    final double elapsedMinutes =
        DateTime.now().difference(_startTime).inSeconds / 60.0;
    if (elapsedMinutes >= 0.05) {
      Future.microtask(() {
        ProgressService.instance.recordSession(
          'fidget_spinner',
          elapsedMinutes,
        );
      });
    }
    super.dispose();
  }

  // ── Spin physics ──────────────────────────────────────────────

  void _onPanUpdate(DragUpdateDetails details) {
    final renderBox =
        _spinnerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final size = renderBox.size;
    final center = Offset(size.width / 2, size.height / 2);
    final dx = details.localPosition.dx - center.dx;
    final dy = details.localPosition.dy - center.dy;
    final tangentialForce = (dx * details.delta.dy) - (dy * details.delta.dx);

    setState(() {
      _angularVelocity += tangentialForce / 8000.0;
      _angularVelocity = _angularVelocity.clamp(-1.5, 1.5);
    });
  }

  void _impulse() {
    HapticFeedback.heavyImpact();
    _totalSpins++;
    setState(() {
      final boost = _angularVelocity >= 0 ? 0.7 : -0.7;
      _angularVelocity = (_angularVelocity + boost).clamp(-1.5, 1.5);
    });
  }

  void _brake() {
    HapticFeedback.mediumImpact();
    setState(() {
      _angularVelocity *= 0.3;
    });
  }

  double get _currentRpm => (_angularVelocity.abs() / (2 * math.pi)) * 60 * 60;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final isEs = Localizations.localeOf(context).languageCode == 'es';

    final bgColor = isDark
        ? SensoryColors.backgroundDark
        : SensoryColors.background;
    final cardColor = theme.cardTheme.color ?? theme.colorScheme.surface;

    final speedPercent = (_angularVelocity.abs() / 1.5).clamp(0.0, 1.0);
    final speedColor = Color.lerp(
      SensoryColors.zenTeal,
      SensoryColors.zenAmber,
      speedPercent,
    )!;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.refresh_rounded, size: 22),
            const SizedBox(width: 8),
            Text(
              l10n?.routineSpinnerTitle ?? 'Fidget Spinner',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),

            // Instruction text
            Text(
              isEs
                  ? 'Desliza los bordes para girar el spinner'
                  : 'Swipe the edges to spin the spinner',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 12),

            // Speed indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: speedColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: speedColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.speed_rounded, size: 20, color: speedColor),
                  const SizedBox(width: 8),
                  Text(
                    '${_currentRpm.toInt()} RPM',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: speedColor,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // ── Spinner ──
            Center(
              child: GestureDetector(
                onPanUpdate: _onPanUpdate,
                child: Container(
                  key: _spinnerKey,
                  width: 300,
                  height: 300,
                  color: Colors.transparent,
                  child: Transform.rotate(
                    angle: _angle,
                    child: _SpinnerWidget(
                      size: 300,
                      isDark: isDark,
                      speedPercent: speedPercent,
                    ),
                  ),
                ),
              ),
            ),

            const Spacer(),

            // ── Stats row ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStat(
                    icon: Icons.bolt_rounded,
                    label: isEs ? 'Máx RPM' : 'Max RPM',
                    value: '${_maxRpm.toInt()}',
                    color: SensoryColors.zenAmber,
                    isDark: isDark,
                    cardColor: cardColor,
                  ),
                  _buildStat(
                    icon: Icons.touch_app_rounded,
                    label: isEs ? 'Impulsos' : 'Boosts',
                    value: '$_totalSpins',
                    color: SensoryColors.zenIndigo,
                    isDark: isDark,
                    cardColor: cardColor,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Action buttons ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Row(
                children: [
                  // Audio button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _toggleAudio,
                      icon: Icon(
                        _audioEnabled
                            ? Icons.volume_up_rounded
                            : Icons.volume_off_rounded,
                        size: 18,
                        color: _audioEnabled
                            ? SensoryColors.primary
                            : theme.colorScheme.onSurface,
                      ),
                      label: Text(
                        _audioEnabled
                            ? (isEs ? 'Sonido' : 'Sound')
                            : (isEs ? 'Mudo' : 'Mute'),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _audioEnabled
                              ? SensoryColors.primary
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(
                          color: _audioEnabled
                              ? SensoryColors.primary
                              : theme.colorScheme.onSurface.withValues(
                                  alpha: 0.2,
                                ),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Brake button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _angularVelocity.abs() > 0.01 ? _brake : null,
                      icon: const Icon(Icons.pan_tool_rounded, size: 18),
                      label: Text(
                        isEs ? 'Frenar' : 'Brake',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.2,
                          ),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Boost button
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _impulse,
                      icon: const Icon(
                        Icons.bolt_rounded,
                        size: 20,
                        color: Colors.white,
                      ),
                      label: Text(
                        isEs ? '⚡ Impulso' : '⚡ Boost',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SensoryColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
    required Color cardColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
              fontFamily: 'monospace',
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark
                  ? SensoryColors.textLightSecondary
                  : SensoryColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Spinner visual widget with 3 arms and metallic gradients
// ─────────────────────────────────────────────────────────────────────────────
class _SpinnerWidget extends StatelessWidget {
  final double size;
  final bool isDark;
  final double speedPercent;

  const _SpinnerWidget({
    required this.size,
    required this.isDark,
    required this.speedPercent,
  });

  static const double _wingOffset = 82.0;
  static const double _wingSize = 105.0;
  static const double _centerSize = 85.0;
  static const double _bearingSize = 34.0;

  @override
  Widget build(BuildContext context) {
    // Dynamic glow based on speed
    final glowColor = Color.lerp(
      SensoryColors.zenTeal,
      SensoryColors.zenAmber,
      speedPercent,
    )!;

    final primaryGradient = isDark
        ? [
            const Color(0xFF3A4A54),
            const Color(0xFF556B78),
            const Color(0xFF2C3E50),
          ]
        : [
            const Color(0xFFB0BEC5),
            const Color(0xFF78909C),
            const Color(0xFF546E7A),
          ];

    final centerGradient = isDark
        ? [const Color(0xFF4A5A68), const Color(0xFF37474F)]
        : [const Color(0xFFCFD8DC), const Color(0xFF90A4AE)];

    final bearingGradient = isDark
        ? [const Color(0xFF607D8B), const Color(0xFF455A64)]
        : [const Color(0xFFECEFF1), const Color(0xFFB0BEC5)];

    return Stack(
      alignment: Alignment.center,
      children: [
        // Speed glow
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: size * 0.6,
          height: size * 0.6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: glowColor.withValues(alpha: 0.15 + speedPercent * 0.25),
                blurRadius: 30 + speedPercent * 40,
                spreadRadius: 5 + speedPercent * 15,
              ),
            ],
          ),
        ),

        // Arm 1 (up)
        Transform.translate(
          offset: const Offset(0, -_wingOffset),
          child: _buildWing(primaryGradient, bearingGradient, glowColor),
        ),

        // Arm 2 (bottom-left, 120°)
        Transform.rotate(
          angle: 2 * math.pi / 3,
          child: Transform.translate(
            offset: const Offset(0, -_wingOffset),
            child: _buildWing(primaryGradient, bearingGradient, glowColor),
          ),
        ),

        // Arm 3 (bottom-right, 240°)
        Transform.rotate(
          angle: 4 * math.pi / 3,
          child: Transform.translate(
            offset: const Offset(0, -_wingOffset),
            child: _buildWing(primaryGradient, bearingGradient, glowColor),
          ),
        ),

        // Center bearing
        Container(
          width: _centerSize,
          height: _centerSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: centerGradient,
              center: const Alignment(-0.3, -0.35),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(2, 4),
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: _bearingSize,
              height: _bearingSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: bearingGradient,
                  center: const Alignment(-0.3, -0.4),
                ),
                border: Border.all(
                  color: glowColor.withValues(alpha: 0.3 + speedPercent * 0.5),
                  width: 2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWing(
    List<Color> wingGradient,
    List<Color> bearingGradient,
    Color glowColor,
  ) {
    return Container(
      width: _wingSize,
      height: _wingSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: wingGradient,
          center: const Alignment(-0.25, -0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 12,
            offset: const Offset(3, 6),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: _wingSize * 0.36,
          height: _wingSize * 0.36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: bearingGradient,
              center: const Alignment(-0.3, -0.4),
            ),
            border: Border.all(
              color: glowColor.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
