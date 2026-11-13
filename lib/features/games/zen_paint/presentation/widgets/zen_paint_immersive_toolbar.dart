import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../controllers/zen_paint_controller.dart';
import 'paint_toolbar.dart';

class ZenPaintImmersiveToolbar extends StatelessWidget {
  final Animation<double> immersiveAnim;

  const ZenPaintImmersiveToolbar({super.key, required this.immersiveAnim});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final controller = ZenPaintController();

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (!controller.immersiveMode || !controller.showImmersiveToolbar) {
          return const SizedBox.shrink();
        }

        final screenSize = MediaQuery.of(context).size;
        final offset =
            controller.floatingToolbarOffset ??
            Offset(
              math.max(12.0, (screenSize.width - 350) / 2),
              screenSize.height - 180,
            );

        return Positioned(
          left: offset.dx,
          top: offset.dy,
          child: FadeTransition(
            opacity: immersiveAnim,
            child: Container(
              width: math.min(360, screenSize.width - 40),
              decoration: BoxDecoration(
                color: (isDark ? Colors.black : Colors.white).withValues(
                  alpha: 0.65,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.15)
                      : Colors.black.withValues(alpha: 0.1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle bar
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanUpdate: (details) {
                      final current =
                          controller.floatingToolbarOffset ??
                          Offset(
                            math.max(12.0, (screenSize.width - 350) / 2),
                            screenSize.height - 180,
                          );
                      controller.updateFloatingToolbarOffset(
                        Offset(
                          (current.dx + details.delta.dx).clamp(
                            0.0,
                            screenSize.width - 80,
                          ),
                          (current.dy + details.delta.dy).clamp(
                            0.0,
                            screenSize.height - 80,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 8,
                        bottom: 4,
                        left: 20,
                        right: 20,
                      ),
                      child: Container(
                        width: 36,
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
                  PaintToolbar(
                    selectedColor: controller.selectedColor,
                    onColorChanged: controller.setColor,
                    isEraser: controller.isEraser,
                    onEraserChanged: controller.setEraser,
                    strokeWidth: controller.strokeWidth,
                    onStrokeWidthChanged: controller.setStrokeWidth,
                    strokeOpacity: controller.strokeOpacity,
                    onStrokeOpacityChanged: controller.setStrokeOpacity,
                    onUndo: controller.undo,
                    onClear: controller.clearCanvas,
                    canUndo: controller.canUndo,
                    canClear: controller.canClear,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
