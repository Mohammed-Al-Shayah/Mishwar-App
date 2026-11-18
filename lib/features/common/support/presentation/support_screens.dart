import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/theme/app_colors.dart';
import 'package:mishwar/core/theme/app_icons.dart';
import 'package:mishwar/core/theme/app_radius.dart';
import 'package:mishwar/core/theme/app_sizes.dart';
import 'package:mishwar/core/theme/app_spacing.dart';
import 'package:mishwar/core/theme/app_text_styles.dart';
import 'package:mishwar/core/theme/app_theme.dart';
import 'package:mishwar/core/theme/theme_x.dart';
import 'package:mishwar/core/widgets/mw_list_row.dart';
import 'package:mishwar/core/widgets/mw_primary_button.dart';
import 'package:mishwar/core/widgets/mw_text_field.dart';
import 'package:mishwar/core/widgets/trip_stops.dart';
import 'package:mishwar/features/common/ride/presentation/history_widgets.dart';
import 'package:mishwar/features/common/support/domain/support_ticket.dart';
import 'package:mishwar/features/common/support/presentation/support_cubits.dart';

String supportCategory(BuildContext context, SupportCategory category) =>
    switch (category) {
      SupportCategory.lostItem => context.l10n.supportLostItem,
      SupportCategory.fare => context.l10n.supportFare,
      SupportCategory.safety => context.l10n.supportSafety,
      SupportCategory.other => context.l10n.supportOther,
    };
String supportStatus(BuildContext context, SupportStatus status) =>
    switch (status) {
      SupportStatus.open => context.l10n.supportOpen,
      SupportStatus.inProgress => context.l10n.supportInProgress,
      SupportStatus.closed => context.l10n.supportClosed,
    };
String supportError(BuildContext context, Failure failure) =>
    switch (failure.message) {
      'support-limit' => context.l10n.supportLimit,
      'support-message' => context.l10n.supportMessageInvalid,
      _ => context.l10n.errorGeneric,
    };

class SupportStatusPill extends StatelessWidget {
  const SupportStatusPill({required this.status, super.key});
  final SupportStatus status;
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(
      horizontal: AppSpacing.sm,
      vertical: AppSpacing.xs,
    ),
    decoration: BoxDecoration(
      color: context.colors.fill,
      borderRadius: AppRadius.pillBorder,
    ),
    child: Text(supportStatus(context, status), style: AppTextStyles.subhead),
  );
}

