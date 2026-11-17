# Firebase development and security checks

## Admin web workspace (T5.3)

Enable Email/Password in Firebase Auth. Create the email/password user using
the Auth emulator UI for local development. The web application uses email and
password; mobile keeps phone OTP. A profile role never grants admin access.

Grant the boolean custom claim from this CLI only:

```powershell
$env:FIREBASE_AUTH_EMULATOR_HOST = '127.0.0.1:9099'
$env:GCLOUD_PROJECT = 'demo-mishwar'
node firebase/scripts/grant-admin.mjs admin@example.test
```

The script resolves Admin SDK from firebase/functions dependencies and preserves
other custom claims. Outside the emulator it uses Application Default Credentials;
it never reads repository secret files. Sign out and back in after granting or
revoking claims to refresh the ID token. No app screen grants claims.

Build web with `fvm flutter build web --release`. Optionally supply
`--dart-define=MAPS_WEB_KEY=...` through your local environment/build pipeline.
The app injects the Maps JS script at runtime; with no key or a loading failure,
the live driver list shows coordinates. Restrict this browser key by HTTP referrer.

`reviewDriver`, `updatePricing`, and `adminCancelRide` run in europe-west1,
require `request.auth.token.admin === true`, and append transactionally to
`adminLog`. Firestore and Storage grant admin reads only; client writes are
denied even for admin-owned profiles. Existing non-admin ownership rules and
pricing-read behavior are retained. Deploy the two added composite indexes for
driver status/date and ride status/date queries with the rules.

## Automated security rules suite (T5.4)

With the existing demo-mishwar Firestore (8080) and Storage (9199) emulators
running on loopback, run from the repository root:

```sh
npm --prefix firebase/tests install
npm --prefix firebase/tests test
```

On Windows with PowerShell script execution disabled, use npm.cmd. If the
standard npm cache is unavailable, add --cache firebase/tests/node_modules/.npm-cache
to the install command. The lockfile pins rules-unit-testing v4 and Firebase v11.
The gRPC override keeps Firebase v11's transitive gRPC dependency on a patched
version; npm install reports zero dependency vulnerabilities.
The tests load the actual rules files using initializeTestEnvironment; they
never deploy rules, use production endpoints, load Functions, or read secrets.
Auth tokens/claims are mocked, so Auth is not required. Each test clears
Firestore and seeds through withSecurityRulesDisabled. Storage tests also
clear the bucket. **These commands erase local demo data.** Do not run manual
probes or the app against that project while the suite is running.

Node runs the seven test files in separate processes. A temporary OS-directory
lock serializes rule uploads, fixture writes, and clears for the shared project.
Cleanup releases the lock even after test failures; waiting fails after four
minutes. After a forcibly terminated run, remove the stale directory named
mishwar-demo-rules-tests.lock from your OS temporary directory only after
checking no suite is still running. No emulator processes are managed.

Separate CRUD tests cover anonymous, owner, unrelated, rider, assigned driver,
offered driver and boolean admin contexts. Additional tests cover queries,
terminal-status history pagination, earnings, resubmission, presence, live
tracking, malformed fields, bounds and server-owned field deletion.
The suite supersedes the Firestore/Storage checks in rules_probe.mjs and
admin_probe.mjs. Both remain optional smoke checks:

```sh
node firebase/tests/rules_probe.mjs
node firebase/tests/admin_probe.mjs
```

The admin probe also checks the claim-grant CLI. tasks_probe.mjs remains a
separate Cloud Tasks delivery integration check, outside security rules.

### Final client access matrix

Admin means the boolean custom claim admin: true, never a profile role.
Admin clients have read access only, including their own records. Cloud
Functions/Admin SDK writes bypass these client rules.

| Path | Get/read | List/query | Create | Update | Delete |
|---|---|---|---|---|---|
| users/{uid} | Owner, admin | Owner-constrained results, admin | Owner: profile allowlist, optional initial rider/driver role | Owner: profile/push allowlist; existing role immutable | Owner only before a role exists |
| drivers/{uid} | Owner, admin (including missing own document) | Owner-constrained results, admin | Owner: pending offline application | Pending/rejected: application fields; rejected may resubmit. Approved: presence only | Denied |
| drivers/{uid}/earnings/{day} | Owner, admin | Owner, admin | Denied | Denied | Denied |
| rides/{rideId} | Rider, assigned driver, offered driver, admin | riderId == uid or driverId == uid; admin unrestricted | Denied | Denied | Denied |
| rides/{rideId}/live/driver | Rider, assigned driver, admin | Same participants for this ride; admin | Assigned driver during accepted/arriving/arrived/in_progress | Same as create | Denied |
| config/{id} | Admin | Admin | Denied | Denied | Denied |
| adminLog/{id} | Admin | Admin | Denied | Denied | Denied |
| Storage drivers/{uid}/{file}, one file segment | Owner, admin | Own folder, admin | Owner: image MIME type, strictly less than 5 MiB | Same as create, including metadata | Denied |
| All other paths, including subcollections | Denied | Denied | Denied | Denied | Denied |

Profile fields: name 2-40 characters, phone string at most 20, nullable photo
URL at most 2048, nullable/absent FCM token or string at most 4096. Initial
null token supports Flutter serialization; non-null token writes and changes
or deletion require fcmTokenUpdatedAt == request.time. Profile fields are
optional; first role selection happens after creation. Creation timestamps,
when supplied, use server timestamps; createdAt cannot change later.
Server-owned ratings, ride pointers and deletion flags cannot be added,
changed or removed by clients.

