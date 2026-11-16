import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishwar/core/l10n/gen/app_localizations_ar.dart';
import 'package:mishwar/core/l10n/gen/app_localizations_en.dart';
import 'package:mishwar/core/theme/app_theme.dart';
import 'package:mishwar/features/driver/home/presentation/driver_home_screen.dart';
import 'package:mishwar/features/driver/offer/presentation/bloc/driver_offer_bloc.dart';
import 'package:mishwar/features/driver/offer/presentation/driver_offer_sheet.dart';
import 'package:mishwar/features/driver/presence/presentation/bloc/driver_presence_bloc.dart'
    as presence;
import 'package:mocktail/mocktail.dart';

import '../presence/driver_home_screen_test.dart'
    show MockPresenceBloc, map, size, wrap;
import 'driver_offer_bloc_test.dart' show MockOfferBloc, offerRide;

Widget sheet(DriverOfferState state) => Builder(
  builder: (_) => Theme(
    data: AppTheme.dark(),
    child: Scaffold(body: DriverOfferSheet(state: state)),
  ),
);
void main() {
  setUpAll(() {
    registerFallbackValue(const AcceptPressed());
    registerFallbackValue(const presence.GoOnlinePressed());
  });
  testWidgets('offer overlays home and hides stop at scale 1.3', (
    tester,
  ) async {
    size(tester);
    final bloc = MockOfferBloc();
    final presenceBloc = MockPresenceBloc();
    whenListen(
      bloc,
      const Stream<DriverOfferState>.empty(),
      initialState: DriverOfferState(
        status: OfferStatus.offered,
        ride: offerRide,
        remaining: const Duration(seconds: 12),
      ),
    );
    whenListen(
      presenceBloc,
      const Stream<presence.DriverPresenceState>.empty(),
      initialState: const presence.DriverPresenceState(
        status: presence.PresenceStatus.online,
        isOnline: true,
      ),
    );
    await tester.pumpWidget(
      wrap(
        BlocProvider<DriverOfferBloc>.value(
          value: bloc,
          child: BlocProvider<presence.DriverPresenceBloc>.value(
            value: presenceBloc,
            child: const DriverHomeScreen(uid: 'd', mapBuilder: map),
          ),
        ),
      ),
    );
    expect(find.byType(DriverOfferSheet), findsOneWidget);
    expect(find.byKey(const Key('driver_stop')), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
  for (final language in ['ar', 'en']) {
    final l10n = language == 'ar' ? AppLocalizationsAr() : AppLocalizationsEn();
    testWidgets('sheet content, 1.3 scale and actions $language', (
      tester,
    ) async {
      size(tester);
      const remaining = Duration(seconds: 12);
      final state = DriverOfferState(
        status: OfferStatus.offered,
        ride: offerRide,
        remaining: remaining,
      );
      final bloc = MockOfferBloc();
      whenListen(
        bloc,
        const Stream<DriverOfferState>.empty(),
        initialState: state,
      );
      await tester.pumpWidget(
        wrap(
          BlocProvider<DriverOfferBloc>.value(value: bloc, child: sheet(state)),
          language: language,
        ),
      );
      expect(find.text(l10n.fareJod('4.70')), findsOneWidget);
      expect(find.text(l10n.offerSeconds(12)), findsOneWidget);
      expect(find.text(l10n.offerPickupDistance(3, '1.2')), findsOneWidget);
      expect(find.text(l10n.offerTripDistance(10, '5.0')), findsOneWidget);
      expect(find.text('Pickup'), findsOneWidget);
      expect(find.text('Dropoff'), findsOneWidget);
      await tester.ensureVisible(find.text(l10n.offerAccept));
      await tester.tap(find.text(l10n.offerAccept));
      verify(() => bloc.add(any(that: isA<AcceptPressed>()))).called(1);
      await tester.ensureVisible(find.text(l10n.offerDecline));
      await tester.tap(find.text(l10n.offerDecline));
      verify(() => bloc.add(any(that: isA<DeclinePressed>()))).called(1);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
    for (final status in [OfferStatus.expired, OfferStatus.lost]) {
      testWidgets('terminal copy $language $status', (tester) async {
        size(tester);
        await tester.pumpWidget(
          wrap(
            sheet(DriverOfferState(status: status, ride: offerRide)),
            language: language,
          ),
        );
        expect(find.text(l10n.offerLost), findsOneWidget);
        expect(find.text(l10n.offerAccept), findsNothing);
        expect(find.text(l10n.offerDecline), findsNothing);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
