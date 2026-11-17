import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishwar/core/theme/app_colors.dart';
import 'package:mishwar/core/theme/app_text_styles.dart';
import 'package:mishwar/core/widgets/mw_logo.dart';

/// Run via render_brand_test.dart to rasterize the bundled font with Flutter.
Future<void> renderBrand(WidgetTester tester) async {
  final loader = FontLoader(AppTextStyles.fontFamily)
    ..addFont(
      rootBundle.load(
        'assets/fonts/ibm_plex_sans_arabic/IBMPlexSansArabic-Bold.ttf',
      ),
    );
  await loader.load();
  await tester.binding.setSurfaceSize(const Size(1024, 1024));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  Future<void> write(String name, Size size, Widget child) async {
    final key = GlobalKey();
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, _) => Directionality(
          textDirection: TextDirection.rtl,
          child: Center(
            child: RepaintBoundary(
              key: key,
              child: SizedBox.fromSize(size: size, child: child),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    await tester.runAsync(() async {
      final image = await boundary.toImage();
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final file = File('assets/branding/$name');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes!.buffer.asUint8List(), flush: true);
      image.dispose();
    });
  }

  await write(
    'icon.png',
    const Size(1024, 1024),
    const ColoredBox(color: AppColors.black, child: MwLogoMark()),
  );
  await write(
    'icon_foreground.png',
    const Size(1024, 1024),
    const MwLogoMark(foreground: true),
  );
  await write(
    'splash_logo.png',
    const Size(600, 240),
    const Padding(
      padding: EdgeInsets.all(24),
      child: FittedBox(child: MwWordmark(color: AppColors.white)),
    ),
  );
}
