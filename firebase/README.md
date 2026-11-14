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
