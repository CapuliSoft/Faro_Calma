import 'package:flutter/material.dart';
import 'package:gtc6/core/theme/colors.dart';
import '../../domain/models/rmp_models.dart';
import 'rmp_session_screen.dart';
import 'package:gtc6/l10n/app_localizations.dart';

enum RmpRoutine {
  cuerpoCompleto(
    'Cuerpo Completo',
    'Todas las 14 zonas musculares para una relajación profunda y total.',
    14,
  ),
  express(
    'Express (Básico)',
    '4 zonas principales (manos, frente, hombros, pies) ideal para calma rápida.',
    4,
  ),
  superior(
    'Tren Superior',
    '8 zonas superiores (brazos, hombros, cara, cuello) para liberar tensión acumulada.',
    8,
  ),
  inferior(
    'Tren Inferior',
    '6 zonas inferiores (torso, piernas, pantorrillas y pies) para descansar el cuerpo.',
    6,
  );

  final String title;
  final String description;
  final int count;
  const RmpRoutine(this.title, this.description, this.count);
}

extension LocalizedRmpRoutine on RmpRoutine {
  String getLocalizedTitle(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (this) {
      case RmpRoutine.cuerpoCompleto:
        return l10n?.rmp_routine_cuerpoCompleto_title ?? title;
      case RmpRoutine.express:
        return l10n?.rmp_routine_express_title ?? title;
      case RmpRoutine.superior:
        return l10n?.rmp_routine_superior_title ?? title;
      case RmpRoutine.inferior:
        return l10n?.rmp_routine_inferior_title ?? title;
    }
  }

  String getLocalizedDescription(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (this) {
      case RmpRoutine.cuerpoCompleto:
        return l10n?.rmp_routine_cuerpoCompleto_desc ?? description;
      case RmpRoutine.express:
        return l10n?.rmp_routine_express_desc ?? description;
      case RmpRoutine.superior:
        return l10n?.rmp_routine_superior_desc ?? description;
      case RmpRoutine.inferior:
        return l10n?.rmp_routine_inferior_desc ?? description;
    }
  }
}

class RmpIntroScreen extends StatefulWidget {
  const RmpIntroScreen({super.key});

  @override
  State<RmpIntroScreen> createState() => _RmpIntroScreenState();
}

class _RmpIntroScreenState extends State<RmpIntroScreen> {
  RmpRoutine _selectedRoutine = RmpRoutine.express;
  int _selectedDurationMinutes = 3;
  bool _soundEnabled = true;

  List<MuscleGroup> _getSelectedMuscleGroups() {
    switch (_selectedRoutine) {
      case RmpRoutine.express:
        return [
          kRmpMuscleGroups[0], // Mano derecha
          kRmpMuscleGroups[4], // Frente
          kRmpMuscleGroups[8], // Hombros
          kRmpMuscleGroups[13], // Pies
        ];
      case RmpRoutine.superior:
        return kRmpMuscleGroups
            .where(
              (g) =>
                  g.category == 'Brazos' ||
                  g.category == 'Cara y Cabeza' ||
                  g.category == 'Cuello y Hombros',
            )
            .toList();
      case RmpRoutine.inferior:
        return kRmpMuscleGroups
            .where(
              (g) => g.category == 'Torso' || g.category == 'Piernas y Pies',
            )
            .toList();
      case RmpRoutine.cuerpoCompleto:
        return List<MuscleGroup>.from(kRmpMuscleGroups);
    }
  }

