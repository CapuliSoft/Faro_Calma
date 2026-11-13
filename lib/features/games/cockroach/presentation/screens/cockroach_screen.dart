import 'package:flutter/material.dart';
import 'package:gtc6/core/theme/colors.dart';
import '../widgets/cockroach_canvas.dart';
import 'package:gtc6/features/progress/domain/services/progress_service.dart';
import 'package:gtc6/l10n/app_localizations.dart';

class CockroachScreen extends StatefulWidget {
  const CockroachScreen({super.key});

  @override
  State<CockroachScreen> createState() => _CockroachScreenState();
}

class _CockroachScreenState extends State<CockroachScreen> {
  final GlobalKey<CockroachCanvasState> _canvasKey =
      GlobalKey<CockroachCanvasState>();
  late final DateTime _startTime;
  int _score = 0;

  // Settings
  double _speed = 2.5;
  int _maxRoaches = 6;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
  }

  @override
  void dispose() {
    final double elapsedMinutes =
        DateTime.now().difference(_startTime).inSeconds / 60.0;
    if (elapsedMinutes >= 0.05) {
      Future.microtask(() {
        ProgressService.instance.recordSession('cockroach', elapsedMinutes);
      });
    }
    super.dispose();
  }

  void _resetGame() {
    _canvasKey.currentState?.resetGame();
    setState(() {
      _score = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardTheme.color ?? theme.colorScheme.surface;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.black.withValues(alpha: 0.03);
    final isEs = Localizations.localeOf(context).languageCode == 'es';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)?.routineCockroachTitle ??
              'Cucaracha Aplastada',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: SensoryColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: SensoryColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  isEs ? 'Aplastadas: $_score' : 'Smashed: $_score',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: SensoryColors.secondary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Game canvas area
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: const AssetImage('assets/images/kitchen_floor.jpg'),
                    fit: BoxFit.cover,
                    colorFilter: Theme.of(context).brightness == Brightness.dark
                        ? ColorFilter.mode(
                            Colors.black.withValues(alpha: 0.35),
                            BlendMode.darken,
                          )
                        : null,
                  ),
                ),
                child: ClipRect(
                  child: CockroachCanvas(
                    key: _canvasKey,
                    maxRoaches: _maxRoaches,
                    baseSpeed: _speed,
                    onSquashChanged: (score) {
                      setState(() {
                        _score = score;
                      });
                    },
                  ),
                ),
              ),
            ),

            // Help instruction text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                isEs
                    ? '¡Toca las cucarachas que corren para aplastarlas!'
                    : 'Tap the running cockroaches to smash them!',
                style: TextStyle(
                  fontSize: 13.5,
                  fontStyle: FontStyle.italic,
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Controls card
            Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.15)
                        : Colors.black.withValues(alpha: 0.02),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Row for speed / roach count
                  Row(
                    children: [
                      // Speed Slider
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEs ? 'Velocidad' : 'Speed',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: SensoryColors.secondary,
                              ),
                            ),
                            Slider(
                              value: _speed,
                              min: 1.0,
                              max: 5.0,
                              divisions: 8,
                              label: _speed.toStringAsFixed(1),
                              activeColor: SensoryColors.primary,
                              inactiveColor: theme.scaffoldBackgroundColor,
                              onChanged: (val) {
                                setState(() {
                                  _speed = val;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Count Slider
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEs ? 'Cucarachas' : 'Cockroaches',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: SensoryColors.secondary,
                              ),
                            ),
                            Slider(
                              value: _maxRoaches.toDouble(),
                              min: 3.0,
                              max: 12.0,
                              divisions: 9,
                              label: _maxRoaches.toString(),
                              activeColor: SensoryColors.primary,
                              inactiveColor: theme.scaffoldBackgroundColor,
                              onChanged: (val) {
                                setState(() {
                                  _maxRoaches = val.round();
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Reset Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: _resetGame,
                      icon: const Icon(
                        Icons.refresh_rounded,
                        color: SensoryColors.secondary,
                      ),
                      label: Text(
                        isEs ? 'Limpiar Pantalla' : 'Reset Screen',
                        style: const TextStyle(
                          color: SensoryColors.secondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: SensoryColors.secondary.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
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
}
