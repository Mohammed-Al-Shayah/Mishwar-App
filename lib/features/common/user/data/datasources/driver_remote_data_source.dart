import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/features/common/user/data/models/driver_model.dart';
import 'package:mishwar/features/common/user/data/models/vehicle_model.dart';

@lazySingleton
class DriverRemoteDataSource {
  const DriverRemoteDataSource(this._firestore, this._storage);
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  DocumentReference<Map<String, dynamic>> _driver(String uid) =>
      _firestore.collection('drivers').doc(uid);
  Stream<DriverModel?> watchDriver(String uid) => _driver(uid).snapshots().map(
    (snapshot) => snapshot.exists ? DriverModel.fromFirestore(snapshot) : null,
  );
  Future<String> uploadLicensePhoto(
    String uid,
    Uint8List bytes,
    String contentType,
  ) async {
    final path =
        'drivers/$uid/license-${DateTime.now().microsecondsSinceEpoch}';
    await _storage
        .ref(path)
        .putData(bytes, SettableMetadata(contentType: contentType));
    return path;
  }

  Future<void> submitApplication(
    String uid,
    VehicleModel vehicle,
    String path,
  ) => _firestore.runTransaction<void>((transaction) async {
    final reference = _driver(uid);
    final snapshot = await transaction.get(reference);
    final data = <String, dynamic>{
      'vehicle': vehicle.toJson(),
      'licensePhotoPath': path,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (!snapshot.exists) {
      transaction.set(reference, {
        ...data,
        'status': 'pending',
        'isOnline': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else if (snapshot.data()!['status'] == 'rejected') {
      transaction.update(reference, {...data, 'status': 'pending'});
    } else {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'application-not-editable',
      );
    }
  });
}
