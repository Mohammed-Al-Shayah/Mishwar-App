import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/l10n/gen/app_localizations.dart';
import 'package:mishwar/core/theme/admin_theme.dart';
import 'package:mishwar/features/admin/domain/admin_usecases.dart';
import 'package:mishwar/features/admin/presentation/admin_content.dart';
import 'package:mishwar/features/admin/presentation/admin_content_cubit.dart';
import 'package:mishwar/features/common/app_config/domain/app_banner.dart';
import 'package:mishwar/features/common/app_config/domain/app_config_usecases.dart';
import 'package:mishwar/features/common/app_config/domain/app_service.dart';
import 'package:mocktail/mocktail.dart';

import '../admin/admin_test.dart' show TestAdminRepository;
import 'app_config_test.dart' show MockConfigRepository, demoBanner;

Widget harness(Widget child, {String language = 'en'}) => ScreenUtilInit(
  designSize: const Size(375, 812),
  enableScaleWH: () => false,
  enableScaleText: () => false,
  builder: (_, _) => MaterialApp(
    theme: AdminTheme.light(),
    locale: Locale(language),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: child,
  ),
);

void main() {
  for (final action in [BannerAction.openPromo, BannerAction.url]) {
    testWidgets('banner target validation for ${action.name}', (tester) async {
      final repo = MockConfigRepository();
      when(
        repo.watchAllBanners,
      ).thenAnswer((_) => Stream.value(Right([demoBanner(action: action)])));
      when(
        repo.watchServices,
      ).thenAnswer((_) => Stream.value(const Right(AppService.defaults)));
      final admin = TestAdminRepository();
      final cubit = AdminContentCubit(
        WatchAllBanners(repo),
        WatchServices(repo),
        AdminAction(admin),
      )..start();
      addTearDown(cubit.close);
      addTearDown(admin.feed.close);
      await tester.pumpWidget(
        harness(
          BlocProvider.value(
            value: cubit,
            child: const Scaffold(body: AdminContent()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Offer a'));
      await tester.tap(find.text('Offer a'));
      await tester.pumpAndSettle();
      final fields = find.byType(TextFormField);
      await tester.enterText(
        fields.at(3),
        action == BannerAction.url ? 'http://example.com' : '',
      );
      await tester.tap(find.text('Save').last);
      await tester.pumpAndSettle();
      expect(admin.actions, isEmpty);
      await tester.enterText(
        fields.at(3),
        action == BannerAction.url ? 'https://example.com' : 'WELCOME50',
      );
      await tester.tap(find.text('Save').last);
      await tester.pumpAndSettle();
      expect(
        admin.actions.single.$2[action == BannerAction.url
            ? 'url'
            : 'promoCode'],
        action == BannerAction.url ? 'https://example.com' : 'WELCOME50',
      );
    });
  }

  testWidgets(
    'services toggle and reorder remain local until save via callable',
    (tester) async {
      final repo = MockConfigRepository();
      when(
        repo.watchAllBanners,
      ).thenAnswer((_) => Stream.value(const Right([])));
      when(
        repo.watchServices,
      ).thenAnswer((_) => Stream.value(const Right(AppService.defaults)));
      final admin = TestAdminRepository();
      final cubit = AdminContentCubit(
        WatchAllBanners(repo),
        WatchServices(repo),
        AdminAction(admin),
      )..start();
      addTearDown(cubit.close);
      addTearDown(admin.feed.close);
      await tester.pumpWidget(
        harness(
          BlocProvider.value(
            value: cubit,
            child: const Scaffold(body: AdminContent()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Switch).at(2));
      await tester.pumpAndSettle();
      expect(cubit.state.services[2].enabled, isTrue);
      expect(admin.actions, isEmpty);
      await tester.tap(find.byTooltip('Move up').at(2));
      await tester.pumpAndSettle();
      expect(cubit.state.services[1].id, ServiceId.parcel);
      await tester.tap(find.text('Save').last);
      await tester.pumpAndSettle();
      expect(admin.actions.single.$1, 'updateServices');
      final sent = admin.actions.single.$2['services']! as List;
      expect((sent[1] as Map)['id'], 'parcel');
      expect((sent[1] as Map)['order'], 1);
      expect((sent[1] as Map)['enabled'], isTrue);
      expect(cubit.state.dirty, isFalse);
    },
  );

  testWidgets(
    'banner editor validates bounds and https, saves action and target',
    (tester) async {
      final repo = MockConfigRepository();
      when(
        repo.watchAllBanners,
      ).thenAnswer((_) => Stream.value(Right([demoBanner()])));
      when(repo.watchServices).thenAnswer((_) => const Stream.empty());
      final admin = TestAdminRepository();
      final cubit = AdminContentCubit(
        WatchAllBanners(repo),
        WatchServices(repo),
        AdminAction(admin),
      )..start();
      addTearDown(cubit.close);
      addTearDown(admin.feed.close);
      await tester.pumpWidget(
        harness(
          BlocProvider.value(
            value: cubit,
            child: const Scaffold(body: AdminContent()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add banner'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save').last);
      await tester.pumpAndSettle();
      expect(admin.actions, isEmpty);
      expect(find.text('Check this value'), findsWidgets);
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'x' * 61);
      await tester.enterText(fields.at(2), 'http://example.com');
      await tester.tap(find.text('Save').last);
      await tester.pumpAndSettle();
      expect(admin.actions, isEmpty);
      await tester.enterText(fields.at(0), 'Welcome');
      await tester.enterText(fields.at(1), 'Offer');
      await tester.enterText(fields.at(2), 'https://example.com/image');
      await tester.tap(find.text('Save').last);
      await tester.pumpAndSettle();
      expect(admin.actions.single.$1, 'upsertBanner');
      expect(admin.actions.single.$2['title'], 'Welcome');
      expect(admin.actions.single.$2['action'], 'open_search');
    },
  );
  testWidgets('delete requires confirmation', (tester) async {
    final repo = MockConfigRepository();
    when(
      repo.watchAllBanners,
    ).thenAnswer((_) => Stream.value(Right([demoBanner()])));
    final admin = TestAdminRepository();
    when(repo.watchServices).thenAnswer((_) => const Stream.empty());
    final cubit = AdminContentCubit(
      WatchAllBanners(repo),
      WatchServices(repo),
      AdminAction(admin),
    )..start();
    addTearDown(cubit.close);
    addTearDown(admin.feed.close);
    await tester.pumpWidget(
      harness(
        BlocProvider.value(
          value: cubit,
          child: const Scaffold(body: AdminContent()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(admin.actions, isEmpty);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(admin.actions, isEmpty);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();
    expect(admin.actions.single.$1, 'deleteBanner');
  });
}
