import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:gtc6/core/theme/colors.dart';
import 'package:gtc6/features/progress/domain/services/progress_service.dart';
import 'package:gtc6/l10n/app_localizations.dart';

class BubbleData {
  final int id;
  final Offset position;
  final Color color;
  bool isPopped;
  double scale;

  BubbleData({
    required this.id,
    required this.position,
    required this.color,
    this.isPopped = false,
    this.scale = 1.0,
  });
}

class BubbleScreen extends StatefulWidget {
  const BubbleScreen({super.key});

  @override
  State<BubbleScreen> createState() => _BubbleScreenState();
}

class _BubbleScreenState extends State<BubbleScreen> {
  final List<BubbleData> _bubbles = [];
  final int _cols = 5;
  final int _rows = 6;

  final AudioPlayer _audioPlayer = AudioPlayer();

  // ── Experience Controls ──────────────────────────────────────────
  bool _soundEnabled = true;
  bool _synthTypeSoft =
      true; // Programmatic audio variations instead of external assets
  bool _regenerativeMode = false;

  late final DateTime _startTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _generateBubbles();
  }

  @override
  void dispose() {
    final double elapsedMinutes =
        DateTime.now().difference(_startTime).inSeconds / 60.0;
    if (elapsedMinutes >= 0.05) {
      Future.microtask(() {
        ProgressService.instance.recordSession('popit', elapsedMinutes);
      });
    }
    _audioPlayer.dispose();
    super.dispose();
  }

  void _generateBubbles() {
    _bubbles.clear();
    final List<Color> rowColors = [
      SensoryColors.calmPink,
      SensoryColors.calmYellow,
      SensoryColors.calmGreen,
      SensoryColors.calmBlue,
      SensoryColors.calmPurple,
      SensoryColors.primary.withValues(alpha: 0.5),
    ];

    int id = 0;
    for (int r = 0; r < _rows; r++) {
      for (int c = 0; c < _cols; c++) {
        _bubbles.add(
          BubbleData(
            id: id++,
            position: Offset(c.toDouble(), r.toDouble()),
            color: rowColors[r % rowColors.length],
          ),
        );
      }
    }
  }

  // ── Programmatic Audio Synthesizer (Fast & Asset-free) ───────────
  String _generatePopSound({required bool softType}) {
    const sampleRate = 44100;
    final double duration = softType
        ? 0.06
        : 0.12; // 60ms (ultra fast) or 120ms (bubble)
    final numSamples = (sampleRate * duration);

    // Frequency sweeps for bubble effects
    final double startFrequency = softType ? 450.0 : 250.0;
    final double endFrequency = softType ? 900.0 : 800.0;

    final dataSize = (numSamples * 2).toInt();
    final bytes = BytesBuilder();

    // RIFF header
    bytes.add(utf8.encode('RIFF'));
    bytes.add(_int32ToBytes(36 + dataSize));
    bytes.add(utf8.encode('WAVE'));

    // fmt subchunk
    bytes.add(utf8.encode('fmt '));
    bytes.add(_int32ToBytes(16));
    bytes.add(_int16ToBytes(1));
    bytes.add(_int16ToBytes(1)); // Mono
    bytes.add(_int32ToBytes(sampleRate));
    bytes.add(_int32ToBytes(sampleRate * 2));
    bytes.add(_int16ToBytes(2));
    bytes.add(_int16ToBytes(16));

    // data subchunk
    bytes.add(utf8.encode('data'));
    bytes.add(_int32ToBytes(dataSize));

    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      final freq =
          startFrequency + ((endFrequency - startFrequency) * (t / duration));
      // Fast exponential envelope decay
      final envelope = math.exp((softType ? -40.0 : -25.0) * t);
      final wave = math.sin(2 * math.pi * freq * t);

      final sample = (wave * envelope * 0.8 * 32767).toInt().clamp(
        -32768,
        32767,
      );
      bytes.add(_int16ToBytes(sample));
    }

    final base64String = base64Encode(bytes.toBytes());
    return 'data:audio/wav;base64,$base64String';
  }

  List<int> _int32ToBytes(int value) => [
    value & 0xFF,
    (value >> 8) & 0xFF,
    (value >> 16) & 0xFF,
    (value >> 24) & 0xFF,
  ];

  List<int> _int16ToBytes(int value) => [value & 0xFF, (value >> 8) & 0xFF];

  Future<void> _playPopSound() async {
    if (!_soundEnabled) return;

    try {
      await _audioPlayer.stop();
      final uri = _generatePopSound(softType: _synthTypeSoft);
      await _audioPlayer.setSource(UrlSource(uri));

      // Pitch variation for variety
      final pitch = 0.92 + (math.Random().nextDouble() * 0.16); // 0.92 to 1.08
      await _audioPlayer.setPlaybackRate(pitch);
      await _audioPlayer.resume();
    } catch (_) {}
  }

  void _popBubble(int index) {
    if (_bubbles[index].isPopped) return;

    HapticFeedback.heavyImpact();
    _playPopSound();

    setState(() {
      _bubbles[index].isPopped = true;
      _bubbles[index].scale = 1.3;
    });

    Future.delayed(const Duration(milliseconds: 120), () {
      if (!mounted) return;
      setState(() {
        _bubbles[index].scale = 0.86;
      });
    });

    // Infinite / Regenerative mode
    if (_regenerativeMode) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        setState(() {
          _bubbles[index].isPopped = false;
          _bubbles[index].scale = 1.0;
        });
      });
    } else {
      // Auto reset if all are popped
      if (_bubbles.every((b) => b.isPopped)) {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (!mounted) return;
          _resetBubbles();
        });
      }
    }
  }

  void _resetBubbles() {
    HapticFeedback.mediumImpact();
    setState(() {
      for (final b in _bubbles) {
        b.isPopped = false;
        b.scale = 1.0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardTheme.color ?? theme.colorScheme.surface;

    final l10n = AppLocalizations.of(context);
    final isEs = Localizations.localeOf(context).languageCode == 'es';
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n?.routineBubblesTitle ?? 'Pop-It / Burbujas',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                isEs ? 'Toca para explotar' : 'Tap to pop',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: SensoryColors.primary,
                ),
              ),
              const SizedBox(height: 14),

              // Pop-It board container
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.15)
                          : Colors.black.withValues(alpha: 0.03),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    const spacing = 12.0;
                    final maxBubbleSize =
                        (constraints.maxWidth - ((_cols - 1) * spacing)) /
                        _cols;
                    final bubbleSize = maxBubbleSize
                        .clamp(38.0, 54.0)
                        .toDouble();

                    final gridWidth =
                        (_cols * bubbleSize) + ((_cols - 1) * spacing);
                    final gridHeight =
                        (_rows * bubbleSize) + ((_rows - 1) * spacing);

                    return Center(
                      child: SizedBox(
                        width: gridWidth,
                        height: gridHeight,
                        child: Stack(
                          children: _bubbles.asMap().entries.map((entry) {
                            final index = entry.key;
                            final bubble = entry.value;
                            return Positioned(
                              left: bubble.position.dx * (bubbleSize + spacing),
                              top: bubble.position.dy * (bubbleSize + spacing),
                              child: GestureDetector(
                                onTapDown: (_) => _popBubble(index),
                                child: AnimatedScale(
                                  scale: bubble.scale,
                                  duration: const Duration(milliseconds: 120),
                                  curve: Curves.easeOutBack,
                                  child: _BubbleWidget(
                                    size: bubbleSize,
                                    isPopped: bubble.isPopped,
                                    color: bubble.color,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Reset button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _resetBubbles,
                  icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                  label: Text(
                    isEs ? 'Reiniciar burbujas' : 'Reset bubbles',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SensoryColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Configuration card
              Material(
                color: cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.03),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Column(
                    children: [
                      // Sound toggle
                      SwitchListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                        dense: true,
                        title: Row(
                          children: [
                            Icon(
                              _soundEnabled
                                  ? Icons.volume_up_rounded
                                  : Icons.volume_off_rounded,
                              size: 20,
                              color: _soundEnabled
                                  ? SensoryColors.primary
                                  : theme.textTheme.bodyMedium?.color,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              l10n?.popitSoundOption ?? 'Sonido de explosión',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: _soundEnabled
                                    ? theme.colorScheme.onSurface
                                    : theme.textTheme.bodyMedium?.color,
                              ),
                            ),
                          ],
                        ),
                        value: _soundEnabled,
                        activeThumbColor: SensoryColors.primary,
                        onChanged: (val) {
                          setState(() {
                            _soundEnabled = val;
                          });
                        },
                      ),
                      // Infinite mode toggle
                      SwitchListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                        dense: true,
                        title: Row(
                          children: [
                            Icon(
                              Icons.autorenew_rounded,
                              size: 20,
                              color: _regenerativeMode
                                  ? SensoryColors.primary
                                  : theme.textTheme.bodyMedium?.color,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              l10n?.popitInfiniteOption ?? 'Burbujas infinitas',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: _regenerativeMode
                                    ? theme.colorScheme.onSurface
                                    : theme.textTheme.bodyMedium?.color,
                              ),
                            ),
                          ],
                        ),
                        value: _regenerativeMode,
                        activeThumbColor: SensoryColors.primary,
                        onChanged: (val) {
                          setState(() {
                            _regenerativeMode = val;
                          });
                        },
                      ),
                      // Sound Type toggle (Programmatic sound variation)
                      if (_soundEnabled)
                        SwitchListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                          dense: true,
                          title: Row(
                            children: [
                              Icon(
                                Icons.audiotrack_rounded,
                                size: 20,
                                color: _synthTypeSoft
                                    ? SensoryColors.primary
                                    : theme.textTheme.bodyMedium?.color,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  isEs
                                      ? (_synthTypeSoft
                                            ? 'Sonido: Burbuja suave'
                                            : 'Sonido: Pop clásico')
                                      : (_synthTypeSoft
                                            ? 'Sound: Soft bubble'
                                            : 'Sound: Classic pop'),
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          value: _synthTypeSoft,
                          activeThumbColor: SensoryColors.primary,
                          onChanged: (val) {
                            setState(() {
                              _synthTypeSoft = val;
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BubbleWidget extends StatelessWidget {
  final double size;
  final bool isPopped;
  final Color color;

  const _BubbleWidget({
    required this.size,
    required this.isPopped,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (isPopped) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.25),
          border: Border.all(color: color.withValues(alpha: 0.4), width: 2),
        ),
      );
    }

    // Active bubble with 3D gradient, colored row styling, and shine highlight
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: 0.3), color],
          center: const Alignment(-0.3, -0.3),
        ),
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.4),
            blurRadius: 4,
            offset: const Offset(-2, -2),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.20),
            blurRadius: 8,
            offset: const Offset(2, 3),
          ),
        ],
      ),
      child: Align(
        alignment: const Alignment(-0.25, -0.4),
        child: Container(
          width: size * 0.3,
          height: size * 0.18,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
