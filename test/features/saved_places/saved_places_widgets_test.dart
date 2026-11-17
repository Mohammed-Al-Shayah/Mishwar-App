import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/widgets/mw_list_row.dart';
import 'package:mishwar/features/common/places/domain/entities/place_details.dart';
import 'package:mishwar/features/common/saved_places/domain/saved_place.dart';
import 'package:mishwar/features/common/saved_places/presentation/saved_places_cubit.dart';
import 'package:mishwar/features/rider/home/presentation/cubit/recent_places_cubit.dart';
import 'package:mishwar/features/rider/home/presentation/widgets/home_shortcuts.dart';
import 'package:mishwar/features/rider/places/presentation/saved_places_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/saved_places_mocks.dart';
import '../../widget_test.dart' show harness;

void size(WidgetTester tester) {
  tester.view.physicalSize = const Size(375, 812);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  setUpAll(() => registerFallbackValue(savedHome));
  for (final language in ['ar', 'en']) {
    for (final dark in [false, true]) {
      testWidgets(
        'shortcuts set/unset and recent $language dark=$dark scale 1.3',
        (tester) async {
          size(tester);
          final saved = savedCubit(places: [savedHome]);
          final recent = recentCubit(places: [savedOther.details]);
          addTearDown(saved.close);
          addTearDown(recent.close);
          PlaceDetails? picked;
          SavedPlaceLabel? added;
          await tester.pumpWidget(
            harness(
              MultiBlocProvider(
                providers: [
                  BlocProvider<SavedPlacesCubit>.value(value: saved),
                  BlocProvider<RecentPlacesCubit>.value(value: recent),
                ],
                child: Scaffold(
                  body: HomeShortcuts(
                    onPlace: (p) => picked = p,
                    onAddSaved: (label) => added = label,
                  ),
                ),
              ),
              language: language,
              dark: dark,
              textScale: 1.3,
            ),
          );
          await tester.pumpAndSettle();
          expect(find.byType(MwListRow), findsNWidgets(3));
          await tester.tap(find.byKey(const Key('home_shortcut_home')));
          expect(picked, savedHome.details);
          await tester.tap(find.byKey(const Key('home_shortcut_work')));
          expect(added, SavedPlaceLabel.work);
          await tester.tap(find.text('Park'));
          expect(picked, savedOther.details);
          expect(tester.takeException(), isNull);
        },
      );
      testWidgets(
        'list, edit and delete $language dark=$dark scale 1.3',
        (tester) async {
          size(tester);
          final cubit = savedCubit(places: [savedHome, savedOther]);
          addTearDown(cubit.close);
          when(() => cubit.save(any())).thenAnswer((_) async => true);
          when(() => cubit.delete('park')).thenAnswer((_) async => true);
          await tester.pumpWidget(
            harness(
              BlocProvider<SavedPlacesCubit>.value(
                value: cubit,
                child: const SavedPlacesScreen(),
              ),
              language: language,
              dark: dark,
              textScale: 1.3,
            ),
          );
          await tester.pumpAndSettle();
          final l10n = tester.element(find.byType(SavedPlacesScreen)).l10n;
          expect(find.text(l10n.savedPlaces), findsOneWidget);
          expect(find.text('Home street'), findsOneWidget);
          await tester.tap(find.byType(IconButton).last);
          await tester.pumpAndSettle();
          await tester.tap(find.text(l10n.savedPlaceEdit));
          await tester.pumpAndSettle();
          expect(
            tester.widget<TextField>(find.byType(TextField)).controller!.text,
            'Park',
          );
          await tester.enterText(find.byType(TextField), 'New park');
          await tester.ensureVisible(find.text(l10n.accountSave));
          await tester.tap(find.text(l10n.accountSave));
          await tester.pumpAndSettle();
          final place =
              verify(() => cubit.save(captureAny())).captured.single
                  as SavedPlace;
          expect(place.id, 'park');
          expect(place.name, 'New park');
          expect(place.location, savedOther.location);
          await tester.tap(find.byType(IconButton).last);
          await tester.pumpAndSettle();
          await tester.tap(find.text(l10n.savedPlaceDelete));
          await tester.pumpAndSettle();
          expect(
            find.text(l10n.savedPlaceDeleteConfirm('Park')),
            findsOneWidget,
          );
          verifyNever(() => cubit.delete('park'));
          await tester.tap(find.text(l10n.accountConfirm));
          await tester.pumpAndSettle();
          verify(() => cubit.delete('park')).called(1);
          expect(tester.takeException(), isNull);
        },
      );
    }
    testWidgets('empty state and editor singleton availability $language', (
      tester,
    ) async {
      size(tester);
      final cubit = savedCubit();
      addTearDown(cubit.close);
      await tester.pumpWidget(
        harness(
          BlocProvider<SavedPlacesCubit>.value(
            value: cubit,
            child: const SavedPlacesScreen(),
          ),
          language: language,
          textScale: 1.3,
        ),
      );
      await tester.pumpAndSettle();
      final l10n = tester.element(find.byType(SavedPlacesScreen)).l10n;
      expect(find.text(l10n.savedPlacesEmpty), findsOneWidget);
      expect(find.text(l10n.savedPlacesEmptyHint), findsOneWidget);
      await tester.tap(find.text(l10n.savedPlaceAdd));
      await tester.pumpAndSettle();
      expect(find.byType(RadioListTile<SavedPlaceLabel>), findsNWidgets(3));
      expect(find.byType(TextField), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets(
    'editor picks a place through search contract and shows inline failure',
    (tester) async {
      size(tester);
      final cubit = savedCubit(places: [savedHome]);
      final states = StreamController<SavedPlacesState>.broadcast();
      addTearDown(states.close);
      whenListen(
        cubit,
        states.stream,
        initialState: const SavedPlacesState(
          places: [savedHome],
          loading: false,
        ),
      );
      addTearDown(cubit.close);
      when(() => cubit.save(any())).thenAnswer((_) async => false);
      final router = GoRouter(
        initialLocation: '/rider/places',
        routes: [
          GoRoute(
            path: '/rider/places',
            builder: (_, _) => BlocProvider<SavedPlacesCubit>.value(
              value: cubit,
              child: const SavedPlacesScreen(
                openEditorFor: SavedPlaceLabel.work,
              ),
            ),
          ),
          GoRoute(
            path: '/rider/search',
            builder: (context, _) => Scaffold(
              body: TextButton(
                onPressed: () => context.pop(savedOther.details),
                child: const Text('Pick park'),
              ),
            ),
          ),
        ],
      );
      addTearDown(router.dispose);
      // Reuse the localized harness while installing this test router.
      await tester.pumpWidget(
        harness(
          Builder(builder: (context) => Router.withConfig(config: router)),
          textScale: 1.3,
        ),
      );
      await tester.pumpAndSettle();
      final l10n = tester.element(find.byType(SavedPlacesScreen)).l10n;
      final options = tester
          .widgetList<RadioListTile<SavedPlaceLabel>>(
            find.byType(RadioListTile<SavedPlaceLabel>),
          )
          .toList();
      expect(options.first.enabled, isFalse);
      expect(options[1].enabled, isTrue);
      expect(find.byType(TextField), findsNothing);
      await tester.tap(find.text(l10n.savedPlaceChooseLocation));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pick park'));
      await tester.pumpAndSettle();
      expect(find.text('Park'), findsOneWidget);
      await tester.tap(find.text(l10n.savedPlaceOther));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'Park',
      );
      await tester.tap(find.text(l10n.savedPlaceWork));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.accountSave));
      await tester.pumpAndSettle();
      final saved =
          verify(() => cubit.save(captureAny())).captured.single as SavedPlace;
      expect(saved.id, 'work');
      expect(saved.label, SavedPlaceLabel.work);
      expect(saved.name, 'Park');
      states.add(
        const SavedPlacesState(
          loading: false,
          places: [savedHome],
          failure: ValidationFailure('saved-places-limit'),
        ),
      );
      // Deliver a failed submission to the editor.
      await tester.tap(find.text(l10n.savedPlaceOther));
      await tester.pumpAndSettle();
      expect(find.text(l10n.savedPlaceLimit), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );
}
