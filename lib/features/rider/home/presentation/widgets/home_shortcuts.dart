import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/theme/app_icons.dart';
import 'package:mishwar/core/theme/app_sizes.dart';
import 'package:mishwar/core/widgets/mw_list_row.dart';
import 'package:mishwar/features/common/places/domain/entities/place_details.dart';
import 'package:mishwar/features/common/saved_places/domain/saved_place.dart';
import 'package:mishwar/features/common/saved_places/presentation/saved_place_labels.dart';
import 'package:mishwar/features/common/saved_places/presentation/saved_places_cubit.dart';
import 'package:mishwar/features/rider/home/presentation/cubit/recent_places_cubit.dart';

/// Rider home rows 5–6: recent destinations, then home and work shortcuts.
class HomeShortcuts extends StatelessWidget {
  const HomeShortcuts({
    required this.onPlace,
    required this.onAddSaved,
    super.key,
  });

  /// Go straight to choosing a ride for this destination.
  final ValueChanged<PlaceDetails> onPlace;

  /// Open the saved-place editor for an unset home/work shortcut.
  final ValueChanged<SavedPlaceLabel> onAddSaved;

  @override
  Widget build(BuildContext context) {
    final saved = context.watch<SavedPlacesCubit>().state.places;
    final recent = context.watch<RecentPlacesCubit>().state;
    SavedPlace? find(SavedPlaceLabel label) =>
        saved.where((p) => p.label == label).firstOrNull;
    final chevron = Icon(AppIcons.chevron, size: AppSizes.icon);
    Widget savedRow(SavedPlaceLabel label, String addText) {
      final place = find(label);
      return MwListRow(
        key: Key('home_shortcut_${label.name}'),
        icon: savedPlaceIcon(label),
        title: place == null ? addText : savedPlaceLabelText(context, label),
        subtitle: place == null
            ? context.l10n.savedPlaceTapToSet
            : place.address,
        trailing: chevron,
        onTap: () => place == null ? onAddSaved(label) : onPlace(place.details),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final place in recent)
          MwListRow(
            key: Key('home_recent_${place.placeId}'),
            icon: AppIcons.clock,
            title: place.name,
            subtitle: place.address,
            trailing: chevron,
            onTap: () => onPlace(place),
          ),
        savedRow(SavedPlaceLabel.home, context.l10n.savedPlaceAddHome),
        savedRow(SavedPlaceLabel.work, context.l10n.savedPlaceAddWork),
      ],
    );
  }
}
