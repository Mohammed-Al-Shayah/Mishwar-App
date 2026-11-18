import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mishwar/core/l10n/failure_message.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/theme/app_icons.dart';
import 'package:mishwar/core/theme/app_spacing.dart';
import 'package:mishwar/core/theme/app_text_styles.dart';
import 'package:mishwar/core/theme/theme_x.dart';
import 'package:mishwar/core/widgets/mw_list_row.dart';
import 'package:mishwar/core/widgets/mw_primary_button.dart';
import 'package:mishwar/core/widgets/mw_skeleton.dart';
import 'package:mishwar/core/widgets/mw_text_field.dart';
import 'package:mishwar/features/common/places/domain/entities/place_details.dart';
import 'package:mishwar/features/common/ride/domain/entities/airport_details.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_draft.dart';
import 'package:mishwar/features/rider/airport/presentation/airport_cubit.dart';
import 'package:mishwar/features/rider/search/presentation/bloc/destination_search_bloc.dart';

class AirportScreen extends StatefulWidget {
  const AirportScreen({super.key});
  @override
  State<AirportScreen> createState() => _AirportScreenState();
}

class _AirportScreenState extends State<AirportScreen> {
  final _flight = TextEditingController();
  AirportDirection _direction = AirportDirection.toAirport;
  RideStop? _point;
  var _invalid = false;
  var _navigating = false;
  @override
  void dispose() {
    _flight.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (_navigating) return;
    final flight = normalizeFlightNumber(_flight.text);
    setState(() => _invalid = _flight.text.trim().isNotEmpty && flight == null);
    if (_invalid) return;
    final cubit = context.read<AirportCubit>();
    final config = cubit.state.config;
    if (config == null) return;
    setState(() => _navigating = true);
    try {
      final toAirport = _direction == AirportDirection.toAirport;
      final location = toAirport ? await cubit.pickup() : _point?.location;
      if (!mounted || location == null) return;
      final name = context.l10n.airportName;
      final current = context.l10n.currentLocation;
      final pickup = toAirport
          ? RideStop(name: current, address: current, location: location)
          : _point!;
      RideStop dropoff;
      if (toAirport) {
        dropoff = RideStop(
          name: name,
          address: name,
          location: config.centroid,
        );
      } else {
        final destination = await context.push<PlaceDetails>(
          '/rider/search',
          extra: DestinationSearchParams(
            position: location,
            pickupName: pickup.name,
            language: Localizations.localeOf(context).languageCode,
          ),
        );
        if (!mounted || destination == null) return;
        dropoff = RideStop(
          name: destination.name,
          address: destination.address,
          location: destination.location,
        );
      }
      if (!mounted) return;
      await context.push<void>(
        '/rider/confirm',
        extra: RideDraft(
          pickup: pickup,
          dropoff: dropoff,
          flightNumber: flight,
        ),
      );
    } finally {
      if (mounted) setState(() => _navigating = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.l10n.serviceAirport)),
    body: BlocBuilder<AirportCubit, AirportState>(
      builder: (context, state) => ListView(
        padding: EdgeInsets.all(AppSpacing.md),
        children: [
          SegmentedButton<AirportDirection>(
            segments: [
              ButtonSegment(
                value: AirportDirection.toAirport,
                label: Text(context.l10n.airportTo),
              ),
              ButtonSegment(
                value: AirportDirection.fromAirport,
                label: Text(context.l10n.airportFrom),
              ),
            ],
            selected: {_direction},
            onSelectionChanged: _navigating
                ? null
                : (values) => setState(() => _direction = values.single),
          ),
          SizedBox(height: AppSpacing.lg),
          if (state.loading && state.config == null)
            const MwSkeleton()
          else if (state.config == null) ...[
            Text(
              state.failure == null
                  ? context.l10n.airportUnavailable
                  : failureMessage(context, state.failure!),
              style: AppTextStyles.body,
            ),
            TextButton(
              onPressed: () => context.read<AirportCubit>().load(),
              child: Text(context.l10n.retryLabel),
            ),
          ] else ...[
            if (_direction == AirportDirection.toAirport)
              MwListRow(
                icon: AppIcons.airplane,
                title: context.l10n.airportName,
                subtitle: context.l10n.currentLocation,
              )
            else ...[
              Text(context.l10n.airportPickup, style: AppTextStyles.title2),
              for (final point in state.config!.pickupPoints)
                MwListRow(
                  icon: AppIcons.mapPin,
                  title: point.name,
                  // The section title already says what these are.
                  subtitle: '',
                  trailing: _point == point
                      ? Icon(AppIcons.check, color: context.colors.textPrimary)
                      : null,
                  onTap: _navigating
                      ? null
                      : () => setState(() => _point = point),
                ),
              if (state.config!.pickupPoints.isEmpty)
                Text(
                  context.l10n.airportUnavailable,
                  style: AppTextStyles.body,
                ),
            ],
            SizedBox(height: AppSpacing.md),
            MwTextField(
              label: context.l10n.airportFlightNumber,
              hintText: context.l10n.airportFlightHint,
              controller: _flight,
              enabled: !_navigating,
              textDirection: TextDirection.ltr,
              onChanged: (_) => setState(
                () => _invalid =
                    _flight.text.trim().isNotEmpty &&
                    normalizeFlightNumber(_flight.text) == null,
              ),
            ),
            if (_invalid)
              Text(
                context.l10n.airportFlightInvalid,
                style: AppTextStyles.footnote.copyWith(
                  color: context.colors.negative,
                ),
              ),
            if (state.failure != null)
              Text(
                failureMessage(context, state.failure!),
                style: AppTextStyles.footnote.copyWith(
                  color: context.colors.negative,
                ),
              ),
            SizedBox(height: AppSpacing.lg),
            MwPrimaryButton(
              label: context.l10n.airportContinue,
              isLoading: _navigating,
              onPressed:
                  _invalid ||
                      (_direction == AirportDirection.fromAirport &&
                          _point == null)
                  ? null
                  : _continue,
            ),
          ],
        ],
      ),
    ),
  );
}
