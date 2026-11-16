# Local security checks (T1.5)

Use only the Firebase Emulator Suite with a demo project:

```sh
firebase emulators:start --project demo-mishwar --only auth,firestore,storage
```

Firestore is on 8080; Storage is on 9199. Use two authenticated emulator users
(A and B), plus an unauthenticated client. Seed review statuses using the
emulator Admin SDK only.

Manual checklist for `firestore.rules` (automated rules tests are T5.4):

- [ ] A can read A's driver document, including a missing document; B and signed-out clients cannot.
- [ ] A can create a pending application with isOnline=false, no currentRideId,
      economy/comfort/van vehicle, non-empty string make/model/color/plate, and
      licensePhotoPath beginning with drivers/A/.
- [ ] Creation fails for another uid, approved/rejected/suspended status,
      isOnline=true, any currentRideId (including null), invalid/missing vehicle
      fields/type, or a missing/non-string/foreign license path.
- [ ] Pending and rejected owners can edit only vehicle, licensePhotoPath, updatedAt.
- [ ] Rejected owners can additionally change status to pending.
- [ ] Pending cannot change to rejected; neither status can change to approved or suspended.
- [ ] Editing isOnline, currentRideId, rejectionReason, createdAt, location, or any
      other field is denied, including removal of those fields.
- [ ] Approved and suspended applications cannot be edited by clients.
- [ ] Driver deletion is denied for everyone.
- [ ] Existing users ownership and immutable-role behavior is unchanged.

Storage checklist:

- [ ] A can upload an image smaller than 5 MiB to drivers/A/license-file and read it.
- [ ] Exactly 5 MiB, larger files, non-image content types, deletes, nested paths,
      other users, signed-out clients, and all other paths are denied.

## Automated rules probe

With the emulators running (`firebase emulators:start`), run:

```
node firebase/tests/rules_probe.mjs +962781111199
```

It signs in a fresh phone user on the Auth emulator and checks 11 Firestore/Storage rules
(self-approval, going online while pending, admin escalation, foreign uploads, non-image uploads, ...).
Use a new phone number each run. Emulators only — it never talks to a real project.

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
