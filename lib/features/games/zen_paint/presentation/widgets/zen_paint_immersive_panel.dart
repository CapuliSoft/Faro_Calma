import 'package:flutter/material.dart';
import '../controllers/zen_paint_controller.dart';
import 'package:gtc6/core/theme/colors.dart';

class ZenPaintImmersivePanel extends StatelessWidget {
  final Animation<double> immersiveAnim;
  final VoidCallback onExport;
  final VoidCallback onExit;

  const ZenPaintImmersivePanel({
    super.key,
    required this.immersiveAnim,
    required this.onExport,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEs = Localizations.localeOf(context).languageCode == 'es';
    final controller = ZenPaintController();

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (!controller.immersiveMode) return const SizedBox.shrink();

        final screenSize = MediaQuery.of(context).size;
        final offset =
            controller.floatingPanelOffset ??
            Offset(screenSize.width - 58, screenSize.height / 2 - 140);

        return Positioned(
          left: offset.dx,
          top: offset.dy,
          child: FadeTransition(
            opacity: immersiveAnim,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
              decoration: BoxDecoration(
                color: (isDark ? Colors.black : Colors.white).withValues(
                  alpha: 0.55,
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : Colors.black.withValues(alpha: 0.08),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanUpdate: (details) {
                      final current =
                          controller.floatingPanelOffset ??
                          Offset(
                            screenSize.width - 58,
                            screenSize.height / 2 - 140,
                          );
                      controller.updateFloatingPanelOffset(
                        Offset(
                          (current.dx + details.delta.dx).clamp(
                            0.0,
                            screenSize.width - 54,
                          ),
                          (current.dy + details.delta.dy).clamp(
                            0.0,
                            screenSize.height - 280,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 4,
                        bottom: 10,
                        left: 10,
                        right: 10,
                      ),
                      child: Container(
                        width: 24,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.4)
                              : Colors.black.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  _buildFloatingButton(
                    context: context,
                    icon: Icons.fullscreen_exit_rounded,
                    tooltip: isEs ? 'Salir del Modo Pro' : 'Exit Pro Mode',
                    onTap: controller.toggleImmersiveMode,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 6),
                  _buildFloatingButton(
                    context: context,
                    icon: controller.showImmersiveToolbar
                        ? Icons.brush_rounded
                        : Icons.brush_outlined,
                    tooltip: isEs ? 'Herramientas' : 'Tools',
                    onTap: controller.toggleImmersiveToolbar,
                    isActive: controller.showImmersiveToolbar,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 6),
                  _buildFloatingButton(
                    context: context,
                    icon: Icons.save_alt_rounded,
                    tooltip: isEs ? 'Guardar PNG' : 'Save PNG',
                    onTap: controller.canUndo
                        ? onExport
                        : null, // Reusing canUndo as it checks completedStrokes.isNotEmpty
                    isDark: isDark,
                  ),
                  const SizedBox(height: 6),
                  _buildFloatingButton(
                    context: context,
                    icon: Icons.undo_rounded,
                    tooltip: isEs ? 'Deshacer' : 'Undo',
                    onTap: controller.canUndo ? controller.undo : null,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 6),
                  _buildFloatingButton(
                    context: context,
                    icon: Icons.arrow_back_ios_new_rounded,
                    tooltip: isEs ? 'Salir' : 'Back',
                    onTap: onExit,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingButton({
    required BuildContext context,
    required IconData icon,
    required String tooltip,
    VoidCallback? onTap,
    bool isActive = false,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Tooltip(
        message: tooltip,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isActive
                ? SensoryColors.primary
                : (isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.05)),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 22,
            color: isActive
                ? Colors.white
                : (isDark ? Colors.white70 : Colors.black87),
          ),
        ),
      ),
    );
  }
}
