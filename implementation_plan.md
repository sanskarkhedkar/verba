# Verba — Flutter App Implementation Plan

## Overview

Verba is a hybrid **AI Language Learning + Translation** Flutter app targeting iOS and Android. It features a 15-step high-conversion onboarding funnel, a 5-tab home structure, real-time AI speaking practice, translation utilities, and a freemium paywall.

---

## User Review Required

> [!IMPORTANT]
> **API Keys**: The plan uses OpenAI (GPT-4o), ElevenLabs (TTS), Deepgram (STT), and Google Translate. You'll need to supply API keys. For now, all AI features will be built with mock/stub responses so the UI is fully functional without live keys.

> [!IMPORTANT]
> **Paywall**: Flutter does not have built-in IAP. We'll use the `purchases_flutter` (RevenueCat) package for subscription management on both iOS and Android. You'll need a RevenueCat account and App Store / Play Store product IDs.

> [!WARNING]
> **Phase 1 Only (MVP)**: This plan delivers Phase 1 (Onboarding + Speaking AI + Basic Lessons + Paywall). Phases 2 & 3 are documented but not built yet.

> [!NOTE]
> **State Management**: We'll use **Riverpod** (flutter_riverpod) — it's the current Flutter best practice for complex state.

---

## Tech Stack

| Concern | Package |
|---|---|
| State Management | `flutter_riverpod` |
| Navigation | `go_router` |
| HTTP / API | `dio` + `retrofit` |
| Local Storage | `hive_flutter` |
| Animations | `lottie` + `flutter_animate` |
| Audio Playback | `just_audio` |
| STT | `speech_to_text` |
| TTS (ElevenLabs) | custom `dio` client |
| In-App Purchase | `purchases_flutter` (RevenueCat) |
| Google Fonts | `google_fonts` |
| SVG | `flutter_svg` |
| Permissions | `permission_handler` |
| Image Picker (OCR) | `image_picker` |
| Shared Preferences | `shared_preferences` |

---

## Project Structure

```
lib/
├── main.dart
├── app.dart                      # MaterialApp + GoRouter + ProviderScope
├── core/
│   ├── theme/
│   │   ├── app_theme.dart        # Dark premium theme
│   │   ├── app_colors.dart
│   │   └── app_typography.dart
│   ├── router/
│   │   └── app_router.dart       # GoRouter config
│   ├── constants/
│   │   └── app_constants.dart
│   └── utils/
│       └── extensions.dart
├── features/
│   ├── onboarding/
│   │   ├── models/
│   │   ├── providers/
│   │   │   └── onboarding_provider.dart
│   │   └── screens/
│   │       ├── ob_01_welcome.dart
│   │       ├── ob_02_language.dart
│   │       ├── ob_03_skill_level.dart
│   │       ├── ob_04_motivation.dart
│   │       ├── ob_05_daily_goal.dart
│   │       ├── ob_06_focus_area.dart
│   │       ├── ob_07_confidence_graph.dart
│   │       ├── ob_08_speed_comparison.dart
│   │       ├── ob_09_plan_loader.dart
│   │       ├── ob_10_outcome.dart
│   │       ├── ob_11_social_proof.dart
│   │       ├── ob_12_notifications.dart
│   │       ├── ob_13_name_input.dart
│   │       ├── ob_14_auth.dart
│   │       └── ob_15_paywall.dart
│   ├── home/
│   │   └── screens/
│   │       └── home_screen.dart  # Bottom nav shell
│   ├── learn/
│   │   ├── models/
│   │   ├── providers/
│   │   └── screens/
│   │       └── learn_screen.dart
│   ├── speak/
│   │   ├── models/
│   │   ├── providers/
│   │   │   └── speak_provider.dart
│   │   └── screens/
│   │       └── speak_screen.dart
│   ├── tools/
│   │   ├── providers/
│   │   └── screens/
│   │       ├── tools_screen.dart
│   │       ├── text_translate_screen.dart
│   │       ├── voice_translate_screen.dart
│   │       └── image_translate_screen.dart
│   ├── progress/
│   │   └── screens/
│   │       └── progress_screen.dart
│   └── profile/
│       └── screens/
│           └── profile_screen.dart
├── services/
│   ├── openai_service.dart
│   ├── elevenlabs_service.dart
│   ├── stt_service.dart
│   └── translation_service.dart
└── shared/
    └── widgets/
        ├── gradient_button.dart
        ├── onboarding_scaffold.dart
        └── mascot_widget.dart
```

