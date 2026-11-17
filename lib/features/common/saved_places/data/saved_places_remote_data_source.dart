import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/features/common/saved_places/data/saved_place_model.dart';
import 'package:mishwar/features/common/saved_places/domain/saved_place.dart';

@lazySingleton
class SavedPlacesRemoteDataSource {
  SavedPlacesRemoteDataSource(this._firestore);
  final FirebaseFirestore _firestore;
  CollectionReference<Map<String, dynamic>> _places(String uid) =>
      _firestore.collection('users').doc(uid).collection('savedPlaces');

  Stream<List<SavedPlaceModel>> watch(String uid) =>
      _places(uid).snapshots().map(
        (snapshot) => snapshot.docs
            .map(
              (doc) => SavedPlaceModel.fromJson({
                ...doc.data(),
                'id': doc.id,
              }),
            )
            .toList(),
      );

  Map<String, dynamic> _data(SavedPlace place) => {
    'label': place.label.name,
    'name': place.name.trim(),
    'address': place.address,
    'geopoint': GeoPoint(place.location.lat, place.location.lng),
    'updatedAt': FieldValue.serverTimestamp(),
  };

  Future<void> upsert(String uid, SavedPlace place) => _places(uid)
      .doc(place.label == SavedPlaceLabel.other ? place.id : place.label.name)
      .set(_data(place));

  Future<void> addOther(String uid, SavedPlace place) async {
    // The cap is deliberately app-enforced; rules validate document shape only.
    final others = await _places(
      uid,
    ).where('label', isEqualTo: 'other').limit(20).get();
    if (others.docs.length >= 20) throw const SavedPlacesLimitException();
    await _places(uid).add(_data(place));
  }

  Future<void> rename(String uid, String id, String name) =>
      _places(uid).doc(id).update({
        'name': name.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
  Future<void> delete(String uid, String id) => _places(uid).doc(id).delete();
}

class SavedPlacesLimitException implements Exception {
  const SavedPlacesLimitException();
}
