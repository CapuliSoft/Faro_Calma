import 'package:flutter/material.dart';
import 'package:gtc6/core/theme/colors.dart';
import '../controllers/zen_paint_controller.dart';
import '../../domain/models/paint_models.dart';


class ZenPaintHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onShowTemplateSelector;
  final VoidCallback onExit;

  const ZenPaintHeader({
    super.key,
    required this.onShowTemplateSelector,
    required this.onExit,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {

    final isEs = Localizations.localeOf(context).languageCode == 'es';
    final controller = ZenPaintController();

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (controller.immersiveMode) {
          return const SizedBox.shrink();
        }

        return AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: onExit,
            tooltip: isEs ? 'Salir' : 'Exit',
          ),
          title: Text(
            isEs ? 'Lienzo Libre' : 'Zen Paint',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          actions: [
            IconButton(
              icon: const Icon(Icons.fullscreen_rounded),
              tooltip: isEs ? 'Modo Pro (Pantalla Completa)' : 'Pro Mode (Fullscreen)',
              onPressed: controller.toggleImmersiveMode,
            ),
            const SizedBox(width: 4),
          ],
        );
      },
    );
  }
}

class ZenPaintTemplateSelector extends StatelessWidget {
  final VoidCallback onShowTemplateSelector;

  const ZenPaintTemplateSelector({
    super.key,
    required this.onShowTemplateSelector,
  });

  @override
  Widget build(BuildContext context) {
    final isEs = Localizations.localeOf(context).languageCode == 'es';
    final controller = ZenPaintController();

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          child: controller.immersiveMode
              ? const SizedBox.shrink()
              : GestureDetector(
                  onTap: onShowTemplateSelector,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: SensoryColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: SensoryColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.palette_outlined,
                            size: 18, color: SensoryColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isEs
                                ? 'Modo actual: ${controller.selectedTemplate.type.getLocalizedTitle(context)} • Toca aquí para cambiar'
                                : 'Current mode: ${controller.selectedTemplate.type.getLocalizedTitle(context)} • Tap here to change',
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: SensoryColors.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.keyboard_arrow_down_rounded,
                            size: 18, color: SensoryColors.primary),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}
