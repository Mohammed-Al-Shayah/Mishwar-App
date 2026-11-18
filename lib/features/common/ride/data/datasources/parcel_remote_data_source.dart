import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/features/common/ride/domain/repositories/parcel_repository.dart';

@lazySingleton
class ParcelRemoteDataSource {
  const ParcelRemoteDataSource(this._storage, this._firestore, this._functions);
  final FirebaseStorage _storage;
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  Stream<ParcelUpload> upload(String uid, Uint8List bytes) async* {
    if (bytes.isEmpty || bytes.length > 5 * 1024 * 1024) {
      throw const FormatException('Invalid photo size');
    }
    final path = 'parcels/$uid/${DateTime.now().microsecondsSinceEpoch}.jpg';
    final task = _storage
        .ref(path)
        .putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
    final events = StreamController<ParcelUpload>();
    final progress = task.snapshotEvents.listen(
      (snapshot) {
        if (!events.isClosed) {
          events.add(
            ParcelUpload(
              snapshot.totalBytes == 0
                  ? 0
                  : snapshot.bytesTransferred / snapshot.totalBytes,
            ),
          );
        }
      },
      onError: (Object _) {
        /* The task future reports the same failure. */
      },
    );
    unawaited(
      task.then<void>(
        (_) {
          events.add(ParcelUpload(1, path: path));
          unawaited(events.close());
        },
        onError: (Object error, StackTrace stack) {
          events.addError(error, stack);
          unawaited(events.close());
        },
      ),
    );
    try {
      yield* events.stream;
    } finally {
      await progress.cancel();
    }
  }

  Stream<String> watchCode(String id) => _firestore
      .doc('rides/$id/private/rider')
      .snapshots()
      .where((s) => s.exists)
      .map((s) => s.data()!['deliveryCode'] as String);

  Future<Uri> photoUrl(String id) async {
    final response = await _functions
        .httpsCallable('parcelPhotoUrl')
        .call<Map<String, dynamic>>({'rideId': id});
    final uri = Uri.parse(response.data['url'] as String);
    if (uri.scheme != 'https' && uri.scheme != 'http') {
      throw const FormatException('Invalid photo URL');
    }
    return uri;
  }
}
