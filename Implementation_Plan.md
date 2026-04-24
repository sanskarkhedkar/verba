# IMPLEMENTATION PLAN: VERBA APP
**Product:** Verba — AI Language Learning + Translation App  
**Version:** 1.0  
**Status:** Approved for Execution  
**Last Updated:** April 2026  

> ⚠️ **CRITICAL:** This document is the source of truth during development. All PRDs (1–4) must be consulted before implementing any feature. Do not skip phases, do not reverse order.

---

## EXECUTION PRINCIPLES

1. **PRDs are law** — Every UI screen, API call, data schema, and animation must match the PRDs exactly. Deviation requires explicit decision and documentation.
2. **Ship each phase as a testable milestone** — Phase 1 must be demo-able before Phase 2 starts.
3. **Build order respects dependencies** — Foundation before feature, backend before frontend, auth before data, skeleton before animation.
4. **No premature optimization** — Build correct first, optimize in Phase 3.
5. **Test at every checkpoint** — Do not proceed past a checkpoint without passing its criteria.

---

## PROJECT STRUCTURE (Flutter)

```
verba/
├── lib/
│   ├── main.dart
│   ├── app.dart                    ← MaterialApp + routing + theme
│   ├── core/
│   │   ├── theme/
│   │   │   ├── app_colors.dart     ← All color constants from PRD 3
│   │   │   ├── app_typography.dart ← Bricolage Grotesque text styles
│   │   │   ├── app_theme.dart      ← ThemeData configuration
│   │   │   └── app_spacing.dart    ← Spacing constants
│   │   ├── constants/
│   │   │   ├── api_constants.dart  ← API endpoints, keys (env vars)
│   │   │   ├── app_constants.dart  ← XP values, limits, timeouts
│   │   │   └── route_constants.dart
│   │   ├── utils/
│   │   │   ├── extensions.dart
│   │   │   ├── validators.dart
│   │   │   └── helpers.dart
│   │   ├── widgets/               ← Shared reusable widgets
│   │   │   ├── verba_button.dart
│   │   │   ├── glass_card.dart
│   │   │   ├── gradient_text.dart
│   │   │   ├── mascot_widget.dart
│   │   │   └── xp_progress_bar.dart
│   │   └── services/              ← Service layer (API clients)
│   │       ├── gemini_service.dart
│   │       ├── elevenlabs_service.dart
│   │       ├── stt_service.dart
│   │       ├── translation_service.dart
│   │       ├── auth_service.dart
│   │       ├── firestore_service.dart
│   │       ├── fcm_service.dart
│   │       └── revenuecat_service.dart
│   │
│   ├── features/
│   │   ├── onboarding/
│   │   │   ├── models/
│   │   │   │   └── onboarding_state.dart
│   │   │   ├── providers/
│   │   │   │   └── onboarding_provider.dart
│   │   │   └── screens/
│   │   │       ├── ob_01_welcome.dart
│   │   │       ├── ob_02_language.dart
│   │   │       ├── ob_03_skill_level.dart
│   │   │       ├── ob_04_motivation.dart
│   │   │       ├── ob_05_daily_goal.dart
│   │   │       ├── ob_06_focus_area.dart
│   │   │       ├── ob_07_confidence_graph.dart
│   │   │       ├── ob_08_speed_comparison.dart
│   │   │       ├── ob_09_plan_loader.dart
│   │   │       ├── ob_10_outcome_preview.dart
│   │   │       ├── ob_11_social_proof.dart
│   │   │       ├── ob_12_notifications.dart
│   │   │       ├── ob_13_name_input.dart
│   │   │       ├── ob_14_auth.dart
│   │   │       └── ob_15_paywall.dart
│   │   │
│   │   ├── home/
│   │   │   ├── screens/
│   │   │   │   └── home_screen.dart
│   │   │   └── widgets/
│   │   │       ├── streak_widget.dart
│   │   │       ├── daily_lesson_card.dart
│   │   │       └── progress_mini_chart.dart
│   │   │
│   │   ├── learn/
│   │   │   ├── models/
│   │   │   │   ├── lesson.dart
│   │   │   │   └── lesson_turn.dart
│   │   │   ├── providers/
│   │   │   │   └── lesson_provider.dart
│   │   │   └── screens/
│   │   │       ├── lesson_list_screen.dart
│   │   │       ├── lesson_screen.dart
│   │   │       └── lesson_complete_screen.dart
│   │   │   └── widgets/
│   │   │       ├── mic_button.dart
│   │   │       ├── waveform_widget.dart
│   │   │       ├── feedback_overlay.dart
│   │   │       └── turn_prompt_card.dart
│   │   │
│   │   ├── tools/
│   │   │   ├── screens/
│   │   │   │   ├── tools_screen.dart
│   │   │   │   ├── text_translation_screen.dart
│   │   │   │   ├── voice_translation_screen.dart
│   │   │   │   ├── image_translation_screen.dart
│   │   │   │   └── face_to_face_screen.dart
│   │   │   └── widgets/
│   │   │       ├── translation_result_card.dart
│   │   │       ├── language_selector.dart
│   │   │       └── practice_bridge_cta.dart
│   │   │
│   │   ├── speak/
│   │   │   └── screens/
│   │   │       ├── speak_home_screen.dart
│   │   │       └── conversation_screen.dart
│   │   │
│   │   ├── profile/
│   │   │   └── screens/
│   │   │       ├── profile_screen.dart
│   │   │       ├── progress_screen.dart
│   │   │       ├── achievements_screen.dart
│   │   │       └── settings_screen.dart
│   │   │
│   │   └── paywall/
│   │       └── screens/
│   │           └── paywall_screen.dart
│   │
├── assets/
│   ├── rive/
│   │   ├── vern_mascot.riv
│   │   ├── ui_elements.riv
│   │   └── celebrations.riv
│   ├── lottie/
│   │   ├── plan_loading.json
│   │   ├── confetti.json
│   │   ├── bell_notification.json
│   │   └── sparkle.json
│   ├── fonts/
│   │   └── BricolageGrotesque/
│   │       └── [variable font or 400/600/700/800 weights]
│   └── images/
│       └── flags/ [country flag assets]
│
├── test/
│   ├── unit/
│   ├── widget/
│   └── integration/
│
├── pubspec.yaml
├── .env                           ← API keys (gitignored)
└── firebase.json
```

