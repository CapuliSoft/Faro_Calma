import 'package:flutter/material.dart';
import 'package:gtc6/core/theme/colors.dart';
import '../../domain/models/rmp_models.dart';
import 'rmp_session_screen.dart';

enum RmpRoutine {
  cuerpoCompleto('Cuerpo Completo', 'Todas las 14 zonas musculares para una relajación profunda y total.', 14),
  express('Express (Básico)', '4 zonas principales (manos, frente, hombros, pies) ideal para calma rápida.', 4),
  superior('Tren Superior', '8 zonas superiores (brazos, hombros, cara, cuello) para liberar tensión acumulada.', 8),
  inferior('Tren Inferior', '6 zonas inferiores (torso, piernas, pantorrillas y pies) para descansar el cuerpo.', 6);

  final String title;
  final String description;
  final int count;
  const RmpRoutine(this.title, this.description, this.count);
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
        return kRmpMuscleGroups.where((g) => 
          g.category == 'Brazos' || 
          g.category == 'Cara y Cabeza' || 
          g.category == 'Cuello y Hombros'
        ).toList();
      case RmpRoutine.inferior:
        return kRmpMuscleGroups.where((g) => 
          g.category == 'Torso' || 
          g.category == 'Piernas y Pies'
        ).toList();
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
      MaterialPageRoute(
        builder: (_) => RmpSessionScreen(config: config),
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
        title: const Text(
          'Relajación Muscular',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 110),
          children: [
            _buildConceptCard(isDark),
            const SizedBox(height: 28),
            _buildSectionHeader('1. SELECCIONAR RUTINA'),
            const SizedBox(height: 12),
            _buildRoutinesGrid(isDark),
            const SizedBox(height: 28),
            _buildSectionHeader('2. SELECCIONAR DURACIÓN'),
            const SizedBox(height: 12),
            _buildDurationsRow(isDark),
            const SizedBox(height: 28),
            _buildSectionHeader('3. AUDIO GUÍA'),
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

  Widget _buildConceptCard(bool isDark) {
    final theme = Theme.of(context);
    final cardColor = theme.cardTheme.color ?? theme.colorScheme.surface;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: SensoryColors.calmPurple.withValues(alpha: isDark ? 0.25 : 0.6),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.accessibility_new_rounded,
              color: SensoryColors.calmPurple,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Relajación Muscular Progresiva (RMP)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'La RMP consiste en tensar suavemente un grupo muscular durante unos segundos y luego liberarlo por completo. Te ayuda a reconocer la tensión física del cuerpo y soltarla para inducir un estado de calma mental profundo.',
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutinesGrid(bool isDark) {
    final theme = Theme.of(context);
    final cardColor = theme.cardTheme.color ?? theme.colorScheme.surface;

    return Column(
      children: RmpRoutine.values.map((routine) {
        final selected = _selectedRoutine == routine;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Container(
            decoration: BoxDecoration(
              color: selected
                  ? SensoryColors.primary.withValues(alpha: isDark ? 0.20 : 0.15)
                  : cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected
                    ? SensoryColors.primary
                    : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03)),
                width: selected ? 2.0 : 1.0,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                selected: selected,
                selectedColor: SensoryColors.primary,
                onTap: () => setState(() => _selectedRoutine = routine),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              title: Text(
                routine.title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: selected ? SensoryColors.primary : theme.colorScheme.onSurface,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  routine.description,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: selected ? 0.9 : 0.7),
                    height: 1.3,
                  ),
                ),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: selected
                      ? SensoryColors.primary.withValues(alpha: 0.2)
                      : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${routine.count} zonas',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: selected ? SensoryColors.primary : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
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
                      ? SensoryColors.primary.withValues(alpha: isDark ? 0.20 : 0.15)
                      : cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selected
                        ? SensoryColors.primary
                        : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03)),
                    width: selected ? 1.8 : 1.0,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$mins min',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: selected ? SensoryColors.primary : theme.colorScheme.onSurface,
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

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
        ),
      ),
      child: SwitchListTile(
        title: const Text(
          'Efectos de sonido programados',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5),
        ),
        subtitle: const Text(
          'Tocar tonos auditivos al inicio de la contracción y al soltar la relajación.',
          style: TextStyle(fontSize: 12.5),
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
        icon: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
        label: const Text(
          'Iniciar Relajación Muscular',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
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
