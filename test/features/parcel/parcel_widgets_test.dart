import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mishwar/app/di/injection.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/core/l10n/gen/app_localizations.dart';
import 'package:mishwar/core/l10n/gen/app_localizations_ar.dart';
import 'package:mishwar/core/l10n/gen/app_localizations_en.dart';
import 'package:mishwar/core/theme/app_theme.dart';
import 'package:mishwar/core/widgets/mw_otp_input.dart';
import 'package:mishwar/core/widgets/mw_primary_button.dart';
import 'package:mishwar/features/common/location/domain/usecases/current_position.dart';
import 'package:mishwar/features/common/ride/data/models/ride_model.dart';
import 'package:mishwar/features/common/ride/domain/usecases/parcel_usecases.dart';
import 'package:mishwar/features/common/ride/presentation/parcel_tools_cubit.dart';
import 'package:mishwar/features/common/ride/presentation/parcel_widgets.dart';
import 'package:mishwar/features/driver/trip/presentation/bloc/driver_trip_bloc.dart';
import 'package:mishwar/features/driver/trip/presentation/parcel_delivery_sheet.dart';
import 'package:mishwar/features/rider/parcel/presentation/parcel_form_cubit.dart';
import 'package:mishwar/features/rider/parcel/presentation/parcel_form_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../common/ride/ride_data_test.dart' show rideJson;
import '../driver/presence/driver_home_screen_test.dart' show size;
import '../driver/trip/driver_trip_bloc_test.dart' show MockTripBloc;
import 'parcel_test.dart' show MockLocation, MockParcels;

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
Map<String, dynamic> parcelJson({int attempts = 0}) => {
  ...rideJson(),
  'serviceType': 'parcel',
  'status': 'in_progress',
  'parcel': {
    'recipientName': 'Recipient',
    'recipientPhone': '+962781234567',
    'description': 'Books',
    'codeAttempts': attempts,
  },
};

void main() {
  setUpAll(() => registerFallbackValue(const Started()));
  tearDown(() async => getIt.reset());
  for (final language in ['ar', 'en']) {
    final l10n = language == 'ar' ? AppLocalizationsAr() : AppLocalizationsEn();
    testWidgets('parcel form scrolls and validates at $language scale 1.3', (
      tester,
    ) async {
      size(tester);
      final cubit = ParcelFormCubit(
        UploadParcelPhoto(MockParcels()),
        CurrentPosition(MockLocation()),
      );
      addTearDown(cubit.close);
      await tester.pumpWidget(
        wrap(
          BlocProvider.value(
            value: cubit,
            child: const ParcelFormScreen(uid: 'rider', pickupAvailable: false),
          ),
          language,
        ),
      );
      await tester.pumpAndSettle();
      final button = find.byType(MwPrimaryButton);
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(find.text(l10n.parcelInvalid), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
    testWidgets(
      'rider recovers code and launches recipient SMS at $language scale 1.3',
      (tester) async {
        size(tester);
        final repo = MockParcels();
        when(
          () => repo.watchCode('ride'),
        ).thenAnswer((_) => Stream.value(const Right('4821')));
        getIt.registerFactory<ParcelToolsCubit>(
          () => ParcelToolsCubit(
            WatchDeliveryCode(repo),
            GetParcelPhotoUrl(repo),
          ),
        );
        final uris = <Uri>[];
        await tester.pumpWidget(
          wrap(
            Scaffold(
              body: ParcelCodeCard(
                ride: RideModel.fromJson(parcelJson()).toEntity(),
                launcher: (uri) async {
                  uris.add(uri);
                  return true;
                },
              ),
            ),
            language,
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text(l10n.parcelCode('4821')), findsOneWidget);
        await tester.tap(find.text(l10n.parcelSendCode));
        await tester.pumpAndSettle();
        expect(uris.single.scheme, 'sms');
        expect(uris.single.path, '+962781234567');
        expect(uris.single.queryParameters['body'], l10n.parcelSms('4821'));
        expect(tester.takeException(), isNull);
      },
    );
    for (final locked in [false, true]) {
      testWidgets(
        'driver parcel code input locked=$locked at $language scale 1.3',
        (tester) async {
          size(tester);
          final bloc = MockTripBloc();
          whenListen(
            bloc,
            const Stream<DriverTripState>.empty(),
            initialState: DriverTripState(
              ride: RideModel.fromJson(
                parcelJson(attempts: locked ? 5 : 0),
              ).toEntity(),
              phase: TripPhase.onTrip,
              failure: RideActionFailure(
                locked
                    ? RideActionFailureReason.codeLocked
                    : RideActionFailureReason.badCode,
              ),
            ),
          );
          await tester.pumpWidget(
            wrap(
              Scaffold(
                body: BlocProvider<DriverTripBloc>.value(
                  value: bloc,
                  child: const ParcelDeliverySheet(),
                ),
              ),
              language,
              dark: true,
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.widget<MwOtpInput>(find.byType(MwOtpInput)).length, 4);
          expect(find.byType(TextField), findsNWidgets(4));
          expect(
            find.text(locked ? l10n.parcelCodeLocked : l10n.parcelBadCode),
            findsOneWidget,
          );
          if (locked) {
            expect(find.text(l10n.parcelSupport), findsOneWidget);
            expect(
              tester.widget<TextField>(find.byType(TextField).first).enabled,
              isFalse,
            );
          } else {
            await tester.enterText(
              find.byKey(const Key('otp_digit_0')),
              '4821',
            );
            await tester.pump();
            await tester.ensureVisible(find.byType(MwPrimaryButton));
            await tester.tap(find.byType(MwPrimaryButton));
            await tester.pump();
            final event =
                verify(() => bloc.add(captureAny())).captured.single
                    as CompletePressed;
            expect(event.deliveryCode, '4821');
          }
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
