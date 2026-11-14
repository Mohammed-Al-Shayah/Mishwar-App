# AGENTS.md — Mishwar (ride-hailing app)

Read `PROJECT_SPEC.md` before any task. It is the source of truth for features, data model, architecture and the task list (section 8).

## Workflow
- Work on **one task ID at a time** (e.g. `T0.1`). Do not start the next task.
- Touch only the files the task needs. No drive-by refactors.
- When done, report: files changed, commands run and their results, anything left open.
- Do not commit. The reviewer (Claude) reviews first; commits use `feat(T1.2): short description`.
- After review approval, tick the task in `PROJECT_SPEC.md` section 8.

## Stack (do not substitute)
Flutter + Dart 3 · Firebase (Auth phone/OTP, Firestore, Functions in TypeScript, FCM) · `flutter_bloc` (Cubit / Bloc) · `get_it` + `injectable` · `flutter_screenutil` · `go_router` · `freezed` + `json_serializable` · `fpdart` · `equatable` · `bloc_test` + `mocktail` · `very_good_analysis`.
No Riverpod, Provider, GetX, or other state management.

## Repo layout
**One Flutter app** (`package:mishwar`, Android id `com.mishwar`, targets Android/iOS/Web) with three modes:
rider, driver, admin (admin = web only, `admin` custom claim).
- `lib/app/` — app widget, go_router (`/auth`, `/role`, `/rider/*`, `/driver/*`, `/admin/*`), DI setup
- `lib/core/` — di, error, usecase, network, theme, l10n, widgets
- `lib/features/common/` — auth, ride, location, pricing, profile (shared by all modes)
- `lib/features/rider/`, `lib/features/driver/`, `lib/features/admin/` — mode-specific features
- `firebase/` — rules, indexes, Cloud Functions (TypeScript)
Rider code must not import driver code and vice versa; share through `features/common`.
Request background location only when the user enables driver mode.

## Flutter version
Flutter is managed by **FVM** (pinned in `.fvmrc`). Always run `fvm flutter ...` / `fvm dart ...`.

## Clean Architecture rules
- `domain/`: pure Dart. Entities, abstract repositories, use cases. No Flutter, Firebase or JSON imports.
- `data/`: models (freezed + json, with `toEntity()`), data sources (Firebase), repository implementations. Catch exceptions → return `Failure`.
- `presentation/`: cubits/blocs, screens, widgets. Depends on use cases only — never on data sources or Firebase.
- Use case: single `call()` returning `Future<Either<Failure, T>>` or `Stream<Either<Failure, T>>`.
- Cubit for simple state; Bloc for event-heavy flows (search with debounce, ride lifecycle, live tracking, offer countdown).
- States are immutable (freezed or equatable).

## DI
- `@lazySingleton` for data sources, repositories, use cases. `@injectable` (factory) for cubits/blocs.
- Firebase instances registered in a `@module` (`FirebaseModule`).
- Resolve cubits only via `BlocProvider(create: (_) => getIt<X>())` or in the router. No `getIt` calls elsewhere in widgets.

## UI rules
- **Follow `DESIGN_SYSTEM.md` exactly** (colors, typography, components, motion, map style). It is part of every UI task's acceptance criteria.
- `ScreenUtilInit(designSize: Size(375, 812), minTextAdapt: true, splitScreenMode: true)`.
- All sizes use `.w .h .r .sp`; spacing and text styles come from `core/theme` tokens. No magic numbers.
- Arabic is the default locale (RTL); every user-facing string comes from `.arb` files.

## Security
- Never put API keys or secrets in app code. Use `--dart-define` or Cloud Functions.
- Ride status, final fare, driver assignment are changed **only** by Cloud Functions.

## Commands to run before reporting
```
fvm dart run build_runner build   # after changing freezed / injectable / json code
fvm dart format .
fvm flutter analyze                  # must be 0 issues
fvm flutter test                     # must pass
```
For `firebase/functions`: `npm run lint && npm run build && npm test`.
Use the Firebase Emulator Suite for local testing; never touch a production project.
