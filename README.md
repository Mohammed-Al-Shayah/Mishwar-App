# Mishwar

One Flutter ride-hailing app with rider, driver, and web admin modes.
Use the Flutter SDK pinned by FVM in `.fvmrc`.

## Run locally

Prerequisites: FVM, Node.js 22, Firebase CLI, and a Java runtime supported by
the Firestore emulator. Run `fvm flutter pub get` and, inside
`firebase/functions`, `npm install` followed by `npm run build` once.

1. From the repository root, run `firebase emulators:start`.
   The Emulator UI is at http://localhost:4000.
2. Run `fvm flutter run`. Emulators are enabled by default.
   `--dart-define=USE_EMULATORS=false` disables emulator routing; the demo
   placeholders must be replaced before connecting a real Firebase project.
3. On a physical device, run
   `fvm flutter run --dart-define=EMULATOR_HOST=<your PC LAN IP>`.
   The device must reach the PC over the LAN. Configure the auth, firestore,
   and functions emulators in `firebase.json` to bind to `0.0.0.0`
   (`"host": "0.0.0.0"`) and allow their ports through the local firewall.

The project is `demo-mishwar`: no Google account or production project required.
Auth runs on port 9099, Firestore on 8080, and Functions on 5001.
Callable functions use `europe-west1` (including the `ping` callable).
Android emulators use `10.0.2.2`; web and iOS simulators use `localhost`.
Only Android debug builds enable cleartext HTTP traffic.

Cloud Functions checks: `npm run lint`, `npm run build`, and `npm test` inside
`firebase/functions`. The test script currently reports that no tests exist
and exits successfully; it does not claim test coverage.

Auth emulator shows OTP codes at http://localhost:4000/auth (or in emulator logs); any phone number works.
