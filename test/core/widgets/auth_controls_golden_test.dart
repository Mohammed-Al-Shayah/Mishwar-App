import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishwar/core/l10n/gen/app_localizations.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/theme/app_spacing.dart';
import 'package:mishwar/core/theme/app_theme.dart';
import 'package:mishwar/core/widgets/mw_otp_input.dart';
import 'package:mishwar/core/widgets/mw_primary_button.dart';
import 'package:mishwar/core/widgets/mw_text_field.dart';

void main() {
  setUpAll(() async {
    for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
      final loader = FontLoader('IBMPlexSansArabic')
        ..addFont(
          rootBundle.load(
            'assets/fonts/ibm_plex_sans_arabic/IBMPlexSansArabic-$weight.ttf',
          ),
        );
      await loader.load();
    }
  });
  for (final language in ['ar', 'en']) {
    for (final dark in [false, true]) {
      testWidgets('core auth controls $language dark=$dark', (tester) async {
        tester.view.physicalSize = const Size(375, 812);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          ScreenUtilInit(
            designSize: const Size(375, 812),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (_, _) => MaterialApp(
              theme: dark ? AppTheme.dark() : AppTheme.light(),
              locale: Locale(language),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Builder(
                builder: (context) => Scaffold(
                  body: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.screenPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          MwTextField(label: context.l10n.phoneLabel),
                          SizedBox(height: AppSpacing.xl),
                          MwOtpInput(onChanged: (_) {}),
                          SizedBox(height: AppSpacing.xl),
                          MwPrimaryButton(
                            label: context.l10n.continueLabel,
                            onPressed: () {},
                          ),
                          SizedBox(height: AppSpacing.xl),
                          MwPrimaryButton(
                            label: context.l10n.continueLabel,
                            onPressed: null,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await expectLater(
          find.byType(Scaffold),
          matchesGoldenFile(
            'goldens/auth_controls_${language}_${dark ? 'dark' : 'light'}.png',
          ),
        );
      });
    }
  }
}
