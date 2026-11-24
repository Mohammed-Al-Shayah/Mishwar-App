import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:mishwar/core/firebase/demo_firebase_options.dart';
import 'package:mishwar/core/firebase/firebase_env.dart';
import 'package:mishwar/firebase_options.dart';

abstract final class FirebaseBootstrap {
  static Future<void>? _initialization;

  static Future<void> init() => _initialization ??= _initialize();

  static Future<void> _initialize() async {
    await Firebase.initializeApp(
      // Emulators run demo-mishwar; real builds use the live project.
      options: useEmulators && !kReleaseMode
          ? DemoFirebaseOptions.currentPlatform
          : DefaultFirebaseOptions.currentPlatform,
    );
    const siteKey = String.fromEnvironment('RECAPTCHA_SITE_KEY');
    const debug = !kReleaseMode;
    if (!kIsWeb || siteKey.isNotEmpty) {
      await FirebaseAppCheck.instance.activate(
        providerAndroid: debug
            ? const AndroidDebugProvider()
            : const AndroidPlayIntegrityProvider(),
        providerApple: debug
            ? const AppleDebugProvider()
            : const AppleAppAttestWithDeviceCheckFallbackProvider(),
        providerWeb: debug
            ? WebDebugProvider()
            : ReCaptchaEnterpriseProvider(siteKey),
      );
    }
    // Release builds never use emulators, whatever USE_EMULATORS says.
    if (useEmulators && !kReleaseMode) {
      final host = emulatorHost(
        isAndroid: defaultTargetPlatform == TargetPlatform.android,
        isWeb: kIsWeb,
      );
      await FirebaseAuth.instance.useAuthEmulator(host, authEmulatorPort);
      await FirebaseStorage.instance.useStorageEmulator(
        host,
        storageEmulatorPort,
      );
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
