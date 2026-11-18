import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/features/admin/data/admin_record_model.dart';
import 'package:mishwar/features/admin/domain/admin_repository.dart';
import 'package:mishwar/features/common/pricing/domain/entities/pricing_table.dart';
import 'package:mishwar/features/common/pricing/domain/entities/vehicle_rates.dart';
import 'package:mishwar/features/common/user/domain/entities/vehicle_entity.dart';

@lazySingleton
class AdminRemoteDataSource {
  const AdminRemoteDataSource(
    this._db,
    this._auth,
    this._functions,
    this._storage,
  );
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final FirebaseFunctions _functions;
  final FirebaseStorage _storage;

  Future<void> signIn(String email, String password) async {
    if (!kIsWeb) throw StateError('web-only');
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<List<AdminEntry>> _entries(
    QuerySnapshot<Map<String, dynamic>> snapshot, {
    bool drivers = false,
  }) async => Future.wait(
    snapshot.docs.map((doc) async {
      final data = doc.data();
      if (drivers) {
        final user = (await _db.doc('users/${doc.id}').get()).data() ?? {};
        final completed = await _db
            .collection('rides')
            .where('driverId', isEqualTo: doc.id)
            .where('status', isEqualTo: 'completed')
            .count()
            .get();
        return AdminRecordModel(
          id: doc.id,
          fields: {
            ...data,
            'name': user['name'],
            'phone': user['phone'],
            'rating': user['rating'],
            'completedTrips': completed.count ?? 0,
          },
        ).toEntity();
      }
      return AdminRecordModel(id: doc.id, fields: data).toEntity();
    }),
  );

  Future<AdminData> load(AdminQuery params) async {
    final drivers = params.section == AdminSection.drivers;
    Query<Map<String, dynamic>> query = _db.collection(
      drivers ? 'drivers' : 'rides',
    );
    if (params.status != null) {
      query = query.where('status', isEqualTo: params.status);
    }
    if (params.from != null) {
      query = query.where(
        'createdAt',
        isGreaterThanOrEqualTo: Timestamp.fromDate(params.from!),
      );
    }
    if (params.to != null) {
      query = query.where(
        'createdAt',
        isLessThan: Timestamp.fromDate(params.to!),
      );
    }
    query = query.orderBy('createdAt', descending: true);
    if (params.after != null) {
      final cursor = await _db
          .doc('${drivers ? 'drivers' : 'rides'}/${params.after}')
          .get();
      if (cursor.exists) query = query.startAfterDocument(cursor);
    }
    final snapshot = await query.limit(26).get();
    final entries = await _entries(snapshot, drivers: drivers);
    return AdminData(
      entries: entries.take(25).toList(),
      next: entries.length > 25 ? entries[24].id : null,
    );
  }

  Stream<AdminData> watch(AdminSection section) {
    if (section == AdminSection.content) return Stream.value(AdminData());
    if (section == AdminSection.map) {
      return _db
          .collection('drivers')
          .where('isOnline', isEqualTo: true)
          .snapshots()
          .asyncMap(
            (s) async => AdminData(entries: await _entries(s, drivers: true)),
          );
    }
    if (section == AdminSection.pricing) {
      return _db.doc('config/pricing').snapshots().map((doc) {
        final data = doc.data();
        final pricing = data == null
            ? PricingTable.defaults()
            : PricingTable({
                for (final type in VehicleType.values)
                  type: _rates(adminMap(data[type.name])),
              });
        return AdminData(
          pricing: pricing,
          updatedBy: data?['updatedBy'] as String?,
          updatedAt: (data?['updatedAt'] as Timestamp?)?.toDate(),
        );
      });
    }
    // Streams invalidate counts; count() computes the aggregates.
    late StreamController<AdminData> controller;
    final subscriptions = <StreamSubscription<dynamic>>[];
    var generation = 0;
    List<Query<Map<String, dynamic>>> statQueries() {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      return [
        _db.collection('drivers').where('isOnline', isEqualTo: true),
        _db.collection('rides').where('status', whereIn: adminActiveStatuses),
        _db
            .collection('rides')
            .where(
              'createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(today),
            ),
        _db.collection('drivers').where('status', isEqualTo: 'pending'),
      ];
    }

    Timer? midnightRefresh;
    Future<void> refresh() async {
      final current = ++generation;
      try {
        final queries = statQueries();
        final counts = await Future.wait(queries.map((q) => q.count().get()));
        final rides = await _db
            .collection('rides')
            .orderBy('createdAt', descending: true)
            .limit(10)
            .get();
        final entries = await _entries(rides);
        if (!controller.isClosed && current == generation) {
          controller.add(
            AdminData(
              entries: entries,
              stats: counts.map((c) => c.count ?? 0).toList(),
            ),
          );
        }
      } on Object catch (error, stack) {
        if (!controller.isClosed && current == generation) {
          controller.addError(error, stack);
        }
      }
    }

    controller = StreamController<AdminData>(
      onListen: () {
        for (final query in [
          ...statQueries(),
          _db
              .collection('rides')
              .orderBy('createdAt', descending: true)
              .limit(10),
        ]) {
          subscriptions.add(
            query.snapshots().listen(
              (_) => unawaited(refresh()),
              onError: controller.addError,
            ),
          );
        }
        midnightRefresh = Timer.periodic(const Duration(minutes: 1), (_) {
          unawaited(refresh());
        });
      },
      onCancel: () async {
        generation++;
        midnightRefresh?.cancel();
        for (final subscription in subscriptions) {
          await subscription.cancel();
        }
      },
    );
    return controller.stream;
  }

  VehicleRates _rates(Map<String, dynamic> data) => VehicleRates(
    base: ((data['base'] as num) * 1000).round(),
    perKm: ((data['perKm'] as num) * 1000).round(),
    perMin: ((data['perMin'] as num) * 1000).round(),
    minimum: ((data['minimum'] as num) * 1000).round(),
  );
  Future<String> license(String path) => _storage.ref(path).getDownloadURL();
  Future<void> action(String name, Map<String, Object> arguments) async {
    await _functions.httpsCallable(name).call<void>(arguments);
  }
}
