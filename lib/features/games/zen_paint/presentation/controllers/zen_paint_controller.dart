import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gtc6/core/theme/colors.dart';
import '../../domain/models/paint_models.dart';

class ZenPaintController extends ChangeNotifier {
  // ── Singleton Pattern ──
  static final ZenPaintController _instance = ZenPaintController._internal();
  factory ZenPaintController() => _instance;
  ZenPaintController._internal();

  // ── State Variables ──
  final List<DrawingStroke> completedStrokes = [];
  DrawingStroke? currentStroke;

  Color selectedColor = SensoryColors.zenTeal;
  double strokeWidth = 12.0;
  double strokeOpacity = 1.0;
  bool isEraser = false;
  int selectedTemplateIndex = 0;

  bool immersiveMode = false;
  bool showImmersiveToolbar = false;

  Offset? floatingPanelOffset;
  Offset? floatingToolbarOffset;

  // ── Getters for UI ──
  bool get canUndo => completedStrokes.isNotEmpty;
  bool get canClear => completedStrokes.isNotEmpty;
  ArtTemplate get selectedTemplate => kArtTemplates[selectedTemplateIndex];

  // ── Actions ──
  void initOffsets(Size screenSize) {
    bool changed = false;
    if (floatingPanelOffset == null) {
      floatingPanelOffset = Offset(
        screenSize.width - 58,
        screenSize.height / 2 - 140,
      );
      changed = true;
    }
    if (floatingToolbarOffset == null) {
      floatingToolbarOffset = Offset(
        (screenSize.width - 360) / 2 > 0 ? (screenSize.width - 360) / 2 : 12.0,
        screenSize.height - 180,
      );
      changed = true;
    }
    if (changed) notifyListeners();
  }

  void updateFloatingPanelOffset(Offset newOffset) {
    floatingPanelOffset = newOffset;
    notifyListeners();
  }

  void updateFloatingToolbarOffset(Offset newOffset) {
    floatingToolbarOffset = newOffset;
    notifyListeners();
  }

  void toggleImmersiveMode() {
    immersiveMode = !immersiveMode;
    notifyListeners();
  }

  void toggleImmersiveToolbar() {
    showImmersiveToolbar = !showImmersiveToolbar;
    notifyListeners();
  }

  void setTemplateIndex(int index) {
    selectedTemplateIndex = index;
    notifyListeners();
  }

  void setColor(Color color) {
    selectedColor = color;
    notifyListeners();
  }

  void setEraser(bool value) {
    isEraser = value;
    notifyListeners();
  }

  void setStrokeWidth(double width) {
    strokeWidth = width;
    notifyListeners();
  }

  void setStrokeOpacity(double opacity) {
    strokeOpacity = opacity;
    notifyListeners();
  }

  // ── Drawing Actions ──
  void onPanStart(Offset point) {
    currentStroke = DrawingStroke(
      points: [point],
      color: selectedColor,
      strokeWidth: strokeWidth,
      strokeOpacity: strokeOpacity,
      isEraser: isEraser,
    );
    notifyListeners();
    HapticFeedback.selectionClick();
  }

  void onPanUpdate(Offset point) {
    if (currentStroke != null) {
      currentStroke!.points.add(point);
      notifyListeners();
    }
  }

  void onPanEnd() {
    if (currentStroke != null) {
      completedStrokes.add(currentStroke!);
      currentStroke = null;
      notifyListeners();
    }
  }

  void undo() {
    if (completedStrokes.isNotEmpty) {
      completedStrokes.removeLast();
      notifyListeners();
      HapticFeedback.lightImpact();
    }
  }

  void clearCanvas() {
    completedStrokes.clear();
    notifyListeners();
  }

  void resetState() {
    completedStrokes.clear();
    currentStroke = null;
    selectedColor = SensoryColors.zenTeal;
    strokeWidth = 12.0;
    strokeOpacity = 1.0;
    isEraser = false;
    selectedTemplateIndex = 0;
    immersiveMode = false;
    showImmersiveToolbar = false;
    floatingPanelOffset = null;
    floatingToolbarOffset = null;
    notifyListeners();
  }
}
