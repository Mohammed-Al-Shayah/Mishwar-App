import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishwar/app/app.dart';

void main() {
  testWidgets('role picker opens rider and driver modes', (tester) async {
    await tester.pumpWidget(const MishwarApp());
    expect(find.text('Mishwar'), findsOneWidget);

    await tester.tap(find.byKey(const Key('role_rider')));
    await tester.pumpAndSettle();
    expect(find.text('Rider mode'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('role_driver')));
    await tester.pumpAndSettle();
    expect(find.text('Driver mode'), findsOneWidget);
  });
}
