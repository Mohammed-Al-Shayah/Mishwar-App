import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/theme/admin_sizes.dart';
import 'package:mishwar/core/theme/app_spacing.dart';
import 'package:mishwar/core/theme/app_text_styles.dart';
import 'package:mishwar/core/theme/theme_x.dart';
import 'package:mishwar/core/widgets/market_switcher.dart';
import 'package:mishwar/features/admin/domain/admin_management.dart';
import 'package:mishwar/features/admin/presentation/admin_labels.dart';
import 'package:mishwar/features/admin/presentation/management_cubit.dart';

String settingsLabel(BuildContext c, String key) => switch (key) {
  'rounding' || 'step' => c.l10n.settingsRounding,
  'cancellationFee' => c.l10n.settingsCancellation,
  'waitingFee' => c.l10n.settingsWaiting,
  'scheduling' => c.l10n.settingsScheduling,
  'airport' => c.l10n.settingsAirport,
  'amount' => c.l10n.settingsAmount,
  'afterSeconds' => c.l10n.settingsAfterSeconds,
  'freeMinutes' => c.l10n.settingsFreeMinutes,
  'perMinute' => c.l10n.settingsPerMinute,
  'minLeadMinutes' => c.l10n.settingsMinLeadMinutes,
  'maxDaysAhead' => c.l10n.settingsMaxDaysAhead,
  'dispatchBeforeMinutes' => c.l10n.settingsDispatchBeforeMinutes,
  'economy' => c.l10n.settingsEconomy,
  'comfort' => c.l10n.settingsComfort,
  'van' => c.l10n.settingsVan,
  _ => c.l10n.adminUnknown,
};
Map<String, Object?> managementMap(Object? value) =>
    value is Map ? value.cast<String, Object?>() : {};

class AdminSettings extends StatelessWidget {
  const AdminSettings({super.key});
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<ManagementCubit, ManagementState>(
        builder: (context, state) => ListView(
          children: [
            MarketSwitcher(
              value: state.market,
              enabled: !state.loading && !state.busy,
              onChanged: context.read<ManagementCubit>().selectMarket,
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
            if (state.data != null)
              for (final section in [
                'cancellationFee',
                'waitingFee',
                'rounding',
                'scheduling',
                if (state.market == 'JO') 'airport',
              ])
                SettingsCard(
                  key: ValueKey('${state.market}-$section'),
                  section: section,
                  data: section == 'rounding'
                      ? {
                          'step':
                              managementMap(
                                state.data!.settings['rounding'],
                              )[state.market] ??
                              (state.market == 'PS' ? 0.5 : 0.05),
                        }
                      : managementMap(
                          ['cancellationFee', 'waitingFee'].contains(section)
                              ? managementMap(
                                      state.data!.settings[section],
                                    )[state.market] ??
                                    state.data!.settings[section]
                              : state.data!.settings[section],
                        ),
                  edited: state.data!.edits[section],
                  busy: state.busy,
                ),
          ],
        ),
      );
}

class SettingsCard extends StatefulWidget {
  const SettingsCard({
    required this.section,
    required this.data,
    required this.busy,
    this.edited,
    super.key,
  });
  final String section;
  final Map<String, Object?> data;
  final DateTime? edited;
  final bool busy;
  @override
  State<SettingsCard> createState() => _SettingsCardState();
}

class _SettingsCardState extends State<SettingsCard> {
  final _form = GlobalKey<FormState>();
  Map<String, Object?> get _initialValues => widget.section == 'airport'
      ? managementMap(widget.data['fixedFares'])
      : widget.data;
  late final Map<String, (double, double, bool)> _bounds =
      settingsBounds[widget.section == 'airport'
          ? 'fixedFares'
          : widget.section]!;
  late final Map<String, TextEditingController> _fields = {
    for (final key in _bounds.keys)
      key: TextEditingController(
        text: '${_initialValues[key] ?? _bounds[key]!.$1}',
      ),
  };
  late final List<Map<String, Object>> _points = [
    for (final p in widget.data['pickupPoints'] as List? ?? [])
      Map<String, Object>.from(p as Map),
  ];
  @override
  void dispose() {
    for (final c in _fields.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _point([int? index]) async {
    final point = index == null ? null : _points[index];
    final name = TextEditingController(text: point?['name'] as String?);
    final lat = TextEditingController(text: '${point?['lat'] ?? ''}');
    final lng = TextEditingController(text: '${point?['lng'] ?? ''}');
    final form = GlobalKey<FormState>();
    final result = await showDialog<Map<String, Object>>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(c.l10n.settingsPickupPoints),
        scrollable: true,
        content: SizedBox(
          width: AdminSizes.panel,
          child: Form(
            key: form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: name,
                  maxLength: 60,
                  decoration: InputDecoration(labelText: c.l10n.adminName),
                  validator: (v) =>
                      (v ?? '').trim().isEmpty ? c.l10n.contentInvalid : null,
                ),
                TextFormField(
                  controller: lat,
                  textDirection: TextDirection.ltr,
                  decoration: InputDecoration(
                    labelText: c.l10n.settingsLatitude,
                  ),
                  validator: (v) => validNumber(v ?? '', -90, 90)
                      ? null
                      : c.l10n.contentInvalid,
                ),
                TextFormField(
                  controller: lng,
                  textDirection: TextDirection.ltr,
                  decoration: InputDecoration(
                    labelText: c.l10n.settingsLongitude,
                  ),
                  validator: (v) =>
                      validNumber(v ?? '', -180, 180) &&
                          _inside(
                            double.tryParse(lat.text) ?? double.nan,
                            double.parse(v!),
                          )
                      ? null
                      : c.l10n.contentInvalid,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: Text(c.l10n.contentCancel),
          ),
          TextButton(
            onPressed: () {
              if (form.currentState!.validate()) {
                Navigator.pop(c, <String, Object>{
                  'id':
                      point?['id'] ??
                      'point_${DateTime.now().microsecondsSinceEpoch}',
                  'name': name.text.trim(),
                  'lat': double.parse(lat.text),
                  'lng': double.parse(lng.text),
                });
              }
            },
            child: Text(c.l10n.contentSave),
          ),
        ],
      ),
    );
    if (mounted && result != null) {
      setState(() {
        if (index == null) {
          _points.add(result);
        } else {
          _points[index] = result;
        }
      });
    }
    await Future<void>.delayed(kThemeAnimationDuration);
    name.dispose();
    lat.dispose();
    lng.dispose();
  }

