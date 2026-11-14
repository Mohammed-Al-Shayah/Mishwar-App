import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/features/common/user/data/models/user_model.dart';
import 'package:mishwar/features/common/user/domain/entities/user_role.dart';

@lazySingleton
class UserRemoteDataSource {
  const UserRemoteDataSource(this._firestore);
  final FirebaseFirestore _firestore;
  DocumentReference<Map<String, dynamic>> _user(String uid) =>
      _firestore.collection('users').doc(uid);

  Stream<UserModel?> watchUser(String uid) => _user(uid).snapshots().map((
    snapshot,
  ) {
    if (!snapshot.exists) return null;
    // Local serverTimestamp transforms are null until acknowledged.
    final data = snapshot.data()!;
    return UserModel.fromJson({
      ...data,
      'id': snapshot.id,
      'createdAt': data['createdAt'] ?? Timestamp.fromMillisecondsSinceEpoch(0),
    });
  });

  Future<void> createProfile({
    required String uid,
    required String phone,
    required String name,
  }) async {
    final model = UserModel(
      id: uid,
      name: name,
      phone: phone,
      createdAt: DateTime.now().toUtc(),
    );
    final data = model.toJson()..remove('role');
    data['createdAt'] = FieldValue.serverTimestamp();
    // Retrying name submission must never overwrite an existing profile.
    await _firestore.runTransaction<void>((transaction) async {
      final document = _user(uid);
      final existing = await transaction.get(document);
      if (!existing.exists) transaction.set(document, data);
    });
  }

  Future<void> setRole(String uid, UserRole role) =>
      _user(uid).update({'role': role.name});
}
