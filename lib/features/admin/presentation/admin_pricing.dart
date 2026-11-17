import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/theme/admin_sizes.dart';
import 'package:mishwar/core/theme/app_spacing.dart';
import 'package:mishwar/core/widgets/mw_primary_button.dart';
import 'package:mishwar/features/admin/domain/admin_repository.dart';
import 'package:mishwar/features/admin/presentation/admin_cubit.dart';
import 'package:mishwar/features/admin/presentation/admin_labels.dart';
import 'package:mishwar/features/common/pricing/domain/entities/vehicle_rates.dart';
import 'package:mishwar/features/common/user/domain/entities/vehicle_entity.dart';

class AdminPricing extends StatefulWidget {
  const AdminPricing({required this.data, required this.busy, super.key});
  final AdminData data;
  final bool busy;
  @override
  State<AdminPricing> createState() => _AdminPricingState();
}

class _AdminPricingState extends State<AdminPricing> {
  final _form = GlobalKey<FormState>();
  late final Map<VehicleType, List<TextEditingController>> _controllers = {
    for (final type in VehicleType.values)
      type:
          [
                widget.data.pricing![type].base,
                widget.data.pricing![type].perKm,
                widget.data.pricing![type].perMin,
                widget.data.pricing![type].minimum,
              ]
              .map(
                (v) =>
                    TextEditingController(text: (v / 1000).toStringAsFixed(3)),
              )
              .toList(),
  };
  @override
  void dispose() {
    for (final list in _controllers.values) {
      for (final c in list) {
        c.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final labels = [
      context.l10n.adminEconomy,
      context.l10n.adminComfort,
      context.l10n.adminVan,
    ];
    final fields = [
      context.l10n.adminBase,
      context.l10n.adminPerKm,
      context.l10n.adminPerMin,
      context.l10n.adminMinimum,
    ];
    return Form(
      key: _form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              dataRowMinHeight: AdminSizes.row,
              dataRowMaxHeight: AdminSizes.row * 2,
              columns: [
                DataColumn(label: Text(context.l10n.adminVehicle)),
                ...fields.map((s) => DataColumn(label: Text(s))),
                DataColumn(label: Text(context.l10n.adminPreview)),
              ],
              rows: [
                for (final type in VehicleType.values)
                  DataRow(
                    cells: [
                      DataCell(Text(labels[type.index])),
                      for (var i = 0; i < fields.length; i++)
                        DataCell(
                          SizedBox(
                            width: AdminSizes.field,
                            child: TextFormField(
                              key: ValueKey('${type.name}-$i'),
                              controller: _controllers[type]![i],
                              enabled: !widget.busy,
                              textDirection: TextDirection.ltr,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: InputDecoration(labelText: fields[i]),
                              onChanged: (_) => setState(() {}),
                              validator: (value) =>
                                  AdminCubit.parseRate(value ?? '') == null
                                  ? context.l10n.adminRateInvalid
                                  : null,
                            ),
                          ),
                        ),
                      DataCell(
                        Text(
                          _preview(context, type),
                          textDirection: TextDirection.ltr,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.xl),
          Text(context.l10n.adminRateInvalid),
          SizedBox(height: AppSpacing.md),
          Text(
            '${context.l10n.adminUpdatedBy}: '
            '${widget.data.updatedBy ?? context.l10n.adminUnknown}',
          ),
          Text(
            '${context.l10n.adminUpdatedAt}: '
            '${adminDate(context, widget.data.updatedAt)}',
          ),
          SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: AdminSizes.login,
            child: MwPrimaryButton(
              label: context.l10n.adminSave,
              isLoading: widget.busy,
              onPressed: () {
                if (!_form.currentState!.validate()) return;
                const names = ['base', 'perKm', 'perMin', 'minimum'];
                unawaited(
                  context.read<AdminCubit>().act('updatePricing', {
                    for (final type in VehicleType.values)
                      type.name: {
                        for (var i = 0; i < names.length; i++)
                          names[i]:
                              AdminCubit.parseRate(
                                _controllers[type]![i].text,
                              )! /
                              1000,
                      },
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _preview(BuildContext context, VehicleType type) {
    final values = _controllers[type]!
        .map((c) => AdminCubit.parseRate(c.text))
        .toList();
    if (values.contains(null)) return context.l10n.adminUnknown;
    final money = context.read<AdminCubit>().preview(
      VehicleRates(
        base: values[0]!,
        perKm: values[1]!,
        perMin: values[2]!,
        minimum: values[3]!,
      ),
    );
    return adminMoney(context, money.amount);
  }
}
