import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart' hide Retry;
import 'package:go_router/go_router.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/core/l10n/gen/app_localizations.dart';
import 'package:mishwar/core/theme/app_theme.dart';
import 'package:mishwar/core/widgets/mw_list_row.dart';
import 'package:mishwar/core/widgets/mw_skeleton.dart';
import 'package:mishwar/features/common/places/domain/entities/place_details.dart';
import 'package:mishwar/features/rider/search/presentation/bloc/destination_search_bloc.dart';
import 'package:mishwar/features/rider/search/presentation/bloc/destination_search_event.dart';
import 'package:mishwar/features/rider/search/presentation/bloc/destination_search_state.dart';
import 'package:mishwar/features/rider/search/presentation/destination_search_screen.dart';
import 'package:mocktail/mocktail.dart';

import 'destination_search_bloc_test.dart' show details, suggestion;

class MockSearchBloc
    extends MockBloc<DestinationSearchEvent, DestinationSearchState>
    implements DestinationSearchBloc {}

void main() {
  late MockSearchBloc bloc;
  late StreamController<DestinationSearchState> states;
  setUp(() {
    bloc = MockSearchBloc();
    states = StreamController<DestinationSearchState>.broadcast();
    addTearDown(states.close);
  });
  Future<void> pump(
    WidgetTester tester,
    DestinationSearchState state, {
    String locale = 'en',
    bool dark = false,
    double scale = 1,
  }) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    whenListen(bloc, states.stream, initialState: state);
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, _) => MaterialApp(
          theme: dark ? AppTheme.dark() : AppTheme.light(),
          locale: Locale(locale),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
          home: BlocProvider<DestinationSearchBloc>.value(
            value: bloc,
            child: const DestinationSearchScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final locale in ['ar', 'en']) {
    for (final dark in [false, true]) {
      testWidgets('suggestions $locale dark=$dark at scale 1.3', (
        tester,
      ) async {
        await pump(
          tester,
          DestinationResults(const [suggestion]),
          locale: locale,
          dark: dark,
          scale: 1.3,
        );
        expect(find.byType(MwListRow), findsOneWidget);
        expect(find.text(suggestion.primaryText), findsOneWidget);
        expect(find.text(suggestion.secondaryText), findsOneWidget);
        await tester.tap(find.text(suggestion.primaryText));
        verify(() => bloc.add(const SuggestionSelected(suggestion))).called(1);
        expect(tester.takeException(), isNull);
      });
    }
  }
  testWidgets('empty state includes query', (tester) async {
    await pump(tester, const DestinationEmpty('Park'));
    expect(find.text('No results for “Park”'), findsOneWidget);
  });
  testWidgets('failure is localized with retry', (tester) async {
    await pump(
      tester,
      const DestinationFailure(ServerFailure('internal'), 'Park'),
    );
    expect(find.text('internal'), findsNothing);
    expect(
      find.text('Something went wrong. Please try again.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Try again'));
    verify(() => bloc.add(const Retry())).called(1);
  });
  testWidgets('clear button clears input and dispatches Cleared', (
    tester,
  ) async {
    await pump(tester, const DestinationIdle());
    expect(find.byKey(const Key('clear_destination')), findsNothing);
    await tester.enterText(find.byType(TextField), 'Park');
    await tester.pump();
    verify(() => bloc.add(const QueryChanged('Park'))).called(1);
    await tester.tap(find.byKey(const Key('clear_destination')));
    await tester.pump();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
    expect(find.byKey(const Key('clear_destination')), findsNothing);
    verify(() => bloc.add(const Cleared())).called(1);
  });
  testWidgets('loading has skeletons or keeps previous rows', (tester) async {
    await pump(tester, DestinationLoading(const []));
    expect(find.byType(MwSkeleton), findsNWidgets(9));
    states.add(DestinationLoading(const [suggestion]));
    await tester.pump();
    await tester.pump();
    expect(find.byType(MwSkeleton), findsNothing);
    expect(find.byType(MwListRow), findsOneWidget);
    states.add(DestinationResolving(suggestion, const [suggestion]));
    await tester.pump();
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
  testWidgets('tapping suggestion resolves then pops PlaceDetails', (
    tester,
  ) async {
    whenListen(
      bloc,
      states.stream,
      initialState: DestinationResults(const [suggestion]),
    );
    PlaceDetails? result;
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, _) => Scaffold(
            body: TextButton(
              onPressed: () async {
                result = await context.push<PlaceDetails>('/search');
              },
              child: const Text('Open'),
            ),
          ),
        ),
        GoRoute(
          path: '/search',
          builder: (_, _) => BlocProvider<DestinationSearchBloc>.value(
            value: bloc,
            child: const DestinationSearchScreen(),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, _) => MaterialApp.router(
          routerConfig: router,
          theme: AppTheme.light(),
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(suggestion.primaryText));
    verify(() => bloc.add(const SuggestionSelected(suggestion))).called(1);
    states.add(const DestinationChosen(details));
    await tester.pumpAndSettle();
    expect(result, details);
    expect(find.text('Open'), findsOneWidget);
  });
}
