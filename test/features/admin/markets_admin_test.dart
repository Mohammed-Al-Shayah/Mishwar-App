import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishwar/core/l10n/gen/app_localizations.dart';
import 'package:mishwar/features/admin/domain/admin_repository.dart';
import 'package:mishwar/features/admin/presentation/admin_cubit.dart';
import 'package:mishwar/features/admin/presentation/admin_pricing.dart';
import 'package:mishwar/features/common/pricing/domain/entities/pricing_table.dart';
import 'package:mishwar/features/common/pricing/domain/entities/vehicle_rates.dart';
import 'package:mishwar/features/common/user/domain/entities/vehicle_entity.dart';

import 'admin_test.dart' show TestAdminRepository, makeCubit;

void main() {
  for (final language in ['ar', 'en']) {
    testWidgets(
      'pricing switches market and submits PS currency rates $language',
      (tester) async {
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final repository = TestAdminRepository();
        final cubit = makeCubit(repository);
        final ps = PricingTable({
          for (final type in VehicleType.values)
            type: const VehicleRates(
              base: 300,
              perKm: 180,
              perMin: 30,
              minimum: 1000,
            ),
        });
        await tester.pumpWidget(
          ScreenUtilInit(
            designSize: const Size(375, 812),
            enableScaleWH: () => false,
            enableScaleText: () => false,
            builder: (_, _) => MaterialApp(
              locale: Locale(language),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: MediaQuery(
                data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
                child: Scaffold(
                  body: BlocProvider<AdminCubit>.value(
                    value: cubit,
                    child: AdminPricing(
                      data: AdminData(
                        pricing: PricingTable.defaults(),
                        marketPricing: {
                          'JO': PricingTable.defaults(),
                          'PS': ps,
                        },
                      ),
                      busy: false,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text(language == 'ar' ? 'فلسطين' : 'Palestine'));
        await tester.pumpAndSettle();
        final input = tester.widget<TextFormField>(
          find.byKey(const ValueKey('economy-0')),
        );
        expect(input.controller!.text, '3.00');
        await tester.tap(find.text(language == 'ar' ? 'حفظ' : 'Save'));
        await tester.pumpAndSettle();
        expect(repository.actions.single.$2['market'], 'PS');
        expect((repository.actions.single.$2['economy']! as Map)['base'], 3);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        await cubit.close();
        await repository.feed.close();
      },
    );
  }
}
