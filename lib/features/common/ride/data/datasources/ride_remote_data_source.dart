import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/features/common/ride/data/models/driver_live_location_model.dart';
import 'package:mishwar/features/common/ride/data/models/ride_model.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_history.dart';

@lazySingleton
class RideRemoteDataSource {
  const RideRemoteDataSource(this._functions, this._firestore);
  final FirebaseFunctions _functions;
  final FirebaseFirestore _firestore;
  Future<RideHistoryPage> history({
    required RideParty party,
    required String uid,
    HistoryCursor? after,
    int limit = 20,
  }) async {
    if (limit < 1) throw ArgumentError.value(limit, 'limit');
    var query = _firestore
        .collection('rides')
        .where('${party.name}Id', isEqualTo: uid)
        .where('status', whereIn: ['completed', 'cancelled', 'no_drivers'])
        .orderBy('createdAt', descending: true);
    if (after != null) {
      if (after is! _FirestoreHistoryCursor ||
          after.party != party ||
          after.uid != uid) {
        throw ArgumentError('Invalid history cursor');
      }
      query = query.startAfterDocument(after.snapshot);
    }
    final result = await query.limit(limit + 1).get();
    final docs = result.docs.take(limit).toList();
    return RideHistoryPage(
      items: docs
          .map(
            (doc) =>
                RideModel.fromJson({...doc.data(), 'id': doc.id}).toEntity(),
          )
          .toList(),
      next: result.docs.length > limit
          ? _FirestoreHistoryCursor(docs.last, party, uid)
          : null,
    );
  }

  Stream<List<RideModel>> scheduled(String uid) => _firestore
      .collection('rides')
      .where('riderId', isEqualTo: uid)
      .where('status', isEqualTo: 'scheduled')
      .orderBy('scheduledFor')
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => RideModel.fromJson({...doc.data(), 'id': doc.id}))
            .toList(),
      );
  Future<String> schedule(Map<String, dynamic> data) async {
    final result = await _functions
        .httpsCallable('scheduleRide')
        .call<Map<String, dynamic>>(data);
    return result.data['rideId'] as String;
  }

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

class _FirestoreHistoryCursor extends HistoryCursor {
  const _FirestoreHistoryCursor(this.snapshot, this.party, this.uid);
  final DocumentSnapshot<Map<String, dynamic>> snapshot;
  final RideParty party;
  final String uid;
}
