import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gtc6/core/theme/colors.dart';
import '../../domain/models/paint_models.dart';
import '../../domain/services/canvas_export_service.dart';
import '../widgets/zen_paint_canvas.dart';
import '../widgets/paint_toolbar.dart';
import 'package:gtc6/features/progress/domain/services/progress_service.dart';

class ZenPaintScreen extends StatefulWidget {
  const ZenPaintScreen({super.key});

  @override
  State<ZenPaintScreen> createState() => _ZenPaintScreenState();
}

class _ZenPaintScreenState extends State<ZenPaintScreen>
    with SingleTickerProviderStateMixin {
  final List<DrawingStroke> _completedStrokes = [];
  DrawingStroke? _currentStroke;

  Color _selectedColor = SensoryColors.zenTeal;
  double _strokeWidth = 12.0;
  double _strokeOpacity = 1.0;
  bool _isEraser = false;
  int _selectedTemplateIndex = 0;

  /// Immersive / Pro mode: hides toolbar, appbar, and template pill
  bool _immersiveMode = false;

  /// Whether to show the paint toolbar in immersive mode
  bool _showImmersiveToolbar = false;

  /// Position offset for the draggable floating panel in immersive mode
  /// Starts at mid-right; position is set dynamically on first build
  Offset? _floatingPanelOffset;

  /// Position offset for the draggable tool bar (PaintToolbar) in immersive mode
  Offset? _floatingToolbarOffset;

  /// Key for capturing the canvas as a PNG image
  final GlobalKey _canvasBoundaryKey = GlobalKey();

  late final DateTime _startTime;
  late final AnimationController _immersiveAnimController;
  late final Animation<double> _immersiveAnim;

  ArtTemplate get _selectedTemplate => kArtTemplates[_selectedTemplateIndex];

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _immersiveAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _immersiveAnim = CurvedAnimation(
      parent: _immersiveAnimController,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _immersiveAnimController.dispose();
    final double elapsedMinutes =
        DateTime.now().difference(_startTime).inSeconds / 60.0;
    if (elapsedMinutes >= 0.1) {
      Future.microtask(() {
        ProgressService.instance.recordSession('zen_paint', elapsedMinutes);
      });
    }
    super.dispose();
  }

  // ── Drawing handlers ──────────────────────────────────────────

  void _onPanStart(Offset point) {
    setState(() {
      _currentStroke = DrawingStroke(
        points: [point],
        color: _selectedColor,
        strokeWidth: _strokeWidth,
        strokeOpacity: _strokeOpacity,
        isEraser: _isEraser,
      );
    });
    HapticFeedback.selectionClick();
  }

  void _onPanUpdate(Offset point) {
    if (_currentStroke == null) return;
    setState(() {
      _currentStroke!.points.add(point);
    });
  }

  void _onPanEnd() {
    if (_currentStroke != null) {
      setState(() {
        _completedStrokes.add(_currentStroke!);
        _currentStroke = null;
      });
    }
  }

  void _undo() {
    if (_completedStrokes.isNotEmpty) {
      setState(() {
        _completedStrokes.removeLast();
      });
      HapticFeedback.lightImpact();
    }
  }

  void _clearCanvas() {
    if (_completedStrokes.isEmpty) return;
    final isEs = Localizations.localeOf(context).languageCode == 'es';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEs ? '¿Borrar todo el lienzo?' : 'Clear all canvas?'),
        content: Text(
            isEs ? 'Todos tus trazos se borrarán y volverás a empezar en limpio.' : 'All your strokes will be deleted and you will start fresh.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isEs ? 'Cancelar' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _completedStrokes.clear();
              });
              HapticFeedback.mediumImpact();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: SensoryColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text(isEs ? 'Borrar' : 'Clear'),
          ),
        ],
      ),
    );
  }

  // ── Immersive (Pro) mode ──────────────────────────────────────

  void _toggleImmersiveMode() {
    setState(() {
      _immersiveMode = !_immersiveMode;
      if (!_immersiveMode) _showImmersiveToolbar = false;
    });
    if (_immersiveMode) {
      _immersiveAnimController.forward();
    } else {
      _immersiveAnimController.reverse();
    }
    HapticFeedback.lightImpact();
  }

  // ── Confirm exit ──────────────────────────────────────────────

  Future<bool> _confirmExit() async {
    if (_completedStrokes.isEmpty) {
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
            const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isEs ? '¿Salir del lienzo?' : 'Leave canvas?',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
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

  // ── Export to PNG ─────────────────────────────────────────────

  Future<void> _exportToPng() async {
    final isEs = Localizations.localeOf(context).languageCode == 'es';

    // Show saving indicator
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20, height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
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
                    ? (isEs ? '¡Imagen guardada en la galería! 🎨' : 'Image saved to gallery! 🎨')
                    : (isEs ? 'Error al guardar la imagen' : 'Error saving image'),
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

  // ── Template selector ─────────────────────────────────────────

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
              isEs ? 'Seleccionar Plantilla o Modo de Dibujo' : 'Select Template or Drawing Mode',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              isEs ? 'Dibuja libremente en blanco o colorea plantillas zen prediseñadas.' : 'Draw freely on a blank canvas or color predesigned Zen templates.',
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: kArtTemplates.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, idx) {
                  final template = kArtTemplates[idx];
                  final isSelected = idx == _selectedTemplateIndex;

                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _selectedTemplateIndex = idx;
                      });
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
                              : theme.colorScheme.onSurface.withValues(alpha: 0.1),
                          width: isSelected ? 2.0 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            template.type.icon,
                            color: isSelected
                                ? SensoryColors.primary
                                : theme.colorScheme.onSurface.withValues(alpha: 0.8),
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
                                  template.type.getLocalizedDescription(context),
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
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
          ],
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEs = Localizations.localeOf(context).languageCode == 'es';
    final canvasBgColor = isDark ? const Color(0xFF1B2127) : const Color(0xFFFBFBFB);
    final outlineColor = isDark ? Colors.white : Colors.black87;

    return PopScope(
      canPop: _completedStrokes.isEmpty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmExit();
      },
      child: Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // AppBar with animated visibility
      appBar: _immersiveMode
          ? null
          : AppBar(
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_selectedTemplate.type.icon, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    _selectedTemplate.type.getLocalizedTitle(context),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
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
                // Export PNG button
                IconButton(
                  icon: const Icon(Icons.save_alt_rounded),
                  tooltip: isEs ? 'Guardar como PNG' : 'Save as PNG',
                  onPressed: _completedStrokes.isNotEmpty ? _exportToPng : null,
                ),
                // Template selector
                IconButton(
                  icon: const Icon(Icons.style_rounded),
                  tooltip: isEs ? 'Cambiar Plantilla o Modo' : 'Change Template or Mode',
                  onPressed: _showTemplateSelector,
                ),
                // Immersive mode toggle
                IconButton(
                  icon: const Icon(Icons.fullscreen_rounded),
                  tooltip: isEs ? 'Modo Pro (Pantalla Completa)' : 'Pro Mode (Full Screen)',
                  onPressed: _toggleImmersiveMode,
                ),
                const SizedBox(width: 4),
              ],
            ),
      body: SafeArea(
        top: !_immersiveMode,
        child: Stack(
          children: [
            // ── Main column with canvas ──
            Column(
              children: [
                // Top template pill (hidden in immersive mode)
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOutCubic,
                  child: _immersiveMode
                      ? const SizedBox.shrink()
                      : GestureDetector(
                          onTap: _showTemplateSelector,
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
                                        ? 'Modo actual: ${_selectedTemplate.type.getLocalizedTitle(context)} • Toca aquí para cambiar'
                                        : 'Current mode: ${_selectedTemplate.type.getLocalizedTitle(context)} • Tap here to change',
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
                ),

                SizedBox(height: _immersiveMode ? 0 : 8),

                // Drawing Canvas Area
                Expanded(
                  child: Center(
                    child: _immersiveMode
                        ? Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: _buildCanvas(isDark, canvasBgColor, outlineColor),
                          )
                        : AspectRatio(
                            aspectRatio: 0.82,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: _buildCanvas(isDark, canvasBgColor, outlineColor),
                            ),
                          ),
                  ),
                ),

                // Bottom toolbar (hidden in immersive mode)
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOutCubic,
                  child: _immersiveMode
                      ? const SizedBox.shrink()
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 12),
                            PaintToolbar(
                              selectedColor: _selectedColor,
                              onColorChanged: (color) => setState(() => _selectedColor = color),
                              isEraser: _isEraser,
                              onEraserChanged: (isEraser) => setState(() => _isEraser = isEraser),
                              strokeWidth: _strokeWidth,
                              onStrokeWidthChanged: (width) => setState(() => _strokeWidth = width),
                              strokeOpacity: _strokeOpacity,
                              onStrokeOpacityChanged: (opacity) => setState(() => _strokeOpacity = opacity),
                              onUndo: _undo,
                              onClear: _clearCanvas,
                              canUndo: _completedStrokes.isNotEmpty,
                              canClear: _completedStrokes.isNotEmpty,
                            ),
                          ],
                        ),
                ),
              ],
            ),

            // ── Draggable floating action buttons in immersive mode ──
            if (_immersiveMode)
              Builder(builder: (context) {
                final screenSize = MediaQuery.of(context).size;
                _floatingPanelOffset ??= Offset(screenSize.width - 58, screenSize.height / 2 - 140);
                final offset = _floatingPanelOffset!;
                return Positioned(
                  left: offset.dx,
                  top: offset.dy,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      setState(() {
                        final current = _floatingPanelOffset ?? Offset(screenSize.width - 58, screenSize.height / 2 - 140);
                        _floatingPanelOffset = Offset(
                          (current.dx + details.delta.dx).clamp(0.0, screenSize.width - 54),
                          (current.dy + details.delta.dy).clamp(0.0, screenSize.height - 280),
                        );
                      });
                    },
                    child: FadeTransition(
                      opacity: _immersiveAnim,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                        decoration: BoxDecoration(
                          color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.55),
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
                            Container(
                              width: 24,
                              height: 4,
                              margin: const EdgeInsets.only(bottom: 6),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.4)
                                    : Colors.black.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            _buildFloatingButton(
                              icon: Icons.fullscreen_exit_rounded,
                              tooltip: isEs ? 'Salir del Modo Pro' : 'Exit Pro Mode',
                              onTap: _toggleImmersiveMode,
                            ),
                            const SizedBox(height: 6),
                            _buildFloatingButton(
                              icon: _showImmersiveToolbar
                                  ? Icons.brush_rounded
                                  : Icons.brush_outlined,
                              tooltip: isEs ? 'Herramientas' : 'Tools',
                              onTap: () => setState(() => _showImmersiveToolbar = !_showImmersiveToolbar),
                              isActive: _showImmersiveToolbar,
                            ),
                            const SizedBox(height: 6),
                            _buildFloatingButton(
                              icon: Icons.save_alt_rounded,
                              tooltip: isEs ? 'Guardar PNG' : 'Save PNG',
                              onTap: _completedStrokes.isNotEmpty ? _exportToPng : null,
                            ),
                            const SizedBox(height: 6),
                            _buildFloatingButton(
                              icon: Icons.undo_rounded,
                              tooltip: isEs ? 'Deshacer' : 'Undo',
                              onTap: _completedStrokes.isNotEmpty ? _undo : null,
                            ),
                            const SizedBox(height: 6),
                            _buildFloatingButton(
                              icon: Icons.arrow_back_ios_new_rounded,
                              tooltip: isEs ? 'Salir' : 'Back',
                              onTap: _confirmExit,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),

            // ── Draggable floating toolbar (PaintToolbar) in immersive mode ──
            if (_immersiveMode && _showImmersiveToolbar)
              Builder(builder: (context) {
                final screenSize = MediaQuery.of(context).size;
                _floatingToolbarOffset ??= Offset(math.max(12.0, (screenSize.width - 350) / 2), screenSize.height - 180);
                final offset = _floatingToolbarOffset!;
                return Positioned(
                  left: offset.dx,
                  top: offset.dy,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      setState(() {
                        final current = _floatingToolbarOffset ?? Offset(math.max(12.0, (screenSize.width - 350) / 2), screenSize.height - 180);
                        _floatingToolbarOffset = Offset(
                          (current.dx + details.delta.dx).clamp(0.0, screenSize.width - 80),
                          (current.dy + details.delta.dy).clamp(0.0, screenSize.height - 80),
                        );
                      });
                    },
                    child: FadeTransition(
                      opacity: _immersiveAnim,
                      child: Container(
                        decoration: BoxDecoration(
                          color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.65),
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
                            Container(
                              width: 36,
                              height: 4,
                              margin: const EdgeInsets.only(top: 8, bottom: 2),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.4)
                                    : Colors.black.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            PaintToolbar(
                              selectedColor: _selectedColor,
                              onColorChanged: (color) => setState(() => _selectedColor = color),
                              isEraser: _isEraser,
                              onEraserChanged: (isEraser) => setState(() => _isEraser = isEraser),
                              strokeWidth: _strokeWidth,
                              onStrokeWidthChanged: (width) => setState(() => _strokeWidth = width),
                              strokeOpacity: _strokeOpacity,
                              onStrokeOpacityChanged: (opacity) => setState(() => _strokeOpacity = opacity),
                              onUndo: _undo,
                              onClear: _clearCanvas,
                              canUndo: _completedStrokes.isNotEmpty,
                              canClear: _completedStrokes.isNotEmpty,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
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
        completedStrokes: _completedStrokes,
        currentStroke: _currentStroke,
        selectedTemplate: _selectedTemplate,
        templateOutlineColor: outlineColor,
        backgroundColor: canvasBgColor,
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
      ),
    );
  }

  Widget _buildFloatingButton({
    required IconData icon,
    required String tooltip,
    VoidCallback? onTap,
    bool isActive = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final enabled = onTap != null;

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
                ? SensoryColors.primary.withValues(alpha: 0.9)
                : (isDark ? Colors.black : Colors.white).withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 22,
            color: isActive
                ? Colors.white
                : enabled
                    ? (isDark ? Colors.white : Colors.black87)
                    : (isDark ? Colors.white24 : Colors.black26),
          ),
        ),
      ),
    );
  }
}
