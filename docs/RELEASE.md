# Release preparation (1.0.0+1)

## Test APK on a real Android phone

Use a trusted Wi-Fi network shared by the phone and development PC. Find the
PC's IPv4 address with `ipconfig` (for example `192.168.1.20`). Start locally:

```powershell
firebase emulators:start --project demo-mishwar
fvm flutter build apk --debug --dart-define=EMULATOR_HOST=192.168.1.20
# Equivalent helper:
.\scripts\build_test_apk.ps1 -HostIp 192.168.1.20
```

Every emulator in `firebase.json` listens on `0.0.0.0`. Allow Node/Java through
the Windows firewall prompt on **private networks**; phone traffic must reach
ports 9099 (Auth), 8080 (Firestore), 5001 (Functions), 9199 (Storage).
Use the Auth emulator's test verification code; it sends no real SMS.
Install `build/app/outputs/flutter-apk/app-debug.apk` on the phone. Emulator data
is local; this APK is for testing. Maps still need the owner's restricted app
key in `android/secrets.properties`; never publish or print it.

## Owner-managed upload signing

The owner runs this interactively themselves (passwords are prompted):

```powershell
keytool -genkeypair -v -keystore C:/private/mishwar-upload.jks -alias upload -keyalg RSA -keysize 2048 -validity 10000
```

Back up the upload key securely. Copy `android/key.properties.example` to
`android/key.properties` and fill all four values locally. Absolute store paths
use forward slashes; relative paths resolve from `android/`. Both signing
properties and `*.jks` / `*.keystore` are ignored by Git. Missing properties file
means Gradle warns and falls back to debug signing; do not upload that build.
Release enables R8 minification/resource shrinking with Flutter/SDK consumer
rules and `android/app/proguard-rules.pro`.

## Production (owner setup, no emulator deploys)

1. Create the real Firebase project, enable Blaze billing, and run
   `flutterfire configure --project=<REAL_PROJECT_ID>` for Android
   `com.shayah.mishwar`, iOS `com.shayah.mishwar`, and web. Replace the development
   Firebase options through this command; install native configuration files
   locally as needed. On macOS configure the Apple team and provisioning.
2. Enable Phone Authentication (authorized web domains and Android SHA-1/SHA-256
   fingerprints, including the Play App Signing certificate), create Firestore
   in `europe-west1`, and enable Storage. Functions use `europe-west1`.
3. Enable Maps SDKs, Places API (New), and Routes API. Restrict app keys to their
   platform package/bundle and signing fingerprints (web keys by referrer).
   Keep the server key restricted to Places/Routes, accessible only to Functions.
4. Set the Functions secret interactively and deploy to the explicit project:

   ```powershell
   firebase functions:secrets:set GOOGLE_MAPS_SERVER_KEY --project <REAL_PROJECT_ID>
   firebase deploy --only firestore:rules,firestore:indexes,storage,functions --project <REAL_PROJECT_ID>
   ```

5. Configure the upload signing above, then build:

   ```powershell
   fvm flutter build appbundle --release --dart-define=USE_EMULATORS=false
   fvm flutter build web --release --dart-define=USE_EMULATORS=false
   ```

   AAB: `build/app/outputs/bundle/release/app-release.aab`; web: `build/web/`.
   Release bootstrap disables emulators regardless of the define. Smoke-test
   Phone Auth, Maps, push, and ride flows before distributing through Play's
   internal testing. iOS archive/upload requires macOS/Xcode and Apple signing.

Brand regeneration commands and asset details: [branding README](../assets/branding/README.md).
