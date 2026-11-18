import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishwar/features/common/app_config/domain/app_banner.dart';
import 'package:mishwar/features/rider/home/presentation/widgets/banner_carousel.dart';

import '../../widget_test.dart' show harness;
import 'app_config_test.dart' show demoBanner;

void main() {
  testWidgets('unrelated parent rebuilds do not postpone the next page', (
    tester,
  ) async {
    final banners = [demoBanner(), demoBanner(id: 'b')];
    Widget carousel() => harness(
      Scaffold(
        body: BannerCarousel(banners: banners, onAction: (_) {}),
      ),
    );
    await tester.pumpWidget(carousel());
    await tester.pump();
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpWidget(carousel());
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(tester.widget<PageView>(find.byType(PageView)).controller!.page, 1);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('empty banners hide the carousel', (tester) async {
    await tester.pumpWidget(
      harness(
        Scaffold(
          body: BannerCarousel(banners: const [], onAction: (_) {}),
        ),
      ),
    );
    expect(find.byType(PageView), findsNothing);
  });
  for (final action in BannerAction.values) {
    testWidgets('dispatches $action with target', (tester) async {
      final banner = demoBanner(action: action);
      AppBanner? tapped;
      await tester.pumpWidget(
        harness(
          Scaffold(
            body: BannerCarousel(
              banners: [banner],
              onAction: (b) => tapped = b,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(banner.title));
      expect(tapped, banner);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets(
    'fake clock advances after 5s, pauses on touch, resumes and wraps',
    (tester) async {
      await tester.pumpWidget(
        harness(
          Scaffold(
            body: BannerCarousel(
              banners: [
                demoBanner(),
                demoBanner(id: 'b'),
              ],
              onAction: (_) {},
            ),
          ),
        ),
      );
      await tester.pump();
      final controller = tester
          .widget<PageView>(find.byType(PageView))
          .controller!;
      await tester.pump(const Duration(seconds: 4));
      expect(controller.page, 0);
      final touch = await tester.startGesture(
        tester.getCenter(find.byType(PageView)),
      );
      await tester.pump(const Duration(seconds: 6));
      expect(controller.page, 0);
      await touch.up();
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      expect(controller.page, 1);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      expect(controller.page, 0);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
  testWidgets('reduced motion disables automatic paging', (tester) async {
    await tester.pumpWidget(
      harness(
        Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: Scaffold(
              body: BannerCarousel(
                banners: [
                  demoBanner(),
                  demoBanner(id: 'b'),
                ],
                onAction: (_) {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 20));
    expect(tester.widget<PageView>(find.byType(PageView)).controller!.page, 0);
  });
}