---

## Proposed Changes

### Phase 1 — Foundation

#### [NEW] `pubspec.yaml`
Full dependency manifest with all packages listed above.

#### [NEW] `lib/core/theme/app_theme.dart`
Dark premium theme — deep navy/purple palette, Inter/Outfit fonts, rounded corners.

#### [NEW] `lib/core/router/app_router.dart`
GoRouter with routes: `/onboarding/:step`, `/home` (shell with 5 tabs).

---

### Phase 1 — Onboarding (15 Screens)

Each screen follows a consistent scaffold:
- Dark gradient background
- Progress indicator (step X of 15)
- Animated mascot (Lottie or custom)
- "Continue" CTA button (gradient)

| Screen | Key UI Elements |
|---|---|
| Welcome | Hero animation, value props, "Start Free Trial" |
| Language Selection | Flag + language grid, search |
| Skill Level | 5-level animated slider |
| Motivation | Icon cards (travel, career, etc.) |
| Daily Goal | Slider 5–20 min |
| Focus Area | Multi-select chips |
| Confidence Graph | Animated line chart |
| Speed Comparison | "10x faster" animated counter |
| Plan Loader | Shimmer + fake progress bar |
| Outcome | 3-month results preview card |
| Social Proof | Star ratings + testimonial cards |
| Notifications | Permission dialog + visual |
| Name Input | Text field |
| Auth | Google / Apple sign-in buttons |
| Paywall | Trial offer, feature list, CTA |

---

### Phase 1 — Home Shell

#### [NEW] `lib/features/home/screens/home_screen.dart`
5-tab bottom navigation:
1. **Learn** — Lesson cards, progress stats
2. **Speak** — AI conversation interface
3. **Tools** — Translation utilities
4. **Progress** — Charts and streaks
5. **Profile** — Settings, subscription

---

### Phase 1 — Speak Tab (AI Conversation)

- Waveform animation (recording)
- Chat bubble UI (user vs AI)
- STT: `speech_to_text` package (device native)
- AI response: mock → OpenAI GPT-4o (stub)
- TTS playback: ElevenLabs API stub
- Correction overlay: pronunciation feedback chip

---

### Phase 1 — Learn Tab

- Lesson card with locked/unlocked state
- Practice modules: vocabulary, phrases
- Daily streak indicator
- XP progress bar

---

### Phase 1 — Tools Tab

- 4 tool cards: Voice, Text, Image, Face-to-Face
- Phrasebook list
- After translate: "Practice this phrase" CTA

---

### Phase 1 — Paywall

- Free trial badge (7 days)
- Feature comparison list
- Monthly / Annual toggle
- RevenueCat purchase integration (stubbed)

---

## Open Questions

> [!IMPORTANT]
> **Do you have API keys ready?** (OpenAI, ElevenLabs, Google Translate, Deepgram) — If not, all AI features will be mocked with realistic fake data and can be swapped in later.

> [!IMPORTANT]
> **RevenueCat**: Do you have a RevenueCat account + product IDs set up, or should the paywall be purely UI-only for now?

> [!NOTE]
> **Authentication**: Should Google/Apple Auth be real (using `firebase_auth`) or mocked for now?

> [!NOTE]
> **Mascot**: Should I generate a custom mascot character image, or use a placeholder?

---

## Verification Plan

### Automated
- `flutter analyze` — no errors
- `flutter build apk --debug` — successful build

### Manual
- Walk through all 15 onboarding screens
- Verify bottom nav tab switching
- Test speak tab recording + mock AI response
- Test tools tab translation (mocked)
- Verify paywall UI renders correctly
