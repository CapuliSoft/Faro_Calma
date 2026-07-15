import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_pcm_sound/flutter_pcm_sound.dart';
import 'package:gtc6/features/sound_therapy/domain/models/sound_therapy_models.dart';

/// Contrato que cualquier motor de audio debe cumplir.
abstract class SoundTherapyEngine {
  /// Inicia la generación/reproducción del tono según [config].
  Future<void> start(SoundTherapySessionConfig config);

  /// Pausa la reproducción (mantiene el progreso).
  Future<void> pause();

  /// Reanuda después de pause().
  Future<void> resume();

  /// Detiene completamente y libera recursos.
  Future<void> stop();

  /// Cambia el volumen en vivo sin reiniciar la sesión (0.0–1.0).
  Future<void> setVolumeLive(double volume);

  /// Stream que emite el tiempo restante cada segundo mientras suena.
  Stream<Duration> get remainingTimeStream;

  /// Se completa cuando la sesión termina naturalmente (tiempo agotado).
  Future<void> get onCompleted;

  /// Libera recursos (llamar en dispose() de la pantalla).
  void dispose();
}

// ═══════════════════════════════════════════════════════════════════════════
//  IMPLEMENTACIÓN REAL — Síntesis de audio con flutter_pcm_sound
// ═══════════════════════════════════════════════════════════════════════════

class RealSoundEngine implements SoundTherapyEngine {
  static const int _sampleRate = 44100;
  static const int _channelCount = 2; // estéreo
  static const int _chunkFrames = 4096; // frames por feed
  static const double _modRate = 0.2; // Hz — pulso AM lento y suave

  SoundTherapySessionConfig? _config;
  double _volume = 1.0;
  bool _paused = false;
  bool _running = false;

  /// Fase acumulada en samples — mantiene continuidad de la onda
  int _sampleOffset = 0;

  Timer? _countdownTimer;
  Duration _remaining = Duration.zero;
  final _remainingController = StreamController<Duration>.broadcast();
  Completer<void> _completer = Completer<void>();

  bool _pcmInitialized = false;

  @override
  Stream<Duration> get remainingTimeStream => _remainingController.stream;

  @override
  Future<void> get onCompleted => _completer.future;

  @override
  Future<void> start(SoundTherapySessionConfig config) async {
    _config = config;
    _volume = config.volume;
    _sampleOffset = 0;
    _paused = false;
    _running = true;

    if (_completer.isCompleted) {
      _completer = Completer<void>();
    }

    try {
      await FlutterPcmSound.setup(
        sampleRate: _sampleRate,
        channelCount: _channelCount,
      );
      _pcmInitialized = true;
      await FlutterPcmSound.setFeedThreshold(8000);
      FlutterPcmSound.setFeedCallback(_onFeedRequested);

      // Alimentación inicial
      _generateAndFeed();
      _generateAndFeed();
    } catch (e) {
      debugPrint('[RealSoundEngine] Error al inicializar PCM: $e');
      _pcmInitialized = false;
    }

    _remaining = config.duration;
    _remainingController.add(_remaining);

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_paused) return;

      if (_remaining.inSeconds <= 1) {
        _remaining = Duration.zero;
        _remainingController.add(_remaining);
        _stopAudio();
        _countdownTimer?.cancel();
        if (!_completer.isCompleted) _completer.complete();
        return;
      }

      _remaining -= const Duration(seconds: 1);
      _remainingController.add(_remaining);
    });
  }

  void _onFeedRequested(int remainingFrames) {
    if (!_running || _paused) return;
    _generateAndFeed();
  }

  void _generateAndFeed() {
    if (!_running || _paused || _config == null || !_pcmInitialized) return;

    final cfg = _config!;
    final freqL = cfg.frequency.hz.toDouble();
    final freqR = cfg.binauralBeat != null
        ? freqL + cfg.binauralBeat!.hz
        : freqL;
    final modDepth = cfg.modulation.depth;

    final samples = List<int>.filled(_chunkFrames * _channelCount, 0);

    for (int i = 0; i < _chunkFrames; i++) {
      final t = (_sampleOffset + i) / _sampleRate;
      final am = 1.0 - modDepth + modDepth * sin(2 * pi * _modRate * t);
      final amp = _volume * am * 32767.0;

      final sampleL = (sin(2 * pi * freqL * t) * amp).round().clamp(-32767, 32767);
      final sampleR = (sin(2 * pi * freqR * t) * amp).round().clamp(-32767, 32767);

      samples[i * 2] = sampleL;
      samples[i * 2 + 1] = sampleR;
    }

    _sampleOffset += _chunkFrames;

    try {
      FlutterPcmSound.feed(PcmArrayInt16.fromList(samples));
    } catch (e) {
      debugPrint('[RealSoundEngine] Error al enviar PCM: $e');
    }
  }

  @override
  Future<void> pause() async {
    _paused = true;
  }

  @override
  Future<void> resume() async {
    if (!_running) return;
    _paused = false;
    if (_pcmInitialized) {
      _generateAndFeed();
    }
  }

  @override
  Future<void> stop() async {
    _countdownTimer?.cancel();
    _stopAudio();
  }

  void _stopAudio() {
    _running = false;
    _paused = false;

    if (_pcmInitialized) {
      try {
        FlutterPcmSound.setFeedCallback(null);
        FlutterPcmSound.release();
      } catch (e) {
        debugPrint('[RealSoundEngine] Error al liberar PCM: $e');
      }
      _pcmInitialized = false;
    }
  }

  @override
  Future<void> setVolumeLive(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _stopAudio();
    _remainingController.close();
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  IMPLEMENTACIÓN PLACEHOLDER (fallback para plataformas sin PCM)
// ═══════════════════════════════════════════════════════════════════════════

class PlaceholderSoundEngine implements SoundTherapyEngine {
  Timer? _timer;
  Duration _remaining = Duration.zero;
  bool _paused = false;

  final _remainingController = StreamController<Duration>.broadcast();
  Completer<void> _completer = Completer<void>();

  @override
  Stream<Duration> get remainingTimeStream => _remainingController.stream;

  @override
  Future<void> get onCompleted => _completer.future;

  @override
  Future<void> start(SoundTherapySessionConfig config) async {
    _remaining = config.duration;
    _remainingController.add(_remaining);

    if (_completer.isCompleted) {
      _completer = Completer<void>();
    }

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_paused) return;
      if (_remaining.inSeconds <= 1) {
        _remaining = Duration.zero;
        _remainingController.add(_remaining);
        _timer?.cancel();
        if (!_completer.isCompleted) _completer.complete();
        return;
      }
      _remaining -= const Duration(seconds: 1);
      _remainingController.add(_remaining);
    });
  }

  @override
  Future<void> pause() async {
    _paused = true;
  }

  @override
  Future<void> resume() async {
    _paused = false;
  }

  @override
  Future<void> stop() async {
    _timer?.cancel();
  }

  @override
  Future<void> setVolumeLive(double volume) async {}

  @override
  void dispose() {
    _timer?.cancel();
    _remainingController.close();
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  FACTORY
// ═══════════════════════════════════════════════════════════════════════════

SoundTherapyEngine createSoundTherapyEngine() {
  if (kIsWeb || defaultTargetPlatform == TargetPlatform.windows) {
    return PlaceholderSoundEngine();
  }
  return RealSoundEngine();
}
