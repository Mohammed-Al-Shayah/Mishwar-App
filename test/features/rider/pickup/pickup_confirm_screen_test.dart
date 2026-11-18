import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/core/l10n/gen/app_localizations.dart';
import 'package:mishwar/core/theme/app_theme.dart';
import 'package:mishwar/core/widgets/map/mw_map.dart';
import 'package:mishwar/core/widgets/mw_skeleton.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_draft.dart';
import 'package:mishwar/features/common/user/domain/entities/geo_point_value.dart';
import 'package:mishwar/features/rider/pickup/presentation/pickup_confirm_cubit.dart';
import 'package:mishwar/features/rider/pickup/presentation/pickup_confirm_screen.dart';
import 'package:mocktail/mocktail.dart';

import 'pickup_confirm_cubit_test.dart';

void main() {
  setUp(() => registerFallbackValue(point));
  for (final lang in ['ar', 'en']) {
    testWidgets(
      'placeholder map, movement, suggestion and fallback at 1.3 $lang',
      (tester) async {
        tester.view.physicalSize = const Size(375, 812);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final repository = MockPickupRepository();
        when(() => repository.reverse(any(), lang)).thenAnswer(
          (invocation) async => Right(
            RideStop(
              name: 'Street',
              address: 'Full address',
              location: invocation.positionalArguments.first as GeoPointValue,
            ),
          ),
        );
        final cubit = pickupCubit(repository);
        addTearDown(cubit.close);
        await tester.pumpWidget(
          ScreenUtilInit(
            designSize: const Size(375, 812),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (_, _) => MaterialApp(
              theme: AppTheme.light(),
              locale: Locale(lang),
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: const TextScaler.linear(1.3),
                  disableAnimations: true,
                ),
                child: child!,
              ),
              home: BlocProvider.value(
                value: cubit,
                child: PickupConfirmScreen(
                  mapBuilder: (_) => const MwMapPlaceholder(),
                ),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pumpAndSettle();
        expect(find.text('Full address'), findsOneWidget);
        final map = tester.widget<MwMap>(find.byType(MwMap));
        expect(map.initialTarget, point);
        map.onCameraMoveStarted!();
        map.onCameraMove!(suggestion.location);
        await tester.pump();
        await tester.pump();
        expect(find.byType(MwSkeleton), findsNWidgets(2));
        expect(
          tester
              .widget<AnimatedContainer>(find.byType(AnimatedContainer))
              .duration,
          Duration.zero,
        );
        map.onCameraIdle!();
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pumpAndSettle();
        expect(cubit.state.farFromDevice, isTrue);
        expect(
          find.text(
            lang == 'ar'
                ? '???? ???????? ????? ?? ?????'
                : 'Pickup point is far from your location',
          ),
          findsOneWidget,
        );
        when(
          () => repository.reverse(any(), lang),
        ).thenAnswer((_) async => const Left(ServerFailure('private')));
        await tester.ensureVisible(find.text('Parking'));
        await tester.tap(find.text('Parking'));
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pumpAndSettle();
        expect(cubit.state.phase, PickupPhase.failure);
        expect(cubit.state.stop.location, suggestion.location);
        expect(find.text('private'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