  void _startRmp() {
    final groups = _getSelectedMuscleGroups();
    final config = RmpSessionConfig(
      activeGroups: groups,
      totalDurationSeconds: _selectedDurationMinutes * 60,
      soundEnabled: _soundEnabled,
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RmpSessionScreen(config: config)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final isEs = Localizations.localeOf(context).languageCode == 'es';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n?.rmpIntroTitle ?? 'Relajación Muscular',
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
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 110),
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: SensoryColors.zenTeal.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: SensoryColors.zenTeal.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.accessibility_new_rounded,
                    color: SensoryColors.zenTeal,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n?.rmpIntroBanner ??
                          'La técnica de Jacobson consiste en tensar conscientemente grupos musculares y luego soltarlos...',
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
            _buildSectionHeader(
              isEs ? '1. SELECCIONAR RUTINA' : '1. SELECT ROUTINE',
            ),
            const SizedBox(height: 12),
            _buildRoutinesGrid(isDark),
            const SizedBox(height: 28),
            _buildSectionHeader(
              isEs ? '2. SELECCIONAR DURACIÓN' : '2. SELECT DURATION',
            ),
            const SizedBox(height: 12),
            _buildDurationsRow(isDark),
            const SizedBox(height: 28),
            _buildSectionHeader(isEs ? '3. AUDIO GUÍA' : '3. AUDIO GUIDE'),
            const SizedBox(height: 12),
            _buildSoundSwitchCard(isDark),
            const SizedBox(height: 36),
            _buildStartButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: SensoryColors.secondary,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildRoutinesGrid(bool isDark) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final cardColor = theme.cardTheme.color ?? theme.colorScheme.surface;

    return Column(
      children: RmpRoutine.values.map((routine) {
        final selected = _selectedRoutine == routine;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Material(
            color: selected
                ? SensoryColors.primary.withValues(alpha: isDark ? 0.20 : 0.15)
                : cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: selected
                    ? SensoryColors.primary
                    : (isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.black.withValues(alpha: 0.03)),
                width: selected ? 2.0 : 1.0,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              selected: selected,
              selectedColor: SensoryColors.primary,
              onTap: () => setState(() => _selectedRoutine = routine),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 8,
              ),
              title: Text(
                routine.getLocalizedTitle(context),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: selected
                      ? SensoryColors.primary
                      : theme.colorScheme.onSurface,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  routine.getLocalizedDescription(context),
                  style: TextStyle(
                    fontSize: 12.5,
                    color: theme.textTheme.bodyMedium?.color?.withValues(
                      alpha: selected ? 0.9 : 0.7,
                    ),
                    height: 1.3,
                  ),
                ),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? SensoryColors.primary.withValues(alpha: 0.2)
                      : (isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.black.withValues(alpha: 0.03)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${routine.count} ${l10n?.rmpZones ?? "zonas"}',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: selected
                        ? SensoryColors.primary
                        : theme.textTheme.bodyMedium?.color?.withValues(
                            alpha: 0.8,
                          ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDurationsRow(bool isDark) {
    final theme = Theme.of(context);
    final cardColor = theme.cardTheme.color ?? theme.colorScheme.surface;
    final durations = [1, 2, 3, 5];

    return Row(
      children: durations.map((mins) {
        final selected = _selectedDurationMinutes == mins;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: GestureDetector(
              onTap: () => setState(() => _selectedDurationMinutes = mins),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 52,
                decoration: BoxDecoration(
                  color: selected
                      ? SensoryColors.primary.withValues(
                          alpha: isDark ? 0.20 : 0.15,
                        )
                      : cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selected
                        ? SensoryColors.primary
                        : (isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.black.withValues(alpha: 0.03)),
                    width: selected ? 1.8 : 1.0,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$mins min',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: selected
                          ? SensoryColors.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSoundSwitchCard(bool isDark) {
    final theme = Theme.of(context);
    final cardColor = theme.cardTheme.color ?? theme.colorScheme.surface;
    final l10n = AppLocalizations.of(context);

    return Material(
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
      child: SwitchListTile(
        title: Text(
          l10n?.rmpSoundLabel ?? 'Efectos de sonido programados',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5),
        ),
        subtitle: Text(
          l10n?.rmpSoundSubtitle ??
              'Tocar tonos auditivos al inicio de la contracción y al soltar la relajación.',
          style: const TextStyle(fontSize: 12.5),
        ),
        value: _soundEnabled,
        activeThumbColor: SensoryColors.primary,
        onChanged: (val) {
          setState(() {
            _soundEnabled = val;
          });
        },
      ),
    );
  }

  Widget _buildStartButton() {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton.icon(
        onPressed: _startRmp,
        icon: const Icon(
          Icons.play_arrow_rounded,
          color: Colors.white,
          size: 24,
        ),
        label: Text(
          AppLocalizations.of(context)?.rmpStartBtn ??
              'Iniciar Relajación Muscular',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: SensoryColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
