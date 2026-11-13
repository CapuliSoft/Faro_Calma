import 'package:flutter/material.dart';
import 'package:gtc6/core/theme/colors.dart';

class AppInfoScreen extends StatelessWidget {
  const AppInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEs = Localizations.localeOf(context).languageCode == 'es';
    final cardColor = theme.cardTheme.color ?? theme.colorScheme.surface;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEs ? 'Información de la App' : 'App Information',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero Identity Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    SensoryColors.primary.withValues(
                      alpha: isDark ? 0.28 : 0.16,
                    ),
                    SensoryColors.zenTeal.withValues(
                      alpha: isDark ? 0.2 : 0.08,
                    ),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: SensoryColors.primary.withValues(alpha: 0.25),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: SensoryColors.primary.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.spa_rounded,
                      size: 34,
                      color: SensoryColors.primary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'GTC6',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isEs
                        ? 'Rutinas de regulación y bienestar sensorial'
                        : 'Sensory regulation & wellness routines',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? SensoryColors.textLightSecondary
                          : SensoryColors.textLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: SensoryColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isEs ? 'Versión 1.0.0' : 'Version 1.0.0',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: SensoryColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _InfoCard(
              cardColor: cardColor,
              isDark: isDark,
              icon: Icons.psychology_alt_rounded,
              iconColor: SensoryColors.zenTeal,
              title: isEs ? 'Propósito' : 'Purpose',
              body: isEs
                  ? 'GTC6 reúne herramientas prácticas de regulación emocional, respiración guiada, relajación muscular, terapia sonora y juegos sensoriales suaves para acompañarte en momentos de estrés o sobrecarga.'
                  : 'GTC6 brings together practical tools for emotional regulation, guided breathing, muscle relaxation, sound therapy, and gentle sensory games to support you during stress or overload.',
            ),
            const SizedBox(height: 14),

            _InfoCard(
              cardColor: cardColor,
              isDark: isDark,
              icon: Icons.lock_outline_rounded,
              iconColor: SensoryColors.zenSage,
              title: isEs
                  ? 'Privacidad y Datos Locales'
                  : 'Privacy & Local Data',
              body: isEs
                  ? 'Tu progreso, rachas y notas del diario personal se almacenan directamente en tu dispositivo de forma privada, sin compartir información personal con terceros.'
                  : 'Your progress, streaks, and personal journal notes are stored privately on your device without sharing personal data with third parties.',
            ),
            const SizedBox(height: 14),

            _InfoCard(
              cardColor: cardColor,
              isDark: isDark,
              icon: Icons.architecture_rounded,
              iconColor: SensoryColors.zenIndigo,
              title: isEs ? 'Espacio en Evolución' : 'Growing Space',
              body: isEs
                  ? 'Esta sección está preparada para ampliar detalles de créditos, enlaces de soporte y futuras funciones conectadas.'
                  : 'This section is designed to grow with credits, support links, and upcoming connected features.',
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final Color cardColor;
  final bool isDark;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;

  const _InfoCard({
    required this.cardColor,
    required this.isDark,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.45,
                    color: theme.textTheme.bodyMedium?.color?.withValues(
                      alpha: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
