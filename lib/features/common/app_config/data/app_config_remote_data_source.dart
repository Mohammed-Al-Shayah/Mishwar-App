import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/features/common/app_config/data/app_banner_model.dart';

@lazySingleton
class AppConfigRemoteDataSource {
  const AppConfigRemoteDataSource(this._db);
  final FirebaseFirestore _db;
  Stream<Map<String, dynamic>?> watchServices() =>
      _db.doc('config/app').snapshots().map((doc) => doc.data());
  Stream<List<AppBannerModel>> watchBanners({bool all = false}) {
    final collection = _db.collection('banners');
    final query = all
        ? collection
        : collection.where('active', isEqualTo: true);
    return query
        .orderBy('order')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => AppBannerModel.fromJson({...doc.data(), 'id': doc.id}),
              )
              .toList(),
        );
  }
}
