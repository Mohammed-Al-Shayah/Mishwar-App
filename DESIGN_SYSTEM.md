# Mishwar Design System — "Monochrome"

> Every screen must follow this file. If a need isn't covered, extend this file first, then build.
> Direction: the clean, monochrome, utility-first language of top-tier ride apps — black, white and greys,
> real-size native components, real map, real vehicle images. Our own name, logo and copy; no third-party branding or assets.

---

## 1. Principles

1. **Monochrome UI.** Black and white do 95% of the work. Colour only carries meaning (cash green, SOS red, online green, map parks).
2. **Real native proportions.** Body 16, titles 24–28, controls 48–56 high. Nothing tiny, nothing cramped.
3. **Lists, not cards.** Content is rows (icon circle + title + subtitle + hairline divider). Cards only for promos and suggestion tiles.
4. **One black button per screen**, full width, bottom of the sheet.
5. **Map is functional.** Grey map, black route, black square pins with black label tags, top-down cars on the map.
6. **Platform chrome respected.** Status bar, safe areas, home indicator, system back gestures.
7. **RTL first.** Designed in Arabic; directional icons mirror automatically.

---

## 2. Colour tokens

| Token | Hex | Use |
|---|---|---|
| `black` | `#000000` | Text, primary button, route, pins, selected border |
| `white` | `#FFFFFF` | Backgrounds, sheets |
| `grey50` | `#F3F3F3` | Suggestion tiles, map base |
| `grey100` | `#EEEEEE` | Search pill, icon circles, secondary button |
| `grey200` | `#E2E2E2` | Hairline dividers |
| `grey300` | `#CBCBCB` | Sheet grabber, disabled |
| `grey500` | `#8A8A8A` | Inactive tab icons |
| `grey600` | `#5E5E5E` | Secondary text |
| `cash` | `#3AA757` | Cash payment badge only |
| `positive` | `#05A357` | Online, success |
| `negative` | `#E11900` | SOS, errors, destructive |
| `info` | `#276EF1` | Pickup-point dots, info banners (rare) |
| `brand` | `#FFB627` | **Brand mark only** (logo, app icon, splash). Never in UI controls. |

Dark mode: invert surfaces (`#000` bg, `#1C1C1C` sheet, `#2A2A2A` fills, white text/buttons). Driver mode defaults to dark.
Implement via Material 3 `ThemeData` + `MishwarColors` `ThemeExtension`; widgets never use hex directly.

---

## 3. Typography

- Font: **IBM Plex Sans Arabic** (bundled assets, weights 400/500/600/700). Prices/times with `FontFeature.tabularFigures()`.
- Prices ("JD 4.70"), plates and phone numbers render **LTR inside RTL screens but stay at the layout start edge**: wrap the LTR `Text` in `Align(alignment: AlignmentDirectional.centerStart)` (or put it in a Row) — never a bare `Text(textDirection: ltr)` in a stretched Column, which pushes it to the left edge in Arabic.
- Status colours (cash, positive, negative) are used for small marks (dots, icons, borders), never as a fill behind normal text.
- Sizes via `.sp`.

| Token | Size / LH | Weight | Use |
|---|---|---|---|
| `largeTitle` | 28 / 36 | 700 | Home title, big screen headers |
| `title1` | 24 / 32 | 700 | Sheet titles ("وين رايح؟") |
| `title2` | 18 / 24 | 600 | Section headers ("اقتراحات") |
| `headline` | 16 / 22 | 600 | Row titles, prices, buttons |
| `body` | 16 / 24 | 400 | Body |
| `subhead` | 14 / 20 | 500 | Chips, tab labels, links |
| `footnote` | 13 / 18 | 400 | Row subtitles (grey600) |
| `caption` | 11 / 14 | 500 | Bottom nav labels |

---

## 4. Layout, radius, elevation

- **8pt grid.** Spacing: 4, 8, 12, 16, 20, 24, 32. Screen side padding **16**.
- **Radius:** buttons **8**, selected vehicle row **10**, tiles/promo **12**, sheet top **16**, search pill & chips **full pill**, icon circles full.
- **Heights:** primary button 52–56 · search pill 52 · list row min 64 · icon circle 40 · map FAB 40 · bottom nav 72 (incl. safe area).
- **Elevation:** flat. Sheets and FABs get one soft shadow (`0 -2 12 rgba(0,0,0,0.08)`); nothing else has shadows.
- **Dividers:** 0.5–1px `grey200`, inset to start at the text (not under the icon).

---

## 5. Components (`lib/core/widgets/`)

