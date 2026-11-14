import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/firebase/firebase_env.dart';

@module
abstract class FirebaseModule {
  @lazySingleton
  FirebaseAuth get auth => FirebaseAuth.instance;

  @lazySingleton
  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  @lazySingleton
  FirebaseFunctions get functions =>
      FirebaseFunctions.instanceFor(region: functionsRegion);
}
