import 'dart:async';

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
import 'package:mishwar/core/widgets/mw_list_row.dart';
import 'package:mishwar/core/widgets/mw_primary_button.dart';
import 'package:mishwar/core/widgets/mw_text_field.dart';
import 'package:mishwar/features/common/places/domain/entities/place_details.dart';
import 'package:mishwar/features/common/saved_places/domain/saved_place.dart';
import 'package:mishwar/features/common/saved_places/presentation/saved_place_labels.dart';
import 'package:mishwar/features/common/saved_places/presentation/saved_places_cubit.dart';
import 'package:mishwar/features/rider/search/presentation/bloc/destination_search_bloc.dart';

Future<T?> _sheet<T>(
  BuildContext context,
  String title,
  Widget child,
) => showModalBottomSheet<T>(
  context: context,
  isScrollControlled: true,
  backgroundColor: context.colors.sheet,
  shape: RoundedRectangleBorder(borderRadius: AppRadius.sheetBorder),
  builder: (context) => SafeArea(
    child: SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.md + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // The theme draws the drag handle (bottomSheetTheme.showDragHandle).
          Text(
            title,
            textAlign: TextAlign.center,
            style: context.textStyles.titleMedium,
          ),
          const Divider(),
          child,
        ],
      ),
    ),
  ),
);

class SavedPlacesScreen extends StatefulWidget {
  const SavedPlacesScreen({this.openEditorFor, super.key});
  final SavedPlaceLabel? openEditorFor;
  @override
  State<SavedPlacesScreen> createState() => _SavedPlacesScreenState();
}

