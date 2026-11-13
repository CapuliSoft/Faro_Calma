import 'package:flutter/material.dart';
import 'package:gtc6/core/theme/colors.dart';
import 'package:gtc6/features/info/presentation/screens/app_info_screen.dart';
import 'package:gtc6/features/info/presentation/screens/welcome_guide_screen.dart';
import 'package:gtc6/features/journal/presentation/screens/journal_screen.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.pop(context); // Close the drawer first
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEs = Localizations.localeOf(context).languageCode == 'es';

    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drawer Header
            Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    SensoryColors.primary.withValues(
                      alpha: isDark ? 0.28 : 0.16,
                    ),
                    SensoryColors.zenTeal.withValues(
                      alpha: isDark ? 0.20 : 0.08,
                    ),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: SensoryColors.primary.withValues(alpha: 0.25),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: SensoryColors.primary.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.spa_rounded,
                      color: SensoryColors.primary,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'GTC6',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isEs
                        ? 'Bienestar y regulación sensorial'
                        : 'Sensory wellness & regulation',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? SensoryColors.textLightSecondary
                          : SensoryColors.textLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // Option 1: Welcome & What the app does
            _DrawerTile(
              icon: Icons.waving_hand_rounded,
              iconColor: SensoryColors.zenSage,
              title: isEs ? 'Bienvenida y Guía' : 'Welcome & Guide',
              subtitle: isEs
                  ? 'Descubre qué puedes hacer en la app'
                  : 'Discover what the app does',
              onTap: () => _navigateTo(context, const WelcomeGuideScreen()),
            ),

            // Option 2: Personal Journal
            _DrawerTile(
              icon: Icons.menu_book_rounded,
              iconColor: SensoryColors.zenTeal,
              title: isEs ? 'Diario Personal' : 'Personal Journal',
              subtitle: isEs
                  ? 'Guarda tus notas y pensamientos'
                  : 'Save your notes and thoughts',
              onTap: () => _navigateTo(context, const JournalScreen()),
            ),

            // Option 3: App Information
            _DrawerTile(
              icon: Icons.info_outline_rounded,
              iconColor: SensoryColors.zenIndigo,
              title: isEs ? 'Información de la App' : 'App Information',
              subtitle: isEs
                  ? 'Detalles, propósito y privacidad'
                  : 'Details, purpose & privacy',
              onTap: () => _navigateTo(context, const AppInfoScreen()),
            ),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'v1.0.0 • GTC6',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withValues(
                    alpha: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _DrawerTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, size: 20),
        onTap: onTap,
      ),
    );
  }
}

/// Animated amber/yellow hamburger button to draw attention to the side drawer.
class AnimatedDrawerButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String tooltip;

  const AnimatedDrawerButton({
    super.key,
    required this.onPressed,
    required this.tooltip,
  });

  @override
  State<AnimatedDrawerButton> createState() => _AnimatedDrawerButtonState();
}

class _AnimatedDrawerButtonState extends State<AnimatedDrawerButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _glowAnim = Tween<double>(
      begin: 0.18,
      end: 0.42,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const amberColor = Color(0xFFFFB300);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnim.value,
          child: Container(
            decoration: BoxDecoration(
              color: amberColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: amberColor.withValues(alpha: _glowAnim.value + 0.25),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: amberColor.withValues(alpha: _glowAnim.value),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: child,
          ),
        );
      },
      child: IconButton(
        icon: const Icon(Icons.menu_rounded, color: amberColor),
        tooltip: widget.tooltip,
        onPressed: widget.onPressed,
      ),
    );
  }
}
