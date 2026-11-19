import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/theme/admin_sizes.dart';
import 'package:mishwar/core/theme/admin_theme.dart';
import 'package:mishwar/core/theme/app_spacing.dart';
import 'package:mishwar/core/theme/app_text_styles.dart';
import 'package:mishwar/core/theme/theme_x.dart';
import 'package:mishwar/core/widgets/market_switcher.dart';
import 'package:mishwar/features/admin/domain/admin_management.dart';
import 'package:mishwar/features/admin/presentation/admin_labels.dart';
import 'package:mishwar/features/admin/presentation/management_cubit.dart';

class AdminPromos extends StatelessWidget {
  const AdminPromos({super.key});
  String _typeLabel(BuildContext c, Map<String, Object?> p) =>
      p['type'] == 'percent' ? c.l10n.promoPercent : c.l10n.promoFixed;
  Future<void> _edit(BuildContext context, [Map<String, Object?>? promo]) =>
      showGeneralDialog<void>(
        context: context,
        barrierDismissible: true,
        barrierLabel: context.l10n.adminClose,
        pageBuilder: (_, _, _) => Theme(
          data: AdminTheme.light(),
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Material(
              child: SizedBox(
                width: AdminSizes.panel,
                child: BlocProvider.value(
                  value: context.read<ManagementCubit>(),
                  child: PromoEditor(promo: promo),
                ),
              ),
            ),
          ),
        ),
      );
  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<ManagementCubit, ManagementState>(
    builder: (context, state) => ListView(
      children: [
        MarketSwitcher(
          value: state.market,
          enabled: !state.busy && !state.loading,
          onChanged: context.read<ManagementCubit>().selectMarket,
        ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton(
            onPressed: state.busy ? null : () => _edit(context),
            child: Text(context.l10n.promoCreateAdmin),
          ),
        ),
        if (state.loading) const LinearProgressIndicator(),
        if (state.failure != null)
          Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.adminError,
                  style: TextStyle(color: context.colors.negative),
                ),
              ),
              TextButton(
                onPressed: context.read<ManagementCubit>().load,
                child: Text(context.l10n.adminRetry),
              ),
            ],
          ),
        if (state.data?.promos.isEmpty ?? false) Text(context.l10n.adminEmpty),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            dataRowMinHeight: AdminSizes.row,
            dataRowMaxHeight: AdminSizes.row * 2,
            showCheckboxColumn: false,
            columns: [
              for (final label in [
                context.l10n.promoCodeLabel,
                context.l10n.promoType,
                context.l10n.promoUsed,
                context.l10n.promoValidity,
                context.l10n.contentActive,
              ])
                DataColumn(label: Text(label)),
            ],
            rows: [
              for (final p
                  in (state.data?.promos ?? <Map<String, Object?>>[]).where(
                    (p) => (p['market'] ?? 'JO') == state.market,
                  ))
                DataRow(
                  onSelectChanged: state.busy ? null : (_) => _edit(context, p),
                  cells: [
                    DataCell(
                      Text('${p['code']}', textDirection: TextDirection.ltr),
                    ),
                    DataCell(
                      Text(
                        '${_typeLabel(context, p)}: ${p['value']}',
                      ),
                    ),
                    DataCell(
                      Text(
                        '${p['usedCount']} / ${p['usageLimit'] ?? '∞'}',
                        textDirection: TextDirection.ltr,
                      ),
                    ),
                    DataCell(
                      Text(
                        '${adminDate(context, p['validFrom'] as DateTime?)} → '
                        '${adminDate(context, p['validUntil'] as DateTime?)}',
                      ),
                    ),
                    DataCell(
                      Switch(
                        value: p['active'] as bool? ?? false,
                        onChanged: state.busy
                            ? null
                            : (active) => context.read<ManagementCubit>().save(
                                'setPromoActive',
                                {'code': p['code']!, 'active': active},
                              ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    ),
  );
}

class PromoEditor extends StatefulWidget {
  const PromoEditor({this.promo, super.key});
  final Map<String, Object?>? promo;
  @override
  State<PromoEditor> createState() => _PromoEditorState();
}

class _PromoEditorState extends State<PromoEditor> {
  final _form = GlobalKey<FormState>();
  Object _defaultValue(String key) =>
      key == 'value' || key == 'perUserLimit' ? 1 : '';
  late final Map<String, TextEditingController> _fields = {
    for (final key in [
      'code',
      'value',
      'maxDiscount',
      'minFare',
      'usageLimit',
      'perUserLimit',
    ])
      key: TextEditingController(
        text: '${widget.promo?[key] ?? _defaultValue(key)}',
      ),
  };
  late String _type = widget.promo?['type'] as String? ?? 'fixed';
  late bool _first = widget.promo?['firstRideOnly'] as bool? ?? false;
  late bool _active = widget.promo?['active'] as bool? ?? true;
  late DateTime _from =
      widget.promo?['validFrom'] as DateTime? ?? DateTime.now();
  late DateTime _until =
      widget.promo?['validUntil'] as DateTime? ??
      DateTime.now().add(const Duration(days: 30));
  @override
  void dispose() {
    for (final c in _fields.values) {
      c.dispose();
    }
    super.dispose();
  }

  String _label(BuildContext c, String k) => switch (k) {
    'code' => c.l10n.promoCodeLabel,
    'value' => c.l10n.promoValue,
    'maxDiscount' => c.l10n.promoMaxDiscount,
    'minFare' => c.l10n.promoMinimumFareLabel,
    'usageLimit' => c.l10n.promoUsageLimit,
    _ => c.l10n.promoPerUserLimit,
  };
  Future<void> _date({required bool start}) async {
    final initial = start ? _from : _until;
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1),
      lastDate: DateTime(9999, 12, 31),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time != null && mounted) {
      setState(() {
        final d = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
        if (start) {
          _from = d;
        } else {
          _until = d;
        }
      });
    }
  }

  String? _validate(String key, String text) {
    final v = text.trim();
    if (key == 'code') {
      return RegExp(r'^[A-Z0-9]{3,20}$').hasMatch(v)
          ? null
          : context.l10n.contentInvalid;
    }
    if (v.isEmpty && ['maxDiscount', 'minFare', 'usageLimit'].contains(key)) {
      return null;
    }
    final min = key == 'value'
        ? 0.001
        : (key == 'perUserLimit' || key == 'usageLimit' ? 1.0 : 0.0);
    final integer = key == 'perUserLimit' || key == 'usageLimit';
    if (!validNumber(
      v,
      min,
      integer ? 9007199254740991 : 100,
      integer: integer,
    )) {
      return context.l10n.contentInvalid;
    }
    if (key == 'usageLimit' &&
        double.parse(v) < (widget.promo?['usedCount'] as num? ?? 0)) {
      return context.l10n.contentInvalid;
    }
    return null;
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<ManagementCubit, ManagementState>(
    builder: (context, state) => SafeArea(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Form(
          key: _form,
          child: ListView(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      context.l10n.adminPromos,
                      style: AppTextStyles.title1,
                    ),
                  ),
                  TextButton(
                    onPressed: state.busy ? null : () => Navigator.pop(context),
                    child: Text(context.l10n.adminClose),
                  ),
                ],
              ),
              if (state.failure != null)
                Text(
                  context.l10n.adminError,
                  style: TextStyle(color: context.colors.negative),
                ),
              for (final e in _fields.entries)
                Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.md),
                  child: TextFormField(
                    controller: e.value,
                    enabled:
                        !state.busy &&
                        (e.key != 'code' || widget.promo == null),
                    textDirection: TextDirection.ltr,
                    decoration: InputDecoration(
                      labelText: _label(context, e.key),
                    ),
                    validator: (v) => _validate(e.key, v ?? ''),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              DropdownButtonFormField<String>(
                initialValue: _type,
                decoration: InputDecoration(labelText: context.l10n.promoType),
                items: [
                  DropdownMenuItem(
                    value: 'fixed',
                    child: Text(context.l10n.promoFixed),
                  ),
                  DropdownMenuItem(
                    value: 'percent',
                    child: Text(context.l10n.promoPercent),
                  ),
                ],
                onChanged:
                    state.busy || (widget.promo?['usedCount'] as num? ?? 0) > 0
                    ? null
                    : (v) => setState(() => _type = v!),
              ),
              SwitchListTile(
                title: Text(context.l10n.promoFirstRide),
                value: _first,
                onChanged: state.busy
                    ? null
                    : (v) => setState(() => _first = v),
              ),
              SwitchListTile(
                title: Text(context.l10n.contentActive),
                value: _active,
                onChanged: state.busy
                    ? null
                    : (v) => setState(() => _active = v),
              ),
              ListTile(
                title: Text(context.l10n.promoValidFrom),
                subtitle: Text(adminDate(context, _from)),
                onTap: state.busy ? null : () => _date(start: true),
              ),
              ListTile(
                title: Text(context.l10n.contentValidUntil),
                subtitle: Text(adminDate(context, _until)),
                onTap: state.busy ? null : () => _date(start: false),
              ),
              FormField<bool>(
                validator: (_) =>
                    _until.isAfter(_from) ? null : context.l10n.contentInvalid,
                builder: (field) => field.hasError
                    ? Text(
                        field.errorText!,
                        style: TextStyle(color: context.colors.negative),
                      )
                    : const SizedBox.shrink(),
              ),
              SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: state.busy
                    ? null
                    : () async {
                        if (!_form.currentState!.validate()) return;
                        final ok = await context.read<ManagementCubit>().save(
                          'upsertPromo',
                          {
                            'code': _fields['code']!.text.trim(),
                            'type': _type,
                            'value': double.parse(_fields['value']!.text),
                            for (final k in [
                              'maxDiscount',
                              'minFare',
                              'usageLimit',
                              'perUserLimit',
                            ])
                              if (_fields[k]!.text.trim().isNotEmpty)
                                k: k.endsWith('Limit')
                                    ? int.parse(_fields[k]!.text)
                                    : double.parse(_fields[k]!.text),
                            'firstRideOnly': _first,
                            'active': _active,
                            'validFrom': _from.toUtc().toIso8601String(),
                            'validUntil': _until.toUtc().toIso8601String(),
                          },
                        );
                        if (ok && context.mounted) Navigator.pop(context);
                      },
                child: state.busy
                    ? const CircularProgressIndicator()
                    : Text(context.l10n.contentSave),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
