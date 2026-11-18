import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/admin/domain/admin_management.dart';

@LazySingleton(as: ManagementRepository)
class ManagementRepositoryImpl implements ManagementRepository {
  const ManagementRepositoryImpl(this._db);
  final FirebaseFirestore _db;
  Object? _decode(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is Map) {
      return Map<String, Object?>.unmodifiable(
        value.map((k, v) => MapEntry(k as String, _decode(v))),
      );
    }
    if (value is List) return List<Object?>.unmodifiable(value.map(_decode));
    return value;
  }

  @override
  Future<Either<Failure, ManagementData>> load() async {
    try {
      final app = await _db.doc('config/app').get();
      final promos = await _db
          .collection('promos')
          .orderBy(FieldPath.documentId)
          .get();
      final logs = await _db
          .collection('adminLog')
          .where('action', isEqualTo: 'updateAppSettings')
          .get();
      final edits = <String, DateTime>{};
      for (final log in logs.docs) {
        final data = log.data();
        final at = (data['at'] as Timestamp).toDate();
        for (final section in (data['details'] as Map).keys.cast<String>()) {
          if (edits[section] == null || at.isAfter(edits[section]!)) {
            edits[section] = at;
          }
        }
      }
      return Right(
        ManagementData(
          settings:
              _decode(app.data() ?? <String, Object?>{})!
                  as Map<String, Object?>,
          promos: [
            for (final p in promos.docs)
              {...(_decode(p.data())! as Map<String, Object?>), 'code': p.id},
          ],
          edits: edits,
        ),
      );
    } on Object {
      return const Left(ServerFailure('management-load'));
    }
  }
}
