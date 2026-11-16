import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mishwar/core/theme/app_colors.dart';
import 'package:mishwar/core/theme/app_sizes.dart';

/// Cached per pixel ratio, including simultaneous callers.
abstract final class MwMapMarkers {
  static final _cache = <(bool, double, double), Future<BitmapDescriptor>>{};
  static Future<BitmapDescriptor> square({
    required bool pickup,
    required double pixelRatio,
  }) => _cache.putIfAbsent((
    pickup,
    pixelRatio,
    AppSizes.pinSize,
  ), () => _draw(pickup, pixelRatio));

  static Future<BitmapDescriptor> _draw(bool pickup, double ratio) async {
    // Logical marker dimensions: 12 dp square, 2 dp white surround.
    final pin = AppSizes.pinSize;
    final stroke = AppSizes.pinStroke;
    final inner = AppSizes.pinInner;
    final size = pin + stroke * 2;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder)
      ..scale(ratio)
      ..drawRect(
        Rect.fromLTWH(0, 0, size, size),
        Paint()..color = AppColors.white,
      )
      ..drawRect(
        Rect.fromLTWH(stroke, stroke, pin, pin),
        Paint()..color = AppColors.black,
      );
    if (pickup) {
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(size / 2, size / 2),
          width: inner,
          height: inner,
        ),
        Paint()..color = AppColors.white,
      );
    }
    final picture = recorder.endRecording();
    final image = await picture.toImage(
      (size * ratio).ceil(),
      (size * ratio).ceil(),
    );
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    picture.dispose();
    return BitmapDescriptor.bytes(
      bytes!.buffer.asUint8List(),
      imagePixelRatio: ratio,
      width: size,
      height: size,
    );
  }
}