---

## DEPENDENCIES (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.5.0
  riverpod_annotation: ^2.3.0
  
  # Firebase
  firebase_core: ^2.27.0
  firebase_auth: ^4.17.3
  cloud_firestore: ^4.16.0
  firebase_messaging: ^14.8.0
  firebase_remote_config: ^4.4.0
  firebase_storage: ^11.7.0
  
  # Authentication
  google_sign_in: ^6.2.1
  sign_in_with_apple: ^6.0.0
  
  # AI/APIs
  google_generative_ai: ^0.4.3
  http: ^1.2.1
  dio: ^5.4.3
  
  # Speech
  record: ^5.1.0              # Audio recording
  just_audio: ^0.9.37         # Audio playback (ElevenLabs TTS)
  speech_to_text: ^6.6.0      # Platform native STT fallback
  fftea: ^1.3.0               # FFT for waveform visualization
  permission_handler: ^11.3.0
  
  # Payments
  purchases_flutter: ^7.3.3   # RevenueCat
  
  # OCR
  google_mlkit_text_recognition: ^0.13.1
  camera: ^0.10.5+9
  
  # Animations
  rive: ^0.13.6
  lottie: ^3.1.0
  
  # Navigation
  go_router: ^13.2.0
  
  # Local Storage
  shared_preferences: ^2.2.3
  flutter_secure_storage: ^9.0.0  # API keys in secure storage
  path_provider: ^2.1.3
  hive_flutter: ^1.1.0           # Local lesson cache
  
  # UI Utilities
  flutter_svg: ^2.0.10+1
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0
  haptic_feedback: ^0.5.0
  
  # Utilities
  uuid: ^4.4.0
  intl: ^0.19.0
  connectivity_plus: ^6.0.3
  package_info_plus: ^8.0.0
