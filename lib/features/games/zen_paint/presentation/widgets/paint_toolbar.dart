import 'package:flutter/material.dart';
import 'package:gtc6/core/theme/colors.dart';
import 'package:gtc6/l10n/app_localizations.dart';

class PaintToolbar extends StatelessWidget {
  final Color selectedColor;
  final ValueChanged<Color> onColorChanged;
  final bool isEraser;
  final ValueChanged<bool> onEraserChanged;
  final double strokeWidth;
  final ValueChanged<double> onStrokeWidthChanged;
  final double strokeOpacity;
  final ValueChanged<double> onStrokeOpacityChanged;
  final VoidCallback onUndo;
  final VoidCallback onClear;
  final bool canUndo;
  final bool canClear;

  const PaintToolbar({
    super.key,
    required this.selectedColor,
    required this.onColorChanged,
    required this.isEraser,
    required this.onEraserChanged,
    required this.strokeWidth,
    required this.onStrokeWidthChanged,
    required this.strokeOpacity,
    required this.onStrokeOpacityChanged,
    required this.onUndo,
    required this.onClear,
    required this.canUndo,
    required this.canClear,
  });

  static const List<Color> _palette = [
    SensoryColors.zenTeal,
    SensoryColors.zenIndigo,
    SensoryColors.zenSage,
    SensoryColors.zenAmber,
    SensoryColors.zenCyan,
    Color(0xFFE91E63), // Vibrant Pink Rose
    Color(0xFFFFB300), // Sunshine Gold
    Color(0xFF8E24AA), // Deep Violet
    Color(0xFF00ACC1), // Turquoise
    Color(0xFF43A047), // Fresh Emerald
    Color(0xFF37474F), // Slate Charcoal
    Color(0xFFFFFFFF), // Pure White
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.cardTheme.color ?? theme.colorScheme.surface;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Color picker row
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _palette.length,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final color = _palette[index];
                final isSelected = !isEraser && selectedColor == color;

                return GestureDetector(
                  onTap: () {
                    onColorChanged(color);
                    if (isEraser) onEraserChanged(false);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: isSelected ? 42 : 36,
                    height: isSelected ? 42 : 36,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? (isDark ? Colors.white : Colors.black87)
                            : Colors.black.withValues(alpha: 0.15),
                        width: isSelected ? 3.0 : 1.0,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: color.withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              )
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check_rounded,
                            size: 20,
                            color: _getContrastingColor(color),
                          )
                        : null,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // Brush settings card (Grosor y Espesor) + Live Preview
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                // Live Brush Circle Preview
                Container(
                  width: 54,
                  height: 54,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF161A1F) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Container(
                    width: strokeWidth.clamp(6.0, 44.0),
                    height: strokeWidth.clamp(6.0, 44.0),
                    decoration: BoxDecoration(
                      color: isEraser
                          ? theme.colorScheme.onSurface.withValues(alpha: 0.25)
                          : selectedColor.withValues(alpha: strokeOpacity),
                      shape: BoxShape.circle,
                      border: isEraser
                          ? Border.all(color: theme.colorScheme.onSurface, width: 1.5)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Sliders for Grosor and Espesor
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Grosor (Width)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.line_weight_rounded,
                                  size: 15,
                                  color: isEraser ? null : selectedColor),
                              const SizedBox(width: 6),
                              Text(
                                '${AppLocalizations.of(context)?.paintBrushSize ?? 'Grosor Pincel'}: ${strokeWidth.toInt()} px',
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 28,
                        child: Slider(
                          value: strokeWidth,
                          min: 2.0,
                          max: 48.0,
                          activeColor: isEraser
                              ? theme.colorScheme.onSurface
                              : selectedColor,
                          onChanged: onStrokeWidthChanged,
                        ),
                      ),

                      const SizedBox(height: 4),

                      // Espesor (Opacity / Tinta)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.opacity_rounded,
                                  size: 15,
                                  color: isEraser ? null : selectedColor),
                              const SizedBox(width: 6),
                              Text(
                                isEraser
                                    ? '${(AppLocalizations.of(context)?.localeName == 'es') ? 'Fuerza borrador: ' : 'Eraser strength: '}${(strokeOpacity * 100).toInt()}%'
                                    : '${AppLocalizations.of(context)?.paintOpacity ?? 'Espesor/Opacidad'}: ${(strokeOpacity * 100).toInt()}%',
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 28,
                        child: Slider(
                          value: strokeOpacity,
                          min: 0.1,
                          max: 1.0,
                          activeColor: isEraser
                              ? theme.colorScheme.onSurface
                              : selectedColor,
                          onChanged: onStrokeOpacityChanged,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Tools row (Brush, Eraser, Undo, Clear)
          Row(
            children: [
              // Brush tool
              Expanded(
                child: _buildToolButton(
                  context: context,
                  icon: Icons.brush_rounded,
                  label: AppLocalizations.of(context)?.paintBrushMode ?? 'Pincel',
                  isActive: !isEraser,
                  onTap: () => onEraserChanged(false),
                ),
              ),
              const SizedBox(width: 8),

              // Eraser tool
              Expanded(
                child: _buildToolButton(
                  context: context,
                  icon: Icons.auto_fix_high_rounded,
                  label: AppLocalizations.of(context)?.paintEraserMode ?? 'Borrador',
                  isActive: isEraser,
                  onTap: () => onEraserChanged(true),
                ),
              ),
              const SizedBox(width: 10),

              // Undo button
              IconButton(
                icon: const Icon(Icons.undo_rounded),
                tooltip: (AppLocalizations.of(context)?.localeName == 'es') ? 'Deshacer último trazo' : 'Undo last stroke',
                onPressed: canUndo ? onUndo : null,
              ),

              // Clear button
              IconButton(
                icon: const Icon(Icons.delete_sweep_rounded),
                tooltip: AppLocalizations.of(context)?.paintClearBtn ?? 'Limpiar Lienzo',
                color: SensoryColors.error,
                onPressed: canClear ? onClear : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final activeColor = SensoryColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? activeColor.withValues(alpha: 0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive ? activeColor : theme.dividerColor,
            width: isActive ? 1.8 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive ? activeColor : theme.iconTheme.color?.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isActive ? activeColor : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getContrastingColor(Color background) {
    return background.computeLuminance() > 0.5 ? Colors.black87 : Colors.white;
  }
}
