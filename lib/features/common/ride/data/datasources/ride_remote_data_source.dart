import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:injectable/injectable.dart';
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

  Future<void> cancel(String id) async {
    await _functions.httpsCallable('cancelRide').call<void>({'rideId': id});
  }

  Future<void> accept(String id) async {
    await _functions.httpsCallable('acceptRide').call<void>({'rideId': id});
  }

  Future<void> decline(String id) async {
    await _functions.httpsCallable('declineRide').call<void>({'rideId': id});
  }

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