```

---

## PHASE 1: ONBOARDING + CORE SPEAKING LOOP
**Duration:** Weeks 1–8  
**Goal:** Fully functional onboarding → auth → first speaking lesson  
**Demo Criteria:** A new user can install the app, complete onboarding, sign in, and complete one AI-generated speaking lesson with pronunciation feedback.

---

### PHASE 1 — TASK BREAKDOWN

#### 1.1 PROJECT SETUP (Week 1)
**Frontend (Flutter):**
- [ ] Initialize Flutter project with correct package name (`com.verba.app`)
- [ ] Configure `pubspec.yaml` with all dependencies (see above)
- [ ] Set up folder structure exactly as specified in Project Structure section
- [ ] Add Bricolage Grotesque font (variable weight recommended)
- [x] Implement `AppColors` class — all color constants from PRD 3 design system
- [x] Implement `AppTypography` class — all text styles from PRD 3
- [x] Implement `AppTheme.darkTheme` using color + typography classes
- [x] Implement `AppSpacing` constants
- [x] Create `GlassCard` widget (glassmorphism as per PRD 3 spec)
- [x] Create `VerbaButton` gradient button widget (with press animation per PRD 4)
- [x] Configure `go_router` with all route paths defined upfront
- [x] Set up `.env` file reading (flutter_dotenv or similar) for API keys

**Backend (Firebase):**
- [ ] Create Firebase project: `verba-prod`
- [ ] Enable Authentication providers: Google, Apple, Email/Password, Anonymous
- [ ] Configure Firestore in production mode
- [ ] Set up Firestore security rules (deny all by default → allow per auth)
- [ ] Add `google-services.json` (Android) + `GoogleService-Info.plist` (iOS)
- [ ] Deploy initial Remote Config with all flag keys from PRD 2 Section 4.3 (defaults)

**Verification Checkpoint 1.1:**
- App launches to blank screen without crash
- Theme colors and fonts visible correctly
- Firebase connection confirmed (no initialization error)

---

#### 1.2 ONBOARDING FLOW — SCREENS 1–8 (Weeks 2–3)
**Frontend (Flutter):**
- [x] Create `OnboardingState` model (holds all collected data fields)
- [x] Create `onboarding_provider.dart` (Riverpod StateNotifier)
- [ ] Implement `OnboardingRouter` — manages screen-to-screen navigation within onboarding
- [x] Build `ob_01_welcome.dart` — language grid, CTA, Lottie mascot placeholder
- [x] Build `ob_02_language.dart` — full language list, search functionality
- [x] Build `ob_03_skill_level.dart` — auto-advance on tap, 5 options
- [x] Build `ob_04_motivation.dart` — 7 tappable options, auto-advance
- [x] Build `ob_05_daily_goal.dart` — 4 options, recommended badge on 10min
- [x] Build `ob_06_focus_area.dart` — multi-select grid (2-col), CTA enables at ≥1
- [x] Build `ob_07_confidence_graph.dart` — animated line chart (Flutter CustomPainter)
- [x] Build `ob_08_speed_comparison.dart` — animated counter widgets
- [x] Progress bar widget: thin linear indicator, fills screen-by-screen
- [ ] Back navigation: swipe-right gesture + back icon on each screen
- [x] Screen entry animation: slide-up + fade (use `AnimatedSwitcher` or custom)

**Verification Checkpoint 1.2:**
- All 8 screens render correctly to design spec
- Data flows correctly through OnboardingProvider (verify with debug print)
- Progress bar fills at correct percentages
- Auto-advance works on Screens 3, 4, 5
- Font and colors match PRD 3 exactly

---

#### 1.3 ONBOARDING FLOW — SCREENS 9–13 (Week 3)
**Frontend (Flutter):**
- [x] Build `ob_09_plan_loader.dart` — animated checklist, 4s timing, auto-advance
  - Implement staggered item animation (500ms delays)
  - Implement progress ring (CustomPainter arc)
  
**Backend (Firebase):**
- [ ] On Plan Loader screen entry: call `FirebaseAuth.instance.signInAnonymously()`
- [ ] Store anonymous UID in OnboardingProvider state
- [x] Implement `AuthService.signInAnonymously()` method

**Frontend (Flutter) continued:**
- [x] Build `ob_10_outcome_preview.dart` — dynamic outcomes based on motivation  
  - Create outcome mapping: motivation → list of outcomes
- [x] Build `ob_11_social_proof.dart` — PageView with 3 testimonial cards, rating display
- [x] Build `ob_12_notifications.dart` — FCM permission request, time picker
  - Implement FCM permission request flow
  - Native time picker widget
  - Store `notification_time` in OnboardingProvider
- [x] Build `ob_13_name_input.dart` — auto-focus text field, CTA enables at ≥2 chars

**Verification Checkpoint 1.3:**
- Anonymous Firebase Auth created on Screen 9 (verify in Firebase Console)
- FCM permission request works on both iOS and Android
- All screens 9–13 render correctly
- Name input validation works

---

#### 1.4 AUTHENTICATION SCREEN (Week 4)
**Frontend (Flutter):**
- [x] Build `ob_14_auth.dart` — Google, Apple, Email/Password options
- [x] Implement Google Sign-In flow (`google_sign_in` + Firebase credential link)
- [x] Implement Apple Sign-In flow (`sign_in_with_apple` + Firebase credential link)
- [x] Implement Email/Password registration (with validation)
- [x] On successful auth: link anonymous account to new credentials (preserve anonymous data)

**Backend (Firebase):**
- [ ] On auth success: batch write all OnboardingProvider state to Firestore
  - Create `users/{uid}` document
  - Write `profile`, `progress`, `settings`, `subscription` sub-documents
  - Set `onboarding_complete: false` (set to true after paywall screen)
- [ ] Implement `FirestoreService.createUserProfile(uid, onboardingState)` method
- [ ] Set FCM token on user document: `users/{uid}/fcm_token`

**Verification Checkpoint 1.4:**
- Google Sign-In works on Android
- Apple Sign-In works on iOS  
- User profile created in Firestore with all onboarding data
- Anonymous account successfully linked/converted

---

#### 1.5 PAYWALL SCREEN (Week 4)
**Frontend (Flutter):**
- [ ] Initialize RevenueCat SDK in `main.dart` with platform API keys
- [ ] Implement `RevenueCatService` class:
  - `getOfferings()` — fetch available packages
  - `purchasePackage(package)` — handle purchase
  - `restorePurchases()` — for restore button
  - `isPremium()` — check current entitlement
- [x] Build `ob_15_paywall.dart` — annual/monthly/lifetime options per PRD 3 spec
  - Annual card highlighted with gradient border
  - Price displays loading state while RevenueCat loads
  - "Continue with limited access" skip option
- [ ] On purchase success: update `users/{uid}/subscription.is_premium = true` in Firestore
- [ ] On skip: mark `onboarding_complete: true`, navigate to home

**Verification Checkpoint 1.5:**
- RevenueCat initializes without error (use sandbox/test mode)
- Offerings load and display correctly
- Sandbox purchase completes successfully
- Entitlement is reflected in app state after purchase
- Skip navigates to home correctly

---

#### 1.6 CORE SERVICES LAYER (Weeks 4–5)
**AI Services:**
- [x] Implement `GeminiService`:
  - `generateLesson(userContext)` — calls Gemini 2.0 Flash with lesson gen prompt from PRD 2
  - `evaluateSpeech(turnContext, transcription)` — calls feedback eval prompt
  - `transcribeAudio(file, languageHint)` — Gemini multimodal STT
  - Proper JSON parsing and error handling with fallback lesson
- [x] Implement `ElevenLabsService`:
  - `speak(text, language)` / `speakSlow(text, language)` — POST to ElevenLabs API
  - Voice mapping table per language
  - Per-session in-memory cache (path_provider temp files)
- [x] Implement `SttService`:
  - `transcribeAudio(File audioFile, String languageHint)` — primary Gemini multimodal STT
  - `_transcribeNative(language)` — speech_to_text package fallback
  - Unified interface with automatic fallback

**Data Services:**
- [ ] Implement `FirestoreService`:
  - `getUserProfile(uid)` — streams user document
  - `updateProgress(uid, xpGained, streakDate)` — atomic update
  - `saveLesson(uid, lesson)` — write lesson result
  - `getRecentLessons(uid, limit)` — fetch lesson history
  - `updateSubscription(uid, subscriptionData)` — update sub status

**Verification Checkpoint 1.6:**
- Gemini API returns valid JSON lesson (test with hardcoded user context)
- ElevenLabs generates and plays audio correctly
- STT transcribes a test recording correctly
- Firestore read/write operations work with security rules

---

#### 1.7 LESSON SCREEN — CORE LOOP (Weeks 5–7)
**Frontend (Flutter):**
- [x] Build `LessonProvider` (Riverpod):
  - State: current turn index, lesson object, turn results, mic state
  - Methods: `loadLesson()`, `startRecording()`, `stopRecording()`, `submitEvaluation()`
- [x] Build `lesson_screen.dart`:
  - Header: close button + turn counter + progress bar
  - Phrase display card: target phrase + phonetic guide (glass card per PRD 3)
  - "Listen" button → plays ElevenLabs audio for this turn
  - VERN mascot widget (Rive — idle state initially)
  - Mic button widget with all 5 states (idle/listening/processing/success/error)
  - Waveform widget (CustomPainter, 5 bars, amplitude animation)
  - Feedback overlay widget
- [x] Implement `MicButton` widget:
  - Tap handler (not hold — tap to start, tap again to stop, or auto-stop)
  - State-driven visual changes per PRD 4 spec
  - Ring glow animations (Rive `ui_elements.riv` or Flutter Animation)
- [x] Implement `WaveformWidget` (CustomPainter):
  - FFT processing from audio stream
  - 5-bar visualization per PRD 4 spec
  - 30fps update rate
- [x] Implement `FeedbackOverlay` widget:
  - Animated entry (slide up + fade)
  - Success / Warning / Error visual states per PRD 3
  - XP pop animation
  - Retry / Next buttons
- [x] Wire full speaking loop sequence per PRD 2 System Flow Diagram 7.1
- [x] Audio pipeline:
  - `record` package for microphone capture
  - Request microphone permission
  - 3-second silence auto-stop (amplitude monitoring)
  - 15-second max duration
  - Encode as PCM/WAV for STT submission
- [x] Pre-load all ElevenLabs audio on lesson start (not during turn)

**Backend:**
- [ ] After each lesson: write result to `users/{uid}/lessons/{lessonId}`
- [ ] Update `users/{uid}/progress` (XP, streak, words_learned_count)
- [ ] Check and write daily session to `users/{uid}/sessions/{sessionId}`

**Verification Checkpoint 1.7 (CRITICAL):**
- Full speaking loop executes end-to-end without error
- Gemini generates a valid 7-turn lesson
- ElevenLabs audio plays for each turn prompt
- Microphone captures speech correctly
- STT produces transcription
- Gemini evaluates transcription and returns feedback_type
- All 3 feedback states (success/warning/error) display correctly
- VERN mascot transitions between states correctly
- XP pop animation plays on success
- Lesson result written to Firestore

---

#### 1.8 HOME SCREEN + NAVIGATION (Week 8)
**Frontend (Flutter):**
- [x] Build `home_screen.dart` with bottom tab bar (Learn / Speak / Tools / Profile)
- [x] Build `learn_tab.dart`:
  - Greeting header with name + emoji
  - Streak card (XP bar + streak count)
  - Today's lesson card (calls `GeminiService.generateLesson()` on tab load)
  - Continue learning horizontal scroll (placeholder cards initially)
- [x] Build `speak_tab.dart`:
  - Quick practice button
  - Custom phrase practice input
  - Conversation simulator (locked for free users)
  - Speaking stats
- [x] Build `tools_tab.dart`:
  - 2×2 tool grid
  - Quick translate inline widget
  - Recent translations list (from local storage)
- [x] Build `profile_tab.dart`:
  - User info display
  - Progress summary
  - Settings navigation
- [ ] Configure `go_router` deep links for FCM notification targets

**Verification Checkpoint 1.8:**
- Tab navigation works correctly
- Learn tab loads today's lesson card
- Deep links from notifications navigate to correct screens
- No layout overflow errors on small screens (iPhone SE)
- All tabs accessible from bottom bar

---

### PHASE 1 EXIT CRITERIA
Before proceeding to Phase 2, ALL of the following must pass:
1. ✅ Complete onboarding (all 15 screens) runs without crash
2. ✅ Firebase Auth (Google + Apple + Email) works on both platforms
3. ✅ User profile created in Firestore with correct schema
4. ✅ Full speaking lesson loop (7 turns) completes successfully
5. ✅ All 3 feedback states (success/warning/error) function correctly
6. ✅ ElevenLabs audio plays for prompts and corrections
7. ✅ Waveform animates during recording
8. ✅ XP is correctly calculated and saved to Firestore
9. ✅ RevenueCat paywall loads and sandbox purchase works
10. ✅ App does not crash on 5 consecutive lesson attempts

---

## PHASE 2: TRANSLATION TOOLS + LEARNING BRIDGE
**Duration:** Weeks 9–14  
**Goal:** All 4 translation tools functional + "Practice This" bridge CTA working  
**Demo Criteria:** User can translate text/voice/image, and tap "Practice This" to enter a speaking mini-lesson.

---

### PHASE 2 — TASK BREAKDOWN

#### 2.1 TEXT TRANSLATION (Week 9)
- [ ] Implement `TranslationService.translateText(text, sourceLang, targetLang)`
- [ ] Build `text_translation_screen.dart`:
  - Source text input (glass styled, auto-focus)
  - Language selector dropdown (swap button)
  - Real-time translation (300ms debounce)
  - Result card with glassmorphism styling
  - Copy / Save / 🔊 (ElevenLabs) / Practice CTA
- [ ] Implement `practice_bridge_cta.dart` widget:
  - Animated gradient border button
  - On tap: opens bottom sheet mini-lesson
  - Mini-lesson: 3-turn drill via Gemini for the exact phrase
- [ ] Save recent translations to local Hive storage (20 item ring buffer)

#### 2.2 VOICE TRANSLATION (Week 10)
- [ ] Build `voice_translation_screen.dart`:
  - Language pair header with swap
  - Large mic button ("Speak to translate")
  - STT → Translation API → result display pipeline
  - Optional ElevenLabs readout (toggle)
  - Practice bridge CTA on result
- [ ] Implement voice translation pipeline (STT → Internal API → ElevenLabs optional)
- [ ] Free tier: track voice translation count (Remote Config limit)

#### 2.3 IMAGE TRANSLATION — OCR (Week 11)
- [ ] Implement `MlKitOcrService.extractText(imagePath)` using `google_mlkit_text_recognition`
- [ ] Build `image_translation_screen.dart`:
  - Camera capture mode (using `camera` package)
  - Gallery pick fallback
  - Processing state (overlay shimmer on image)
  - OCR text blocks → Translation API → overlay
  - Tap individual word for context translation
  - Practice CTA for recognized words
- [ ] Handle multiple text blocks with bounding box overlay

#### 2.4 FACE-TO-FACE TRANSLATION (Week 12)
- [ ] Build `face_to_face_screen.dart`:
  - Split screen (top/bottom for two speakers)
  - Large tap buttons per PRD 3 spec
  - STT → Translation → ElevenLabs per speaker turn
  - Conversation log scroll view
- [ ] Implement two-speaker translation pipeline

#### 2.5 PHRASEBOOK (Week 13)
- [ ] Build `phrasebook_screen.dart`:
  - Pre-loaded packs (Travel, Restaurant, Emergency)
  - Saved phrases from user translations/lessons
  - ElevenLabs playback per phrase
  - "Practice" button → 2-min drill
- [ ] Load premium packs behind premium gate
- [ ] Implement phrase save flow (from translation and lesson screens)

#### 2.6 PUSH NOTIFICATIONS (Week 13)
- [ ] Implement `FcmService`:
  - Token registration + Firestore save
  - Foreground message handling
  - Background message handling (Firebase background handler)
  - Deep link routing from notification payload
- [ ] Set up Firebase Cloud Functions (or schedule via App Check):
  - `sendDailyReminder` — queries users where streak_last_date < today-1
  - `sendStreakAtRisk` — queries users 22h without session
- [ ] Test notification delivery on both platforms

#### 2.7 TRANSLATION → BRIDGE INTEGRATION (Week 14)
- [ ] Implement bridge detection logic (PRD 2 Section 7.2):
  - Check if translated language = user's target learning language
  - Determine premium vs free bridge experience
- [ ] Wire "Practice This" CTA across all translation modes
- [ ] Implement mini-lesson bottom sheet (3-turn drill)
- [ ] Award +15 XP "Translation Practice Bonus" on bridge completion
- [ ] Add bridge phrase to phrasebook automatically

**Phase 2 Verification Checkpoints:**
- All 4 translation tools work end-to-end
- OCR successfully extracts and translates menu/sign text
- Bridge CTA appears after translation and launches mini-lesson
- Push notifications delivered on Android and iOS
- Phrasebook saves and plays phrases correctly

---

## PHASE 3: PAYMENTS, POLISH & OPTIMIZATION
**Duration:** Weeks 15–18  
**Goal:** Production-ready, submission-ready build  

---

### PHASE 3 — TASK BREAKDOWN

#### 3.1 PREMIUM GATING (Week 15)
- [ ] Implement premium check wrapper widget (`PremiumGate`)
- [ ] Apply premium gate to all restricted features per PRD 2 Section 5.3
- [ ] Implement lesson limit enforcement (Remote Config `free_lesson_limit`)
- [ ] Implement voice translation daily limit enforcement
- [ ] Wire all paywall trigger points:
  - Lesson limit hit
  - Detailed feedback tap
  - Conversation mode tap
  - OCR translation attempt
  - Settings → Upgrade
- [ ] Test free tier experience end-to-end (verify all gates work)

#### 3.2 ANIMATIONS INTEGRATION (Weeks 15–16)
- [ ] Integrate Rive mascot file when provided by designer
- [ ] Wire all 8 VERN state machine inputs to lesson screen provider states
- [ ] Implement waveform amplitude → Rive number input pipeline
- [ ] Add screen transition animations per PRD 4 (custom `PageTransitionBuilder`)
- [ ] Add button press animations per PRD 4
- [ ] Integrate Lottie files for onboarding screens
- [ ] Implement XP pop animation
- [ ] Implement achievement unlock overlay
- [ ] Performance test animations on mid-range Android device

#### 3.3 OFFLINE + CACHING (Week 16)
- [ ] Implement Firestore offline persistence (`settings.persistenceEnabled = true`)
- [ ] Cache last 5 generated lessons in Hive for offline replay
- [ ] Implement connectivity check → graceful degradation messaging
- [ ] ElevenLabs audio cache validation on app launch (prune expired)

#### 3.4 ANALYTICS + MONITORING (Week 17)
- [ ] Add Firebase Analytics: key event tracking
  - `onboarding_screen_viewed` (screen_name)
  - `onboarding_completed`
  - `lesson_started` (lesson_id, lesson_type)
  - `lesson_completed` (xp_earned, accuracy)
  - `lesson_abandoned` (turn_index)
  - `translation_performed` (type: text/voice/image)
  - `bridge_cta_tapped` (source)
  - `bridge_lesson_completed`
  - `paywall_viewed` (placement)
  - `purchase_initiated` (plan: monthly/annual/lifetime)
  - `purchase_completed` (plan, revenue)
  - `purchase_cancelled`
- [ ] Add Crashlytics (via `firebase_crashlytics` package)
- [ ] Add non-fatal error logging for API failures

#### 3.5 PRODUCT POLISH (Week 17)
- [ ] Complete profile screen (progress detail, achievement list)
- [ ] Complete settings screen (notifications, theme, speech speed, account)
- [ ] Implement account deletion flow (GDPR requirement)
- [ ] Implement restore purchases (RevenueCat `.restorePurchases()`)
- [ ] Add loading skeleton states to all data-fetching screens
- [ ] Add empty states for all lists (no lessons, no saved phrases, etc.)
- [ ] Implement error boundaries with user-friendly error messages
- [ ] Review all strings for typos and consistency
- [ ] Test on smallest supported device (iPhone SE 2nd gen, 375pt width)

#### 3.6 TESTING (Week 18)
- [ ] Unit tests: All service classes (GeminiService, FirestoreService, etc.)
- [ ] Widget tests: Critical components (MicButton, FeedbackOverlay, LessonScreen)
- [ ] Integration test: Full onboarding flow (using `integration_test` package)
- [ ] Integration test: Full speaking lesson loop
- [ ] Integration test: Translation → bridge flow
- [ ] Performance profiling: Lesson screen render time, jank frames
- [ ] Memory leak check: Rive controllers disposed, audio recorders disposed

#### 3.7 SUBMISSION PREP (Week 18)
- [ ] App icons for all required sizes (iOS + Android)
- [ ] Splash screen (Flutter native splash)
- [ ] App Store screenshots (6.5" iPhone, 12.9" iPad, Android Play Store)
- [ ] App store descriptions in English (localizations later)
- [ ] Privacy policy URL
- [ ] Terms of service URL
- [ ] GDPR compliance audit
- [ ] Review Apple App Store guidelines (subscription, in-app purchase)
- [ ] Review Google Play store policies
- [ ] Configure `flutter_flavor` or similar for prod vs dev environments
- [ ] Final build: `flutter build ipa --release` + `flutter build appbundle --release`

---

## 3. DEPENDENCIES MAP

```
Firebase Setup
  ↓
