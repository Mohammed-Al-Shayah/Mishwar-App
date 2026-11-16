import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart' show Either;
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/theme/app_spacing.dart';
import 'package:mishwar/core/theme/app_theme.dart';
import 'package:mishwar/core/theme/theme_x.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_entity.dart';
import 'package:mishwar/features/common/ride/domain/usecases/watch_ride.dart';

class DriverRidePlaceholder extends StatefulWidget {
  const DriverRidePlaceholder({
    required this.rideId,
    required this.watchRide,
    super.key,
  });
  final String rideId;
  final WatchRide watchRide;
  @override
  State<DriverRidePlaceholder> createState() => _DriverRidePlaceholderState();
}

class _DriverRidePlaceholderState extends State<DriverRidePlaceholder> {
  late final Stream<Either<Failure, RideEntity>> _ride = widget.watchRide(
    widget.rideId,
  );
  @override
  Widget build(BuildContext context) => Theme(
    data: AppTheme.dark(),
    child: Builder(
      builder: (context) => PopScope(
        canPop: false,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text(context.l10n.driverHeadingToPickup),
          ),
          body: Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: StreamBuilder<Either<Failure, RideEntity>>(
              stream: _ride,
              builder: (context, snapshot) => Text(
                snapshot.data?.getRight().toNullable()?.pickup.name ?? '',
                style: context.textStyles.titleMedium,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
