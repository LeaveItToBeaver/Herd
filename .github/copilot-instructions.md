# Copilot instructions (Herd)

## Project shape & “where stuff lives”
- Flutter app code is under `lib/`, organized by **feature**: `lib/features/<area>/...` with a common split of `data/` (models/repos), `view/` (screens/widgets), and `view/providers/` (Riverpod).
- Cross-cutting utilities/services live in `lib/core/` (bootstrap, router, cache, themes, shared widgets).
- Firebase Cloud Functions (Node) live in `functions/` (see `functions/index.js` which aggregates handlers).

## Startup & app bootstrap
- Entry point is `lib/main.dart`: initializes Firebase, runs `setupPlatformSpecificFirebase()`, registers FCM background handler (mobile only), kicks off Mobile Ads + cache bootstrap, and then wraps the app in `ProviderScope`.
- App-wide bootstrap wrappers are applied via `BootstrapWrapper` and `AuthGate` (see `lib/main.dart` and `lib/core/bootstrap/app_bootstraps.dart`).

## Navigation
- Navigation is centralized in `lib/core/utils/router.dart` using **GoRouter** behind the `goRouterProvider`.
- Auth gating is primarily done via `GoRouter.redirect`: wait for `authReadyProvider`, then enforce `/login` and `/emailVerification`.
- Many routes wrap screens with `GlobalOverlayManager` (floating buttons/overlays). Its flags are **picked per screen** (e.g., profile pages may hide chat toggle), so match nearby routes’ settings when adding a new one.

## State management (Riverpod 3 + codegen)
- Riverpod 3 **codegen is the default** in this repo: use `riverpod_annotation` + `part '*.g.dart'` (see `lib/features/user/auth/view/providers/auth_provider.dart`).
- Prefer `@Riverpod(keepAlive: true)` for long-lived session state like auth.
- When adding providers, follow the existing convention: keep provider files under `.../view/providers/` and include the `part` file next to it.
- Migration context and patterns are documented in `riverpod-migration-guide.md` (use as the canonical reference for “how we want providers shaped”).

### Notable non-codegen leftovers
- Some legacy providers still exist (example: `FutureProvider.family` in `lib/features/community/moderation/view/screens/pinned_post_management_screen.dart`). When touching these areas, convert them to codegen-style providers so the project keeps moving toward “100% Riverpod 3 + codegen”.

## Firebase integration patterns
- Firebase init and platform-specific setup happens before `runApp` (see `lib/main.dart`).
- Chat E2EE keys are stored in device secure storage and published to Firestore (`userKeys` collection). See `lib/features/social/chat_messaging/data/crypto/chat_crypto_service.dart`.
- Auth readiness is explicitly tracked (see `authReadyProvider` usage in `lib/main.dart` and logic in `auth_provider.dart`). Avoid routing decisions before readiness.

## Common “gotchas” in this repo
- Web vs mobile: some features are guarded with `kIsWeb` in `lib/main.dart` (background FCM handler, Mobile Ads, cache bootstrap). Keep platform gates when touching these areas.
- Android keystore / secure storage corruption is handled defensively (see `ChatCryptoService` handling `BAD_DECRYPT` and `KeystoreRecoveryHelper` usage in `auth_provider.dart`). Don’t remove these recovery paths.

## Developer workflows (commands & where to look)
- Codegen (Riverpod/Freezed/JsonSerializable):
  - Use `dart run build_runner watch --delete-conflicting-outputs` (see `README.md`).
- Linting is via `flutter analyze` plus `custom_lint` plugin configured in `analysis_options.yaml`.
- Tests:
  - There's a test aggregator in `test/test_runner.dart`.
  - Tests run with a custom `testExecutable` hook in `test/flutter_test_config.dart` that conditionally applies Firebase mocks (`test/mocks/firebase_mock.dart`).
- Cloud Functions (Node 20):
  - Scripts are in `functions/package.json` (notably `npm run serve` for emulators).

## Local runtime notes
- For mobile dev, running on an Android emulator is the common path; Firebase emulator usage is optional and not standardized in this repo.

## When making changes
- Prefer editing from the feature boundary outward: update `data/` (models/repos) first, then provider(s), then UI.
- When introducing new routes, add them to `goRouterProvider` and wrap with `GlobalOverlayManager` if it should participate in the floating overlay system.
