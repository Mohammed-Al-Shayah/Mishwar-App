import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/core/geo/geohash.dart';
import 'package:mishwar/features/common/user/domain/entities/geo_point_value.dart';
import 'package:mishwar/features/driver/presence/domain/driver_presence_repository.dart';

@LazySingleton(as: DriverPresenceRepository)
class DriverPresenceRepositoryImpl implements DriverPresenceRepository {
  const DriverPresenceRepositoryImpl(this._firestore, this._auth);
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Future<Either<Failure, Unit>> _write(Map<String, dynamic> data) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Left(AuthFailure('signed-out'));
    try {
      // update() merges, so going offline keeps the last stored location.
      await _firestore.collection('drivers').doc(uid).update({
        ...data,
        'lastSeenAt': FieldValue.serverTimestamp(),
      });
      return const Right(unit);
    } on FirebaseException catch (error) {
      return Left(
        error.code == 'permission-denied'
            ? const PermissionFailure('driver-presence')
            : error.code == 'unavailable'
            ? const NetworkFailure('unavailable')
            : ServerFailure(error.code),
      );
    } on Object {
      return const Left(ServerFailure('driver-presence'));
    }
  }

  Map<String, dynamic> _location(GeoPointValue point, double? heading) => {
    'isOnline': true,
    'location': {
      'geohash': encodeGeohash(point.lat, point.lng),
      'geopoint': GeoPoint(point.lat, point.lng),
    },
    'heading': ?heading,
  };
  @override
  Future<Either<Failure, Unit>> goOnline(
    GeoPointValue point, {
    double? heading,
  }) => _write(_location(point, heading));
  @override
  Future<Either<Failure, Unit>> updateLocation(
    GeoPointValue point, {
    double? heading,
  }) => _write(_location(point, heading));
  @override
  Future<Either<Failure, Unit>> publishTripLocation(
    String rideId,
    GeoPointValue point, {
    double? heading,
  }) async {
    try {
      await _firestore.doc('rides/$rideId/live/driver').set({
        'geopoint': GeoPoint(point.lat, point.lng),
        'heading': ?heading,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return const Right(unit);
    } on Object {
      return const Left(ServerFailure('trip-location'));
    }
  }

  @override
  Future<Either<Failure, Unit>> goOffline() => _write({'isOnline': false});
}
