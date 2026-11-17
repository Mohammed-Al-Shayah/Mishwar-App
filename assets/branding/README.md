# Mishwar branding

Original Arabic artwork built from `MwLogoMark` / `MwWordmark` and the bundled
IBM Plex Sans Arabic Bold font. Yellow is reserved for the small brand mark.

Regenerate using the pinned FVM SDK (same SDK/platform produces identical PNGs):

```powershell
fvm flutter test tool/render_brand_test.dart
fvm dart run flutter_launcher_icons
fvm dart run flutter_native_splash:create
```

`icon.png`: 1024 square, full bleed opaque black (including corners).
`icon_foreground.png`: 1024 square, transparent, artwork inside the central 66%.
`splash_logo.png`: 600 × 240, white wordmark with yellow mark on transparent.
Both splash modes use this same image on black. Android 12 uses the square
glyph because its system splash API masks artwork into an icon.
