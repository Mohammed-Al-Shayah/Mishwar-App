import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/features/common/safety/data/trusted_contact_model.dart';
import 'package:mishwar/features/common/safety/domain/trusted_contact.dart';

@lazySingleton
class SafetyRemoteDataSource {
  SafetyRemoteDataSource(this._firestore, this._functions);
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;
  CollectionReference<Map<String, dynamic>> _contacts(String uid) =>
      _firestore.collection('users').doc(uid).collection('trustedContacts');
  Stream<List<TrustedContactModel>> watch(String uid) =>
      _contacts(uid).snapshots().map(
        (snapshot) => snapshot.docs
            .map(
              (doc) =>
                  TrustedContactModel.fromJson({...doc.data(), 'id': doc.id}),
            )
            .toList(),
      );
  Future<void> save(String uid, TrustedContact contact) async {
    final contacts = _contacts(uid);
    if (contact.id.isEmpty &&
        (await contacts.limit(5).get()).docs.length >= 5) {
      throw const ContactsLimitException();
    }
    await (contact.id.isEmpty ? contacts.doc() : contacts.doc(contact.id)).set({
      'name': contact.name.trim(),
      'phone': contact.phone,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> delete(String uid, String id) => _contacts(uid).doc(id).delete();
  Future<String> createShareLink(String rideId) async {
    final result = await _functions
        .httpsCallable('createShareLink')
        .call<Map<String, dynamic>>({'rideId': rideId});
    return result.data['url'] as String;
  }
}

class ContactsLimitException implements Exception {
  const ContactsLimitException();
}