class SupportListScreen extends StatelessWidget {
  const SupportListScreen({required this.uid, this.driver = false, super.key});
  final String uid;
  final bool driver;
  @override
  Widget build(BuildContext context) => Theme(
    data: driver ? AppTheme.dark() : Theme.of(context),
    child: Builder(
      builder: (context) => Scaffold(
        appBar: AppBar(title: Text(context.l10n.supportTitle)),
        body: BlocBuilder<SupportListCubit, SupportListState>(
          builder: (context, state) => Column(
            children: [
              Expanded(
                child: state.loading
                    ? const HistorySkeleton()
                    : ListView(
                        padding: EdgeInsets.all(AppSpacing.md),
                        children: [
                          if (state.failure != null) ...[
                            Text(supportError(context, state.failure!)),
                            TextButton(
                              onPressed: () => context
                                  .read<SupportListCubit>()
                                  .start(uid: uid),
                              child: Text(context.l10n.retryLabel),
                            ),
                          ] else if (state.tickets.isEmpty)
                            Text(
                              context.l10n.supportEmpty,
                              style: AppTextStyles.body,
                            ),
                          for (final ticket in state.tickets)
                            MwListRow(
                              icon: AppIcons.info,
                              title: supportCategory(context, ticket.category),
                              subtitle: historyDate(
                                context,
                                ticket.lastMessageAt,
                              ),
                              trailing: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: AppSpacing.xs,
                                children: [
                                  if (ticket.userUnread)
                                    Semantics(
                                      label: context.l10n.supportUnread,
                                      child: Icon(
                                        AppIcons.info,
                                        size: AppSizes.icon,
                                      ),
                                    ),
                                  SupportStatusPill(status: ticket.status),
                                ],
                              ),
                              onTap: () => context.push(
                                '/${driver ? 'driver' : 'rider'}/support/${ticket.id}',
                              ),
                            ),
                        ],
                      ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: MwPrimaryButton(
                    label: context.l10n.supportNew,
                    onPressed: () => context.push(
                      '/${driver ? 'driver' : 'rider'}/support/new',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class NewSupportScreen extends StatefulWidget {
  const NewSupportScreen({this.driver = false, super.key});
  final bool driver;
  @override
  State<NewSupportScreen> createState() => _NewSupportScreenState();
}

class _NewSupportScreenState extends State<NewSupportScreen> {
  final _message = TextEditingController();
  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Theme(
    data: widget.driver ? AppTheme.dark() : Theme.of(context),
    child: Builder(
      builder: (context) => Scaffold(
        appBar: AppBar(title: Text(context.l10n.supportNew)),
        body: BlocBuilder<NewSupportCubit, NewSupportState>(
          builder: (context, state) {
            final cubit = context.read<NewSupportCubit>();
            return ListView(
              padding: EdgeInsets.all(AppSpacing.md),
              children: [
                if (state.loadingRide) const HistorySkeleton(),
                if (state.ride != null) ...[
                  Text(
                    historyDate(context, state.ride!.createdAt),
                    style: AppTextStyles.footnote,
                  ),
                  TripStops(ride: state.ride!),
                  SizedBox(height: AppSpacing.lg),
                ],
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (final category in SupportCategory.values)
                      ChoiceChip(
                        label: Text(supportCategory(context, category)),
                        selected: state.category == category,
                        onSelected: state.saving
                            ? null
                            : (_) => cubit.select(category),
                      ),
                  ],
                ),
                SizedBox(height: AppSpacing.lg),
                MwTextField(
                  label: context.l10n.supportMessage,
                  controller: _message,
                  minLines: 4,
                  maxLines: 8,
                  maxLength: 1000,
                  keyboardType: TextInputType.multiline,
                  enabled: !state.saving,
                  onChanged: (_) => setState(() {}),
                ),
                if (state.failure != null)
                  Text(
                    supportError(context, state.failure!),
                    style: AppTextStyles.footnote.copyWith(
                      color: context.colors.negative,
                    ),
                  ),
                if (state.failure != null && state.ride == null)
                  TextButton(
                    onPressed: cubit.retryRide,
                    child: Text(context.l10n.retryLabel),
                  ),
                SizedBox(height: AppSpacing.lg),
                MwPrimaryButton(
                  label: context.l10n.supportSend,
                  isLoading: state.saving,
                  onPressed: _message.text.trim().isEmpty || state.loadingRide
                      ? null
                      : () async {
                          final id = await cubit.submit(_message.text);
                          if (context.mounted && id != null) {
                            context.pushReplacement(
                              '/${widget.driver ? 'driver' : 'rider'}/support/$id',
                            );
                          }
                        },
                ),
              ],
            );
          },
        ),
      ),
    ),
  );
}

class SupportThreadScreen extends StatelessWidget {
  const SupportThreadScreen({this.driver = false, super.key});
  final bool driver;
  @override
  Widget build(BuildContext context) => Theme(
    data: driver ? AppTheme.dark() : Theme.of(context),
    child: Builder(
      builder: (context) => Scaffold(
        appBar: AppBar(title: Text(context.l10n.supportTitle)),
        body: const SupportThreadBody(),
      ),
    ),
  );
}

class SupportThreadBody extends StatefulWidget {
  const SupportThreadBody({this.admin = false, super.key});
  final bool admin;
  @override
  State<SupportThreadBody> createState() => _SupportThreadBodyState();
}

class _SupportThreadBodyState extends State<SupportThreadBody> {
  final _text = TextEditingController();
  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<SupportThreadCubit, SupportThreadState>(
    builder: (context, state) {
      final cubit = context.read<SupportThreadCubit>();
      final ticket = state.ticket;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (ticket != null)
            Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    supportCategory(context, ticket.category),
                    style: AppTextStyles.title2,
                  ),
                  SupportStatusPill(status: ticket.status),
                  if (widget.admin)
                    Wrap(
                      spacing: AppSpacing.xs,
                      children: [
                        for (final status in SupportStatus.values)
                          TextButton(
                            onPressed: state.busy || ticket.status == status
                                ? null
                                : () => cubit.setStatus(status),
                            child: Text(supportStatus(context, status)),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          if (state.failure != null)
            Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  Text(
                    supportError(context, state.failure!),
                    style: AppTextStyles.footnote.copyWith(
                      color: context.colors.negative,
                    ),
                  ),
                  TextButton(
                    onPressed: cubit.retry,
                    child: Text(context.l10n.retryLabel),
                  ),
                ],
              ),
            ),
          Expanded(
            child: state.loading
                ? const HistorySkeleton()
                : ListView.builder(
                    reverse: true,
                    padding: EdgeInsets.all(AppSpacing.md),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message =
                          state.messages[state.messages.length - 1 - index];
                      final user = message.from == 'user';
                      return Align(
                        alignment: user
                            ? AlignmentDirectional.centerEnd
                            : AlignmentDirectional.centerStart,
                        child: FractionallySizedBox(
                          widthFactor: AppSizes.supportBubbleFraction,
                          child: Container(
                            margin: EdgeInsets.only(bottom: AppSpacing.sm),
                            padding: EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: user
                                  ? AppColors.black
                                  : context.colors.fill,
                              borderRadius: AppRadius.tileBorder,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message.text,
                                  style: AppTextStyles.body.copyWith(
                                    color: user
                                        ? AppColors.white
                                        : context.colors.textPrimary,
                                  ),
                                ),
                                if (message.createdAt != null)
                                  Text(
                                    historyDate(context, message.createdAt!),
                                    style: AppTextStyles.footnote.copyWith(
                                      color: user
                                          ? AppColors.white
                                          : context.colors.textSecondary,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (ticket != null)
            SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: ticket.status == SupportStatus.closed
                    ? Text(
                        context.l10n.supportClosedNote,
                        style: AppTextStyles.body,
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          MwTextField(
                            label: context.l10n.supportMessage,
                            controller: _text,
                            minLines: 1,
                            maxLines: 4,
                            maxLength: 1000,
                            keyboardType: TextInputType.multiline,
                            enabled: !state.busy,
                            onChanged: (_) => setState(() {}),
                          ),
                          SizedBox(height: AppSpacing.sm),
                          MwPrimaryButton(
                            label: context.l10n.supportSend,
                            isLoading: state.busy,
                            onPressed: _text.text.trim().isEmpty
                                ? null
                                : () async {
                                    if (await cubit.send(_text.text) &&
                                        mounted) {
                                      _text.clear();
                                      setState(() {});
                                    }
                                  },
                          ),
                        ],
                      ),
              ),
            ),
        ],
      );
    },
  );
}
