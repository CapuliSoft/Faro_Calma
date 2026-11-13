import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

/// Service that captures a [RepaintBoundary] widget tree as a high-resolution
/// PNG and saves it to the device gallery using a platform MethodChannel.
class CanvasExportService {
  static const _channel = MethodChannel('com.gtc6/gallery');

  /// Captures the widget associated with [boundaryKey] at [pixelRatio]
  /// resolution and saves it to the device photo gallery.
  ///
  /// Returns `true` if the image was saved successfully.
  static Future<bool> exportAndSave(
    GlobalKey boundaryKey, {
    double pixelRatio = 3.0,
  }) async {
    try {
      final boundary =
          boundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return false;

      final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) return false;

      final Uint8List pngBytes = byteData.buffer.asUint8List();

      final bool saved = await _channel.invokeMethod('saveImage', {
        'bytes': pngBytes,
        'name': 'ZenPaint_${DateTime.now().millisecondsSinceEpoch}',
      });

      return saved;
    } catch (e) {
      debugPrint('CanvasExportService error: $e');
      return false;
    }
  }
}