  List<List<List<num>>> get _rings {
    final zone = widget.data['zone'];
    if (zone == null) return [];
    final raw = zone is String ? jsonDecode(zone) as Map : zone as Map;
    return [
      for (final ring in raw['coordinates'] as List)
        [for (final p in ring as List) (p as List).cast<num>()],
    ];
  }

  bool _inside(double lat, double lng) {
    bool contains(List<List<num>> ring) {
      var inside = false;
      for (var i = 0, j = ring.length - 1; i < ring.length; j = i++) {
        final x = ring[i][0];
        final y = ring[i][1];
        final px = ring[j][0];
        final py = ring[j][1];
        if (((lng - x) * (py - y) - (lat - y) * (px - x)).abs() < 1e-12 &&
            lng >= (x < px ? x : px) &&
            lng <= (x > px ? x : px) &&
            lat >= (y < py ? y : py) &&
            lat <= (y > py ? y : py)) {
          return true;
        }
        if ((y > lat) != (py > lat) &&
            lng < (px - x) * (lat - y) / (py - y) + x) {
          inside = !inside;
        }
      }
      return inside;
    }

    return _rings.isNotEmpty &&
        contains(_rings.first) &&
        !_rings.skip(1).any(contains);
  }

  String get _box {
    final points = _rings.expand((r) => r).toList();
    if (points.isEmpty) return '—';
    final xs = points.map((p) => p[0]).toList()..sort();
    final ys = points.map((p) => p[1]).toList()..sort();
    return '${ys.first}, ${xs.first} → ${ys.last}, ${xs.last}';
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: AppSpacing.xl),
    child: Form(
      key: _form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            settingsLabel(context, widget.section),
            style: AppTextStyles.title2,
          ),
          SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              for (final entry in _fields.entries)
                SizedBox(
                  width: AdminSizes.field * 2,
                  child: TextFormField(
                    controller: entry.value,
                    enabled: !widget.busy,
                    textDirection: TextDirection.ltr,
                    decoration: InputDecoration(
                      labelText: settingsLabel(context, entry.key),
                    ),
                    validator: (v) {
                      final b = _bounds[entry.key]!;
                      return validNumber(v ?? '', b.$1, b.$2, integer: b.$3)
                          ? null
                          : context.l10n.settingsRange('${b.$1}', '${b.$2}');
                    },
                  ),
                ),
            ],
          ),
          if (widget.section == 'airport') ...[
            SizedBox(height: AppSpacing.md),
            Text(context.l10n.settingsZone, style: AppTextStyles.footnote),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(_box, textDirection: TextDirection.ltr),
            ),
            for (var i = 0; i < _points.length; i++)
              ListTile(
                title: Text('${_points[i]['name']}'),
                subtitle: Text('${_points[i]['lat']}, ${_points[i]['lng']}'),
                onTap: widget.busy ? null : () => _point(i),
                trailing: TextButton(
                  onPressed: widget.busy
                      ? null
                      : () => setState(() => _points.removeAt(i)),
                  child: Text(context.l10n.contentDelete),
                ),
              ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton(
                onPressed: widget.busy || _points.length >= 10 ? null : _point,
                child: Text(context.l10n.settingsAddPoint),
              ),
            ),
          ],
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: OutlinedButton(
              onPressed: widget.busy
                  ? null
                  : () async {
                      if (!_form.currentState!.validate()) return;
                      final values = <String, Object>{
                        for (final e in _fields.entries)
                          e.key: _bounds[e.key]!.$3
                              ? int.parse(e.value.text)
                              : double.parse(e.value.text),
                      };
                      await context.read<ManagementCubit>().save(
                        'updateAppSettings',
                        {
                          widget.section: widget.section == 'rounding'
                              ? values['step']!
                              : widget.section == 'airport'
                              ? {'fixedFares': values, 'pickupPoints': _points}
                              : values,
                        },
                      );
                    },
              child: Text(context.l10n.contentSave),
            ),
          ),
          Text(
            context.l10n.settingsLastEdit(adminDate(context, widget.edited)),
            style: AppTextStyles.footnote,
          ),
          const Divider(),
        ],
      ),
    ),
  );
}
