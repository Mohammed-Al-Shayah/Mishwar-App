import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mishwar/core/l10n/failure_message.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/theme/app_icons.dart';
import 'package:mishwar/core/theme/app_radius.dart';
import 'package:mishwar/core/theme/app_sizes.dart';
import 'package:mishwar/core/theme/app_spacing.dart';
import 'package:mishwar/core/theme/theme_x.dart';
import 'package:mishwar/core/widgets/map/mw_map_fab.dart';
import 'package:mishwar/core/widgets/mw_list_row.dart';
import 'package:mishwar/core/widgets/mw_skeleton.dart';
import 'package:mishwar/core/widgets/mw_text_field.dart';
import 'package:mishwar/features/common/saved_places/presentation/saved_place_labels.dart';
import 'package:mishwar/features/common/saved_places/presentation/saved_places_cubit.dart';
import 'package:mishwar/features/rider/search/presentation/bloc/destination_search_bloc.dart';
import 'package:mishwar/features/rider/search/presentation/bloc/destination_search_event.dart';
import 'package:mishwar/features/rider/search/presentation/bloc/destination_search_state.dart';

class DestinationSearchScreen extends StatefulWidget {
  const DestinationSearchScreen({super.key});
  @override
  State<DestinationSearchScreen> createState() =>
      _DestinationSearchScreenState();
}

class _DestinationSearchScreenState extends State<DestinationSearchScreen> {
  final _controller = TextEditingController();
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _change(String text) {
    setState(() {});
    context.read<DestinationSearchBloc>().add(QueryChanged(text));
  }

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<DestinationSearchBloc, DestinationSearchState>(
        listener: (context, state) {
          if (state is DestinationChosen) context.pop(state.details);
        },
        builder: (context, state) => Scaffold(
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      MwMapFab(
                        icon: AppIcons.back,
                        label: MaterialLocalizations.of(
                          context,
                        ).backButtonTooltip,
                        onPressed: () => context.pop(),
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          context.l10n.planRide,
                          style: context.textStyles.titleMedium,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.md),
                  Container(
                    decoration: BoxDecoration(
                      color: context.colors.fillSubtle,
                      borderRadius: AppRadius.tileBorder,
                    ),
                    padding: EdgeInsets.all(AppSpacing.sm),
                    child: Row(
                      children: [
                        Column(
                          children: [
                            Container(
                              width: AppSizes.timelineMark,
                              height: AppSizes.timelineMark,
                              decoration: BoxDecoration(
                                color: context.colors.textPrimary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Container(
                              width: AppSizes.timelineLine,
                              height: AppSizes.timelineHeight,
                              color: context.colors.textPrimary,
                            ),
                            Container(
                              width: AppSizes.timelineMark,
                              height: AppSizes.timelineMark,
                              color: context.colors.textPrimary,
                            ),
                          ],
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // TODO(T7.3): Allow pickup editing.
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: AppSpacing.sm,
                                ),
                                child: Text(
                                  context.l10n.currentLocation,
                                  style: context.textStyles.bodySmall?.copyWith(
                                    color: context.colors.textSecondary,
                                  ),
                                ),
                              ),
                              MwTextField(
                                label: context.l10n.whereTo,
                                hintText: context.l10n.whereTo,
                                autofocus: true,
                                controller: _controller,
                                textInputAction: TextInputAction.search,
                                onChanged: _change,
                                suffixIcon: _controller.text.isEmpty
                                    ? null
                                    : IconButton(
                                        key: const Key('clear_destination'),
                                        tooltip: context.l10n.clearSearch,
                                        icon: Icon(
                                          AppIcons.close,
                                          size: AppSizes.icon,
                                        ),
                                        onPressed: () {
                                          _controller.clear();
                                          setState(() {});
                                          context
                                              .read<DestinationSearchBloc>()
                                              .add(const Cleared());
                                        },
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),
                  Expanded(
                    child: BlocBuilder<SavedPlacesCubit, SavedPlacesState>(
                      builder: (context, saved) {
                        final query = _controller.text.trim().toLowerCase();
                        final places = saved.places
                            .where(
                              (p) =>
                                  query.isEmpty ||
                                  p.name.toLowerCase().contains(query) ||
                                  p.address.toLowerCase().contains(query),
                            )
                            .toList();
                        return ListView(
                          children: [
                            if (places.isNotEmpty) ...[
                              Text(
                                context.l10n.savedPlaces,
                                style: context.textStyles.titleMedium,
                              ),
                              for (final place in places)
                                MwListRow(
                                  icon: savedPlaceIcon(place.label),
                                  title: savedPlaceTitle(context, place),
                                  subtitle: place.address,
                                  onTap: state is DestinationResolving
                                      ? null
                                      : () => context.pop(place.details),
                                ),
                              SizedBox(height: AppSpacing.md),
                            ],
                            _results(context, state),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _results(BuildContext context, DestinationSearchState state) {
    if (state.suggestions.isNotEmpty) {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: state.suggestions.length,
        itemBuilder: (context, index) {
          final suggestion = state.suggestions[index];
          return MwListRow(
            icon: AppIcons.mapPin,
            title: suggestion.primaryText,
            subtitle: suggestion.secondaryText,
            trailing:
                state is DestinationResolving && state.selected == suggestion
                ? SizedBox.square(
                    dimension: AppSizes.icon,
                    child: CircularProgressIndicator(
                      color: context.colors.textPrimary,
                      strokeWidth: AppSizes.selectedBorder,
                    ),
                  )
                : null,
            onTap: state is DestinationResolving
                ? null
                : () => context.read<DestinationSearchBloc>().add(
                    SuggestionSelected(suggestion),
                  ),
          );
        },
      );
    }
    if (state is DestinationLoading) {
      return Column(
        children: List.generate(
          3,
          (_) => Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Row(
              children: [
                MwSkeleton(
                  width: AppSizes.iconCircle,
                  height: AppSizes.iconCircle,
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MwSkeleton(width: AppSizes.skeletonTitle),
                      SizedBox(height: AppSpacing.xs),
                      MwSkeleton(width: AppSizes.skeletonSubtitle),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            switch (state) {
              DestinationEmpty(:final query) => context.l10n.noPlacesFound(
                query,
              ),
              DestinationFailure(:final failure) => failureMessage(
                context,
                failure,
              ),
              _ => context.l10n.searchPlacesHint,
            },
            style: context.textStyles.bodySmall?.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          if (state is DestinationFailure)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton(
                onPressed: () =>
                    context.read<DestinationSearchBloc>().add(const Retry()),
                child: Text(context.l10n.retryLabel),
              ),
            ),
        ],
      ),
    );
  }
}
