import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishwar/core/l10n/gen/app_localizations.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/theme/app_radius.dart';
import 'package:mishwar/core/theme/app_sizes.dart';
import 'package:mishwar/core/theme/app_spacing.dart';
import 'package:mishwar/core/theme/app_theme.dart';
import 'package:mishwar/core/theme/theme_x.dart';

/// Root widget with responsive sizing and a temporary role picker.
class MishwarApp extends StatelessWidget {
  const MishwarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        // Keep the system-theme policy explicit at the app boundary.
        // ignore: avoid_redundant_argument_values
        themeMode: ThemeMode.system,
        locale: const Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        onGenerateTitle: (context) => context.l10n.appName,
        home: const RoleSelectPlaceholder(),
      ),
    );
  }
}

enum _Role { rider, driver }

/// Temporary role picker until the auth router is implemented in T1.3.
class RoleSelectPlaceholder extends StatefulWidget {
  const RoleSelectPlaceholder({super.key});

  @override
  State<RoleSelectPlaceholder> createState() => _RoleSelectPlaceholderState();
}

class _RoleSelectPlaceholderState extends State<RoleSelectPlaceholder> {
  _Role? _selected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.appName,
                        style: context.textStyles.displayLarge,
                      ),
                      SizedBox(height: AppSpacing.xxl),
                      Text(
                        l10n.roleTitle,
                        style: context.textStyles.headlineMedium,
                      ),
                      SizedBox(height: AppSpacing.xl),
                      for (final role in _Role.values) ...[
                        Semantics(
                          selected: _selected == role,
                          button: true,
                          child: Material(
                            color: _selected == role
                                ? context.colors.fillSubtle
                                : Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.vehicleRowBorder,
                              side: BorderSide(
                                color: _selected == role
                                    ? context.colors.textPrimary
                                    : Colors.transparent,
                                width: AppSizes.selectedBorder,
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              key: Key(
                                role == _Role.rider
                                    ? 'role_rider'
                                    : 'role_driver',
                              ),
                              onTap: () => setState(() => _selected = role),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: AppSizes.rowMinHeight,
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(AppSpacing.sm),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: AppSizes.iconCircle,
                                        height: AppSizes.iconCircle,
                                        decoration: BoxDecoration(
                                          color: context.colors.fill,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          role == _Role.rider
                                              ? Icons.hail_outlined
                                              : Icons.directions_car_outlined,
                                        ),
                                      ),
                                      SizedBox(width: AppSpacing.sm),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              role == _Role.rider
                                                  ? l10n.roleRider
                                                  : l10n.roleDriver,
                                              style: context
                                                  .textStyles
                                                  .titleMedium,
                                            ),
                                            SizedBox(height: AppSpacing.xxs),
                                            Text(
                                              role == _Role.rider
                                                  ? l10n.roleRiderSubtitle
                                                  : l10n.roleDriverSubtitle,
                                              style: context
                                                  .textStyles
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color: context
                                                        .colors
                                                        .textSecondary,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: AppSpacing.sm),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.md),
              FilledButton(
                key: const Key('role_continue'),
                onPressed: _selected == null
                    ? null
                    : () => _open(context, _selected!),
                child: Text(l10n.continueLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _open(BuildContext context, _Role role) {
    unawaited(
      Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (context) => Scaffold(
            appBar: AppBar(),
            body: SafeArea(
              child: Center(
                child: Text(
                  role == _Role.rider
                      ? context.l10n.riderMode
                      : context.l10n.driverMode,
                  style: context.textStyles.headlineMedium,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
