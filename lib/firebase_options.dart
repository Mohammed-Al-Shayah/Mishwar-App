// Generated later by flutterfire configure; these are local demo placeholders.
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

abstract final class DefaultFirebaseOptions {
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
    apiKey: 'AIzaSyAAOMoMMMfMcdvUbG5-zKRYxuHT0_E_k5c',
    appId: '1:174154062820:android:7a472e0888643a625405f1',
    messagingSenderId: '174154062820',
    projectId: 'mishwar-ps-jo',
    storageBucket: 'mishwar-ps-jo.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCKSOz7a12SnYPjkf3MSy10KDFw4OjZGMM',
    appId: '1:174154062820:ios:cfdd9388525451615405f1',
    messagingSenderId: '174154062820',
    projectId: 'mishwar-ps-jo',
    storageBucket: 'mishwar-ps-jo.firebasestorage.app',
    iosBundleId: 'com.shayah.mishwar',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCEm2gPdAiF8KMlzCCCS3VWe5_kpM66RtU',
    appId: '1:174154062820:web:ec5eb152d30fa83f5405f1',
    messagingSenderId: '174154062820',
    projectId: 'mishwar-ps-jo',
    authDomain: 'mishwar-ps-jo.firebaseapp.com',
    storageBucket: 'mishwar-ps-jo.firebasestorage.app',
  );
}
