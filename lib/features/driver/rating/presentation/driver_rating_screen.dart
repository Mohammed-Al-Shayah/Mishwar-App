import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart' show Either;
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/core/l10n/failure_message.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/theme/app_spacing.dart';
import 'package:mishwar/core/theme/app_theme.dart';
import 'package:mishwar/features/common/rating/presentation/rating_exit.dart';
import 'package:mishwar/features/common/rating/presentation/rating_form.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_entity.dart';
import 'package:mishwar/features/common/ride/domain/usecases/watch_ride.dart';

class DriverRatingScreen extends StatefulWidget {
  const DriverRatingScreen({
    required this.rideId,
    required this.watchRide,
    super.key,
  });
  final String rideId;
  final WatchRide watchRide;
  @override
  State<DriverRatingScreen> createState() => _DriverRatingScreenState();
}

class _DriverRatingScreenState extends State<DriverRatingScreen> {
  late Stream<Either<Failure, RideEntity>> _ride;
  @override
  void initState() {
    super.initState();
    _ride = widget.watchRide(widget.rideId);
  }

  @override
  Widget build(BuildContext context) => Theme(
    data: AppTheme.dark(),
    child: Scaffold(
      body: SafeArea(
        child: RatingExit(
          child: StreamBuilder<Either<Failure, RideEntity>>(
            stream: _ride,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              return snapshot.data!.fold(
                (failure) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(failureMessage(context, failure)),
                      TextButton(
                        onPressed: () => setState(() {
                          _ride = widget.watchRide(widget.rideId);
                        }),
                        child: Text(context.l10n.confirmRetry),
                      ),
                    ],
                  ),
                ),
                (ride) => SingleChildScrollView(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: RatingForm(
                    name: ride.riderInfo?.name ?? '',
                    onDone: () => RatingExit.finish(context),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    ),
  );
}
