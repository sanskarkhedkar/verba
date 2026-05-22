# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Verba is a translation-first AI language learning Flutter app targeting iOS, Android, and web. It uses Google Gemini for AI lesson generation and speech evaluation, ElevenLabs for text-to-speech, and Firebase for auth/persistence. RevenueCat handles in-app subscriptions.

## Commands

```bash
# Install dependencies
flutter pub get

# Run on connected device
flutter run

# Run on specific device
flutter run -d <device_id>

# Build
flutter build apk          # Android APK
flutter build aab          # Android App Bundle
flutter build ios
flutter build web

# Tests
flutter test               # All tests
flutter test test/widget_test.dart   # Single file

# Lint and format
flutter analyze
dart format lib/
dart fix --apply
```

## Architecture

Clean architecture with feature-based structure under `lib/`:

- **`core/`** — Shared infrastructure used across all features
  - `constants/` — API endpoints (`api_constants.dart`), XP values/timeouts (`app_constants.dart`), GoRouter route names (`route_constants.dart`)
  - `services/` — All external API and Firebase integrations (see below)
  - `theme/` — Design system: dark palette (`app_colors.dart`), Bricolage Grotesque typography (`app_typography.dart`), spacing constants
  - `widgets/` — Reusable components (GlassCard, VerbaButton, XPProgressBar, MascotWidget)

- **`features/`** — Self-contained feature modules, each owning its screens, models, and state
  - `onboarding/` — 15-screen setup flow (ob_01_welcome → ob_15_paywall)
  - `home/` — 4-tab shell (Learn, Speak, Tools, Profile)
  - `learn/` — Core AI lesson engine with mic input, waveform display, and speech feedback
  - `speak/` — Conversation practice mode
  - `tools/` — Text, voice, image, and face-to-face translation screens
  - `profile/` — Progress tracking, achievements, settings
  - `paywall/` — RevenueCat subscription gate

**State management:** Riverpod providers in each feature's `providers/` directory. `service_providers.dart` in `core/services/` declares all service-level providers for dependency injection.

**Routing:** GoRouter configured in `app.dart`.

**Data flow:** User action → Riverpod provider → Service call (HTTP/Firebase) → state update → reactive UI rebuild → async Firestore persistence.

## External Services

| Service | Purpose | Key file |
|---|---|---|
| Google Gemini | AI lesson generation, speech evaluation | `core/services/gemini_service.dart` via Firebase Functions |
| ElevenLabs | Text-to-speech for AI tutor | `core/services/elevenlabs_service.dart` via Firebase Functions |
| Firebase Auth | Google, Apple, Email sign-in | `core/services/auth_service.dart` |
| Firestore | User data and lesson progress | `core/services/firestore_service.dart` |
| Firebase Messaging | Push notifications | `core/services/fcm_service.dart` |
| RevenueCat | Subscription management | `core/services/revenuecat_service.dart` |

Client-safe build values are loaded from `.env` via `flutter_dotenv`: `FIREBASE_ANDROID_API_KEY`, `FIREBASE_IOS_API_KEY`, `REVENUECAT_API_KEY_IOS`, `REVENUECAT_API_KEY_ANDROID`.

Gemini, ElevenLabs, and Google Translate keys must not be bundled in Flutter. They are Firebase Functions secrets consumed by the callable functions in `functions/index.js`: `GEMINI_API_KEY`, `ELEVENLABS_API_KEY`, `GOOGLE_TRANSLATE_API_KEY`.

## Key Specs

Four PRD documents at the root contain the authoritative feature specifications:
- `PRD_2_Features_APIs_Architecture.md` — API contracts, lesson generation logic, data models
- `PRD_3_UI_UX_Specification.md` — Design system, screen specs, component behavior
- `PRD_4_Animations_Motion.md` — Motion design and transitions
- `Implementation_Plan.md` — Phase-by-phase build plan (source of truth for what's in progress)

## Current Status

Several AI integrations are partially stubbed — `gemini_service.dart` and `elevenlabs_service.dart` may return mock data in some paths. Test coverage is minimal (one basic widget test). The project does not yet have a git repository initialized.