Authentication (Firebase Auth)
  ↓
User Profile Schema (Firestore)
  ↓
Onboarding Flow (collects profile data)
  ↓
Gemini API Integration (GeminiService ready)
  ├── Lesson Generation (depends on user profile in Firestore)
  └── Speech Evaluation (depends on STT service)
      ↓
ElevenLabs API Integration (ElevenLabsService ready)
  ↓
Core Speaking Loop (all 3 AI services operational)
  ↓
Home Screen + Navigation
  ↓
RevenueCat Setup (can be parallel with speaking loop)
  ├── Paywall Screen (depends on RevenueCat offerings)
  └── Premium Gating (depends on entitlement check)
      ↓
Translation Services (Internal Translation API)
  ↓
All Translation Screens
  ↓
Bridge CTA Integration (depends on translation + lesson systems)
  ↓
FCM Push Notifications (parallel — needs user doc for token storage)
  ↓
Analytics + Crashlytics
  ↓
Testing + Polish
  ↓
Production Build + Submission
```

---

## 4. EXECUTION STRATEGY

### Build Order Rationale

**Why Foundation Before Feature:**
Authentication must be established before any data is written. If user profile doesn't exist, progression tracking breaks. If Firestore schema is wrong from the start, every feature that writes data is affected.

**Why AI Services Before Lesson UI:**
The lesson UI is empty shell without AI responses. Building the shell first without testing against real AI responses leads to UI that doesn't match the actual data shape.

**Why Translation Before Bridge:**
The bridge CTA requires a working translation result to appear. The mini-lesson it launches requires the lesson loop (which was built in Phase 1). The bridge is therefore the last feature assembled, from existing building blocks.

**Why Polish in Own Phase:**
Every phase should exit with working features, not perfect features. Polish (animations, error states, loading skeletons) added before core functionality is proven wastes time on features that may need structural changes.

### Integration Order

```
Week 1: Firebase + Theme + Base Widgets
Week 2–3: Onboarding UI (data collection layer)
Week 4: Auth (Firestore write layer)
Week 4: RevenueCat (payment layer — parallel with auth)
Weeks 4–5: AI Services (Gemini + ElevenLabs + STT)
Weeks 5–7: Core Lesson Loop (the heart of the product)
Week 8: Home Screen + Navigation Shell
Week 9: Text Translation
Week 10: Voice Translation
Week 11: OCR
Week 12: Face-to-Face
Week 13: Phrasebook + FCM
Week 14: Bridge Integration
Week 15: Premium Gating
Weeks 15–16: Animations
Week 16: Offline + Caching
Week 17: Analytics + Polish
Week 18: Testing + Submission
```

### Testing Checkpoints (Mandatory Gate Reviews)

| Checkpoint | After | Must Pass Before |
|---|---|---|
| CP-1.1 | Project setup | Any UI work |
| CP-1.2 | OB screens 1–8 | OB screens 9–15 |
| CP-1.3 | OB screens 9–13 | Auth screen |
| CP-1.4 | Auth screen | Paywall |
| CP-1.5 | Paywall | Core services |
| CP-1.6 | Core services | Lesson screen |
| **CP-1.7 (CRITICAL)** | **Full lesson loop** | **Any Phase 2 work** |
| CP-1.8 | Home screen | Any Phase 2 work |
| CP-2.5 | All translation tools | Bridge integration |
| CP-3.1 | Premium gating | Any submission prep |
| CP-3.6 | Full test suite | Submission |

---

## 5. AUTO-EXECUTION INSTRUCTIONS

> These instructions govern how development should proceed during execution. Every engineer and AI agent working on this codebase must follow these in order.

### Pre-Work (Before Writing ANY Code)
1. Read relevant PRD section completely before implementing
2. Check existing code in the feature directory for any existing work
3. Verify the data schema matches PRD 2 before writing Firestore operations
4. Check if a shared widget already exists before creating a new one

### During Development
1. Implement one task from the task list at a time — mark `[/]` when started, `[x]` when done
2. After each task: do a visual sanity check against PRD 3 specs
3. After each service method: write a quick manual test (or unit test)
4. Do NOT write animations before the underlying data/logic is working
5. Commit after each checkpoint passes

### Feature Implementation Order (Per Task)
For each screen/feature:
1. Define the data model first
2. Implement the service layer (API calls, Firestore operations)
3. Build the Riverpod provider (state management)
4. Build the UI widget tree (no animations yet)
5. Wire data to UI
6. Add animations last
7. Test end-to-end
8. Mark checkpoint as passed

### API Keys Management
- All API keys stored in `.env` file (gitignored)
- Loaded via `flutter_dotenv` at app startup
- Sensitive keys (ElevenLabs, Gemini) stored in `flutter_secure_storage` after first app launch
- RevenueCat keys separated by platform (iOS key vs Android key)
- Never hardcode any key in source code

### Blocking Issues Protocol
If any of the following occur, STOP and resolve before continuing:
- Firebase Auth fails to initialize
- Gemini API returns non-JSON response
- ElevenLabs audio fails to play on device
- RevenueCat offerings return null
- Mic permission denied without user prompt (check permission_handler)

---

*End of Implementation Plan*