class _SavedPlacesScreenState extends State<SavedPlacesScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.openEditorFor != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) unawaited(_edit(label: widget.openEditorFor!));
      });
    }
  }

  Future<void> _edit({
    SavedPlace? place,
    SavedPlaceLabel label = SavedPlaceLabel.other,
  }) => _sheet<void>(
    context,
    place == null ? context.l10n.savedPlaceAdd : context.l10n.savedPlaceEdit,
    BlocProvider.value(
      value: context.read<SavedPlacesCubit>(),
      child: _Editor(place: place, label: label),
    ),
  );

  Future<void> _more(SavedPlace place) async {
    final action = await _sheet<bool>(
      context,
      savedPlaceTitle(context, place),
      Builder(
        builder: (context) => Column(
          children: [
            ListTile(
              title: Text(context.l10n.savedPlaceEdit),
              onTap: () => Navigator.pop(context, false),
            ),
            ListTile(
              title: Text(
                context.l10n.savedPlaceDelete,
                style: TextStyle(color: context.colors.negative),
              ),
              onTap: () => Navigator.pop(context, true),
            ),
          ],
        ),
      ),
    );
    if (!mounted || action == null) return;
    if (!action) {
      await _edit(place: place, label: place.label);
      return;
    }
    final confirmed = await _sheet<bool>(
      context,
      context.l10n.savedPlaceDelete,
      Builder(
        builder: (context) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.l10n.savedPlaceDeleteConfirm(
                savedPlaceTitle(context, place),
              ),
            ),
            SizedBox(height: AppSpacing.md),
            MwPrimaryButton(
              label: context.l10n.accountConfirm,
              onPressed: () => Navigator.pop(context, true),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(context.l10n.accountCancel),
            ),
          ],
        ),
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<SavedPlacesCubit>().delete(place.id);
    }
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<SavedPlacesCubit, SavedPlacesState>(
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: Text(context.l10n.savedPlaces)),
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (state.loading) const LinearProgressIndicator(),
                  if (state.failure != null)
                    Text(
                      failureMessage(context, state.failure!),
                      style: context.textStyles.bodySmall?.copyWith(
                        color: context.colors.negative,
                      ),
                    ),
                  Expanded(
                    child: ListView(
                      children: [
                        if (!state.loading && state.places.isEmpty) ...[
                          Text(
                            context.l10n.savedPlacesEmpty,
                            style: context.textStyles.titleMedium,
                          ),
                          SizedBox(height: AppSpacing.xs),
                          Text(
                            context.l10n.savedPlacesEmptyHint,
                            style: context.textStyles.bodySmall,
                          ),
                        ],
                        for (final place in state.places)
                          MwListRow(
                            icon: savedPlaceIcon(place.label),
                            title: savedPlaceTitle(context, place),
                            subtitle: place.address,
                            trailing: IconButton(
                              tooltip: MaterialLocalizations.of(
                                context,
                              ).moreButtonTooltip,
                              icon: Icon(AppIcons.more, size: AppSizes.icon),
                              onPressed: state.saving
                                  ? null
                                  : () => _more(place),
                            ),
                          ),
                      ],
                    ),
                  ),
                  MwPrimaryButton(
                    label: context.l10n.savedPlaceAdd,
                    onPressed: state.loading || state.saving ? null : _edit,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

class _Editor extends StatefulWidget {
  const _Editor({required this.label, this.place});
  final SavedPlaceLabel label;
  final SavedPlace? place;
  @override
  State<_Editor> createState() => _EditorState();
}

class _EditorState extends State<_Editor> {
  late SavedPlaceLabel _label = widget.label;
  late PlaceDetails? _details = widget.place?.details;
  late final _name = TextEditingController(text: widget.place?.name);
  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    final details = await context.push<PlaceDetails>(
      '/rider/search',
      extra: DestinationSearchParams(
        position: _details?.location,
        language: Localizations.localeOf(context).languageCode,
      ),
    );
    if (!mounted || details == null) return;
    setState(() {
      if (_name.text.trim().isEmpty || _name.text == _details?.name) {
        _name.text = details.name;
      }
      _details = details;
    });
  }

  Future<void> _save() async {
    final details = _details;
    if (details == null) return;
    final saved = await context.read<SavedPlacesCubit>().save(
      SavedPlace(
        id:
            widget.place?.id ??
            (_label == SavedPlaceLabel.other ? '' : _label.name),
        label: _label,
        name: _label == SavedPlaceLabel.other
            ? _name.text.trim()
            : details.name,
        address: details.address,
        location: details.location,
      ),
    );
    if (mounted && saved) Navigator.pop(context);
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<SavedPlacesCubit, SavedPlacesState>(
    builder: (context, state) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.savedPlaceType,
          style: context.textStyles.titleMedium,
        ),
        RadioGroup<SavedPlaceLabel>(
          groupValue: _label,
          onChanged: (value) {
            if (value != null) setState(() => _label = value);
          },
          child: Column(
            children: [
              for (final label in SavedPlaceLabel.values)
                RadioListTile<SavedPlaceLabel>(
                  value: label,
                  title: Text(savedPlaceLabelText(context, label)),
                  enabled:
                      !state.loading &&
                      !state.saving &&
                      (widget.place == null || label == widget.place!.label) &&
                      (label == SavedPlaceLabel.other ||
                          !state.places.any(
                            (p) => p.label == label && p.id != widget.place?.id,
                          )),
                ),
            ],
          ),
        ),
        if (_label == SavedPlaceLabel.other)
          MwTextField(
            label: context.l10n.savedPlaceName,
            controller: _name,
            enabled: !state.saving,
            onChanged: (_) => setState(() {}),
          ),
        MwListRow(
          icon: AppIcons.mapPin,
          title: _details?.name ?? context.l10n.savedPlaceChooseLocation,
          subtitle: _details?.address ?? '',
          onTap: state.saving ? null : _pick,
        ),
        if (state.failure != null)
          Text(
            failureMessage(context, state.failure!),
            style: context.textStyles.bodySmall?.copyWith(
              color: context.colors.negative,
            ),
          ),
        SizedBox(height: AppSpacing.md),
        MwPrimaryButton(
          label: context.l10n.accountSave,
          isLoading: state.saving,
          onPressed: state.loading || _details == null ? null : _save,
        ),
      ],
    ),
  );
}
