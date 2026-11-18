# Local demo content

With the existing Firestore emulator running, set FIRESTORE_EMULATOR_HOST to 127.0.0.1:8080 and run node firebase/seed/seed_app_config.mjs demo-mishwar from the repository root. The script refuses non-local emulator hosts and preserves other config/app fields.

This writes the four default services and two demo banners. WELCOME50 is a demo target; seed_promos.mjs supplies the corresponding promo. The neutral picsum.photos images are placeholders and must be replaced with real promotional art.
