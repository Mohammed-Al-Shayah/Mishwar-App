import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/widgets/mw_driver_card.dart';
import 'package:mishwar/features/common/location/domain/repositories/location_repository.dart';
import 'package:mishwar/features/common/location/domain/usecases/current_position.dart';
import 'package:mishwar/features/common/safety/domain/safety_usecases.dart';
import 'package:mishwar/features/common/safety/domain/trusted_contact.dart';
import 'package:mishwar/features/common/safety/presentation/safety_screen.dart';
import 'package:mishwar/features/common/safety/presentation/trip_safety_cubit.dart';
import 'package:mishwar/features/common/safety/presentation/trip_safety_tools.dart';
import 'package:mishwar/features/common/safety/presentation/trusted_contacts_cubit.dart';
import 'package:mishwar/features/common/user/domain/entities/geo_point_value.dart';
import 'package:mocktail/mocktail.dart';

import '../../widget_test.dart' show harness;
import '../history/history_data_cubit_test.dart' show historyRide;
import 'safety_test.dart' show MockSafetyRepository, contact;

class MockLocation extends Mock implements LocationRepository {}

void size(WidgetTester tester) {
  tester.view.physicalSize = const Size(375, 812);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<TrustedContactsCubit> contactsCubit(
  MockSafetyRepository repository,
  List<TrustedContact> contacts,
) async {
  when(
    () => repository.watch('u'),
  ).thenAnswer((_) => Stream.value(Right(contacts)));
  final cubit = TrustedContactsCubit(
    WatchTrustedContacts(repository),
    SaveTrustedContact(repository),
    DeleteTrustedContact(repository),
  );
  await cubit.start('u');
  await Future<void>.value();
  return cubit;
}

void main() {
  setUpAll(() => registerFallbackValue(contact));
  for (final language in ['ar', 'en']) {
    for (final dark in [false, true]) {
      testWidgets('safety list edit delete $language dark=$dark scale 1.3', (
        tester,
      ) async {
        size(tester);
        final repository = MockSafetyRepository();
        final cubit = await contactsCubit(repository, const [
          TrustedContact(id: 'id', name: 'Person', phone: '+962781234567'),
        ]);
        addTearDown(cubit.close);
        when(
          () => repository.save('u', any()),
        ).thenAnswer((_) async => const Right(unit));
        when(
          () => repository.delete('u', 'id'),
        ).thenAnswer((_) async => const Right(unit));
        await tester.pumpWidget(
          harness(
            BlocProvider.value(
              value: cubit,
              child: SafetyScreen(driver: dark),
            ),
            language: language,
            dark: dark,
            textScale: 1.3,
          ),
        );
        await tester.pumpAndSettle();
        final l10n = tester.element(find.byType(SafetyScreen)).l10n;
        expect(find.text(l10n.emergencyFootnote), findsOneWidget);
        final phone = tester.widget<Text>(find.text('+962781234567'));
        expect(phone.textDirection, TextDirection.ltr);
        if (dark) {
          expect(
            Theme.of(tester.element(find.byType(Scaffold))).brightness,
            Brightness.dark,
          );
        }
        await tester.tap(find.text('Person'));
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<TextField>(find.byType(TextField).last)
              .controller!
              .text,
          '0781234567',
        );
        await tester.enterText(find.byType(TextField).first, 'New person');
        await tester.enterText(find.byType(TextField).last, '0791234567');
        await tester.ensureVisible(find.text(l10n.accountSave));
        await tester.tap(find.text(l10n.accountSave));
        await tester.pumpAndSettle();
        final saved =
            verify(() => repository.save('u', captureAny())).captured.single
                as TrustedContact;
        expect(saved.id, 'id');
        expect(saved.name, 'New person');
        expect(saved.phone, '+962791234567');
        await tester.tap(find.byType(PopupMenuButton<bool>));
        await tester.pumpAndSettle();
        await tester.tap(find.text(l10n.contactDelete));
        await tester.pumpAndSettle();
        expect(find.text(l10n.contactDeleteConfirm('Person')), findsOneWidget);
        verifyNever(() => repository.delete(any(), any()));
        await tester.tap(find.text(l10n.accountConfirm));
        await tester.pumpAndSettle();
        verify(() => repository.delete('u', 'id')).called(1);
        expect(tester.takeException(), isNull);
      });
      testWidgets(
        'empty safety screen and invalid add $language dark=$dark scale 1.3',
        (tester) async {
          size(tester);
          final repository = MockSafetyRepository();
          final cubit = await contactsCubit(repository, []);
          addTearDown(cubit.close);
          await tester.pumpWidget(
            harness(
              BlocProvider.value(
                value: cubit,
                child: SafetyScreen(driver: dark),
              ),
              language: language,
              dark: dark,
              textScale: 1.3,
            ),
          );
          await tester.pumpAndSettle();
          final l10n = tester.element(find.byType(SafetyScreen)).l10n;
          expect(find.text(l10n.contactsExplanation), findsOneWidget);
          await tester.tap(find.text(l10n.contactAdd));
          await tester.pumpAndSettle();
          await tester.tap(find.text(l10n.accountSave));
          await tester.pumpAndSettle();
          expect(find.text(l10n.contactInvalid), findsOneWidget);
          verifyNever(() => repository.save(any(), any()));
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
  testWidgets('five contacts disable adding', (tester) async {
    size(tester);
    final repository = MockSafetyRepository();
    final cubit = await contactsCubit(
      repository,
      List.generate(
        5,
        (i) =>
            TrustedContact(id: '$i', name: 'Person $i', phone: contact.phone),
      ),
    );
    addTearDown(cubit.close);
    await tester.pumpWidget(
      harness(BlocProvider.value(value: cubit, child: const SafetyScreen())),
    );
    await tester.pumpAndSettle();
    final l10n = tester.element(find.byType(SafetyScreen)).l10n;
    expect(find.text(l10n.contactsLimit), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
  });
  for (final driver in [false, true]) {
    testWidgets('safety tools confirm tel and launch SMS driver=$driver', (
      tester,
    ) async {
      size(tester);
      final repository = MockSafetyRepository();
      final location = MockLocation();
      final contacts = await contactsCubit(repository, const [
        contact,
        TrustedContact(id: '2', name: 'Other', phone: '+962791234567'),
      ]);
      final safety = TripSafetyCubit(
        CreateShareLink(repository),
        CurrentPosition(location),
      );
      addTearDown(contacts.close);
      addTearDown(safety.close);
      when(location.currentPosition).thenAnswer(
        (_) async => const Right(GeoPointValue(31.95, 35.91)),
      );
      when(
        () => repository.createShareLink('ride'),
      ).thenAnswer((_) async => const Right('https://example.test/t/token'));
      if (!driver) await safety.shareLink('ride');
      final launched = <Uri>[];
      await tester.pumpWidget(
        harness(
          MultiBlocProvider(
            providers: [
              BlocProvider.value(value: contacts),
              BlocProvider.value(value: safety),
            ],
            child: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () => showTripSafety(
                    context,
                    ride: historyRide('ride'),
                    driver: driver,
                    launcher: (uri) async {
                      launched.add(uri);
                      return true;
                    },
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
          dark: driver,
          textScale: 1.3,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      final l10n = tester.element(find.text('open')).l10n;
      await tester.tap(find.text(l10n.emergencyCall));
      await tester.pumpAndSettle();
      expect(launched, isEmpty);
      await tester.tap(find.text(l10n.accountConfirm));
      await tester.pumpAndSettle();
      expect(launched.single.toString(), 'tel:911');
      await tester.tap(find.text(l10n.safetySms));
      await tester.pumpAndSettle();
      final uri = launched.last;
      expect(uri.scheme, 'sms');
      expect(uri.path, '+962781234567,+962791234567');
      final body = uri.queryParameters['body']!;
      expect(body, contains('https://maps.google.com/?q=31.95,35.91'));
      if (driver) {
        expect(body, isNot(contains('example.test')));
      } else {
        expect(body, contains('Driver'));
        expect(body, contains('Toyota Corolla'));
        expect(body, contains('12-345'));
        expect(body, contains('https://example.test/t/token'));
      }
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('no contacts disables SMS and explains how to add them', (
    tester,
  ) async {
    size(tester);
    final repository = MockSafetyRepository();
    final contacts = await contactsCubit(repository, []);
    final safety = TripSafetyCubit(
      CreateShareLink(repository),
      CurrentPosition(MockLocation()),
    );
    addTearDown(contacts.close);
    addTearDown(safety.close);
    final launched = <Uri>[];
    await tester.pumpWidget(
      harness(
        MultiBlocProvider(
          providers: [
            BlocProvider.value(value: contacts),
            BlocProvider.value(value: safety),
          ],
          child: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showTripSafety(
                  context,
                  driver: true,
                  launcher: (uri) async {
                    launched.add(uri);
                    return true;
                  },
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    final l10n = tester.element(find.text('open')).l10n;
    expect(find.text(l10n.safetyNoContacts), findsOneWidget);
    await tester.tap(find.text(l10n.safetySms));
    await tester.pumpAndSettle();
    expect(launched, isEmpty);
  });
  testWidgets(
    'driver card invokes share use case and shares localized trip text',
    (tester) async {
      size(tester);
      final repository = MockSafetyRepository();
      final ride = historyRide('ride');
      final safety = TripSafetyCubit(
        CreateShareLink(repository),
        CurrentPosition(MockLocation()),
      );
      addTearDown(safety.close);
      when(
        () => repository.createShareLink('ride'),
      ).thenAnswer((_) async => const Right('https://example.test/t/token'));
      String? shared;
      await tester.pumpWidget(
        harness(
          BlocProvider.value(
            value: safety,
            child: Builder(
              builder: (context) => Scaffold(
                body: MwDriverCard(
                  driver: ride.driverInfo!,
                  onShare: () => shareSafetyTrip(
                    context,
                    ride,
                    share: (text, origin) async {
                      shared = text;
                      expect(origin.width, greaterThan(0));
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final l10n = tester.element(find.byType(MwDriverCard)).l10n;
      await tester.tap(find.byTooltip(l10n.riderShare));
      await tester.pumpAndSettle();
      expect(
        shared,
        l10n.shareTripText('Driver', 'https://example.test/t/token'),
      );
      verify(() => repository.createShareLink('ride')).called(1);
      expect(tester.takeException(), isNull);
    },
  );
}
