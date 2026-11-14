import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishwar/app/app.dart';
import 'package:mishwar/core/l10n/gen/app_localizations_ar.dart';

void main() {
  testWidgets('Arabic RTL role picker opens rider and driver after continue', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1125, 2436);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final l10n = AppLocalizationsAr();
    await tester.pumpWidget(const MishwarApp());
    await tester.pumpAndSettle();
    expect(find.text(l10n.roleTitle), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.text(l10n.roleTitle))),
      TextDirection.rtl,
    );
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('role_continue')))
          .onPressed,
      isNull,
    );

    await tester.tap(find.byKey(const Key('role_rider')));
    await tester.pump();
    expect(find.text(l10n.riderMode), findsNothing);
    await tester.tap(find.byKey(const Key('role_continue')));
    await tester.pumpAndSettle();
    expect(find.text(l10n.riderMode), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('role_driver')));
    await tester.pump();
    expect(find.text(l10n.driverMode), findsNothing);
    await tester.tap(find.byKey(const Key('role_continue')));
    await tester.pumpAndSettle();
    expect(find.text(l10n.driverMode), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
