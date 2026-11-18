import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mishwar/core/l10n/gen/app_localizations.dart';
import 'package:mishwar/features/common/app_config/domain/app_service.dart';
import 'package:mishwar/features/common/app_config/presentation/app_config_cubit.dart';
import 'package:mishwar/features/rider/home/presentation/widgets/services_grid.dart';

import '../../helpers/saved_places_mocks.dart' show appConfigCubit;
import '../../widget_test.dart' show harness;

void main() {
  for (final locale in ['ar', 'en']) {
    for (final dark in [false, true]) {
      testWidgets(
        'ordered services enabled/disabled, $locale dark=$dark at 1.3',
        (tester) async {
          tester.view.physicalSize = const Size(375, 812);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final selected = <ServiceId>[];
          var all = false;
          await tester.pumpWidget(
            harness(
              Scaffold(
                body: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ServicesGrid(
                    services: const [
                      AppService(id: ServiceId.ride, enabled: true, order: 3),
                      AppService(
                        id: ServiceId.schedule,
                        enabled: true,
                        order: 2,
                      ),
                      AppService(
                        id: ServiceId.parcel,
                        enabled: false,
                        order: 1,
                      ),
                      AppService(
                        id: ServiceId.airport,
                        enabled: false,
                        order: 0,
                      ),
                    ],
                    onService: selected.add,
                    onAll: () => all = true,
                  ),
                ),
              ),
              language: locale,
              dark: dark,
              textScale: 1.3,
            ),
          );
          await tester.pumpAndSettle();
          final l10n = AppLocalizations.of(
            tester.element(find.byType(ServicesGrid)),
          )!;
          expect(find.text(l10n.serviceSoon), findsNWidgets(2));
          final positions = [
            for (final id in [
              ServiceId.airport,
              ServiceId.parcel,
              ServiceId.schedule,
              ServiceId.ride,
            ])
              tester.getCenter(find.byKey(ValueKey('service_${id.name}'))).dx,
          ];
          expect(
            positions,
            locale == 'ar'
                ? orderedEquals(
                    positions.toList()..sort((a, b) => b.compareTo(a)),
                  )
                : orderedEquals(positions.toList()..sort()),
          );
          await tester.tap(find.byKey(const ValueKey('service_parcel')));
          await tester.pumpAndSettle();
          expect(find.text(l10n.serviceSoonMessage), findsOneWidget);
          expect(selected, isEmpty);
          await tester.tap(find.byKey(const ValueKey('service_ride')));
          expect(selected, [ServiceId.ride]);
          await tester.tap(find.text(l10n.servicesAll));
          expect(all, isTrue);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
  testWidgets('all route displays full two-column grid and descriptions', (
    tester,
  ) async {
    final cubit = appConfigCubit();
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, _) => Scaffold(
            body: ServicesGrid(
              services: AppService.defaults,
              onService: (_) {},
              onAll: () => context.push<void>('/rider/services'),
            ),
          ),
        ),
        GoRoute(
          path: '/rider/services',
          builder: (_, _) => BlocProvider<AppConfigCubit>.value(
            value: cubit,
            child: const ServicesScreen(),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    // Reuse localization/theme from the harness while testing the real route.
    await tester.pumpWidget(
      harness(
        Builder(
          builder: (context) => MaterialApp.router(
            routerConfig: router,
            theme: Theme.of(context),
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          ),
        ),
        language: 'en',
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('See all'));
    await tester.pumpAndSettle();
    expect(router.state.uri.path, '/rider/services');
    expect(find.byType(GridView), findsOneWidget);
    expect(find.text('Choose your departure'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('service_ride')));
    await tester.pumpAndSettle();
    expect(router.state.uri.path, '/');
  });
}
