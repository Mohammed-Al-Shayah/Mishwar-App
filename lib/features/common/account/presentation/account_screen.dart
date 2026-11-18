import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mishwar/core/l10n/failure_message.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/settings/locale_cubit.dart';
import 'package:mishwar/core/settings/theme_mode_cubit.dart';
import 'package:mishwar/core/theme/app_icons.dart';
import 'package:mishwar/core/theme/app_radius.dart';
import 'package:mishwar/core/theme/app_sizes.dart';
import 'package:mishwar/core/theme/app_spacing.dart';
import 'package:mishwar/core/theme/app_theme.dart';
import 'package:mishwar/core/theme/theme_x.dart';
import 'package:mishwar/core/widgets/mw_bottom_nav.dart';
import 'package:mishwar/core/widgets/mw_list_row.dart';
import 'package:mishwar/core/widgets/mw_primary_button.dart';
import 'package:mishwar/core/widgets/mw_star_rating.dart';
import 'package:mishwar/core/widgets/mw_text_field.dart';
import 'package:mishwar/features/common/account/presentation/account_cubit.dart';
import 'package:mishwar/features/common/user/domain/entities/user_role.dart';
import 'package:mishwar/features/common/user/domain/entities/vehicle_entity.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({
    this.driver = false,
    this.supportUnread = false,
    super.key,
  });
  final bool supportUnread;
  final bool driver;
  @override
  Widget build(BuildContext context) => driver
      ? Theme(
          data: AppTheme.dark(),
          child: _AccountBody(driver: true, supportUnread: supportUnread),
        )
      : _AccountBody(driver: false, supportUnread: supportUnread);
}

