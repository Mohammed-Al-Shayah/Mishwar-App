# OTP abuse protection (T8.1)

SMS pumping sends costly OTP messages to attacker-controlled numbers. Client
controls improve UX, but production protection depends on server configuration.
No credentials are created by this task; use local emulators for development.

## Layers

- Only Palestine (+970: 56/59) and Jordan (+962: 77/78/79) mobile numbers pass
  shared app validation. The project SMS region allowlist must also be configured.
- App Check uses Play Integrity on Android, App Attest with DeviceCheck fallback
  on iOS, and reCAPTCHA Enterprise on web. Supply the public site key with
  --dart-define=RECAPTCHA_SITE_KEY=...; web skips activation when it is empty.
  Non-release/emulator builds use debug providers, never production attestation.
  Release builds do not connect to emulators. Set USE_EMULATORS=false for releases.
- All callable functions use shared ENFORCE_APP_CHECK (boolean, default false
  for local tests). This parameter does not enforce Auth, Storage or Firestore.
- Installed firebase-functions v7 exports beforeSmsSent. protectOtpSms uses this
  Identity Platform blocking trigger, including requests made directly to Auth.
  In one Firestore transaction it limits each number to 3 sends in a sliding hour
  and 5 in a sliding day, and each canonical IP to 10 in a sliding hour.
  otpLimits document IDs are domain-separated SHA-256 hashes; only timestamps
  and expiry are stored. Clients, including admins, cannot read/write them.
  Configure a Firestore TTL policy on expiresAt for eventual cleanup (not required
  for correctness). No raw phone/IP or incoming event is logged.
- App cooldowns per number are 60, 120, then 300 seconds. The fifth send starts
  a 15-minute lock. Counters and deadlines survive restart in shared_preferences,
  using hashed number keys. Attempts are reserved before Auth, so uncertain or
  failed requests count conservatively. Local storage can be cleared by an attacker;
  it is not the security boundary. Five incorrect codes require a new code.

## Owner production checklist

1. Upgrade/enable Firebase Authentication with Identity Platform. Deploy
   protectOtpSms and verify its beforeSmsSent registration in Auth blocking
   functions. Test an allowed number and a denied fourth request in staging.
   The Auth emulator may not implement the SMS blocking hook; unit and Firestore
   emulator transaction tests cover the handler, not real SMS delivery.
2. From an owner shell with existing Application Default Credentials, run:
   node firebase/scripts/configure-auth.mjs YOUR_PROJECT_ID
   It calls projectConfigManager().updateProjectConfig with smsRegionConfig:
   allowlistOnly.allowedRegions = ['PS', 'JO'] and prints the returned region config.
   This task does not run it. With FIREBASE_AUTH_EMULATOR_HOST it targets the
   emulator, but that emulator may not support project config; do not silently
   fall back to a real project. Use the Firebase console to verify production.
3. Register Android App Check Play Integrity using the SHA-256 fingerprint of
   the Play app-signing certificate (not just the upload/debug certificate).
   Configure Apple App Attest/DeviceCheck and web reCAPTCHA Enterprise, including
   allowed domains. Enable the App Attest capability and production entitlement
   in the Apple signing/provisioning setup. Build web with RECAPTCHA_SITE_KEY.
4. Monitor App Check request metrics, then enable enforcement for Auth,
   Firestore, Storage, and Functions in the console where supported. Set the
   Functions boolean parameter ENFORCE_APP_CHECK=true during production deploy.
   Keep it false locally. Auth's own quotas remain an additional layer.
5. Create a Cloud Billing budget, e.g. $10/month, with email alerts at 50%, 90%,
   and 100%. Budget alerts notify; they do not cap spending or stop SMS sends.

## Registering debug tokens

Run a non-release build. Android/iOS debug providers emit a token in the local
SDK log; web emits one in the browser developer console when a nonempty site key
is supplied. In Firebase Console > App Check > Apps > Manage debug tokens,
register that development token for the matching app. Treat tokens as secrets;
never commit them or use debug providers for production. No token is generated
or registered by this task.

References: [Auth blocking SMS hook](https://firebase.google.com/docs/auth/extend-with-blocking-functions),
[Flutter App Check](https://firebase.google.com/docs/app-check/flutter/default-providers),
[debug providers](https://firebase.google.com/docs/app-check/flutter/debug-provider).
