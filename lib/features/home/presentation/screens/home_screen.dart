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
import 'package:gtc6/features/breathing/presentation/screens/breathing_intro_screen.dart';
import 'package:gtc6/features/games/zen_paint/presentation/screens/zen_paint_screen.dart';
import 'package:gtc6/features/games/fidget_spinner/presentation/screens/fidget_spinner_screen.dart';
import 'package:gtc6/features/home/presentation/widgets/home_drawer.dart';
import 'package:gtc6/l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ProgressService.instance.recordActiveDay();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final routinesList = _getRoutines(l10n);

    return Scaffold(
      key: _scaffoldKey,
      drawer: const HomeDrawer(),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth <= 0) {
              return const SizedBox.shrink();
            }

            // Calculate exact 2-column width for mobile, or 3-4 columns for tablet
            final int columnCount = constraints.maxWidth >= 900
                ? 4
                : (constraints.maxWidth >= 600 ? 3 : 2);
            final double horizontalPadding = 24.0;
            final double cardSpacing = 14.0;
            final double totalSpacing = cardSpacing * (columnCount - 1);
            final double cardWidth =
                ((constraints.maxWidth -
                            (horizontalPadding * 2) -
                            totalSpacing) /
                        columnCount)
                    .clamp(0.0, double.infinity);

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24.0, 28.0, 24.0, 110.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AnimatedDrawerButton(
                        tooltip: MaterialLocalizations.of(
                          context,
                        ).openAppDrawerTooltip,
                        onPressed: () {
                          _scaffoldKey.currentState?.openDrawer();
                        },
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'GTC6',
                              style: theme.textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              l10n?.appSubtitle ??
                                  'Rutinas de regulación y bienestar sensorial',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: isDark
                                    ? SensoryColors.textLightSecondary
                                    : SensoryColors.textLight,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isDark
                              ? Icons.wb_sunny_rounded
                              : Icons.dark_mode_rounded,
                          color: theme.colorScheme.onSurface,
                        ),
                        tooltip: l10n?.toggleThemeTooltip ?? 'Alternar Tema',
                        onPressed: () {
                          ThemeController.instance.toggleTheme();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),

                  // Section 1: Numbered Onboarding Guide ("¿Qué puedes hacer con esta app?")
                  Text(
                    l10n?.guideTitle ?? '🌿 ¿QUÉ PUEDES LOGRAR CON ESTA APP?',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: SensoryColors.primary,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 156,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      children: [
                        _buildGuideCard(
                          number: '1',
                          title:
                              l10n?.guide1Title ??
                              'Calmar la Ansiedad al Instante',
                          subtitle:
                              l10n?.guide1Subtitle ??
                              'Respiración Científica Guiada',
                          description:
                              l10n?.guide1Desc ??
                              'Patrones con aval neurocientífico (4-7-8, Box Breathing, Huberman) para bajar el cortisol en minutos.',
                          icon: Icons.air_rounded,
                          color: SensoryColors.zenSage,
                        ),
                        const SizedBox(width: 14),
                        _buildGuideCard(
                          number: '2',
                          title: l10n?.guide2Title ?? 'Liberar Tensión Física',
                          subtitle:
                              l10n?.guide2Subtitle ??
                              'Relajación Muscular Progresiva',
                          description:
                              l10n?.guide2Desc ??
                              'Rutina Jacobson guiada paso a paso para soltar la rigidez en cuello, hombros, espalda y rostro.',
                          icon: Icons.accessibility_new_rounded,
                          color: SensoryColors.zenTeal,
                        ),
                        const SizedBox(width: 14),
                        _buildGuideCard(
                          number: '3',
                          title:
                              l10n?.guide3Title ??
                              'Sincronizar tus Ondas Cerebrales',
                          subtitle:
                              l10n?.guide3Subtitle ??
                              'Terapia de Sonido Binaural',
                          description:
                              l10n?.guide3Desc ??
                              'Frecuencias curativas y ritmos binaurales diseñados para enfocar tu mente o conciliar el sueño profundo.',
                          icon: Icons.graphic_eq_rounded,
                          color: SensoryColors.zenIndigo,
                        ),
                        const SizedBox(width: 14),
                        _buildGuideCard(
                          number: '4',
                          title:
                              l10n?.guide4Title ??
                              'Enfoque y Terapia de Arte Zen',
                          subtitle:
                              l10n?.guide4Subtitle ??
                              'Mindfulness Sensorial Activo',
                          description:
                              l10n?.guide4Desc ??
                              'Colorea mandalas, revienta burbujas o traza telarañas para disipar el estrés táctil y mental en el presente.',
                          icon: Icons.palette_rounded,
                          color: SensoryColors.zenAmber,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Section 2: 2-Column Routines Grid
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${l10n?.routinesSectionTitle ?? 'RUTINAS DISPONIBLES'} (${routinesList.length})',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? SensoryColors.textLightSecondary
                              : SensoryColors.textDark,
                          letterSpacing: 1.0,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: SensoryColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          l10n?.twoColumnsBadge ?? '2 Columnas',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: SensoryColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Wrap(
                    spacing: cardSpacing,
                    runSpacing: cardSpacing,
                    children: routinesList.map((routine) {
                      return SizedBox(
                        width: cardWidth,
                        child: _buildRoutineCard(
                          context,
                          title: routine.title,
                          category: routine.category,
                          description: routine.description,
                          icon: routine.icon,
                          color: routine.color,
                          destination: routine.destination,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGuideCard({
    required String number,
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 260,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Text(
                  number,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  subtitle.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, size: 20, color: color),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                height: 1.3,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutineCard(
    BuildContext context, {
    required String title,
    required String category,
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
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => destination),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(icon, size: 26, color: color),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.35,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  category.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: color,
                    letterSpacing: 0.6,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.68),
                    height: 1.3,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoutineItem {
  final String title;
  final String category;
  final String description;
  final IconData icon;
  final Color color;
  final Widget destination;

  const _RoutineItem({
    required this.title,
    required this.category,
    required this.description,
    required this.icon,
    required this.color,
    required this.destination,
  });
}

List<_RoutineItem> _getRoutines(AppLocalizations? l10n) => [
  _RoutineItem(
    title: l10n?.routineBreathingTitle ?? 'Respiración Científica',
    category: l10n?.routineBreathingCat ?? 'Sistema Nervioso',
    description:
        l10n?.routineBreathingDesc ??
        'Patrones con aval neurocientífico (4-7-8, Box Breathing, Huberman) para regular el ritmo vagal y bajar el cortisol.',
    icon: Icons.air_rounded,
    color: SensoryColors.zenSage,
    destination: const BreathingIntroScreen(),
  ),
  _RoutineItem(
    title: l10n?.routinePaintTitle ?? 'Arte Zen & Coloreo',
    category: l10n?.routinePaintCat ?? 'Mindfulness Táctil',
    description:
        l10n?.routinePaintDesc ??
        'Lienzo de coloreo con pincel, borrador, grosor/espesor variable y plantillas zen para disipar la ansiedad.',
    icon: Icons.palette_rounded,
    color: SensoryColors.zenAmber,
    destination: const ZenPaintScreen(),
  ),
  _RoutineItem(
    title: l10n?.routineRmpTitle ?? 'Relajación Muscular',
    category: l10n?.routineRmpCat ?? 'Alivio Somático',
    description:
        l10n?.routineRmpDesc ??
        'Rutina Jacobson guiada con animaciones bio-sensoriales y audio tonos para soltar la tensión física.',
    icon: Icons.accessibility_new_rounded,
    color: SensoryColors.zenTeal,
    destination: const RmpIntroScreen(),
  ),
  _RoutineItem(
    title: l10n?.routineSoundTitle ?? 'Terapia de Sonido',
    category: l10n?.routineSoundCat ?? 'Ondas y Sincronía',
    description:
        l10n?.routineSoundDesc ??
        'Frecuencias curativas y ritmos binaurales combinados para relajar la mente o conciliar el sueño.',
    icon: Icons.graphic_eq_rounded,
    color: SensoryColors.zenIndigo,
    destination: const SoundTherapySelectorScreen(),
  ),
  _RoutineItem(
    title: l10n?.routineBallsTitle ?? 'Bolas Sensoriales',
    category: l10n?.routineBallsCat ?? 'Calma Visual',
    description:
        l10n?.routineBallsDesc ??
        'Genera burbujas de colores que rebotan libremente y emiten sonidos suaves al tocar la pantalla.',
    icon: Icons.bubble_chart_rounded,
    color: SensoryColors.calmBlue,
    destination: const BallsScreen(),
  ),
  _RoutineItem(
    title: l10n?.routineBubblesTitle ?? 'Pop-It / Burbujas',
    category: l10n?.routineBubblesCat ?? 'Enfoque Táctil',
    description:
        l10n?.routineBubblesDesc ??
        'Presiona y revienta burbujas virtuales con respuestas táctiles suaves y sonidos relajantes.',
    icon: Icons.grid_view_rounded,
    color: SensoryColors.calmBlue,
    destination: const BubbleScreen(),
  ),
  _RoutineItem(
    title: l10n?.routineSpidersTitle ?? 'Arañas Relajantes',
    category: l10n?.routineSpidersCat ?? 'Tranquilidad Táctil',
    description:
        l10n?.routineSpidersDesc ??
        'Teje líneas y observa cómo las pequeñas arañas escalan y reparan sus redes en armonía visual.',
    icon: Icons.pest_control_rodent_rounded,
    color: SensoryColors.calmGreen,
    destination: const SpidersScreen(),
  ),
  _RoutineItem(
    title: l10n?.routineCockroachTitle ?? 'Cucaracha Aplastada',
    category: l10n?.routineCockroachCat ?? 'Descarga Activa',
    description:
        l10n?.routineCockroachDesc ??
        'Toca las cucarachas que corren por la pantalla para una rápida descarga motriz y reflejos.',
    icon: Icons.bug_report_rounded,
    color: SensoryColors.calmYellow,
    destination: const CockroachScreen(),
  ),
  _RoutineItem(
    title: l10n?.routineSpinnerTitle ?? 'Fidget Spinner',
    category: l10n?.routineSpinnerCat ?? 'Enfoque Cinético',
    description:
        l10n?.routineSpinnerDesc ??
        'Gira el spinner virtual y experimenta una sensación continua de rotación con vibración háptica suave.',
    icon: Icons.refresh_rounded,
    color: SensoryColors.calmPurple,
    destination: const FidgetSpinnerScreen(),
  ),
];