| Component | Spec |
|---|---|
| `MwButton.primary` | Black, white `headline`, h 52, r 8, full width. Pressed: `#333`. Loading: spinner replaces label. |
| `MwButton.secondary` | `grey100` fill, black label. |
| `MwSearchPill` | h 52, `grey100`, pill radius, search icon 22, "وين رايح؟" in `headline`, trailing white pill "لاحقاً ▾" (schedule). |
| `MwListRow` | 40 icon circle (`grey100`) + title (`headline`) + subtitle (`footnote` grey600) + optional trailing chevron; inset divider. |
| `MwSuggestionTile` | `grey50`, r 12, vehicle/icon image 28 high + `subhead` label. Grid of 4. |
| `MwPromoCard` | Black, r 12, white title + grey subtitle + "اطلب الآن ←" + vehicle image bleeding off edge. |
| `MwBottomNav` | 3 tabs: الرئيسية / النشاط / الحساب. Active black, inactive grey500; caption labels. |
| `MwSheet` | White, top r 16, grabber 36×4 grey300, snap points, title centred `headline` + divider. |
| `MwVehicleRow` | Vehicle **image** 70×34 (3/4 view PNG) + name `headline` + seats icon + ETA·time `footnote` + optional tagline; price `headline` at end. Selected: 2px black border, r 10. |
| `MwPaymentRow` | Small coloured method badge (cash green) + method name + chevron. |
| `MwMapFab` | 40 white circle, shadow, back/recenter. |
| `MwPinLabel` | Black tag r 4, white `footnote` + chevron; ETA variant = white box with minutes on the start side. |
| `MwDriverCard` | Avatar 56 + rating, name, car make/colour, plate in bold `title2`; actions (call/message/share/safety) as 48 grey circles. |
| `MwCountdownBar` (driver offer) | Thin black progress bar across the top of the offer sheet, shrinking over 15s. |
| `MwSkeleton` | grey100 shimmer for all loading states. |

---

### Sign-in controls

- `MwPrimaryButton` implements the primary-button specification above; loading keeps the primary fill and replaces the label with a monochrome spinner.
- `MwTextField` uses the theme's filled pill input and body typography.
- `MwOtpInput`: six LTR digit cells, each 48 × 56, radius 8, fill colour; focused cell has a 2px text-primary border. OTP boxes stay LTR within Arabic screens.
- Country chip: non-editable filled pill. Sign-in headings use `title1`; the splash and role-picker wordmarks use `largeTitle`. Supporting copy uses `footnote`, errors use `negative`, countdowns use tabular figures.
- All dimensions above are defined as ScreenUtil tokens in `core/theme`.

## 6. Map

- Custom map style JSON (`assets/map_styles/light.json`, `dark.json`): grey roads/blocks, light green parks, muted blue water, minimal POIs, small grey street labels.
- **Route:** solid black 4px, right-angled joins follow roads. Dark mode: white route.
- **Pins:** pickup = black square with white inner square; drop-off = black square. Each has a `MwPinLabel`.
- **Nearby cars:** top-down white car bitmaps, rotated to heading, positions interpolated (no jumps).
- Camera padding = sheet height so pins are never hidden.

---

## 7. Imagery

- Vehicle images: consistent 3/4-view renders on transparent background, same angle and lighting, one per tier (X, مريح, XL, طرد). Stored in `assets/vehicles/` @1x/@2x/@3x.
- Icons: one icon set only (Phosphor regular, 20–24), black.
- Logo/app icon: "مشوار" wordmark + small brand-yellow mark. No other app's marks, names or assets.

---

## 8. Motion

- 150ms press, 250ms content changes (`easeOutCubic`), 350ms sheet snaps (spring), route draws in 500ms.
- Searching for driver: pulsing black rings at pickup + progress copy.
- Respect reduced-motion.

---

## 9. Screen references

1. **Home:** large title "مشوار" · `MwSearchPill` with schedule · 2 recent `MwListRow` · "اقتراحات" + 4 `MwSuggestionTile` (رحلة، احجز، طرد، مطار) · `MwPromoCard` · `MwBottomNav`.
2. **Choose ride:** map (top ~45%) with route, pins + labels, nearby cars, back FAB · sheet "اختر رحلة أو اسحب للمزيد" · 3 `MwVehicleRow` · `MwPaymentRow` · `MwButton.primary` "اختر مشوار X".
   T6.3 adds a standard ticket-icon list row below payment and a scrollable promo
   sheet with MwTextField, inline negative errors and a loading primary apply
   button. The selected vehicle shows the server quote with the original price
   in grey600 footnote and a strike-through; other vehicles keep their prices.
   Applied discounts use positive text in receipts and summaries; collect-cash
   uses a footnote below the final amount. All variants support text scale 1.3.
