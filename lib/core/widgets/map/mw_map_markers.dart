import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mishwar/core/theme/app_colors.dart';
import 'package:mishwar/core/theme/app_sizes.dart';

/// Cached per pixel ratio, including simultaneous callers.
abstract final class MwMapMarkers {
  static final _cars = <(double, double), Future<BitmapDescriptor>>{};
  static Future<BitmapDescriptor> car({required double pixelRatio}) =>
      _cars.putIfAbsent((
        pixelRatio,
        AppSizes.carMarker,
      ), () => _drawCar(pixelRatio));
  static Future<BitmapDescriptor> _drawCar(double ratio) async {
    final size = AppSizes.carMarker;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder)..scale(ratio);
    // Top-down car, nose up, drawn on a 24 × 44 grid (same proportions as the
    // share page marker) and centred in the square marker.
    final unit = size * .9 / 44;
    final dx = (size - 24 * unit) / 2;
    final dy = size * .05;
    void part(double x, double y, double w, double h, double r, Color c) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(dx + x * unit, dy + y * unit, w * unit, h * unit),
          Radius.circular(r * unit),
        ),
        Paint()..color = c,
      );
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(dx + 2 * unit, dy + 2 * unit, 20 * unit, 42 * unit),
        Radius.circular(7 * unit),
      ),
      Paint()
        ..color = AppColors.black.withValues(alpha: .3)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2 * unit),
    );
    part(2, 1, 20, 42, 7, AppColors.black); // body
    part(.5, 11, 2, 4, 1, AppColors.black); // mirrors
    part(21.5, 11, 2, 4, 1, AppColors.black);
    part(4.5, 8, 15, 8, 2.5, AppColors.grey200); // windshield
    part(5.5, 17.5, 13, 10, 1.5, AppColors.grey600); // roof
    part(5.5, 29, 13, 6, 2, AppColors.grey200); // rear window
    part(5, 2, 4, 2, 1, AppColors.white); // headlights
    part(15, 2, 4, 2, 1, AppColors.white);
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
