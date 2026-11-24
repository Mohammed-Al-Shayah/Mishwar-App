// Local Emulator Suite options (project demo-mishwar). Used only by debug/profile builds
// that talk to the emulators; release builds always use DefaultFirebaseOptions.
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

abstract final class DemoFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => android,
      TargetPlatform.iOS => ios,
      _ => throw UnsupportedError(
        'Firebase is configured for Android/iOS/Web.',
      ),
    };
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'demo-api-key',
    appId: '1:000000000000:android:0000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'demo-mishwar',
    storageBucket: 'demo-mishwar.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'demo-api-key',
    appId: '1:000000000000:ios:0000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'demo-mishwar',
    storageBucket: 'demo-mishwar.appspot.com',
    iosBundleId: 'com.mishwar',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'demo-api-key',
    appId: '1:000000000000:web:0000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'demo-mishwar',
    storageBucket: 'demo-mishwar.appspot.com',
    authDomain: 'demo-mishwar.firebaseapp.com',
  );
}
