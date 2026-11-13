import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gtc6/core/theme/colors.dart';
import '../../domain/models/paint_models.dart';
import '../../domain/services/canvas_export_service.dart';
import 'package:gtc6/features/progress/domain/services/progress_service.dart';

import '../controllers/zen_paint_controller.dart';
import '../widgets/zen_paint_canvas.dart';
import '../widgets/paint_toolbar.dart';
import '../widgets/zen_paint_header.dart';
import '../widgets/zen_paint_immersive_panel.dart';
import '../widgets/zen_paint_immersive_toolbar.dart';

class ZenPaintScreen extends StatefulWidget {
  const ZenPaintScreen({super.key});

  @override
  State<ZenPaintScreen> createState() => _ZenPaintScreenState();
}

class _ZenPaintScreenState extends State<ZenPaintScreen>
    with SingleTickerProviderStateMixin {
  late final ZenPaintController _controller;
  final GlobalKey _canvasBoundaryKey = GlobalKey();

  late final DateTime _startTime;
  late final AnimationController _immersiveAnimController;
  late final Animation<double> _immersiveAnim;

  @override
  void initState() {
    super.initState();
    _controller = ZenPaintController();
    _startTime = DateTime.now();

    _immersiveAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _immersiveAnim = CurvedAnimation(
      parent: _immersiveAnimController,
      curve: Curves.easeInOutCubic,
    );

    // Sync immersive mode with AnimationController
    _controller.addListener(_onControllerUpdate);
  }

  void _onControllerUpdate() {
    if (_controller.immersiveMode &&
        _immersiveAnimController.status != AnimationStatus.completed) {
      _immersiveAnimController.forward();
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else if (!_controller.immersiveMode &&
        _immersiveAnimController.status != AnimationStatus.dismissed) {
      _immersiveAnimController.reverse();
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _immersiveAnimController.dispose();

    final double elapsedMinutes =
        DateTime.now().difference(_startTime).inSeconds / 60.0;
    if (elapsedMinutes >= 0.1) {
      Future.microtask(() {
        ProgressService.instance.recordSession('zen_paint', elapsedMinutes);
      });
    }

    _controller.resetState();
    super.dispose();
  }

  Future<bool> _confirmExit() async {
    if (_controller.completedStrokes.isEmpty) {
      Navigator.pop(context);
      return true;
    }

    final isEs = Localizations.localeOf(context).languageCode == 'es';
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.amber,
              size: 28,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isEs ? '¿Salir del lienzo?' : 'Leave canvas?',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          isEs
              ? 'Tu dibujo actual no se ha guardado. Si sales ahora, perderás todos tus trazos.'
              : 'Your current drawing has not been saved. If you leave now, you will lose all your strokes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(isEs ? 'Seguir dibujando' : 'Keep drawing'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.exit_to_app_rounded, size: 18),
            label: Text(isEs ? 'Salir' : 'Leave'),
            style: ElevatedButton.styleFrom(
              backgroundColor: SensoryColors.error,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );

    if (shouldLeave == true && mounted) {
      Navigator.pop(context);
      return true;
    }
    return false;
  }

  Future<void> _exportToPng() async {
    final isEs = Localizations.localeOf(context).languageCode == 'es';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 14),
            Text(isEs ? 'Guardando imagen...' : 'Saving image...'),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    final success = await CanvasExportService.exportAndSave(_canvasBoundaryKey);

    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              success ? Icons.check_circle_rounded : Icons.error_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                success
                    ? (isEs
                          ? '¡Imagen guardada en la galería! 🎨'
                          : 'Image saved to gallery! 🎨')
                    : (isEs
                          ? 'Error al guardar la imagen'
                          : 'Error saving image'),
              ),
            ),
          ],
        ),
        backgroundColor: success ? SensoryColors.primary : SensoryColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
    HapticFeedback.mediumImpact();
  }

  void _showTemplateSelector() {
    final theme = Theme.of(context);
    final cardColor = theme.cardTheme.color ?? theme.colorScheme.surface;
    final isEs = Localizations.localeOf(context).languageCode == 'es';

    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isEs
                  ? 'Seleccionar Plantilla o Modo de Dibujo'
                  : 'Select Template or Drawing Mode',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              isEs
                  ? 'Dibuja libremente en blanco o colorea plantillas zen prediseñadas.'
                  : 'Draw freely on a blank canvas or color predesigned Zen templates.',
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListenableBuilder(
                listenable: _controller,
                builder: (context, _) => ListView.separated(
                  shrinkWrap: true,
                  itemCount: kArtTemplates.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, idx) {
                    final template = kArtTemplates[idx];
                    final isSelected = idx == _controller.selectedTemplateIndex;

                    return InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.pop(context);
                        _controller.setTemplateIndex(idx);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? SensoryColors.primary.withValues(alpha: 0.15)
                              : theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? SensoryColors.primary
                                : theme.colorScheme.onSurface.withValues(
                                    alpha: 0.1,
                                  ),
                            width: isSelected ? 2.0 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              template.type.icon,
                              color: isSelected
                                  ? SensoryColors.primary
                                  : theme.colorScheme.onSurface.withValues(
                                      alpha: 0.8,
                                    ),
                              size: 28,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    template.type.getLocalizedTitle(context),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.5,
                                      color: isSelected
                                          ? SensoryColors.primary
                                          : theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    template.type.getLocalizedDescription(
                                      context,
                                    ),
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle_rounded,
                                color: SensoryColors.primary,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCanvas(bool isDark, Color canvasBgColor, Color outlineColor) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.08),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ZenPaintCanvas(
        repaintBoundaryKey: _canvasBoundaryKey,
        completedStrokes: _controller.completedStrokes,
        currentStroke: _controller.currentStroke,
        selectedTemplate: _controller.selectedTemplate,
        templateOutlineColor: outlineColor,
        backgroundColor: canvasBgColor,
        onPanStart: _controller.onPanStart,
        onPanUpdate: _controller.onPanUpdate,
        onPanEnd: _controller.onPanEnd,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final canvasBgColor = isDark
        ? const Color(0xFF1B2127)
        : const Color(0xFFFBFBFB);
    final outlineColor = isDark ? Colors.white : Colors.black87;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        // Initialize offsets on first layout frame if needed
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _controller.initOffsets(MediaQuery.of(context).size);
        });

        return PopScope(
          canPop: _controller.completedStrokes.isEmpty,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _confirmExit();
          },
          child: Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: _controller.immersiveMode
                ? null
                : AppBar(
                    title: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_controller.selectedTemplate.type.icon, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          _controller.selectedTemplate.type.getLocalizedTitle(
                            context,
                          ),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      onPressed: _confirmExit,
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.save_alt_rounded),
                        tooltip: 'Guardar como PNG',
                        onPressed: _controller.completedStrokes.isNotEmpty
                            ? _exportToPng
                            : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.fullscreen_rounded),
                        tooltip: 'Modo Pro (Pantalla Completa)',
                        onPressed: _controller.toggleImmersiveMode,
                      ),
                      const SizedBox(width: 4),
                    ],
                  ),
            body: SafeArea(
              top: !_controller.immersiveMode,
              child: Stack(
                children: [
                  Column(
                    children: [
                      ZenPaintTemplateSelector(
                        onShowTemplateSelector: _showTemplateSelector,
                      ),
                      SizedBox(height: _controller.immersiveMode ? 0 : 8),
                      Expanded(
                        child: Center(
                          child: _controller.immersiveMode
                              ? Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: _buildCanvas(
                                    isDark,
                                    canvasBgColor,
                                    outlineColor,
                                  ),
                                )
                              : AspectRatio(
                                  aspectRatio: 0.82,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                    ),
                                    child: _buildCanvas(
                                      isDark,
                                      canvasBgColor,
                                      outlineColor,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOutCubic,
                        child: _controller.immersiveMode
                            ? const SizedBox.shrink()
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(height: 12),
                                  PaintToolbar(
                                    selectedColor: _controller.selectedColor,
                                    onColorChanged: _controller.setColor,
                                    isEraser: _controller.isEraser,
                                    onEraserChanged: _controller.setEraser,
                                    strokeWidth: _controller.strokeWidth,
                                    onStrokeWidthChanged:
                                        _controller.setStrokeWidth,
                                    strokeOpacity: _controller.strokeOpacity,
                                    onStrokeOpacityChanged:
                                        _controller.setStrokeOpacity,
                                    onUndo: _controller.undo,
                                    onClear: _controller.clearCanvas,
                                    canUndo: _controller.canUndo,
                                    canClear: _controller.canClear,
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                  ZenPaintImmersivePanel(
                    immersiveAnim: _immersiveAnim,
                    onExport: _exportToPng,
                    onExit: _confirmExit,
                  ),
                  ZenPaintImmersiveToolbar(immersiveAnim: _immersiveAnim),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
