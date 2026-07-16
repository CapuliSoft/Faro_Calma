import 'package:flutter/material.dart';
import 'package:gtc6/core/theme/colors.dart';
import 'package:gtc6/features/sound_therapy/domain/models/sound_therapy_models.dart';
import 'package:gtc6/features/sound_therapy/presentation/screens/sound_therapy_player_screen.dart';
import 'package:gtc6/l10n/app_localizations.dart';

class SoundTherapySelectorScreen extends StatefulWidget {
  const SoundTherapySelectorScreen({super.key});

  @override
  State<SoundTherapySelectorScreen> createState() =>
      _SoundTherapySelectorScreenState();
}

class _SoundTherapySelectorScreenState
    extends State<SoundTherapySelectorScreen> {
  SoundFrequency _selectedFrequency = kSoundFrequencies[3]; // 528Hz default
  BinauralBeat? _selectedBinaural = kBinauralBeats[0]; // Delta 2Hz default
  ModulationLevel _selectedModulation = ModulationLevel.suave;
  int _selectedDuration = 10;
  double _volume = 0.7;

  void _startSession() {
    final config = SoundTherapySessionConfig(
      frequency: _selectedFrequency,
      binauralBeat: _selectedBinaural,
      modulation: _selectedModulation,
      durationMinutes: _selectedDuration,
      volume: _volume,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SoundTherapyPlayerScreen(config: config),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isEs = Localizations.localeOf(context).languageCode == 'es';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 150),
          children: [
            _buildSectionLabel(isEs ? 'SELECCIONAR FRECUENCIA' : 'SELECT FREQUENCY'),
            const SizedBox(height: 12),
            _buildFrequencyGrid(),
            const SizedBox(height: 24),
            _buildSectionLabel(isEs ? 'RITMOS BINAURALES (OPCIONAL)' : 'BINAURAL BEATS (OPTIONAL)'),
            const SizedBox(height: 12),
            _buildBinauralRow(),
            const SizedBox(height: 24),
            _buildSectionLabel(isEs ? 'MODULACIÓN (OPCIONAL)' : 'MODULATION (OPTIONAL)'),
            const SizedBox(height: 12),
            _buildModulationRow(),
            const SizedBox(height: 24),
            _buildSectionLabel(l10n?.soundDurationLabel ?? 'DURACIÓN'),
            const SizedBox(height: 12),
            _buildDurationRow(),
            const SizedBox(height: 24),
            _buildSectionLabel(l10n?.soundVolumeLabel ?? 'VOLUMEN'),
            const SizedBox(height: 12),
            _buildVolumeSlider(),
            const SizedBox(height: 24),
            _buildStartButton(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final l10n = AppLocalizations.of(context);
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.graphic_eq_rounded, color: SensoryColors.secondary, size: 22),
          const SizedBox(width: 8),
          Text(
            l10n?.soundTherapyTitle ?? 'Terapia de Sonido',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.info_outline_rounded),
          onPressed: _showInfoDialog,
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: SensoryColors.secondary,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildFrequencyGrid() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardTheme.color ?? theme.colorScheme.surface;
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05);
    final textMediumColor = theme.textTheme.bodyMedium?.color;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: kSoundFrequencies.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.35,
      ),
      itemBuilder: (_, i) {
        final freq = kSoundFrequencies[i];
        final selected = freq.hz == _selectedFrequency.hz;
        return GestureDetector(
          onTap: () => setState(() => _selectedFrequency = freq),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: selected
                  ? SensoryColors.secondary.withValues(alpha: 0.15)
                  : cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? SensoryColors.secondary : borderColor,
                width: selected ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      freq.icon,
                      size: 18,
                      color: selected
                          ? SensoryColors.secondary
                          : textMediumColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      freq.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: selected
                            ? SensoryColors.secondary
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  freq.getLocalizedDescription(context),
                  style: TextStyle(
                    fontSize: 12.5,
                    color: selected
                        ? SensoryColors.secondary.withValues(alpha: 0.85)
                        : textMediumColor,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBinauralRow() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        ...kBinauralBeats.map((beat) {
          final selected = _selectedBinaural?.label == beat.label;
          return _buildPillChoice(
            label: beat.label,
            selected: selected,
            color: beat.accentColor,
            onTap: () => setState(() {
              _selectedBinaural = selected ? null : beat;
            }),
          );
        }),
      ],
    );
  }

  Widget _buildModulationRow() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: ModulationLevel.values.map((level) {
        final selected = _selectedModulation == level;
        return _buildPillChoice(
          label: level.getLocalizedLabel(context),
          selected: selected,
          color: SensoryColors.primary,
          onTap: () => setState(() => _selectedModulation = level),
        );
      }).toList(),
    );
  }

  Widget _buildDurationRow() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: kDurationsMinutes.map((min) {
        final selected = _selectedDuration == min;
        return _buildPillChoice(
          label: '$min min',
          selected: selected,
          color: SensoryColors.secondary,
          onTap: () => setState(() => _selectedDuration = min),
        );
      }).toList(),
    );
  }

  Widget _buildPillChoice({
    required String label,
    required bool selected,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardTheme.color ?? theme.colorScheme.surface;
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.15) : cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? color : borderColor,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: selected ? color : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildVolumeSlider() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardTheme.color ?? theme.colorScheme.surface;
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          const Icon(Icons.volume_down_rounded, color: SensoryColors.secondary, size: 20),
          Expanded(
            child: Slider(
              value: _volume,
              onChanged: (v) => setState(() => _volume = v),
              activeColor: SensoryColors.secondary,
              inactiveColor: theme.scaffoldBackgroundColor,
            ),
          ),
          const Icon(Icons.volume_up_rounded, color: SensoryColors.secondary, size: 22),
          const SizedBox(width: 8),
          SizedBox(
            width: 44,
            child: Text(
              '${(_volume * 100).round()}%',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: SensoryColors.secondary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: _startSession,
          icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
          label: Text(
            AppLocalizations.of(context)?.soundStartBtn ?? 'Iniciar Terapia de Sonido',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: SensoryColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }

  void _showInfoDialog() {
    final theme = Theme.of(context);
    final cardColor = theme.cardTheme.color ?? theme.colorScheme.surface;
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n?.soundInfoTitle ?? '¿Qué es la Terapia de Sonido?',
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
        content: Text(
          l10n?.soundInfoContent ?? 'La terapia de sonido utiliza frecuencias específicas para inducir estados de relajación, enfoque o sueño profundo...',
          style: TextStyle(color: theme.textTheme.bodyMedium?.color),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              l10n?.rmpSessionFinishedBtn ?? 'Entendido',
              style: const TextStyle(color: SensoryColors.secondary),
            ),
          ),
        ],
      ),
    );
  }
}
