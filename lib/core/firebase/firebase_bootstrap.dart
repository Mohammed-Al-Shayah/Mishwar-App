import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:mishwar/core/firebase/firebase_env.dart';
import 'package:mishwar/firebase_options.dart';

abstract final class FirebaseBootstrap {
  static Future<void>? _initialization;

  static Future<void> init() => _initialization ??= _initialize();

  static Future<void> _initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Release builds never use emulators, whatever USE_EMULATORS says.
    if (useEmulators && !kReleaseMode) {
      final host = emulatorHost(
        isAndroid: defaultTargetPlatform == TargetPlatform.android,
        isWeb: kIsWeb,
      );
      await FirebaseAuth.instance.useAuthEmulator(host, authEmulatorPort);
      FirebaseFirestore.instance.useFirestoreEmulator(
        host,
        firestoreEmulatorPort,
      );
      FirebaseFunctions.instanceFor(
        region: functionsRegion,
      ).useFunctionsEmulator(host, functionsEmulatorPort);
    }
  }
}
