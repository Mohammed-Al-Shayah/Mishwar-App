import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/theme/admin_sizes.dart';
import 'package:mishwar/core/theme/app_spacing.dart';
import 'package:mishwar/features/admin/presentation/admin_labels.dart';
import 'package:mishwar/features/common/support/domain/support_ticket.dart';
import 'package:mishwar/features/common/support/presentation/support_cubits.dart';
import 'package:mishwar/features/common/support/presentation/support_screens.dart';

class AdminSupport extends StatefulWidget {
  const AdminSupport({this.ticketId, super.key});
  final String? ticketId;
  @override
  State<AdminSupport> createState() => _AdminSupportState();
}

class _AdminSupportState extends State<AdminSupport> {
  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<SupportListCubit, SupportListState>(
    builder: (context, state) => Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: AppSpacing.sm,
                children: [
                  for (final status in [null, ...SupportStatus.values])
                    ChoiceChip(
                      label: Text(
                        status == null
                            ? context.l10n.adminAll
                            : supportStatus(context, status),
                      ),
                      selected: state.filter == status,
                      onSelected: (_) => context.read<SupportListCubit>().start(
                        status: status,
                      ),
                    ),
                ],
              ),
              if (state.loading) const LinearProgressIndicator(),
              if (state.failure != null) ...[
                Text(supportError(context, state.failure!)),
                TextButton(
                  onPressed: () => context.read<SupportListCubit>().start(
                    status: state.filter,
                  ),
                  child: Text(context.l10n.retryLabel),
                ),
              ],
              Expanded(
                child: SingleChildScrollView(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      dataRowMinHeight: AdminSizes.row,
                      dataRowMaxHeight: double.infinity,
                      columns: [
                        for (final title in [
                          context.l10n.supportUser,
                          context.l10n.supportRole,
                          context.l10n.supportCategory,
                          context.l10n.supportRide,
                          context.l10n.supportLastMessage,
                          context.l10n.supportStatus,
                        ])
                          DataColumn(label: Text(title)),
                      ],
                      rows: [
                        for (final ticket in state.tickets)
                          DataRow(
                            selected: widget.ticketId == ticket.id,
                            onSelectChanged: (_) => context.go(
                              '/admin/support?ticket=${Uri.encodeQueryComponent(ticket.id)}',
                            ),
                            cells: [
                              DataCell(Text(ticket.uid)),
                              DataCell(
                                Text(
                                  ticket.role == 'driver'
                                      ? context.l10n.supportDriver
                                      : context.l10n.supportRider,
                                ),
                              ),
                              DataCell(
                                Text(supportCategory(context, ticket.category)),
                              ),
                              DataCell(
                                ticket.rideId == null
                                    ? const Text('—')
                                    : TextButton(
                                        onPressed: () => context.go(
                                          '/admin/rides?rideId=${Uri.encodeQueryComponent(ticket.rideId!)}',
                                        ),
                                        child: Text(ticket.rideId!),
                                      ),
                              ),
                              DataCell(
                                Text(adminDate(context, ticket.lastMessageAt)),
                              ),
                              DataCell(
                                SupportStatusPill(status: ticket.status),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              if (!state.loading &&
                  state.failure == null &&
                  state.tickets.isEmpty)
                Text(context.l10n.supportEmpty),
            ],
          ),
        ),
        if (widget.ticketId != null) ...[
          const VerticalDivider(),
          SizedBox(
            width: AdminSizes.panel,
            child: const SupportThreadBody(admin: true),
          ),
        ],
      ],
    ),
  );
}
