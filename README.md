# HERD

A cross‑platform social app built with Flutter and Firebase. HERD focuses on fast, friendly sharing with a modern feed, rich media posts, and real‑time chat. The project is structured for maintainability with Riverpod state management and code generation.

> **Status:** Closed beta / in active development
> **License:** Proprietary — All rights reserved by Jason Beaver. Unauthorized use, reproduction, or distribution is prohibited without explicit permission.

---

## Table of contents

* [Highlights](#highlights)
* [Tech stack](#tech-stack)
* [Architecture & folder layout](#architecture--folder-layout)
* [Feeds](#feeds)
* [Babble — chat](#babble--chat)
* [Security & privacy](#security--privacy)
* [Backend Functions](#backend-functions)
* [Getting started](#getting-started)
* [Local development (optional)](#local-development-optional)
* [Testing & quality](#testing--quality)
* [Status & roadmap](#status--roadmap)
* [License](#license)

---

## Highlights

* Email/password auth (Firebase Auth)
* **Dual‑feed system**: Alt (anonymous, global), Herds (sub‑communities), and Public (real‑identity social)
* Post creation/editing with **image/video uploads** and **media processing/compression** ✅
* Personalized feed with reactions & comments
* **Offline caching** for posts and media ✅
* **Babble**: real‑time chat with a stretchy "drag‑out" bubble overlay (haptics on mobile), 1:1 and group chats 🛠️
* Push notifications (FCM)
* Light/dark theme with responsive design

## Tech stack

* **Client:** Flutter (Dart), Riverpod 2.x, GoRouter, Freezed, JsonSerializable
* **Backend:** Firebase Auth, Firestore, Cloud Storage, Cloud Functions
* **Tooling:** FlutterFire CLI, build\_runner
* **Platforms:** Android, iOS, Web (port in progress), Desktop (Linux/Windows)

## Architecture & folder layout

```
lib/
  core/               # Core services, bootstrap, utils, themes, widgets
    services/         # app_check_service(…platform), cache & media cache, logging, image helper
    utils/            # router, signed URL, validators, hot algorithm, etc.
  features/
    community/        # herds, moderation, search
    content/          # create_post, drafts, post, rich_text_editing
    social/           # chat_messaging, comment, feed, floating_buttons, mentions, notifications
    ui/               # customization, navigation
    user/             # auth, edit_user, settings, user_profile
  shared/             # behaviors, controls, converters, extensions, styles
  screens/            # splash
  firebase_options.dart
  main.dart
```

## Feeds

HERD uses a **dual‑feed** approach:

* **Alt feed (global, anonymous):** usernames only; world‑wide visibility (similar to Reddit’s r/All);
* **Herds:** topical sub‑communities with their own mods & rules;
* **Public feed:** follow real people (real names & profile photos) similar to Instagram/Twitter.

Feed ranking uses a time‑decay **hot score**. See `core/utils/hot_algorithm.dart` and Cloud Functions helpers.

## Babble — chat

**Babble** is a playful chat overlay. Drag bubbles from the screen edge with a rubber‑band animation + haptics to open 1:1 or group chats; Herd chats are in progress.

Key pieces (client):

* `features/social/chat_messaging/…`

  * `data/crypto/chat_crypto_service.dart` — identity keys & message crypto
  * `data/repositories/message_repository.dart` — CRUD, encryption, search
  * `view/widgets/*` — overlay, headers, message bubbles, etc.

## Security & privacy

End‑to‑end encryption (E2EE) for chat messages:

* **Key exchange:** X25519
* **Key derivation:** HKDF
* **Cipher:** ChaCha20‑Poly1305 (AEAD)
* **Key storage:** device‑local via `FlutterSecureStorage`

> Note: Group‑chat E2EE fan‑out and device‑multi‑session handling are on the roadmap. Treat E2EE as feature‑complete for 1:1, and in‑progress for groups.

## Backend Functions

```
functions/
  admin_init.js                 # Admin SDK bootstrap
  post_triggers.js              # Post create/delete triggers, media hooks, hot score updates
  notification_functions.js     # FCM sends and digest jobs
  score_functions.js            # Ranking utilities / scheduled recalcs
  user_event_handlers.js        # User lifecycle events
  callable_handlers.js          # Callable HTTPS endpoints
  debug_functions.js            # Dev/testing helpers
  utils.js                      # Shared helpers (hot score, media utils, etc.)
  index.js                      # Function registry
```

## Getting started

1. Install Flutter **3.16+**, Dart **3+**, Node.js **18+**
2. Clone repo & install dependencies:

```bash
git clone https://github.com/LeaveItToBeaver/Herd.git
cd Herd
flutter pub get
```

3. Configure Firebase:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

4. Run code generation:

```bash
dart run build_runner watch -d
```

5. Run the app:

```bash
flutter run -d chrome   # web (port in progress)
flutter run -d android  # or ios / desktop
```

## Local development (optional)

Use Firebase emulators for local backend testing.

## Testing & quality

```bash
flutter analyze
flutter test
dart format .
```

## Status & roadmap

**What’s done**

* ✔️ Media processing/compression on upload (client)
* ✔️ Offline caching for posts/media
* ✔️ Auth, posting, comments, reactions
* ✔️ Herds and community scaffolding (models, repos, screens)

**In progress (1.0 blockers)**

* 🛠️ **Babble**: real‑time chat polish (overlay flows, herd chats, group E2EE)
* 🛠️ **Moderation tools**: dashboards, logs, workflows
* 🛠️ **Web**: port + layout/CSS parity; **CSS‑to‑Dart style interpreter** for custom widgets
* 🛠️ End‑to‑end QA: a11y pass, perf, cold‑start, and E2E tests

**Readiness snapshot (rough)**

* Core content (posts/media/comments): **✅**
* Feeds (alt/herds/public) UI & ranking: **🔶 mostly there**
* Chat (Babble): **🔶 near‑complete client; group/herd polish left**
* Moderation: **🔶 usable MVP screens; flows to finalize**
* Offline & media processing: **✅**
* Web port & CSS interpreter: **🟡 underway**

## License

**All Rights Reserved** — Proprietary software owned by **Jason Beaver**.
No right to copy, modify, merge, publish, distribute, sublicense, or sell any part of this codebase without explicit written permission.

> If you need to reference this repo publicly, keep it as **public‑read, no‑license** or switch to **private**. For clarity, consider adding a `LICENSE.txt` with the proprietary terms above and a `NOTICE` naming Jason Beaver as the copyright holder.

