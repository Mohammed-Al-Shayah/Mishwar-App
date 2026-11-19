import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/core/l10n/gen/app_localizations.dart';
import 'package:mishwar/core/theme/admin_theme.dart';
import 'package:mishwar/features/admin/domain/admin_reports.dart';
import 'package:mishwar/features/admin/presentation/admin_reports_page.dart';
import 'package:mishwar/features/admin/presentation/reports_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockReports extends Mock implements ReportsRepository {}

ReportData fixture() => ReportData([
  ReportDay(
    day: '2026-11-17',
    counts: const {
      'requested': 10,
      'completed': 8,
      'revenueMinor': 40000,
      'cancelledByRider': 1,
      'promoUses': 2,
    },
    promos: const {'SAVE20': 2},
  ),
  ReportDay(
    day: '2026-11-18',
    counts: const {
      'requested': 5,
      'completed': 4,
      'revenueMinor': 20000,
      'cancelledByDriver': 1,
      'promoUses': 3,
    },
    promos: const {'SAVE20': 1, 'FIRST': 2},
  ),
]);
void main() {
  test('KPI totals, ranking, CSV quoting and zero denominators', () {
    final d = fixture();
    expect(d.total('requested'), 15);
    expect(d.completionRate, 80);
    expect(d.averageFare, 5);
    expect(d.cancellationRate, closeTo(13.333, 0.001));
    expect(d.topPromos.first.key, 'SAVE20');
    expect(d.topPromos.first.value, 3);
    final csv = d.csv(['Day', 'Fare "JD"']);
    expect(csv, startsWith('\ufeff"Day","Fare ""JD"""\r\n'));
    expect(csv, contains('"40.000"'));
    expect(csv, contains('2026-11-18'));
    final empty = ReportData(const []);
    expect(empty.averageFare, 0);
    expect(empty.completionRate, 0);
    expect(empty.cancellationRate, 0);
  });
  test('range calendar uses Amman midnight', () {
    expect(
      reportDayKey(ammanToday(DateTime.parse('2026-11-18T21:00:00Z'))),
      '2026-11-19',
    );
  });
  blocTest<ReportsCubit, ReportsState>(
    'reports load error is recoverable',
    build: () {
      final r = MockReports();
      when(
        () => r.load(7),
      ).thenAnswer((_) async => const Left(ServerFailure('offline')));
      return ReportsCubit(LoadReports(r));
    },
    act: (c) => c.load(),
    expect: () => [
      const ReportsState(loading: true),
      const ReportsState(failure: ServerFailure('offline')),
    ],
  );
  test('later range wins over stale pending load', () async {
    final r = MockReports();
    final first = Completer<Either<Failure, ReportData>>();
    when(() => r.load(7)).thenAnswer((_) => first.future);
    when(() => r.load(30)).thenAnswer((_) async => Right(fixture()));
    final c = ReportsCubit(LoadReports(r));
    final pending = c.load();
    await c.load(30);
    first.complete(Right(ReportData(const [])));
    await pending;
    expect(c.state.days, 30);
    expect(c.state.data!.total('requested'), 15);
    await c.close();
  });
  for (final locale in ['ar', 'en']) {
    testWidgets('reports 1280x800 $locale with 7/30/90 ranges', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final r = MockReports();
      when(() => r.load(any())).thenAnswer((_) async => Right(fixture()));
      final c = ReportsCubit(LoadReports(r));
      await c.load();
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          enableScaleWH: () => false,
          enableScaleText: () => false,
          builder: (_, _) => MaterialApp(
            theme: AdminTheme.light(),
            locale: Locale(locale),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: BlocProvider.value(
                value: c,
                child: const AdminReportsPage(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(ReportsChart), findsOneWidget);
      for (final days in [30, 90]) {
        await tester.tap(
          find.byWidgetPredicate(
            (w) => w is Text && (w.data?.contains('$days') ?? false),
          ),
        );
        await tester.pumpAndSettle();
        expect(c.state.days, days);
      }
      await tester.pumpWidget(const SizedBox.shrink());
      await c.close();
    });
  }
}
