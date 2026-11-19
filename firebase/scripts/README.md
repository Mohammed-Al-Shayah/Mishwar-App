# Local report backfill

Run only against the existing local emulator, with ride creation/status updates paused.
The script refuses non-loopback hosts and projects outside `demo-mishwar` / `demo-mishwar-*` (isolated test projects).
It does not start or stop emulators, read credentials, or load environment files.

```powershell
npm.cmd --prefix firebase/functions run build
$env:FIRESTORE_EMULATOR_HOST = '127.0.0.1:8080'
node firebase/scripts/backfill-stats.mjs
```

It replaces `stats/**` and resets each ride's `statsCountedFor`. Re-running produces
the same totals. Requests/service counts belong to the creation day; completion
and cancellation totals belong to the transition day in Asia/Amman. Revenue is
the sum of completed `fare.final`, including its existing fees and discounts.
Promo uses require `promo.applied == true`, matching completed redemptions.
Each ride counts once per category, including driver re-dispatch cancellations.
Daily `promoUsesByCode` supports range ranking; the same counts are also stored
at `stats/promos/{code}/{day}`.

Historical re-dispatches can only be recovered when `driverCancelledAt` exists;
`declinedBy` also contains rejected offers and cannot reconstruct cancellations.
Old no-driver records use `searchExpiresAt` when `noDriversAt` is absent. Missing
terminal timestamps fall back to the creation day; recover original timestamps
before backfilling if exact historical transition dates are needed. The script
requires `createdAt` and validates this before changing aggregates.

## OTP SMS region policy (T8.1)

Owner-only: `node firebase/scripts/configure-auth.mjs <project-id>` uses existing ADC
to allow SMS only to PS and JO and prints the resulting region config. Do not run
against production during development. See [the security checklist](../../docs/SECURITY.md).
The Auth emulator may not support this project-config API.
