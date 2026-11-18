import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/core/l10n/gen/app_localizations.dart';
import 'package:mishwar/core/theme/app_theme.dart';
import 'package:mishwar/core/widgets/map/mw_map.dart';
import 'package:mishwar/core/widgets/mw_primary_button.dart';
import 'package:mishwar/core/widgets/mw_skeleton.dart';
import 'package:mishwar/core/widgets/mw_text_field.dart';
import 'package:mishwar/core/widgets/mw_vehicle_row.dart';
import 'package:mishwar/features/common/promos/domain/promo_quote.dart';
import 'package:mishwar/features/common/promos/domain/validate_promo.dart';
import 'package:mishwar/features/common/route/domain/entities/fare_estimates.dart';
import 'package:mishwar/features/common/route/domain/usecases/get_fare_estimates.dart';
import 'package:mishwar/features/common/user/domain/entities/vehicle_entity.dart';
import 'package:mishwar/features/rider/confirm/presentation/cubit/ride_confirm_cubit.dart';
import 'package:mishwar/features/rider/confirm/presentation/ride_confirm_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/ride_mocks.dart';
import 'ride_confirm_cubit_test.dart'
    show MockRouteRepository, draft, estimates, stubSuccess;

Future<void> pumpConfirm(
  WidgetTester tester,
  RideConfirmCubit cubit, {
  double scale = 1,
  String language = 'en',
}) async {
  tester.view.physicalSize = const Size(375, 812);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(cubit.close);
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, _) => MaterialApp(
        theme: AppTheme.light(),
        locale: Locale(language),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: BlocProvider.value(
          value: cubit,
          child: RideConfirmScreen(
            draft: draft,
            mapBuilder: (_) => const MwMapPlaceholder(),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  for (final language in ['ar', 'en']) {
    testWidgets(
      'promo sheet error, success, strike-through and remove at 1.3 $language',
      (tester) async {
        final routes = MockRouteRepository();
        stubSuccess(routes);
        final promos = MockPromoRepository();
        when(
          () => promos.validate('BAD', draft, VehicleType.economy),
        ).thenAnswer((_) async => const Left(PromoFailure('expired')));
        when(
          () => promos.validate('WELCOME50', draft, VehicleType.economy),
        ).thenAnswer(
          (_) async => const Right(
            PromoQuote(
              code: 'WELCOME50',
              discountFils: 1700,
              fareBeforeFils: 4600,
              fareAfterFils: 2900,
            ),
          ),
        );
        final cubit = RideConfirmCubit(
          GetFareEstimates(routes),
          requestRideStub(),
          draft,
          scheduleRide: scheduleRideStub(),
          validatePromo: ValidatePromo(promos),
        );
        await pumpConfirm(tester, cubit, scale: 1.3, language: language);
        await tester.pumpAndSettle();
        final l10n = AppLocalizations.of(
          tester.element(find.byType(RideConfirmScreen)),
        )!;
        await tester.tap(find.text(l10n.promoAdd));
        await tester.pumpAndSettle();
        tester.view.viewInsets = const FakeViewPadding(bottom: 300);
        addTearDown(tester.view.resetViewInsets);
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(MwTextField), 'bad');
        expect(
          tester.widget<TextField>(find.byType(TextField)).controller!.text,
          'BAD',
        );
        await tester.ensureVisible(find.text(l10n.promoApply));
        await tester.tap(find.text(l10n.promoApply));
        await tester.pumpAndSettle();
        expect(
          find.text(
            l10n.promoExpired,
          ),
          findsWidgets,
        );
        await tester.enterText(find.byType(MwTextField), 'welcome50');
        await tester.tap(find.text(l10n.promoApply));
        await tester.pumpAndSettle();
        expect(find.byType(MwTextField), findsNothing);
        tester.view.resetViewInsets();
        await tester.pumpAndSettle();
        final row = tester.widget<MwVehicleRow>(
          find.byKey(const ValueKey(VehicleType.economy)),
        );
        expect(row.price, 'JD 2.90');
        expect(row.originalPrice, 'JD 4.60');
        expect(
          tester
              .widget<MwVehicleRow>(
                find.byKey(const ValueKey(VehicleType.comfort)),
              )
              .originalPrice,
          isNull,
        );
        await tester.tap(
          find.byTooltip(
            l10n.promoRemove,
          ),
        );
        await tester.pumpAndSettle();
        expect((cubit.state as RideConfirmLoaded).promoQuote, isNull);
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets('prices, selection and inline request error', (
    tester,
  ) async {
    final repository = MockRouteRepository();
    stubSuccess(repository);
    final cubit = RideConfirmCubit(
      GetFareEstimates(repository),
      requestRideStub(),
      draft,
      validatePromo: promoValidatorStub(),
      scheduleRide: scheduleRideStub(),
    );
    await pumpConfirm(tester, cubit);
    await tester.pumpAndSettle();
    expect(find.byType(MwVehicleRow), findsNWidgets(3));
    final map = tester.widget<MwMap>(find.byType(MwMap));
    expect(map.padding.bottom, closeTo(812 * 0.58, 0.01));
    expect(map.polylines.single.points, hasLength(3));
    expect(map.polylines.single.width, 4);
    expect(map.polylines.single.color, Colors.black);
    expect(tester.getTopLeft(find.text('10 min · Park')).dy, lessThan(100));
    for (final price in ['JD 4.60', 'JD 5.80', 'JD 7.20']) {
      expect(find.text(price), findsOneWidget);
    }
    expect(
      tester
          .widget<MwVehicleRow>(find.byKey(const ValueKey(VehicleType.economy)))
          .selected,
      isTrue,
    );
    final comfort = find.byKey(const ValueKey(VehicleType.comfort));
    await tester.ensureVisible(comfort);
    await tester.tap(comfort);
    await tester.pumpAndSettle();
    expect(tester.widget<MwVehicleRow>(comfort).selected, isTrue);
    expect(
      tester
          .widget<MwVehicleRow>(find.byKey(const ValueKey(VehicleType.economy)))
          .selected,
      isFalse,
    );
    final selectedDecoration =
        tester
                .widget<AnimatedContainer>(
                  find.descendant(
                    of: comfort,
                    matching: find.byType(AnimatedContainer),
                  ),
                )
                .decoration!
            as BoxDecoration;
    final economyDecoration =
        tester
                .widget<AnimatedContainer>(
                  find.descendant(
                    of: find.byKey(const ValueKey(VehicleType.economy)),
                    matching: find.byType(AnimatedContainer),
                  ),
                )
                .decoration!
            as BoxDecoration;
    expect(selectedDecoration.border, isNot(economyDecoration.border));
    expect(find.text('Choose Comfort'), findsOneWidget);
    await tester.tap(find.byType(MwPrimaryButton));
    await tester.pump();
    expect(
      cubit.state,
      isA<RideConfirmLoaded>().having(
        (s) => s.requestFailure,
        'error',
        isA<ServerFailure>(),
      ),
    );
    expect(find.byType(MwVehicleRow), findsNWidgets(3));
  });
  testWidgets('loading skeletons and disabled button', (tester) async {
    final repository = MockRouteRepository();
    final pending = Completer<Either<Failure, FareEstimates>>();
    when(
      () => repository.getFareEstimates(
        origin: draft.pickup.location,
        destination: draft.dropoff.location,
      ),
    ).thenAnswer((_) => pending.future);
    final cubit = RideConfirmCubit(
      GetFareEstimates(repository),
      requestRideStub(),
      draft,
      validatePromo: promoValidatorStub(),
      scheduleRide: scheduleRideStub(),
    );
    await pumpConfirm(tester, cubit);
    expect(find.byType(MwSkeleton), findsNWidgets(3));
    expect(
      tester.widget<MwPrimaryButton>(find.byType(MwPrimaryButton)).onPressed,
      isNull,
    );
    pending.complete(Right(estimates));
    await tester.pumpAndSettle();
  });
  testWidgets('failure displays retry and recovers', (tester) async {
    final repository = MockRouteRepository();
    when(
      () => repository.getFareEstimates(
        origin: draft.pickup.location,
        destination: draft.dropoff.location,
      ),
    ).thenAnswer((_) async => const Left(ServerFailure('offline')));
    final cubit = RideConfirmCubit(
      GetFareEstimates(repository),
      requestRideStub(),
      draft,
      validatePromo: promoValidatorStub(),
      scheduleRide: scheduleRideStub(),
    );
    await pumpConfirm(tester, cubit);
    await tester.pumpAndSettle();
    expect(find.byType(MwVehicleRow), findsNothing);
    expect(find.text('Try again'), findsOneWidget);
    stubSuccess(repository);
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.byType(MwVehicleRow), findsNWidgets(3));
  });
  for (final language in ['ar', 'en']) {
    testWidgets('text scale 1.3 $language has no overflow, including van', (
      tester,
    ) async {
      final repository = MockRouteRepository();
      stubSuccess(repository);
      final cubit = RideConfirmCubit(
        GetFareEstimates(repository),
        requestRideStub(),
        draft,
        validatePromo: promoValidatorStub(),
        scheduleRide: scheduleRideStub(),
      );
      await pumpConfirm(tester, cubit, scale: 1.3, language: language);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey(VehicleType.van)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.byKey(const ValueKey(VehicleType.van)));
      await tester.pumpAndSettle();
      expect(
        cubit.state,
        isA<RideConfirmLoaded>().having(
          (s) => s.selected,
          'selected',
          VehicleType.van,
        ),
      );
      expect(tester.takeException(), isNull);
    });
  }
}
