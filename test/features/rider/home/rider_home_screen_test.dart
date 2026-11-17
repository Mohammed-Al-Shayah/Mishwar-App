import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/core/l10n/gen/app_localizations.dart';
import 'package:mishwar/core/theme/app_theme.dart';
import 'package:mishwar/core/widgets/map/mw_map.dart';
import 'package:mishwar/core/widgets/map/mw_map_fab.dart';
import 'package:mishwar/features/common/auth/domain/usecases/sign_out.dart';
import 'package:mishwar/features/common/auth/presentation/cubit/home_cubit.dart';
import 'package:mishwar/features/common/location/domain/entities/location_permission_status.dart';
import 'package:mishwar/features/common/user/domain/entities/geo_point_value.dart';
import 'package:mishwar/features/rider/home/presentation/cubit/rider_home_cubit.dart';
import 'package:mishwar/features/rider/home/presentation/rider_home_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/location_mocks.dart';
import '../../../helpers/saved_places_mocks.dart';

class MockSignOut extends Mock implements SignOut {}

class MockMapController extends Mock implements MwMapController {}

void main() {
  setUpAll(() async {
    for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
      final loader = FontLoader('IBMPlexSansArabic')
        ..addFont(
          rootBundle.load(
            'assets/fonts/ibm_plex_sans_arabic/IBMPlexSansArabic-$weight.ttf',
          ),
        );
      await loader.load();
    }
    final icons = FontLoader('PhosphorRegular')
      ..addFont(rootBundle.load('assets/fonts/phosphor/Phosphor.ttf'));
    await icons.load();
  });
  for (final locale in ['ar', 'en']) {
    for (final dark in [false, true]) {
      for (final permission in LocationPermissionStatus.values) {
        testWidgets('$locale dark=$dark $permission inline CTA', (
          tester,
        ) async {
          tester.view.physicalSize = const Size(375, 812);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final repository = MockLocationRepository();
          final positions =
              StreamController<Either<Failure, GeoPointValue>>.broadcast();
          addTearDown(positions.close);
          when(
            repository.checkPermission,
          ).thenAnswer((_) async => Right(permission));
          when(
            repository.requestPermission,
          ).thenAnswer((_) async => Right(permission));
          if (permission == LocationPermissionStatus.granted) {
            // A failed fix still leaves the map usable and the sheet visible.
            when(repository.currentPosition).thenAnswer(
              (_) async =>
                  const Left(LocationFailure(LocationFailureCode.timeout)),
            );
            when(
              repository.watchPosition,
            ).thenAnswer((_) => positions.stream);
          }
          when(repository.openAppSettings).thenAnswer((_) async {});
          when(repository.openLocationSettings).thenAnswer((_) async {});
          final cubit = riderCubit(repository);
          final home = HomeCubit(MockSignOut());
          addTearDown(cubit.close);
          addTearDown(home.close);
          await tester.pumpWidget(
            ScreenUtilInit(
              designSize: const Size(375, 812),
              minTextAdapt: true,
              splitScreenMode: true,
              builder: (_, _) => MaterialApp(
                locale: Locale(locale),
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                theme: dark ? AppTheme.dark() : AppTheme.light(),
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: const TextScaler.linear(1.3)),
                  child: child!,
                ),
                home: MultiBlocProvider(
                  providers: [
                    BlocProvider<RiderHomeCubit>.value(value: cubit),
                    BlocProvider<HomeCubit>.value(value: home),
                  ],
                  child: savedProviders(
                    RiderHomeScreen(
                      mapBuilder: (_) => const MwMapPlaceholder(),
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          final context = tester.element(find.byType(RiderHomeScreen));
          final l10n = AppLocalizations.of(context)!;
          expect(find.text(l10n.whereTo), findsNWidgets(2));
          expect(find.byType(GoogleMap), findsNothing);
          final map = tester.widget<MwMap>(find.byType(MwMap));
          final sheetRect = tester.getRect(
            find
                .ancestor(
                  of: find.text(l10n.whereTo).first,
                  matching: find.byType(Container),
                )
                .first,
          );
          expect(map.padding.bottom, sheetRect.height);
          expect(
            map.permissionGranted,
            permission == LocationPermissionStatus.granted,
          );
          if (permission != LocationPermissionStatus.granted) {
            final label = switch (permission) {
              LocationPermissionStatus.deniedForever => l10n.openSettings,
              LocationPermissionStatus.serviceDisabled => l10n.enableLocation,
              _ => l10n.allowLocation,
            };
            expect(find.text(label), findsOneWidget);
            await tester.tap(find.text(label));
            await tester.pumpAndSettle();
            if (permission == LocationPermissionStatus.deniedForever) {
              verify(repository.openAppSettings).called(1);
            }
            if (permission == LocationPermissionStatus.serviceDisabled) {
              verify(repository.openLocationSettings).called(1);
            }
            if (permission == LocationPermissionStatus.denied) {
              verify(repository.requestPermission).called(2);
            }
          }
          if (permission == LocationPermissionStatus.granted) {
            const first = GeoPointValue(31.9, 35.9);
            const second = GeoPointValue(32, 36);
            final controller = MockMapController();
            when(() => controller.animateTo(first)).thenAnswer((_) async {});
            when(() => controller.animateTo(second)).thenAnswer((_) async {});
            map.onMapCreated!(controller);
            positions.add(const Right(first));
            await tester.pumpAndSettle();
            verify(() => controller.animateTo(first)).called(1);
            positions.add(const Right(second));
            await tester.pumpAndSettle();
            verifyNever(() => controller.animateTo(second));
            final recenter = find.byWidgetPredicate(
              (widget) =>
                  widget is MwMapFab && widget.label == l10n.recenterMap,
            );
            expect(
              tester.getRect(recenter).bottom,
              lessThan(
                tester
                    .getRect(
                      find.byWidgetPredicate(
                        (widget) =>
                            widget is Container && widget.key is GlobalKey,
                      ),
                    )
                    .top,
              ),
            );
            await tester.tap(recenter);
            await tester.pumpAndSettle();
            verify(() => controller.animateTo(second)).called(1);
          }
          expect(sheetRect.height, greaterThan(0));
          if (permission == LocationPermissionStatus.deniedForever) {
            await expectLater(
              find.byType(Scaffold),
              matchesGoldenFile(
                'goldens/rider_home_${locale}_${dark ? 'dark' : 'light'}.png',
              ),
            );
          }
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox.shrink());
        });
      }
    }
  }
}
