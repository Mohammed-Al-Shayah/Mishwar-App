import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/firebase/firebase_env.dart';
import 'package:mishwar/features/common/auth/data/datasources/otp_protection_store.dart';
import 'package:mishwar/features/common/auth/domain/repositories/otp_protection_repository.dart';
import 'package:mishwar/features/common/notifications/data/push_repository_impl.dart';
import 'package:mishwar/features/common/notifications/domain/push_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

@module
abstract class FirebaseModule {
  @lazySingleton
  OtpProtectionRepository otpProtectionRepository(OtpProtectionStore store) =>
      store;

  @preResolve
  Future<SharedPreferences> get preferences => SharedPreferences.getInstance();

  @lazySingleton
  FirebaseAuth get auth => FirebaseAuth.instance;

  @lazySingleton
  FirebaseMessaging get messaging => FirebaseMessaging.instance;

  @lazySingleton
  PushRepository get pushRepository => PushRepositoryImpl(
    kIsWeb ? null : messaging,
    firestore,
  );

  @lazySingleton
  FirebaseStorage get storage => FirebaseStorage.instance;

  @lazySingleton
  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  @lazySingleton
  FirebaseFunctions get functions =>
      FirebaseFunctions.instanceFor(region: functionsRegion);
}
