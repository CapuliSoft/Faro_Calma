import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gtc6/core/theme/colors.dart';
import 'package:gtc6/features/home/presentation/screens/home_screen.dart';
import 'package:gtc6/features/sound_therapy/presentation/screens/sound_therapy_selector_screen.dart';
import 'package:gtc6/features/progress/presentation/screens/progress_screen.dart';
import 'package:gtc6/features/rmp/presentation/screens/rmp_intro_screen.dart';
import 'package:gtc6/features/breathing/presentation/screens/breathing_intro_screen.dart';
import 'package:gtc6/l10n/app_localizations.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const SoundTherapySelectorScreen(),
    const RmpIntroScreen(),
    const BreathingIntroScreen(),
    const ProgressScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // Use Stack to display the pages and overlay the floating bottom navigation bar
      body: Stack(
        children: [
          IndexedStack(index: _currentIndex, children: _pages),
          Positioned(
            left: 14,
            right: 14,
            bottom: 16,
            child: _buildFloatingNavbar(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingNavbar(bool isDark) {
    final theme = Theme.of(context);
    final cardColor = theme.cardTheme.color ?? theme.colorScheme.surface;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.05);

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: cardColor.withValues(alpha: isDark ? 0.88 : 0.92),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                0,
                Icons.fact_check_rounded,
                AppLocalizations.of(context)?.tabRoutines ?? 'Rutinas',
              ),
              _buildNavItem(
                1,
                Icons.graphic_eq_rounded,
                AppLocalizations.of(context)?.tabSounds ?? 'Sonidos',
              ),
              _buildNavItem(
                2,
                Icons.accessibility_new_rounded,
                AppLocalizations.of(context)?.tabRelaxation ?? 'Relajación',
              ),
              _buildNavItem(
                3,
                Icons.air_rounded,
                AppLocalizations.of(context)?.tabBreathing ?? 'Respiración',
              ),
              _buildNavItem(
                4,
                Icons.bar_chart_rounded,
                AppLocalizations.of(context)?.tabProgress ?? 'Progreso',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final theme = Theme.of(context);
    final isSelected = _currentIndex == index;
    final activeColor = SensoryColors.primary;
    final inactiveColor = theme.textTheme.bodyMedium?.color?.withValues(
      alpha: 0.55,
    );

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? activeColor : inactiveColor,
              size: 22,
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: SizedBox(
                width: isSelected ? null : 0,
                child: Padding(
                  padding: const EdgeInsets.only(left: 6.0),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: activeColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
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