Applications allow only known vehicle keys, economy/comfort/van type,
nonempty make/model/color up to 40 and plate up to 15 characters. License
paths are at most 1024 characters and name one direct file in the owner's
folder, comparing the UID literally rather than interpolating it into a regex.
Changed application timestamps require server timestamps. Presence
requires boolean isOnline, a location map containing only geohash (1-12)
and GeoPoint, optional numeric heading (0-360), and lastSeenAt == request.time.
Busy drivers can heartbeat or go offline but cannot go back online while
assigned. Live location requires GeoPoint, updatedAt == request.time and
optional heading (0-360); offered drivers cannot read this channel.

The catch-all deny remains last in both rules files. Future-phase collections
(e.g. saved places) stay denied until their own tasks implement them.

## Places, routes and pricing (T2.1 / T2.3)

The four authenticated callables run in europe-west1. Configure the Maps server
secret in the Functions emulator's ignored local secret file; Firebase loads it
automatically. The app never receives the server key.

Start the Functions and Firestore emulators with a demo project. Build and seed
pricing from PowerShell (all npm commands run inside firebase/functions):

```powershell
cd firebase/functions
npm.cmd run build
$env:FIRESTORE_EMULATOR_HOST = '127.0.0.1:8080'
node ../seed/seed_pricing.mjs demo-mishwar
```

The seed overwrites config/pricing with PROJECT_SPEC section 4 defaults using
REST and Authorization: Bearer owner. It refuses missing or non-loopback hosts
and HTTP redirects. It imports the compiled server defaults, so build first.
Missing pricing documents use defaults; malformed documents fail rather than
silently charging defaults.

Run npm.cmd test in firebase/functions and fvm flutter test at the repo root.
Both pricing suites read firebase/functions/test/fixtures/fares.json. Rates use
whole fils internally in Dart; both calculators preserve decimal inputs as
exact fractions and round half up to 50 fils after applying the minimum.
Numeric callable amounts are JOD; JSON numbers do not preserve trailing zeros.
Dart Money.toJodString() supplies two-digit display formatting.

Create one PlacesSessionToken per autocomplete session. Keep its value for the
selected placeDetails call, then renew it when selection completes or a search
is abandoned. No Google APIs are contacted by the automated tests.

## Leftover emulator processes

If `firebase emulators:start` says a port is taken after an interrupted run, stop the leftovers:

```
powershell -File firebase/scripts/stop-emulators.ps1
```

It only stops Java/Node processes whose command line references the Firebase emulator binaries.

## Matching and offers (T3.2 / T3.3)

`onRideCreated`, `offerTimeout`, `acceptRide`, and `declineRide` run in
`europe-west1`. Matching offers one driver 15 seconds, queues its timeout after
16 seconds, and retries an empty search after 10 seconds while time remains.
The minute scheduler expires searches and recovers searches with lost tasks.
FCM sends best-effort notifications for offers; the emulator logs offer delivery.

Build in `firebase/functions` with `npm run build`, then from the repo root:

```sh
firebase emulators:start --project demo-mishwar --only auth,firestore,functions,storage
```

Firebase CLI starts Eventarc and Cloud Tasks alongside Functions. `firebase.json`
pins Tasks to port 9499. The Functions emulator supplies
`CLOUD_TASKS_EMULATOR_HOST=127.0.0.1:9499` to the Admin SDK; this routes
`getFunctions().taskQueue('locations/europe-west1/functions/offerTimeout')`
`.enqueue(data, {scheduleDelaySeconds})` locally without production credentials.
For a separate local Node process, set this environment variable explicitly.
The SDK sends `{data: {rideId, seq}}` to the task endpoint. Timeout tasks with an
old sequence do nothing. Duplicate tasks are safe through transactional checks.

With emulators running, run these from the repo root:

```sh
npm --prefix firebase/tests test
node firebase/tests/tasks_probe.mjs
```

The task probe uses an isolated emulator queue and loopback HTTP receiver to
verify Admin SDK enqueue, payload wrapping, and the requested 16-second ETA on port 9499.
It does not load Functions or read secret files. Pure matching/offer tests use
the serialized in-memory Firestore fake; they never contact Google APIs.

The installed Tasks emulator delivers scheduled tasks immediately: it preserves
the schedule in `X-CloudTasks-TaskETA` but does not wait for it. A premature
timeout correctly leaves a live offer unchanged. Invoke `expireSearchingRides`
locally to exercise the scheduler safety net; the deployed scheduler runs every
minute. To exercise the 15-second handoff directly,
POST `{"data":{"rideId":"YOUR_LOCAL_RIDE_ID","seq":1}}` to
`http://127.0.0.1:5001/demo-mishwar/europe-west1/offerTimeout` after the offer
expires, using its actual offerSeq. Production Cloud Tasks honors scheduling;
the fake-clock unit tests verify the exact expiry and retry boundaries.

Ride reads allow the rider, assigned driver, or offered driver. All ride writes,
driver offers, and driver assignments remain server-owned. Pending/rejected
application updates only allow their existing application fields (including the
existing rejected-to-pending resubmission); approved presence updates cannot
change status, offers, or assignments.

## Push notifications (T3.5)

Functions emulator runs log `[fcm:emulator] offer <rideId> → <uid>` without FCM.
Real Android/iOS delivery needs a real Firebase project and device. iOS also
needs a real APNs authentication key uploaded to Firebase, Push Notifications
capability and an `aps-environment` entitlement matching the provisioning
profile (development or production). No entitlements files are added yet.
Notification taps open /driver; Firestore remains the source of offer details.
Foreground messages and the background handler do nothing. Web skips messaging.
