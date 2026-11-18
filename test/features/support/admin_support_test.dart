import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/l10n/gen/app_localizations.dart';
import 'package:mishwar/core/theme/app_theme.dart';
import 'package:mishwar/features/admin/presentation/admin_support.dart';
import 'package:mishwar/features/common/support/domain/support_ticket.dart';
import 'package:mishwar/features/common/support/domain/support_usecases.dart';
import 'package:mishwar/features/common/support/presentation/support_cubits.dart';
import 'package:mocktail/mocktail.dart';

import 'support_test.dart';

void main() {
  for (final language in ['ar', 'en']) {
    testWidgets('admin support table, filter, reply and status $language', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repo = MockSupport();
      stubThread(repo);
      when(
        repo.watchTickets,
      ).thenAnswer((_) => Stream.value(Right([ticket()])));
      when(
        () => repo.watchTickets(status: SupportStatus.closed),
      ).thenAnswer((_) => Stream.value(const Right([])));
      when(
        () => repo.send('t', 'We can help', admin: true),
      ).thenAnswer((_) async => const Right(unit));
      when(
        () => repo.setStatus('t', SupportStatus.closed),
      ).thenAnswer((_) async => const Right(unit));
      final list = SupportListCubit(WatchSupportTickets(repo));
      final conversation = thread(repo);
      addTearDown(() => tester.runAsync(list.close));
      addTearDown(() => tester.runAsync(conversation.close));
      await list.start();
      await conversation.start('t', admin: true);
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          enableScaleWH: () => false,
          enableScaleText: () => false,
          builder: (_, _) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: list),
              BlocProvider.value(value: conversation),
            ],
            child: MaterialApp(
              locale: Locale(language),
              theme: AppTheme.light(),
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: const TextScaler.linear(1.3)),
                child: child!,
              ),
              home: const Scaffold(body: AdminSupport(ticketId: 't')),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(DataTable), findsOneWidget);
      expect(find.text('u'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'We can help');
      await tester.pump();
      await tester.tap(find.text(language == 'ar' ? 'إرسال' : 'Send'));
      await tester.pumpAndSettle();
      verify(() => repo.send('t', 'We can help', admin: true)).called(1);
      final closed = language == 'ar' ? 'مغلق' : 'Closed';
      await tester.tap(find.widgetWithText(TextButton, closed));
      await tester.pumpAndSettle();
      verify(() => repo.setStatus('t', SupportStatus.closed)).called(1);
      await tester.runAsync(() async {
        await tester.tap(find.widgetWithText(ChoiceChip, closed));
        await Future<void>.delayed(Duration.zero);
      });
      await tester.pumpAndSettle();
      expect(list.state.filter, SupportStatus.closed);
      expect(find.text('u'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}
