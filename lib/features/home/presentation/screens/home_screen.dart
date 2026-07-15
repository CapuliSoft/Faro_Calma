import 'package:flutter/material.dart';
import 'package:gtc6/core/theme/colors.dart';
import 'package:gtc6/core/theme/theme_controller.dart';
import 'package:gtc6/features/games/balls/presentation/screens/balls_screen.dart';
import 'package:gtc6/features/games/bubble_wrap/presentation/screens/bubble_screen.dart';
import 'package:gtc6/features/games/spiders/presentation/screens/spiders_screen.dart';
import 'package:gtc6/features/sound_therapy/presentation/screens/sound_therapy_selector_screen.dart';
import 'package:gtc6/features/progress/domain/services/progress_service.dart';
import 'package:gtc6/features/games/cockroach/presentation/screens/cockroach_screen.dart';
import 'package:gtc6/features/rmp/presentation/screens/rmp_intro_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Register active day upon landing on Home Screen after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ProgressService.instance.recordActiveDay();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 600;
            final double rawWidth = isWide
                ? (constraints.maxWidth - 48 - 20) / 2
                : constraints.maxWidth - 48;
            final cardWidth = rawWidth < 0.0 ? 0.0 : rawWidth;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24.0, 32.0, 24.0, 110.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'GTC6',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Theme.of(context).brightness == Brightness.dark
                                  ? Icons.wb_sunny_rounded
                                  : Icons.dark_mode_rounded,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            tooltip: 'Alternar Tema',
                            onPressed: () {
                              ThemeController.instance.toggleTheme();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Espacio de juegos sensoriales y relajación.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? SensoryColors.textLightSecondary
                              : SensoryColors.textLight,
                        ),
                  ),
                  const SizedBox(height: 40),
                  Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: [
                      SizedBox(
                        width: cardWidth,
                        child: _buildGameCard(
                          context,
                          title: 'Bolas Sensoriales',
                          description: 'Toca la pantalla para crear burbujas de colores que rebotan libremente. Ideal para relajación visual.',
                          icon: Icons.bubble_chart_rounded,
                          color: SensoryColors.calmBlue,
                          destination: const BallsScreen(),
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: _buildGameCard(
                          context,
                          title: 'Pop-It / Burbujas',
                          description: 'Presiona y revienta las burbujas virtuales. Con respuestas táctiles suaves y sonidos relajantes.',
                          icon: Icons.grid_view_rounded,
                          color: SensoryColors.calmPink,
                          destination: const BubbleScreen(),
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: _buildGameCard(
                          context,
                          title: 'Arañas Relajantes',
                          description: 'Dibuja líneas para tejer hilos de telaraña y observa cómo las pequeñas arañas de colores escalan y juegan en ella.',
                          icon: Icons.pest_control_rodent_rounded,
                          color: SensoryColors.calmGreen,
                          destination: const SpidersScreen(),
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: _buildGameCard(
                          context,
                          title: 'Terapia de Sonido',
                          description: 'Frecuencias de sonido curativas combinadas con ritmos binaurales para relajarse o conciliar el sueño.',
                          icon: Icons.graphic_eq_rounded,
                          color: SensoryColors.calmPurple,
                          destination: const SoundTherapySelectorScreen(),
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: _buildGameCard(
                          context,
                          title: 'Cucaracha Aplastada',
                          description: 'Toca las cucarachas que corren por la pantalla para aplastarlas con sonidos interactivos y animaciones.',
                          icon: Icons.bug_report_rounded,
                          color: SensoryColors.calmYellow,
                          destination: const CockroachScreen(),
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: _buildGameCard(
                          context,
                          title: 'Relajación Muscular',
                          description: 'Rutina Jacobson guiada con animaciones bio-sensoriales y audio tonos para soltar la tensión física.',
                          icon: Icons.accessibility_new_rounded,
                          color: SensoryColors.calmPurple,
                          destination: const RmpIntroScreen(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGameCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required Widget destination,
  }) {
    final theme = Theme.of(context);
    final cardColor = theme.cardTheme.color ?? theme.colorScheme.surface;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => destination),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    icon,
                    size: 40,
                    color: Colors.black.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
