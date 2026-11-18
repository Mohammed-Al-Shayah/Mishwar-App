import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:mishwar/core/l10n/gen/app_localizations.dart';
import 'package:mishwar/core/l10n/gen/app_localizations_ar.dart';
import 'package:mishwar/core/l10n/gen/app_localizations_en.dart';
import 'package:mishwar/core/theme/app_theme.dart';
import 'package:mishwar/core/widgets/mw_primary_button.dart';
import 'package:mishwar/core/widgets/mw_text_field.dart';
import 'package:mishwar/features/common/app_config/data/airport_config_parser.dart';
import 'package:mishwar/features/common/app_config/domain/app_config_usecases.dart';
import 'package:mishwar/features/common/location/domain/usecases/current_position.dart';
import 'package:mishwar/features/common/places/domain/entities/place_details.dart';
import 'package:mishwar/features/common/ride/data/models/ride_model.dart';
import 'package:mishwar/features/common/ride/domain/entities/airport_details.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_draft.dart';
import 'package:mishwar/features/common/ride/presentation/airport_badge.dart';
import 'package:mishwar/features/common/ride/presentation/ride_receipt_screen.dart';
import 'package:mishwar/features/common/route/domain/entities/fare_estimates.dart';
import 'package:mishwar/features/common/route/domain/usecases/get_fare_estimates.dart';
import 'package:mishwar/features/common/user/domain/entities/geo_point_value.dart';
import 'package:mishwar/features/rider/airport/presentation/airport_cubit.dart';
import 'package:mishwar/features/rider/airport/presentation/airport_screen.dart';
import 'package:mishwar/features/rider/confirm/presentation/cubit/ride_confirm_cubit.dart';
import 'package:mishwar/features/rider/search/presentation/bloc/destination_search_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/ride_mocks.dart';
import '../common/ride/ride_data_test.dart' show rideJson;
import '../parcel/parcel_test.dart' show MockLocation;
import '../rider/confirm/ride_confirm_cubit_test.dart'
    show MockRouteRepository, draft, estimates;
import '../rider/confirm/ride_confirm_screen_test.dart' show pumpConfirm;
import 'airport_test.dart' show MockAirportConfigRepository, airportJson;

Widget wrap(Widget child, String language, {bool dark = false}) =>
    ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, _) => MaterialApp(
        theme: dark ? AppTheme.dark() : AppTheme.light(),
        locale: Locale(language),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.3)),
          child: child!,
        ),
        home: child,
      ),
    );

void main() {
  for (final language in ['ar', 'en']) {
    final l10n = language == 'ar' ? AppLocalizationsAr() : AppLocalizationsEn();
    for (final fromAirport in [false, true]) {
      testWidgets('airport flow $language from=$fromAirport at scale 1.3', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(375, 812);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final repo = MockAirportConfigRepository();
        final location = MockLocation();
        final config = parseAirportConfig(airportJson())!;
        when(repo.airportConfig).thenAnswer((_) async => Right(config));
        when(
          location.currentPosition,
        ).thenAnswer((_) async => const Right(GeoPointValue(31.95, 35.91)));
        final cubit = AirportCubit(
          GetAirportConfig(repo),
          CurrentPosition(location),
        );
        await cubit.load();
        addTearDown(cubit.close);
        RideDraft? received;
        DestinationSearchParams? search;
        final router = GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (_, _) => BlocProvider.value(
                value: cubit,
                child: const AirportScreen(pickupAvailable: false),
              ),
            ),
            GoRoute(
              path: '/rider/search',
              builder: (context, state) {
                search = state.extra! as DestinationSearchParams;
                return Scaffold(
                  body: TextButton(
                    onPressed: () => context.pop(
                      const PlaceDetails(
                        placeId: 'amman',
                        name: 'Amman',
                        address: 'Amman',
                        location: GeoPointValue(31.95, 35.91),
                      ),
                    ),
                    child: const Text('Choose destination'),
                  ),
                );
              },
            ),
            GoRoute(
              path: '/rider/confirm',
              builder: (_, state) {
                received = state.extra! as RideDraft;
                return const Scaffold(body: Text('Confirmed'));
              },
            ),
          ],
        );
        addTearDown(router.dispose);
        await tester.pumpWidget(
          ScreenUtilInit(
            designSize: const Size(375, 812),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (_, _) => MaterialApp.router(
              routerConfig: router,
              theme: AppTheme.light(),
              locale: Locale(language),
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: const TextScaler.linear(1.3)),
                child: child!,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        if (fromAirport) {
          await tester.tap(find.text(l10n.airportFrom));
          await tester.pumpAndSettle();
          expect(
            tester
                .widget<MwPrimaryButton>(find.byType(MwPrimaryButton))
                .onPressed,
            isNull,
          );
          await tester.tap(find.text('Gate 3'));
        }
        await tester.enterText(find.byType(MwTextField), 'RJ!');
        await tester.pumpAndSettle();
        expect(find.text(l10n.airportFlightInvalid), findsOneWidget);
        await tester.enterText(find.byType(MwTextField), 'rj 182');
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byType(MwPrimaryButton));
        await tester.tap(find.byType(MwPrimaryButton));
        await tester.pumpAndSettle();
        if (fromAirport) {
          expect(search!.position, config.pickupPoints.last.location);
          expect(search!.pickupName, config.pickupPoints.last.name);
          await tester.tap(find.text('Choose destination'));
          await tester.pumpAndSettle();
          expect(received!.pickup, config.pickupPoints.last);
          verifyNever(location.currentPosition);
        } else {
          expect(received!.dropoff.name, l10n.airportName);
          expect(received!.dropoff.location, config.centroid);
          verify(location.currentPosition).called(1);
        }
        expect(received!.flightNumber, 'RJ 182');
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('fixed fare pills and traffic ETAs at $language scale 1.3', (
      tester,
    ) async {
      final repo = MockRouteRepository();
      when(
        () => repo.getFareEstimates(
          origin: draft.pickup.location,
          destination: draft.dropoff.location,
        ),
      ).thenAnswer(
        (_) async => Right(
          FareEstimates(
            route: estimates.route,
            fares: estimates.fares,
            airport: const AirportDetails(
              direction: AirportDirection.toAirport,
            ),
          ),
        ),
      );
      final cubit = RideConfirmCubit(
        GetFareEstimates(repo),
        requestRideStub(),
        draft,
        scheduleRide: scheduleRideStub(),
        validatePromo: promoValidatorStub(),
      );
      await pumpConfirm(tester, cubit, scale: 1.3, language: language);
      await tester.pumpAndSettle();
      expect(find.text(l10n.airportFixedFare), findsNWidgets(3));
      expect(tester.takeException(), isNull);
    });

    for (final dark in [false, true]) {
      testWidgets('airport badge $language dark=$dark at scale 1.3', (
        tester,
      ) async {
        final ride = RideModel.fromJson({
          ...rideJson(),
          'serviceType': 'airport',
          'airport': {
            'direction': 'from_airport',
            'flightNumber': 'RJ 182',
            'fixedFare': true,
          },
        }).toEntity();
        expect(ride.draft.flightNumber, 'RJ 182');
        await tester.pumpWidget(
          wrap(
            Scaffold(body: AirportBadge(airport: ride.airport!)),
            language,
            dark: dark,
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text(l10n.serviceAirport), findsOneWidget);
        expect(find.text('RJ 182'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(
          wrap(
            Scaffold(
              body: RideReceiptContent(ride: ride, driver: dark),
            ),
            language,
            dark: dark,
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text(l10n.airportReceipt), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