3. **Schedule:** "متى تريد المغادرة؟" date/time wheel pickers, policy rows with icons, primary "حدّد موعد الانطلاق".
   T6.2 uses a horizontal list of date chips, a native time wheel (216 high),
   a departure summary, and the localized primary "تأكيد الموعد". The selected
   time stays in the search pill with a clear action. Scheduled activity uses
   the history row with departure date/time and a trailing cancel text button.
4. **Pickup point:** map zoomed, suggested pickup dots (`info`), sheet "أكّد موقع الانطلاق" with address field + primary button.
5. **On trip / safety:** driver card, safety toolkit list (share trip, emergency, trusted contacts).
6. **Driver offer (dark):** countdown bar, price `largeTitle`, rider rating, pickup→drop rows, primary "قبول" (h 56).

---


### History, receipts and earnings

- History uses the standard 40 icon circle, headline destination, footnote date/status and tabular LTR fare. Only cancelled status text uses negative.
- Receipts are map-free lists: date, shared stop timeline, participant and vehicle, rating, fare/payment rows and a title2 total. Rider receipts end with the rebook primary button.
- Driver earnings uses the dark theme, a largeTitle selected-day total and seven bars in text-primary (selected) / text-secondary (unselected). Chart height is 144 via ScreenUtil; values and day initials use caption typography. Each entire bar column is selectable and exposes its full date and amount to accessibility.
- Loading, empty and retry states use existing skeleton, text and button tokens.

### Account and settings

### Activity and support (T6.8–T6.9)

- Activity starts with a native segmented control for upcoming and past rides.
- Support uses standard list rows, monochrome status pills, category chips and
  multiline MwTextField inputs. Threads use end-aligned black/white user bubbles
  and start-aligned grey100 admin bubbles, tile radius, body copy and footnote
  timestamps. Bubbles occupy at most 85% of the available width.
- Closed threads replace the composer with a localized note. Driver support
  keeps the dark theme; admin support reuses the desktop table and detail panel.

- Account header: 64 avatar circle with initial, title2 name, start-aligned LTR phone in footnote, and a pill with one filled star plus rating.
- Settings use MwListRow icon circles and directional chevrons. Driver account stays dark; appearance selection affects rider mode.
- Settings sheets use the standard grabber, centred headline, divider and scrollable content. Language and appearance choices use native radio rows.
- Sign out uses a secondary button; account deletion uses negative text and two confirmation sheets, ending with a typed localized confirmation word.

## 10. Review checklist

### Admin web workspace (T5.3)

- Light monochrome theme; desktop minimum width 1024 logical pixels. Smaller
  windows show a localized larger-screen notice. The web workspace keeps native
  proportions by disabling ScreenUtil scaling while retaining token dimensions.
- Start sidebar 240, end detail panel 440, sign-in form maximum width 400.
  Content uses 24 spacing, title1 page titles, 64 minimum table rows, flat
  dividers and native monochrome filters. Tables scroll horizontally as needed.
- Overview has four flat statistic tiles. Pricing uses a 3-by-4 editable grid,
  144-wide inputs and one primary save button. License preview height 240;
  live map height 480. Free drivers use a positive dot; busy drivers black.

- [ ] Only theme tokens + ScreenUtil — no raw hex/sizes in widgets.
- [ ] One primary button per screen; monochrome controls.
- [ ] Sizes match section 4 (no text < 11, rows ≥ 64, buttons ≥ 52).
- [ ] RTL + LTR, light + dark, text scale 1.3 all correct.
- [ ] Loading / empty / error states designed.
- [ ] Golden tests for core widgets.

### Home content (T6.4–T6.5)

- Home content scrolls inside a sheet capped at 70% of available height. Map padding follows its measured height.
- Services: four 76 × 76 grey100 tiles, radius 12, Phosphor regular glyphs and captions. Disabled services retain their position with a muted glyph and a small “قريباً” pill. The full services screen uses two columns and one-line descriptions.
- Banner carousel: 16:8 images, radius 12, grey100 loading/error surface, white title/subtitle on a bottom black 50% to transparent gradient, with page dots below. Advance every five seconds; pause during touch and while the app is inactive; disable automatic movement for reduced motion.
- Admin content uses the existing web workspace, flat service rows, native switches, order arrows and a scrollable banner editor.
