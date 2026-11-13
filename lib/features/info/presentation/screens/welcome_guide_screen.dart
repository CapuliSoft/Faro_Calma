import 'package:flutter/material.dart';
import 'package:gtc6/core/theme/colors.dart';

class WelcomeGuideScreen extends StatelessWidget {
  const WelcomeGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEs = Localizations.localeOf(context).languageCode == 'es';
    final cardColor = theme.cardTheme.color ?? theme.colorScheme.surface;

    final features = [
      (
        number: '1',
        title: isEs
            ? 'Respiración Científica Guiada'
            : 'Guided Scientific Breathing',
        desc: isEs
            ? 'Ejercicios como 4-7-8, Box Breathing y suspiro fisiológico para calmar el sistema nervioso en pocos minutos.'
            : 'Patterns like 4-7-8, Box Breathing, and physiological sigh to calm your nervous system in minutes.',
        icon: Icons.air_rounded,
        color: SensoryColors.zenSage,
      ),
      (
        number: '2',
        title: isEs
            ? 'Relajación Muscular Progresiva'
            : 'Progressive Muscle Relaxation',
        desc: isEs
            ? 'Rutina guiada paso a paso para liberar tensión acumulada en hombros, cuello, espalda y rostro.'
            : 'Step-by-step guided routine to release tension stored in shoulders, neck, back, and face.',
        icon: Icons.accessibility_new_rounded,
        color: SensoryColors.zenTeal,
      ),
      (
        number: '3',
        title: isEs ? 'Terapia de Sonido Binaural' : 'Binaural Sound Therapy',
        desc: isEs
            ? 'Paisajes y frecuencias diseñadas para acompañar la concentración, el descanso o la meditación.'
            : 'Soundscapes and frequencies designed to support focus, rest, or meditation.',
        icon: Icons.graphic_eq_rounded,
        color: SensoryColors.zenIndigo,
      ),
      (
        number: '4',
        title: isEs ? 'Lienzo Libre Zen' : 'Zen Paint Canvas',
        desc: isEs
            ? 'Dibuja libremente o colorea mandalas en modo inmersivo con herramientas flotantes y exportación a imagen.'
            : 'Draw freely or color mandalas in immersive mode with floating tools and image export.',
        icon: Icons.palette_rounded,
        color: SensoryColors.zenAmber,
      ),
      (
        number: '5',
        title: isEs ? 'Juegos Sensoriales Táctiles' : 'Tactile Sensory Games',
        desc: isEs
            ? 'Burbujas Pop-It, esferas relajantes, telarañas interactivas y fidget spinner con respuesta háptica suave.'
            : 'Pop-It bubbles, calming spheres, interactive webs, and fidget spinner with gentle haptic feedback.',
        icon: Icons.touch_app_rounded,
        color: SensoryColors.zenCyan,
      ),
      (
        number: '6',
        title: isEs
            ? 'Diario Personal y Progreso'
            : 'Personal Journal & Progress',
        desc: isEs
            ? 'Registra tus pensamientos o estados de ánimo en tu diario privado y observa tus rachas diarias.'
            : 'Record your thoughts and moods in your private journal while tracking daily streaks.',
        icon: Icons.menu_book_rounded,
        color: SensoryColors.primary,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEs ? 'Bienvenida' : 'Welcome',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: SensoryColors.primary.withValues(
                  alpha: isDark ? 0.22 : 0.12,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: SensoryColors.primary.withValues(alpha: 0.25),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.waving_hand_rounded,
                        color: SensoryColors.primary,
                        size: 28,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          isEs ? '¡Bienvenido a GTC6!' : 'Welcome to GTC6!',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isEs
                        ? 'Este es tu espacio seguro para hacer una pausa, regular tu ritmo y reconectar contigo. Aquí tienes todo lo que puedes hacer en la app:'
                        : 'This is your safe space to pause, regulate your pace, and reconnect. Here is everything you can do in the app:',
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            Text(
              isEs ? '¿QUÉ PUEDES HACER AQUÍ?' : 'WHAT CAN YOU DO HERE?',
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: SensoryColors.primary,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),

            ...features.map((item) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
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
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: item.color.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(item.icon, color: item.color, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${item.number}. ${item.title}',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.desc,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 13,
                              height: 1.4,
                              color: theme.textTheme.bodyMedium?.color
                                  ?.withValues(alpha: 0.78),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
