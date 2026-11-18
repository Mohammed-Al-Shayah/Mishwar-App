import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/settings/locale_cubit.dart';
import 'package:mishwar/core/theme/admin_sizes.dart';
import 'package:mishwar/core/theme/admin_theme.dart';
import 'package:mishwar/core/theme/app_icons.dart';
import 'package:mishwar/core/theme/app_spacing.dart';
import 'package:mishwar/core/theme/app_text_styles.dart';
import 'package:mishwar/core/theme/theme_x.dart';
import 'package:mishwar/features/admin/domain/admin_repository.dart';
import 'package:mishwar/features/admin/presentation/admin_content.dart';
import 'package:mishwar/features/admin/presentation/admin_cubit.dart';
import 'package:mishwar/features/admin/presentation/admin_labels.dart';
import 'package:mishwar/features/admin/presentation/admin_live_map.dart';
import 'package:mishwar/features/admin/presentation/admin_pricing.dart';
import 'package:mishwar/features/admin/presentation/admin_support.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({this.supportTicketId, super.key});
  final String? supportTicketId;
  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _scaffold = GlobalKey<ScaffoldState>();
  AdminEntry? _selected;
  bool _driverDetail = false;
  @override
  Widget build(BuildContext context) => Theme(
    data: AdminTheme.light(),
    child: Builder(
      builder: (context) => LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < AdminSizes.minWidth) {
            return Scaffold(
              body: Center(child: Text(context.l10n.adminLargeScreen)),
            );
          }
          return BlocBuilder<AdminCubit, AdminState>(
            builder: (context, state) => Scaffold(
              key: _scaffold,
              endDrawer: _selected == null
                  ? null
                  : Drawer(
                      width: AdminSizes.panel,
                      child: _detail(context, state, _selected!),
                    ),
              body: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: AdminSizes.sidebar,
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            context.l10n.appName,
                            style: AppTextStyles.largeTitle,
                          ),
                          SizedBox(height: AppSpacing.xxl),
                          for (final section in AdminSection.values)
                            ListTile(
                              selected: state.section == section,
                              title: Text(adminTitle(context, section)),
                              onTap: () => context.go(
                                section == AdminSection.overview
                                    ? '/admin'
                                    : '/admin/${section.name}',
                              ),
                            ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              final cubit = context.read<LocaleCubit>();
                              unawaited(
                                cubit.setLocale(
                                  Localizations.localeOf(
                                            context,
                                          ).languageCode ==
                                          'ar'
                                      ? 'en'
                                      : 'ar',
                                ),
                              );
                            },
                            child: Text(context.l10n.adminLanguage),
                          ),
                          TextButton(
                            onPressed: () =>
                                context.read<AdminLoginCubit>().signOut(),
                            child: Text(context.l10n.adminSignOut),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const VerticalDivider(),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            adminTitle(context, state.section),
                            style: AppTextStyles.title1,
                          ),
                          SizedBox(height: AppSpacing.xl),
                          if (state.failure != null)
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    context.l10n.adminError,
                                    style: TextStyle(
                                      color: context.colors.negative,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      [
                                        AdminSection.drivers,
                                        AdminSection.rides,
                                      ].contains(state.section)
                                      ? context.read<AdminCubit>().reload()
                                      : context.read<AdminCubit>().start(
                                          state.section,
                                        ),
                                  child: Text(context.l10n.adminRetry),
                                ),
                              ],
                            ),
                          if (state.saved) Text(context.l10n.adminSaved),
                          if (state.section == AdminSection.drivers)
                            _driverToolbar(context, state),
                          if (state.section == AdminSection.rides)
                            _ridesToolbar(context, state),
                          if (state.loading) const LinearProgressIndicator(),
                          Expanded(
                            child:
                                [
                                  AdminSection.content,
                                  AdminSection.support,
                                ].contains(state.section)
                                ? _body(context, state)
                                : SingleChildScrollView(
                                    child: _body(context, state),
                                  ),
                          ),
                          if ([
                            AdminSection.drivers,
                            AdminSection.rides,
                          ].contains(state.section))
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: state.page == 0 || state.loading
                                      ? null
                                      : context.read<AdminCubit>().previous,
                                  child: Text(context.l10n.adminPrevious),
                                ),
                                Text(
                                  '${state.page + 1}',
                                  style: AppTextStyles.subhead,
                                ),
                                TextButton(
                                  onPressed:
                                      state.data?.next == null || state.loading
                                      ? null
                                      : context.read<AdminCubit>().next,
                                  child: Text(context.l10n.adminNext),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  );

  Widget _driverToolbar(BuildContext context, AdminState state) => Column(
    children: [
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: SegmentedButton<String>(
          segments: [
            for (final status in [
              'pending',
              'approved',
              'suspended',
              'rejected',
            ])
              ButtonSegment(
                value: status,
                label: Text(adminStatus(context, status)),
              ),
          ],
          selected: {state.status ?? 'pending'},
          onSelectionChanged: state.loading
              ? null
              : (values) =>
                    context.read<AdminCubit>().filter(status: values.single),
        ),
      ),
      SizedBox(height: AppSpacing.md),
      TextField(
        decoration: InputDecoration(labelText: context.l10n.adminSearch),
        onChanged: context.read<AdminCubit>().search,
      ),
      SizedBox(height: AppSpacing.md),
    ],
  );
  Widget _ridesToolbar(BuildContext context, AdminState state) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Wrap(
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        children: [
          for (final status in [
            null,
            ...adminActiveStatuses,
            'completed',
            'cancelled',
            'no_drivers',
          ])
            ChoiceChip(
              label: Text(adminStatus(context, status)),
              selected: state.status == status,
              onSelected: state.loading
                  ? null
                  : (_) => context.read<AdminCubit>().filter(
                      status: status,
                      from: state.from,
                      to: state.to,
                    ),
            ),
        ],
      ),
      Wrap(
        spacing: AppSpacing.md,
        children: [
          for (final days in [1, 7])
            TextButton(
              onPressed: () async {
                final now = DateTime.now();
                final from = DateTime.now().subtract(Duration(days: days - 1));
                await context.read<AdminCubit>().filter(
                  status: state.status,
                  from: DateTime(from.year, from.month, from.day),
                  to: DateTime(now.year, now.month, now.day + 1),
                );
              },
              child: Text(
                days == 1 ? context.l10n.adminToday : context.l10n.adminWeek,
              ),
            ),
          TextButton(
            onPressed: () async {
              final now = DateTime.now();
              final range = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime(now.year, now.month, now.day + 1),
                initialDateRange: DateTimeRange(
                  start: state.from ?? now,
                  end: now,
                ),
              );
              if (range != null && context.mounted) {
                unawaited(
                  context.read<AdminCubit>().filter(
                    status: state.status,
                    from: range.start,
                    to: range.end.add(const Duration(days: 1)),
                  ),
                );
              }
            },
            child: Text(context.l10n.adminCustom),
          ),
          if (state.from != null)
            Text(
              '${adminDate(context, state.from)} ? '
              '${adminDate(context, state.to)}',
            ),
        ],
      ),
    ],
  );
  Widget _body(BuildContext context, AdminState state) {
    if (state.data == null) return const SizedBox.shrink();
    return switch (state.section) {
      AdminSection.overview => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              for (var i = 0; i < state.data!.stats.length; i++)
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      border: Border.all(color: context.colors.divider),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          [
                            context.l10n.adminOnline,
                            context.l10n.adminActive,
                            context.l10n.adminTodayRides,
                            context.l10n.adminPendingApplications,
                          ][i],
                          style: AppTextStyles.subhead,
                        ),
                        Text(
                          '${state.data!.stats[i]}',
                          style: AppTextStyles.largeTitle,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: AppSpacing.xl),
          Text(context.l10n.adminLatest, style: AppTextStyles.title2),
          _rides(context, state.entries),
        ],
      ),
      AdminSection.drivers => _drivers(context, state.entries),
      AdminSection.rides => _rides(context, state.entries),
      AdminSection.content => const AdminContent(),
      AdminSection.support => AdminSupport(ticketId: widget.supportTicketId),
      AdminSection.map => AdminLiveMap(drivers: state.entries),
      AdminSection.pricing =>
        state.data!.pricing == null
            ? Text(context.l10n.adminEmpty)
            : AdminPricing(data: state.data!, busy: state.busy),
    };
  }

  Widget _drivers(BuildContext context, List<AdminEntry> entries) => _table(
    context,
    [
      context.l10n.adminName,
      context.l10n.adminPhone,
      context.l10n.adminVehicle,
      context.l10n.adminPlate,
      context.l10n.adminStatus,
      context.l10n.adminRating,
      context.l10n.adminApplied,
    ],
    entries,
    (e) => [
      Text(e.name),
      _ltr(e.phone),
      Text(e.vehicle),
      _ltr(e.plate),
      _status(context, e.status),
      _ltr('${e.rating}'),
      Text(adminDate(context, e.createdAt)),
    ],
    true,
  );
  Widget _rides(BuildContext context, List<AdminEntry> entries) => _table(
    context,
    [
      context.l10n.adminTime,
      context.l10n.adminRider,
      context.l10n.adminDriver,
      context.l10n.adminRoute,
      context.l10n.adminStatus,
      context.l10n.adminFare,
    ],
    entries,
    (e) => [
      Text(adminDate(context, e.createdAt)),
      Text(e.rider),
      Text(e.driver),
      Text('${e.pickup} → ${e.dropoff}'),
      _status(context, e.status),
      _ltr(adminMoney(context, e.finalFare ?? e.estimated)),
    ],
    false,
  );
  Widget _table(
    BuildContext context,
    List<String> headings,
    List<AdminEntry> entries,
    List<Widget> Function(AdminEntry) cells,
    bool drivers,
  ) {
    if (entries.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Text(context.l10n.adminEmpty),
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        showCheckboxColumn: false,
        dataRowMinHeight: AdminSizes.row,
        dataRowMaxHeight: AdminSizes.row * 2,
        columns: headings.map((s) => DataColumn(label: Text(s))).toList(),
        rows: entries
            .map(
              (e) => DataRow(
                onSelectChanged: (_) {
                  setState(() {
                    _selected = e;
                    _driverDetail = drivers;
                  });
                  unawaited(
                    context.read<AdminCubit>().showLicense(
                      drivers ? e.licensePath : null,
                    ),
                  );
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) _scaffold.currentState?.openEndDrawer();
                  });
                },
                cells: cells(e).map(DataCell.new).toList(),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _ltr(String value) => Align(
    alignment: AlignmentDirectional.centerStart,
    child: Text(value, textDirection: TextDirection.ltr),
  );
  Widget _status(BuildContext context, String value) => Chip(
    label: Text(adminStatus(context, value)),
    backgroundColor: context.colors.surface,
  );
  Widget _detail(
    BuildContext context,
    AdminState state,
    AdminEntry entry,
  ) => SafeArea(
    child: SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: IconButton(
                tooltip: context.l10n.adminClose,
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(AppIcons.close),
              ),
            ),
            Text(
              _driverDetail ? entry.name : context.l10n.adminRides,
              style: AppTextStyles.title1,
            ),
            _status(context, entry.status),
            if (state.failure != null) Text(context.l10n.adminError),
            if (_driverDetail) ...[
              Text(entry.vehicle),
              _ltr(entry.plate),
              _ltr(entry.phone),
              Text(context.l10n.adminLicense, style: AppTextStyles.title2),
              if (state.licenseUrl == '')
                Text(context.l10n.adminLicenseMissing)
              else if (state.licenseUrl != null)
                Image.network(
                  state.licenseUrl!,
                  height: AdminSizes.license,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => Text(context.l10n.adminError),
                )
              else if (entry.licensePath != null && state.failure == null)
                const LinearProgressIndicator(),
              Text('${context.l10n.adminRating}: ${entry.rating}'),
              Text('${context.l10n.adminCompletedTrips}: ${entry.completed}'),
              Text('${context.l10n.adminCancellations}: ${entry.cancelled}'),
              if (entry.reason.isNotEmpty) Text(entry.reason),
              for (final decision in switch (entry.status) {
                'pending' => ['approve', 'reject'],
                'approved' => ['suspend'],
                'suspended' => ['reactivate'],
                'rejected' => ['approve'],
                _ => <String>[],
              })
                OutlinedButton(
                  onPressed: state.busy
                      ? null
                      : () => _review(context, entry, decision),
                  child: Text(_decision(context, decision)),
                ),
            ] else ...[
              Text('${context.l10n.adminRider}: ${entry.rider}'),
              Text('${context.l10n.adminDriver}: ${entry.driver}'),
              Text('${entry.pickup} → ${entry.dropoff}'),
              _ltr(
                '${context.l10n.adminEstimated}: '
                '${adminMoney(context, entry.estimated)}',
              ),
              _ltr(
                '${context.l10n.adminFinal}: '
                '${adminMoney(context, entry.finalFare)}',
              ),
              Text(
                '${context.l10n.adminRiderRating}: '
                '${entry.riderRating ?? context.l10n.adminUnknown}',
              ),
              Text(
                '${context.l10n.adminDriverRating}: '
                '${entry.driverRating ?? context.l10n.adminUnknown}',
              ),
              Text(context.l10n.adminTimeline, style: AppTextStyles.title2),
              for (final event in entry.timeline.entries)
                ListTile(
                  title: Text(adminEvent(context, event.key)),
                  subtitle: Text(adminDate(context, event.value)),
                ),
              if (entry.reason.isNotEmpty) Text(entry.reason),
              if (adminActiveStatuses.contains(entry.status))
                OutlinedButton(
                  onPressed: state.busy
                      ? null
                      : () async {
                          final reason = await _reason(context);
                          if (reason != null && context.mounted) {
                            final ok = await context.read<AdminCubit>().act(
                              'adminCancelRide',
                              {'rideId': entry.id, 'reason': reason},
                            );
                            if (ok && context.mounted) {
                              Navigator.of(context).pop();
                            }
                          }
                        },
                  child: Text(context.l10n.adminCancelRide),
                ),
            ],
          ],
        ),
      ),
    ),
  );
  String _decision(BuildContext context, String decision) => switch (decision) {
    'approve' => context.l10n.adminApprove,
    'reject' => context.l10n.adminReject,
    'suspend' => context.l10n.adminSuspend,
    _ => context.l10n.adminReactivate,
  };
  Future<void> _review(
    BuildContext context,
    AdminEntry entry,
    String decision,
  ) async {
    final reason = ['reject', 'suspend'].contains(decision)
        ? await _reason(context)
        : '';
    if (reason == null || !context.mounted) return;
    final ok = await context.read<AdminCubit>().act('reviewDriver', {
      'uid': entry.id,
      'decision': decision,
      if (reason.isNotEmpty) 'reason': reason,
    });
    if (ok && context.mounted) Navigator.of(context).pop();
  }

  Future<String?> _reason(BuildContext context) async {
    final controller = TextEditingController();
    final form = GlobalKey<FormState>();
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.adminReason),
        content: Form(
          key: form,
          child: TextFormField(
            controller: controller,
            maxLength: 200,
            autofocus: true,
            validator: (value) => value == null || value.trim().isEmpty
                ? context.l10n.adminReason
                : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.adminDismiss),
          ),
          FilledButton(
            onPressed: () {
              if (form.currentState!.validate()) {
                Navigator.pop(context, controller.text.trim());
              }
            },
            child: Text(context.l10n.adminConfirm),
          ),
        ],
      ),
    );
    // Dialog exit animation retains its text field briefly.
    await Future<void>.delayed(kThemeAnimationDuration);
    controller.dispose();
    return reason;
  }
}
