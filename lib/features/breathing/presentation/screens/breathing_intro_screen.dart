import 'package:flutter/material.dart';
import 'package:gtc6/core/theme/colors.dart';
import '../../domain/models/breathing_pattern.dart';
import 'breathing_session_screen.dart';
import 'package:gtc6/l10n/app_localizations.dart';

class BreathingIntroScreen extends StatefulWidget {
  const BreathingIntroScreen({super.key});

  @override
  State<BreathingIntroScreen> createState() => _BreathingIntroScreenState();
}

class _BreathingIntroScreenState extends State<BreathingIntroScreen> {
  int _selectedIndex = 0;
  int _selectedCycles = 4;
  bool _soundEnabled = true;
  bool _hapticsEnabled = true;

  BreathingPattern get _selectedPattern => kBreathingPatterns[_selectedIndex];

  @override
  void initState() {
    super.initState();
    _selectedCycles = _selectedPattern.recommendedCycles;
  }

  void _onSelectPattern(int index) {
    setState(() {
      _selectedIndex = index;
      _selectedCycles = kBreathingPatterns[index].recommendedCycles;
    });
  }

  void _startSession() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BreathingSessionScreen(
          pattern: _selectedPattern,
          totalCycles: _selectedCycles,
          soundEnabled: _soundEnabled,
          hapticsEnabled: _hapticsEnabled,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)?.breathingIntroTitle ??
              'Respiración Científica',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top scientific banner
            Container(
              margin: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: SensoryColors.calmGreen.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: SensoryColors.calmGreen.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.biotech_rounded,
                    color: SensoryColors.calmGreen,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)?.breathingIntroBanner ??
                          'Patrones con aval neurocientífico para estimular el nervio vago...',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.9,
                        ),
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Horizontal routine selector list
            SizedBox(
              height: 155,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: kBreathingPatterns.length,
                itemBuilder: (context, idx) {
                  final pattern = kBreathingPatterns[idx];
                  final isSelected = idx == _selectedIndex;

                  return GestureDetector(
                    onTap: () => _onSelectPattern(idx),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      width: 150,
                      margin: const EdgeInsets.only(right: 14),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? pattern.color.withValues(
                                alpha: isDark ? 0.25 : 0.18,
                              )
                            : theme.cardTheme.color ??
                                  theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? pattern.color
                              : (isDark
                                    ? Colors.white.withValues(alpha: 0.06)
                                    : Colors.black.withValues(alpha: 0.05)),
                          width: isSelected ? 2.5 : 1.0,
                        ),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: pattern.color.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(pattern.icon, color: pattern.color, size: 30),
                          const Spacer(),
                          Text(
                            pattern.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                              color: isSelected ? pattern.color : null,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${pattern.cycleDurationSeconds}s/ciclo',
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Selected routine detail card
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color ?? theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: _selectedPattern.color.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _selectedPattern.color.withValues(
                                alpha: 0.15,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _selectedPattern.category.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: _selectedPattern.color,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.timer_outlined,
                            size: 16,
                            color: _selectedPattern.color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '~${((_selectedPattern.cycleDurationSeconds * _selectedCycles) / 60).toStringAsFixed(1)} min',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _selectedPattern.color,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _selectedPattern.getLocalizedName(context),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _selectedPattern.getLocalizedSubtitle(context),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _selectedPattern.color,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        AppLocalizations.of(context)?.breathingBenefitLabel ??
                            'Avalo Científico y Beneficios:',
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _selectedPattern.getLocalizedBenefit(context),
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.85,
                          ),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Divider(height: 1),
                      const SizedBox(height: 16),

                      // Phase breakdown pills
                      Text(
                        AppLocalizations.of(context)?.breathingStructureLabel ??
                            'Estructura del Patrón:',
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _selectedPattern.phases.map((phase) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: _selectedPattern.color.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  phase.type.icon,
                                  size: 16,
                                  color: _selectedPattern.color,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${phase.type.getLocalizedLabel(context)}: ${phase.durationSeconds}s',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _selectedPattern.color,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 20),
                      const Divider(height: 1),
                      const SizedBox(height: 16),

                      // Configuration: cycles, sound, haptics
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(
                                  context,
                                )?.breathingCyclesLabel ??
                                'Ciclos de respiración:',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.remove_circle_outline_rounded,
                                ),
                                color: _selectedPattern.color,
                                onPressed: _selectedCycles > 1
                                    ? () => setState(() => _selectedCycles--)
                                    : null,
                              ),
                              Text(
                                '$_selectedCycles',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.add_circle_outline_rounded,
                                ),
                                color: _selectedPattern.color,
                                onPressed: _selectedCycles < 20
                                    ? () => setState(() => _selectedCycles++)
                                    : null,
                              ),
                            ],
                          ),
                        ],
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.volume_up_rounded, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                AppLocalizations.of(
                                      context,
                                    )?.breathingSoundLabel ??
                                    'Sonido guía (Platillo)',
                                style: const TextStyle(fontSize: 13.5),
                              ),
                            ],
                          ),
                          Switch(
                            value: _soundEnabled,
                            activeThumbColor: _selectedPattern.color,
                            onChanged: (v) => setState(() => _soundEnabled = v),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.vibration_rounded, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                AppLocalizations.of(
                                      context,
                                    )?.breathingHapticLabel ??
                                    'Vibración suave al cambiar',
                                style: const TextStyle(fontSize: 13.5),
                              ),
                            ],
                          ),
                          Switch(
                            value: _hapticsEnabled,
                            activeThumbColor: _selectedPattern.color,
                            onChanged: (v) =>
                                setState(() => _hapticsEnabled = v),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Start button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _startSession,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedPattern.color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    shadowColor: _selectedPattern.color.withValues(alpha: 0.4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context)?.breathingStartBtn ??
                            'Comenzar Respiración',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