class _AccountBody extends StatelessWidget {
  const _AccountBody({required this.driver, required this.supportUnread});
  final bool supportUnread;
  final bool driver;
  Future<T?> _sheet<T>(BuildContext context, String title, Widget child) =>
      showModalBottomSheet<T>(
        // This sheet draws its own grabber.
        showDragHandle: false,
        context: context,
        isScrollControlled: true,
        backgroundColor: context.colors.sheet,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.sheetBorder),
        builder: (context) => SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.md + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: AppSizes.grabberWidth,
                    height: AppSizes.grabberHeight,
                    decoration: BoxDecoration(
                      color: context.colors.divider,
                      borderRadius: AppRadius.pillBorder,
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.md),
                Text(
                  title,
                  style: context.textStyles.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const Divider(),
                child,
              ],
            ),
          ),
        ),
      );
  Future<bool> _confirm(
    BuildContext context,
    String title,
    String message,
  ) async =>
      await _sheet<bool>(
        context,
        title,
        Builder(
          builder: (context) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(message, style: context.textStyles.bodyMedium),
              SizedBox(height: AppSpacing.lg),
              MwPrimaryButton(
                label: context.l10n.accountConfirm,
                onPressed: () => Navigator.pop(context, true),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(context.l10n.accountCancel),
              ),
            ],
          ),
        ),
      ) ??
      false;

  Future<void> _editName(BuildContext context, String name) async {
    final cubit = context.read<AccountCubit>();
    final value = await _sheet<String>(
      context,
      context.l10n.accountProfile,
      _AccountInput(initial: name),
    );
    if (value != null) await cubit.updateName(value);
  }

  Future<void> _language(BuildContext context) async {
    final cubit = context.read<LocaleCubit>();
    await _sheet<void>(
      context,
      context.l10n.accountLanguage,
      Builder(
        builder: (context) => RadioGroup<String>(
          groupValue: cubit.state.languageCode,
          onChanged: (value) {
            if (value != null) unawaited(cubit.setLocale(value));
            Navigator.pop(context);
          },
          child: Column(
            children: [
              RadioListTile(
                value: 'ar',
                title: Text(context.l10n.accountArabic),
              ),
              RadioListTile(
                value: 'en',
                title: Text(context.l10n.accountEnglish),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _appearance(BuildContext context) async {
    final cubit = context.read<ThemeModeCubit>();
    await _sheet<void>(
      context,
      context.l10n.accountAppearance,
      Builder(
        builder: (context) => RadioGroup<ThemeMode>(
          groupValue: cubit.state,
          onChanged: (value) {
            if (value != null) unawaited(cubit.setMode(value));
            Navigator.pop(context);
          },
          child: Column(
            children: [
              RadioListTile(
                value: ThemeMode.system,
                title: Text(context.l10n.accountSystem),
              ),
              RadioListTile(
                value: ThemeMode.light,
                title: Text(context.l10n.accountLight),
              ),
              RadioListTile(
                value: ThemeMode.dark,
                title: Text(context.l10n.accountDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _delete(BuildContext context) async {
    final cubit = context.read<AccountCubit>();
    if (!await _confirm(
          context,
          context.l10n.accountDelete,
          context.l10n.accountDeleteWarning,
        ) ||
        !context.mounted) {
      return;
    }
    final confirmed = await _sheet<String>(
      context,
      context.l10n.accountDelete,
      const _AccountInput(deleting: true),
    );
    if (confirmed != null) await cubit.deleteAccount();
  }

  Future<void> _about(BuildContext context) async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!context.mounted) return;
      await _sheet<void>(
        context,
        context.l10n.accountAbout,
        Text(
          '${context.l10n.accountVersion} ${info.version} '
          '(${info.buildNumber})',
          style: context.textStyles.bodyMedium,
        ),
      );
    } on Object {
      if (context.mounted) {
        await _sheet<void>(
          context,
          context.l10n.accountAbout,
          Text(context.l10n.errorGeneric),
        );
      }
    }
  }

  Future<void> _openUrl(BuildContext context, String url) async {
    try {
      if (await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      )) {
        return;
      }
    } on Object {
      /* Show the same localized failure for unsupported URLs. */
    }
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.errorGeneric)));
    }
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<AccountCubit, AccountState>(
    builder: (context, state) {
      final l10n = context.l10n;
      final cubit = context.read<AccountCubit>();
      final user = state.user;
      Widget row(
        String title,
        IconData icon,
        VoidCallback action, {
        String subtitle = '',
      }) => MwListRow(
        icon: icon,
        title: title,
        subtitle: subtitle,
        trailing: Icon(AppIcons.chevron, size: AppSizes.icon),
        onTap: state.busy ? null : action,
      );
      const terms = String.fromEnvironment('TERMS_URL');
      const privacy = String.fromEnvironment('PRIVACY_URL');
      return Scaffold(
        appBar: AppBar(title: Text(l10n.navAccount)),
        bottomNavigationBar: driver
            ? null
            : MwBottomNav(
                index: 2,
                onTap: (index) {
                  if (index == 0) context.go('/rider');
                  if (index == 1) context.go('/rider/history');
                },
              ),
        body: user == null
            ? Center(
                child: state.failure == null
                    ? const CircularProgressIndicator()
                    : Text(failureMessage(context, state.failure!)),
              )
            : ListView(
                padding: EdgeInsets.all(AppSpacing.md),
                children: [
                  Row(
                    children: [
                      Container(
                        width: AppSizes.statusCircle,
                        height: AppSizes.statusCircle,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: context.colors.fill,
                        ),
                        child: Text(
                          user.name.characters.firstOrNull ?? '',
                          style: context.textStyles.headlineMedium,
                        ),
                      ),
                      SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: context.textStyles.headlineSmall,
                            ),
                            Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: Text(
                                user.phone,
                                textDirection: TextDirection.ltr,
                                style: context.textStyles.bodySmall,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xxs,
                              ),
                              decoration: BoxDecoration(
                                color: context.colors.fill,
                                borderRadius: AppRadius.pillBorder,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  MwStarDisplay(
                                    value: 1,
                                    size: AppSizes.ratingStar,
                                    count: 1,
                                  ),
                                  SizedBox(width: AppSpacing.xxs),
                                  Text(
                                    user.rating.toStringAsFixed(1),
                                    style: context.textStyles.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.lg),
                  if (state.busy) const LinearProgressIndicator(),
                  if (state.failure != null)
                    Text(
                      state.failure!.message == 'account-busy'
                          ? l10n.accountBusy
                          : failureMessage(context, state.failure!),
                      key: const Key('account_error'),
                      style: context.textStyles.bodySmall?.copyWith(
                        color: context.colors.negative,
                      ),
                    ),
                  row(
                    l10n.accountProfile,
                    AppIcons.user,
                    () => _editName(context, user.name),
                  ),
                  if (!driver)
                    row(
                      l10n.savedPlaces,
                      AppIcons.house,
                      () => context.push<void>('/rider/places'),
                    ),
                  row(
                    l10n.safetyTitle,
                    AppIcons.shield,
                    () => context.push<void>(
                      driver ? '/driver/safety' : '/rider/safety',
                    ),
                  ),
                  row(
                    l10n.accountLanguage,
                    AppIcons.globe,
                    () => _language(context),
                    // Language names are shown in their own language.
                    subtitle:
                        context.watch<LocaleCubit>().state.languageCode == 'en'
                        ? 'English'
                        : 'العربية',
                  ),
                  if (!driver)
                    row(
                      l10n.accountAppearance,
                      AppIcons.appearance,
                      () => _appearance(context),
                      subtitle: switch (context.watch<ThemeModeCubit>().state) {
                        ThemeMode.system => l10n.accountSystem,
                        ThemeMode.light => l10n.accountLight,
                        ThemeMode.dark => l10n.accountDark,
                      },
                    ),
                  if (driver)
                    row(
                      l10n.accountVehicle,
                      AppIcons.car,
                      subtitle: [
                        state.driver?.vehicle.make,
                        state.driver?.vehicle.model,
                      ].whereType<String>().join(' '),
                      () {
                        final vehicle = state.driver?.vehicle;
                        unawaited(
                          _sheet<void>(
                            context,
                            l10n.accountVehicle,
                            vehicle == null
                                ? Text(l10n.errorGeneric)
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${vehicle.make} ${vehicle.model}',
                                        style: context.textStyles.titleMedium,
                                      ),
                                      Text(switch (vehicle.type) {
                                        VehicleType.economy =>
                                          l10n.vehicleEconomy,
                                        VehicleType.comfort =>
                                          l10n.vehicleComfort,
                                        VehicleType.van => l10n.vehicleVan,
                                      }),
                                      Text(vehicle.color),
                                      Align(
                                        alignment:
                                            AlignmentDirectional.centerStart,
                                        child: Text(
                                          vehicle.plate,
                                          textDirection: TextDirection.ltr,
                                          style:
                                              context.textStyles.headlineSmall,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        );
                      },
                    ),
                  row(
                    driver ? l10n.accountRide : l10n.accountDrive,
                    driver ? AppIcons.switchMode : AppIcons.car,
                    () async {
                      if (await _confirm(
                        context,
                        driver ? l10n.accountRide : l10n.accountDrive,
                        l10n.accountSwitchConfirm,
                      )) {
                        await cubit.switchRole(
                          driver ? UserRole.rider : UserRole.driver,
                        );
                      }
                    },
                  ),
                  if (terms.isNotEmpty)
                    row(
                      l10n.accountTerms,
                      AppIcons.shield,
                      () => _openUrl(context, terms),
                    ),
                  if (privacy.isNotEmpty)
                    row(
                      l10n.accountPrivacy,
                      AppIcons.shield,
                      () => _openUrl(context, privacy),
                    ),
                  MwListRow(
                    icon: AppIcons.info,
                    title: l10n.supportTitle,
                    subtitle: '',
                    trailing: supportUnread
                        ? Semantics(
                            label: l10n.supportUnread,
                            child: Container(
                              width: AppSpacing.sm,
                              height: AppSpacing.sm,
                              decoration: BoxDecoration(
                                color: context.colors.textPrimary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          )
                        : Icon(AppIcons.chevron, size: AppSizes.icon),
                    onTap: state.busy
                        ? null
                        : () => context.push(
                            '/${driver ? 'driver' : 'rider'}/support',
                          ),
                  ),
                  row(l10n.accountAbout, AppIcons.info, () => _about(context)),
                  SizedBox(height: AppSpacing.lg),
                  FilledButton.tonal(
                    style: FilledButton.styleFrom(
                      backgroundColor: context.colors.fill,
                      foregroundColor: context.colors.textPrimary,
                    ),
                    onPressed: state.busy
                        ? null
                        : () async {
                            if (await _confirm(
                              context,
                              l10n.signOutLabel,
                              l10n.accountSignOutConfirm,
                            )) {
                              await cubit.signOut();
                            }
                          },
                    child: Text(l10n.signOutLabel),
                  ),
                  TextButton(
                    onPressed: state.busy ? null : () => _delete(context),
                    style: TextButton.styleFrom(
                      foregroundColor: context.colors.negative,
                    ),
                    child: Text(l10n.accountDelete),
                  ),
                ],
              ),
      );
    },
  );
}

class _AccountInput extends StatefulWidget {
  const _AccountInput({this.initial = '', this.deleting = false});
  final String initial;
  final bool deleting;
  @override
  State<_AccountInput> createState() => _AccountInputState();
}

class _AccountInputState extends State<_AccountInput> {
  late final _controller = TextEditingController(text: widget.initial);
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final value = _controller.text.trim();
    final valid = widget.deleting
        ? value == l10n.accountDeleteWord
        : value.runes.length >= 2 && value.runes.length <= 40;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MwTextField(
          label: widget.deleting ? l10n.accountDeletePrompt : l10n.accountName,
          controller: _controller,
          onChanged: (_) => setState(() {}),
        ),
        if (!valid && !widget.deleting)
          Text(
            l10n.accountNameError,
            style: context.textStyles.bodySmall?.copyWith(
              color: context.colors.negative,
            ),
          ),
        SizedBox(height: AppSpacing.lg),
        MwPrimaryButton(
          label: widget.deleting ? l10n.accountDelete : l10n.accountSave,
          onPressed: valid ? () => Navigator.pop(context, value) : null,
        ),
      ],
    );
  }
}
