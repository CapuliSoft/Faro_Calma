import 'package:flutter/material.dart';
import 'package:gtc6/core/theme/colors.dart';
import 'package:gtc6/features/progress/domain/models/user_stats.dart';
import 'package:gtc6/features/progress/domain/services/progress_service.dart';
import 'package:gtc6/core/i18n/locale_controller.dart';
import 'package:gtc6/l10n/app_localizations.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  List<DateTime> _getCurrentWeekDates() {
    final now = DateTime.now();
    // Find the nearest Monday (1 = Monday, 7 = Sunday)
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return List.generate(7, (i) => monday.add(Duration(days: i)));
  }

  String _getDayLetter(int weekday) {
    switch (weekday) {
      case 1:
        return 'L';
      case 2:
        return 'M';
      case 3:
        return 'X';
      case 4:
        return 'J';
      case 5:
        return 'V';
      case 6:
        return 'S';
      case 7:
        return 'D';
      default:
        return '';
    }
  }

  void _showResetDialog(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: theme.cardTheme.color ?? theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.orangeAccent,
              size: 28,
            ),
            SizedBox(width: 10),
            Text('¿Reiniciar progreso?'),
          ],
        ),
        content: const Text(
          'Esto borrará todas tus rachas, minutos jugados y registros de actividades de forma permanente. ¿Estás seguro de que quieres comenzar de cero?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancelar',
              style: TextStyle(color: theme.textTheme.bodyMedium?.color),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await ProgressService.instance.resetProgress();
              if (context.mounted) {
                Navigator.of(context).pop(); // Close dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('¡Tu progreso ha sido reiniciado! 🌟'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: SensoryColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Sí, reiniciar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Mi Progreso',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: Listenable.merge([
            ProgressService.instance,
            LocaleController.instance,
          ]),
          builder: (context, _) {
            final stats = ProgressService.instance.stats;
            return ListView(
              padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 110.0),
              children: [
                _buildStreakCard(context, stats),
                const SizedBox(height: 24),
                _buildStatsGrid(context, stats),
                const SizedBox(height: 24),
                _buildWeeklyCalendar(context, stats),
                const SizedBox(height: 24),
                _buildActivityBreakdown(context, stats),
                const SizedBox(height: 24),
                _buildLanguageSettingsCard(context),
                const SizedBox(height: 36),
                _buildResetButton(context),
                const SizedBox(height: 40),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStreakCard(BuildContext context, UserStats stats) {
    final theme = Theme.of(context);
    final cardColor = theme.cardTheme.color ?? theme.colorScheme.surface;
    final isDark = theme.brightness == Brightness.dark;

    final streak = stats.streakCount;
    String motivationMsg = '¡Comienza hoy tu racha diaria!';
    if (streak == 1) {
      motivationMsg = '¡Buen inicio! Vuelve mañana para continuar.';
    } else if (streak > 1 && streak < 4) {
      motivationMsg = '¡Fantástico! Te estás relajando con constancia.';
    } else if (streak >= 4) {
      motivationMsg = '¡Increíble constancia! Eres un experto en relajación.';
    }

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(28),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orangeAccent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_fire_department_rounded,
              color: Colors.orangeAccent,
              size: 44,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  streak == 0
                      ? 'Sin Racha'
                      : '$streak ${streak == 1 ? "Día" : "Días"} de Racha',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 6),
                Text(motivationMsg, style: theme.textTheme.bodyMedium),
                if (stats.longestStreak > 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Racha más larga: ${stats.longestStreak} días',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.bodyMedium?.color?.withValues(
                        alpha: 0.7,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, UserStats stats) {
    final double minutes = stats.totalPlaytimeMinutes;
    final int hoursInt = minutes ~/ 60;
    final int minsInt = (minutes % 60).round();

    final String timeStr = hoursInt > 0
        ? '${hoursInt}h ${minsInt}m'
        : '$minsInt min';

    return Row(
      children: [
        Expanded(
          child: _buildSingleStatCard(
            context,
            icon: Icons.access_time_rounded,
            value: timeStr,
            label: 'Tiempo Relajación',
            color: SensoryColors.calmBlue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSingleStatCard(
            context,
            icon: Icons.check_circle_outline_rounded,
            value: '${stats.totalSessions}',
            label: 'Sesiones Totales',
            color: SensoryColors.calmGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildSingleStatCard(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final cardColor = theme.cardTheme.color ?? theme.colorScheme.surface;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color.withValues(alpha: 0.95), size: 22),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: theme.textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyCalendar(BuildContext context, UserStats stats) {
    final theme = Theme.of(context);
    final cardColor = theme.cardTheme.color ?? theme.colorScheme.surface;
    final isDark = theme.brightness == Brightness.dark;

    final weekDates = _getCurrentWeekDates();

    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Actividad Semanal',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: weekDates.map((date) {
              final dateStr = date.toIso8601String().split('T')[0];
              final isActive = stats.activeDays.contains(dateStr);
              final isToday =
                  dateStr == DateTime.now().toIso8601String().split('T')[0];

              return Column(
                children: [
                  Text(
                    _getDayLetter(date.weekday),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isToday
                          ? SensoryColors.secondary
                          : theme.textTheme.bodyMedium?.color?.withValues(
                              alpha: 0.6,
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive
                          ? SensoryColors.primary
                          : (isToday
                                ? SensoryColors.primary.withValues(alpha: 0.15)
                                : Colors.transparent),
                      border: Border.all(
                        color: isActive
                            ? SensoryColors.primary
                            : (isToday
                                  ? SensoryColors.primary
                                  : (isDark ? Colors.white24 : Colors.black12)),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: isActive
                          ? const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 20,
                            )
                          : Text(
                              '${date.day}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isToday
                                    ? SensoryColors.primary
                                    : theme.textTheme.bodyMedium?.color,
                              ),
                            ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityBreakdown(BuildContext context, UserStats stats) {
    final theme = Theme.of(context);
    final cardColor = theme.cardTheme.color ?? theme.colorScheme.surface;
    final isDark = theme.brightness == Brightness.dark;

    final counts = stats.activityCounts;
    final int balls = counts['balls'] ?? 0;
    final int popit = counts['popit'] ?? 0;
    final int spiders = counts['spiders'] ?? 0;
    final int sound = counts['sound_therapy'] ?? 0;
    final int cockroach = counts['cockroach'] ?? 0;
    final int rmp = counts['rmp'] ?? 0;
    final int total = balls + popit + spiders + sound + cockroach + rmp;

    return Container(
      padding: const EdgeInsets.all(22),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Desglose de Sesiones',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildActivityBar(
            context,
            title: 'Bolas Sensoriales',
            count: balls,
            total: total,
            color: SensoryColors.calmBlue,
          ),
          const SizedBox(height: 14),
          _buildActivityBar(
            context,
            title: 'Pop-It / Burbujas',
            count: popit,
            total: total,
            color: SensoryColors.calmPink,
          ),
          const SizedBox(height: 14),
          _buildActivityBar(
            context,
            title: 'Arañas Relajantes',
            count: spiders,
            total: total,
            color: SensoryColors.calmGreen,
          ),
          const SizedBox(height: 14),
          _buildActivityBar(
            context,
            title: 'Terapia de Sonido',
            count: sound,
            total: total,
            color: SensoryColors.calmPurple,
          ),
          const SizedBox(height: 14),
          _buildActivityBar(
            context,
            title: 'Cucaracha Aplastada',
            count: cockroach,
            total: total,
            color: SensoryColors.calmYellow,
          ),
          const SizedBox(height: 14),
          _buildActivityBar(
            context,
            title: 'Relajación Muscular',
            count: rmp,
            total: total,
            color: Colors.purpleAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityBar(
    BuildContext context, {
    required String title,
    required int count,
    required int total,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final percent = total > 0 ? count / total : 0.0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            Text(
              '$count ${count == 1 ? "sesión" : "sesiones"}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 10,
            backgroundColor: theme.scaffoldBackgroundColor,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageSettingsCard(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.cardTheme.color ?? theme.colorScheme.surface;
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final currentCode = LocaleController.instance.locale.languageCode;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.06),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
            blurRadius: 18,
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
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: SensoryColors.zenIndigo.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.language_rounded,
                  color: SensoryColors.zenIndigo,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n?.languageSettingsTitle ?? 'Idioma de la Aplicación',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n?.languageSettingsSubtitle ??
                          'Elige el idioma para todas las rutinas',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.65,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _buildLangOption(
                  context: context,
                  label: '🇪🇸 Español (ES)',
                  isSelected: currentCode == 'es',
                  onTap: () =>
                      LocaleController.instance.setLocale(const Locale('es')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildLangOption(
                  context: context,
                  label: '🇺🇸 English (EN)',
                  isSelected: currentCode == 'en',
                  onTap: () =>
                      LocaleController.instance.setLocale(const Locale('en')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLangOption({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final activeColor = SensoryColors.primary;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? activeColor : theme.dividerColor,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  fontSize: 13.0,
                  color: isSelected ? activeColor : theme.colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Icon(Icons.check_circle_rounded, size: 16, color: activeColor),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResetButton(BuildContext context) {
    return Center(
      child: TextButton.icon(
        onPressed: () => _showResetDialog(context),
        icon: const Icon(
          Icons.delete_sweep_rounded,
          color: SensoryColors.error,
        ),
        label: const Text(
          'Reiniciar mi progreso',
          style: TextStyle(
            color: SensoryColors.error,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: SensoryColors.error.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
