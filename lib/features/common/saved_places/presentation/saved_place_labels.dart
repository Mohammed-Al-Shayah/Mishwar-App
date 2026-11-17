import 'package:flutter/widgets.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/theme/app_icons.dart';
import 'package:mishwar/features/common/saved_places/domain/saved_place.dart';

IconData savedPlaceIcon(SavedPlaceLabel label) => switch (label) {
  SavedPlaceLabel.home => AppIcons.house,
  SavedPlaceLabel.work => AppIcons.briefcase,
  SavedPlaceLabel.other => AppIcons.mapPin,
};

String savedPlaceLabelText(BuildContext context, SavedPlaceLabel label) =>
    switch (label) {
      SavedPlaceLabel.home => context.l10n.savedPlaceHome,
      SavedPlaceLabel.work => context.l10n.savedPlaceWork,
      SavedPlaceLabel.other => context.l10n.savedPlaceOther,
    };

/// Home/work rows read "البيت" with the address below; other places use their
/// own name.
String savedPlaceTitle(BuildContext context, SavedPlace place) =>
    place.label == SavedPlaceLabel.other
    ? place.name
    : savedPlaceLabelText(context, place.label);
