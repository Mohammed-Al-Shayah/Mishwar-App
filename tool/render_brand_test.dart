import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

import 'render_brand.dart';

void main() {
  testWidgets('regenerates deterministic brand PNGs with bundled font', (
    tester,
  ) async {
    await renderBrand(tester);
    final first = await tester.runAsync(
      () => File('assets/branding/icon.png').readAsBytes(),
    );
    await renderBrand(tester);
    await tester.runAsync(() async {
      expect(await File('assets/branding/icon.png').readAsBytes(), first);
      for (final name in ['icon', 'icon_foreground', 'splash_logo']) {
        final codec = await ui.instantiateImageCodec(
          await File('assets/branding/$name.png').readAsBytes(),
        );
        final frame = await codec.getNextFrame();
        final image = frame.image;
        expect(image.width, name == 'splash_logo' ? 600 : 1024);
        expect(image.height, name == 'splash_logo' ? 240 : 1024);
        final pixels = (await image.toByteData())!;
        if (name == 'icon_foreground') {
          var ink = 0;
          for (var y = 0; y < image.height; y++) {
            for (var x = 0; x < image.width; x++) {
              if (pixels.getUint8((y * image.width + x) * 4 + 3) > 0) {
                ink++;
                // Central 66% adaptive safe square.
                expect(x, inInclusiveRange(174, 849));
                expect(y, inInclusiveRange(174, 849));
                final dx = x - 511.5;
                final dy = y - 511.5;
                expect(dx * dx + dy * dy, lessThanOrEqualTo(338 * 338));
              }
            }
          }
          expect(ink, greaterThan(10000));
        } else {
          expect(pixels.getUint8(3), name == 'icon' ? 255 : 0);
        }
        image.dispose();
        codec.dispose();
      }
    });
  });
}
