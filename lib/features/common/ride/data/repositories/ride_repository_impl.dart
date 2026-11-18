import 'package:cloud_functions/cloud_functions.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/places/data/callable_failure.dart';
import 'package:mishwar/features/common/rating/domain/rating_tag.dart';
import 'package:mishwar/features/common/ride/data/datasources/ride_remote_data_source.dart';
import 'package:mishwar/features/common/ride/data/models/ride_model.dart';
import 'package:mishwar/features/common/ride/domain/entities/cancel_ride_result.dart';
import 'package:mishwar/features/common/ride/domain/entities/driver_live_location.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_draft.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_entity.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_history.dart';
import 'package:mishwar/features/common/ride/domain/repositories/ride_repository.dart';
import 'package:mishwar/features/common/user/domain/entities/vehicle_entity.dart';

@LazySingleton(as: RideRepository)
class RideRepositoryImpl implements RideRepository {
  const RideRepositoryImpl(this._source);
  final RideRemoteDataSource _source;
  @override
  Stream<Either<Failure, List<RideEntity>>> watchScheduledRides(String uid) =>
      _stream(
        () => _source
            .scheduled(uid)
            .map((models) => models.map((model) => model.toEntity()).toList()),
      );
  @override
  Future<Either<Failure, String>> scheduleRide(
    RideDraft draft,
    VehicleType vehicleType,
  ) async {
    Map<String, dynamic> place(RideStop p) => {
      'lat': p.location.lat,
      'lng': p.location.lng,
      'name': p.name,
      'address': p.address,
    };
    try {
      return Right(
        await _source.schedule({
          'pickup': place(draft.pickup),
          'dropoff': place(draft.dropoff),
          'vehicleType': vehicleType.name,
          'paymentMethod': 'cash',
          if (draft.promoCode != null) 'promoCode': draft.promoCode,
          'scheduledFor': draft.scheduledFor?.toUtc().toIso8601String(),
        }),
      );
    } on Object catch (error) {
      if (error is FirebaseFunctionsException &&
          error.code == 'failed-precondition' &&
          error.details is Map &&
          (error.details as Map)['reason'] == 'too-many-scheduled') {
        return const Left(
          SchedulingFailure(SchedulingFailureReason.tooManyScheduled),
        );
      }
      return Left(callableFailure(error));
    }
  }

  @override
  Future<Either<Failure, RideHistoryPage>> history({
    required RideParty party,
    required String uid,
    HistoryCursor? after,
    int limit = 20,
  }) async {
    try {
      return Right(
        await _source.history(
          party: party,
          uid: uid,
          after: after,
          limit: limit,
        ),
      );
    } on Object catch (error) {
      return Left(callableFailure(error));
    }
  }

  @override
  Future<Either<Failure, String>> requestRide(
    RideDraft draft,
    VehicleType vehicleType,
  ) async {
    Map<String, dynamic> place(RideStop p) => {
      'lat': p.location.lat,
      'lng': p.location.lng,
      'name': p.name,
      'address': p.address,
    };
    try {
      return Right(
        await _source.request({
          'pickup': place(draft.pickup),
          'dropoff': place(draft.dropoff),
          'vehicleType': vehicleType.name,
          'paymentMethod': 'cash',
          if (draft.promoCode != null) 'promoCode': draft.promoCode,
        }),
      );
    } on FirebaseFunctionsException catch (error) {
      final details = error.details;
      if (error.code == 'failed-precondition' &&
          details is Map &&
          details['activeRideId'] is String) {
        return Left(ActiveRideFailure(details['activeRideId'] as String));
      }
      return Left(callableFailure(error));
    } on Object catch (error) {
      return Left(callableFailure(error));
    }
  }

  @override
  Future<Either<Failure, int>> cancellationQuote(String id) async {
    try {
      return Right(await _source.cancellationQuote(id));
    } on Object catch (error) {
      return Left(callableFailure(error));
    }
  }

  @override
  Future<Either<Failure, CancelRideResult>> cancelRide(String id) async {
    try {
      return Right(CancelRideResult(redispatched: await _source.cancel(id)));
    } on Object catch (error) {
      return Left(callableFailure(error));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateStatus(
    String rideId,
    RideStatus status,
  ) async {
    try {
      await _source.updateStatus(
        rideId,
        const RideStatusConverter().toJson(status),
      );
      return const Right(unit);
    } on Object catch (error) {
      if (error is FirebaseFunctionsException &&
          error.code == 'failed-precondition' &&
          error.details is Map) {
        final reason = switch ((error.details as Map)['reason']) {
          'too-far' => RideActionFailureReason.tooFar,
          'invalid-transition' => RideActionFailureReason.invalidTransition,
          _ => null,
        };
        if (reason != null) return Left(RideActionFailure(reason));
      }
      return Left(callableFailure(error));
    }
  }

  @override
  Future<Either<Failure, Unit>> acceptRide(String id) async {
    try {
      await _source.accept(id);
      return const Right(unit);
    } on Object catch (error) {
      if (error is FirebaseFunctionsException &&
          error.code == 'failed-precondition' &&
          error.details is Map) {
        final reason = switch ((error.details as Map)['reason']) {
          'offer-expired' => OfferFailureReason.expired,
          'not-offered' => OfferFailureReason.notOffered,
          'driver-busy' => OfferFailureReason.driverBusy,
          _ => null,
        };
        if (reason != null) return Left(OfferFailure(reason));
      }
      return Left(callableFailure(error));
    }
  }

  @override
  Future<Either<Failure, Unit>> declineRide(String id) async {
    try {
      await _source.decline(id);
      return const Right(unit);
    } on Object catch (error) {
      return Left(callableFailure(error));
    }
  }

  @override
  Future<Either<Failure, Unit>> rateRide(
    String rideId,
    int stars,
    List<RatingTag> tags,
    String comment,
  ) async {
    try {
      await _source.rate({
        'rideId': rideId,
        'stars': stars,
        'tags': tags.map((t) => t.value).toList(),
        'comment': comment,
      });
      return const Right(unit);
    } on Object catch (error) {
      if (error is FirebaseFunctionsException &&
          error.code == 'already-exists') {
        return const Left(RatingFailure.alreadyRated());
      }
      return Left(callableFailure(error));
    }
  }

  @override
  Future<Either<Failure, Unit>> skipRating(String rideId) async {
    try {
      await _source.skipRating(rideId);
      return const Right(unit);
    } on Object catch (error) {
      return Left(callableFailure(error));
    }
  }

  Stream<Either<Failure, T>> _stream<T>(Stream<T> Function() source) async* {
    try {
      await for (final value in source()) {
        yield Right(value);
      }
    } on Object catch (error) {
      yield Left(callableFailure(error));
    }
  }

  @override
  Stream<Either<Failure, DriverLiveLocation>> watchDriverLocation(
    String rideId,
  ) => _stream(
    () => _source.watchDriverLocation(rideId).map((model) => model.toEntity()),
  );
  @override
  Stream<Either<Failure, RideEntity>> watchRide(String id) =>
      _stream(() => _source.watch(id).map((model) => model.toEntity()));
  @override
  Stream<Either<Failure, String?>> watchActiveRideId(String uid) =>
      _stream(() => _source.active(uid));
}
