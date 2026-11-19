import 'dart:convert';
import 'dart:io';

import 'package:bloc_test/bloc_test.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/core/l10n/gen/app_localizations.dart';
import 'package:mishwar/features/admin/domain/admin_management.dart';
import 'package:mishwar/features/admin/domain/admin_usecases.dart';
import 'package:mishwar/features/admin/presentation/admin_promos.dart';
import 'package:mishwar/features/admin/presentation/admin_settings.dart';
import 'package:mishwar/features/admin/presentation/management_cubit.dart';

import 'admin_test.dart' show TestAdminRepository;

class TestManagement implements ManagementRepository {
  bool fail = false;
  @override
  Future<Either<Failure, ManagementData>> load() async => fail
      ? const Left(ServerFailure('load'))
      : Right(
          ManagementData(
            settings: const {
              'cancellationFee': {'amount': 0.5, 'afterSeconds': 120},
              'waitingFee': {'freeMinutes': 3, 'perMinute': 0.05},
              'scheduling': {
                'minLeadMinutes': 30,
                'maxDaysAhead': 30,
                'dispatchBeforeMinutes': 15,
              },
            },
          ),
        );
}

void main() {
  blocTest<ManagementCubit, ManagementState>(
    'management loading emits immutable data',
    build: () => ManagementCubit(
      LoadManagement(TestManagement()),
      AdminAction(TestAdminRepository()),
    ),
    act: (c) => c.load(),
    expect: () => [
      isA<ManagementState>().having((s) => s.loading, 'loading', true),
      isA<ManagementState>().having((s) => s.data, 'data', isNotNull),
    ],
  );
  test('promo example matches shared server fixtures', () {
    final fixtures =
        jsonDecode(
              File(
                'firebase/functions/test/fixtures/promo-math.json',
              ).readAsStringSync().replaceFirst('\ufeff', ''),
            )
            as List;
    for (final raw in fixtures) {
      final f = raw as Map<String, dynamic>;
      expect(
        promoDiscountMinor(
          fareMinor: f['fareMinor'] as int,
          type: f['type'] as String,
          value: (f['value'] as num).toDouble(),
          maxDiscount: (f['maxDiscount'] as num?)?.toDouble(),
        ),
        f['expected'],
      );
    }
  });
  test('management cubit loads, saves and exposes failures', () async {
    final repository = TestManagement();
    final actions = TestAdminRepository();
    final cubit = ManagementCubit(
      LoadManagement(repository),
      AdminAction(actions),
    );
    await cubit.load();
    expect(cubit.state.data, isNotNull);
    expect(
      await cubit.save('updateAppSettings', {
        'waitingFee': {'freeMinutes': 3, 'perMinute': 0.05},
      }),
      true,
    );
    expect(actions.actions.single.$1, 'updateAppSettings');
    actions.fail = true;
    expect(await cubit.save('upsertPromo', {}), false);
    expect(cubit.state.failure, isNotNull);
    repository.fail = true;
    await cubit.load();
    expect(cubit.state.failure, isNotNull);
    expect(cubit.state.loading, false);
    await cubit.close();
    await actions.feed.close();
  });
  for (final locale in ['ar', 'en']) {
    for (final page in [
      const AdminSettings(),
      const AdminPromos(),
      const PromoEditor(),
    ]) {
      testWidgets('${page.runtimeType} at 1280x800 $locale', (tester) async {
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final actions = TestAdminRepository();
        final cubit = ManagementCubit(
          LoadManagement(TestManagement()),
          AdminAction(actions),
        );
        await cubit.load();
        await tester.pumpWidget(
          ScreenUtilInit(
            designSize: const Size(375, 812),
            enableScaleWH: () => false,
            enableScaleText: () => false,
            builder: (_, _) => MaterialApp(
              locale: Locale(locale),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: BlocProvider.value(value: cubit, child: page),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        if (page is AdminSettings) {
          final field = find.byType(TextFormField).first;
          await tester.enterText(field, '99');
          await tester.tap(find.text(locale == 'ar' ? 'حفظ' : 'Save').first);
          await tester.pump();
          expect(actions.actions, isEmpty);
        }
        await tester.pumpWidget(const SizedBox.shrink());
        await cubit.close();
        await actions.feed.close();
      });
    }
  }
}
