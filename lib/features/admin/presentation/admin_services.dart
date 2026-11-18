import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/theme/app_icons.dart';
import 'package:mishwar/core/theme/app_spacing.dart';
import 'package:mishwar/core/theme/app_text_styles.dart';
import 'package:mishwar/features/admin/presentation/admin_content_cubit.dart';
import 'package:mishwar/features/common/app_config/domain/app_service.dart';

class AdminServices extends StatelessWidget {
  const AdminServices({required this.state, super.key});
  final AdminContentState state;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(context.l10n.contentServices, style: AppTextStyles.title2),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: [
            DataColumn(label: Text(context.l10n.contentServices)),
            DataColumn(label: Text(context.l10n.contentEnabled)),
            DataColumn(label: Text(context.l10n.contentOrder)),
          ],
          rows: [
            for (var i = 0; i < state.services.length; i++)
              DataRow(
                cells: [
                  DataCell(
                    Text(switch (state.services[i].id) {
                      ServiceId.ride => context.l10n.serviceRide,
                      ServiceId.schedule => context.l10n.serviceSchedule,
                      ServiceId.parcel => context.l10n.serviceParcel,
                      ServiceId.airport => context.l10n.serviceAirport,
                    }),
                  ),
                  DataCell(
                    Switch(
                      value: state.services[i].enabled,
                      onChanged: state.busy
                          ? null
                          : (v) => context.read<AdminContentCubit>().toggle(
                              state.services[i].id,
                              enabled: v,
                            ),
                    ),
                  ),
                  DataCell(
                    Row(
                      children: [
                        Text(state.services[i].order.toString()),
                        IconButton(
                          tooltip: context.l10n.contentMoveUp,
                          onPressed: state.busy || i == 0
                              ? null
                              : () => context.read<AdminContentCubit>().move(
                                  state.services[i].id,
                                  -1,
                                ),
                          icon: const RotatedBox(
                            quarterTurns: 2,
                            child: Icon(AppIcons.caretDown),
                          ),
                        ),
                        IconButton(
                          tooltip: context.l10n.contentMoveDown,
                          onPressed:
                              state.busy || i == state.services.length - 1
                              ? null
                              : () => context.read<AdminContentCubit>().move(
                                  state.services[i].id,
                                  1,
                                ),
                          icon: const Icon(AppIcons.caretDown),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
      SizedBox(height: AppSpacing.md),
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: FilledButton(
          onPressed: state.busy || !state.dirty
              ? null
              : () => context.read<AdminContentCubit>().saveServices(),
          child: Text(context.l10n.contentSave),
        ),
      ),
      SizedBox(height: AppSpacing.xl),
    ],
  );
}
