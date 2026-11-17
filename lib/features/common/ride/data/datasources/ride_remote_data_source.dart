import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/features/common/ride/data/models/driver_live_location_model.dart';
import 'package:mishwar/features/common/ride/data/models/ride_model.dart';

@lazySingleton
class RideRemoteDataSource {
  const RideRemoteDataSource(this._functions, this._firestore);
  final FirebaseFunctions _functions;
  final FirebaseFirestore _firestore;
  Future<String> request(Map<String, dynamic> data) async {
    final result = await _functions
        .httpsCallable('requestRide')
        .call<Map<String, dynamic>>(data);
    return result.data['rideId'] as String;
  }

  Future<bool> cancel(String id) async {
    final result = await _functions
        .httpsCallable('cancelRide')
        .call<Map<String, dynamic>>({'rideId': id});
    return result.data['redispatched'] == true;
  }

  Future<void> updateStatus(String id, String status) async {
    await _functions.httpsCallable('updateRideStatus').call<void>({
      'rideId': id,
      'status': status,
    });
  }

  Future<void> rate(Map<String, dynamic> data) async {
    await _functions.httpsCallable('rateRide').call<void>(data);
  }

  Future<void> skipRating(String id) async {
    await _functions.httpsCallable('skipRating').call<void>({'rideId': id});
  }

  Future<void> accept(String id) async {
    await _functions.httpsCallable('acceptRide').call<void>({'rideId': id});
  }

  Future<void> decline(String id) async {
    await _functions.httpsCallable('declineRide').call<void>({'rideId': id});
  }

  Stream<DriverLiveLocationModel> watchDriverLocation(String id) => _firestore
      .doc('rides/$id/live/driver')
      .snapshots()
      .where(
        (snapshot) => snapshot.exists && snapshot.data()?['updatedAt'] != null,
      )
      .map((snapshot) => DriverLiveLocationModel.fromJson(snapshot.data()!));
  Stream<RideModel> watch(String id) =>
      _firestore.collection('rides').doc(id).snapshots().map((snapshot) {
        final data = snapshot.data();
        if (data == null) throw const FormatException('Ride not found');
        return RideModel.fromJson({...data, 'id': snapshot.id});
      });
  Stream<String?> active(String uid) => _firestore
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((snapshot) => snapshot.data()?['activeRideId'] as String?);
}
