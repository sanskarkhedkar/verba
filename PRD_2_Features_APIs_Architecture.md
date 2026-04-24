# PRD 2: FEATURES, APIs & ARCHITECTURE
**Product:** Verba — AI Language Learning + Translation App  
**Version:** 1.0  
**Status:** Execution Ready  
**Last Updated:** April 2026  

---

## 1. FEATURE BREAKDOWN

---

### 1.1 LEARNING MODULE

#### 1.1.1 Lessons

**Description:**  
AI-generated, goal-personalized language lessons delivered as structured speaking conversations. Lessons are 3–8 minutes long, containing 5–10 speaking prompts. Each lesson has a theme aligned to the user's stated goal (travel, business, casual, culture).

**Lesson Types:**
| Type | Description | Frequency |
|---|---|---|
| **Daily Spoken Lesson** | Core loop — AI prompts user to speak | Daily |
| **Phrase Drill** | Rapid-fire pronunciation of a phrase set | 2–3x/week |
| **Conversation Simulation** | Multi-turn AI dialogue practice | Weekly |
| **Review Lesson** | Spaced repetition of previously weak phrases | Auto-triggered |
| **Cultural Insight** | Text/audio lesson about cultural context | Weekly |

**Lesson Generation Logic:**
1. On lesson request, Verba calls Gemini API with user context:
   - Target language
   - Native language
   - Current level (A1–C2)
   - Goal category (travel, business, casual)
   - Weak phonemes/words from past sessions
   - Lesson history (avoid repetition)
2. Gemini returns structured JSON lesson plan
3. ElevenLabs renders AI tutor voice for all prompts
4. Lesson plays as a sequence of speaking turns

**Lesson Object (Conceptual):**
- Title + theme
- 5–10 `turns`, each with: AI prompt text, AI prompt audio URL, expected user response hint, evaluation criteria

---

#### 1.1.2 Speaking Practice

**The Core Product Loop — MUST EXECUTE FLAWLESSLY**

```
[AI says phrase in target language via ElevenLabs voice]
         ↓
[User sees phrase on screen + phonetic guide]
         ↓
[User taps mic button]
         ↓
[Voice recording begins — waveform animates]
         ↓
[User speaks]
         ↓
[User releases mic / auto-stop after silence]
         ↓
[Audio sent to STT service → transcribed text]
         ↓
[Gemini evaluates: correctness, fluency, confidence score]
         ↓
[Feedback shown: ✅ Great / ⚠️ Almost / ❌ Try again]
         ↓
[If ❌: ElevenLabs plays correct pronunciation slowly]
         ↓
[User can retry or tap "Next"]
         ↓
[Loop continues to next turn]
```

**Mic States:**
- `idle` — Ready to record
- `listening` — Recording in progress (waveform active)
- `processing` — Audio being evaluated (spinner/pulse animation)
- `feedback_success` — Green ring, celebration animation
- `feedback_warning` — Yellow ring, gentle encouragement
- `feedback_error` — Red/orange ring, retry prompt

**Auto-stop Logic:**
- Stop recording after 3 seconds of silence detected
- Maximum recording duration: 15 seconds
- If no speech detected after 5 seconds: show "Tap to speak" prompt

---

#### 1.1.3 Feedback System

**Feedback Dimensions (Evaluated by Gemini):**
| Dimension | Description | Display |
|---|---|---|
| **Accuracy** | Are the right words said? | Word-level highlighting |
| **Pronunciation** | Are phonemes correct? | Phoneme score 0–100 |
| **Fluency** | Is speech natural, not choppy? | Flow bar |
| **Confidence** | Speed, hesitation, volume level | Qualitative label |

**Feedback Display Modes:**
- **Quick mode (default):** Simple emoji + one-line text ("Almost there! Watch your 'G' sound")
- **Detailed mode (premium):** Word-by-word breakdown, phoneme heatmap, ElevenLabs playback at 0.7x speed

**Feedback Copy Patterns:**
- Success: "Perfect! You nailed it." / "Excellent pronunciation!" / "Native-level!"
- Warning: "So close! Try rounding your lips for the 'u'." / "A bit fast — try taking a breath."
- Error: "Let's try again. Listen carefully to the 'ch' sound." / "Not quite — here's the correct way:"

**Retry Logic:**
- Max 3 retries per turn before auto-advancing with learning note saved
- Weak turns flagged for review session

---

#### 1.1.4 Progress Tracking

**User Progress Dimensions:**
| Metric | Description | Storage |
|---|---|---|
| **XP (Experience Points)** | Earned per lesson, accuracy bonus | Firestore user doc |
| **Streak** | Consecutive days practiced | Firestore user doc |
| **Level** | A1 → A2 → B1 → B2 → C1 → C2 | Calculated from XP |
| **Words Learned** | Unique phrases user has ≥70% accuracy on | Firestore progress collection |
| **Weak Spots** | Phonemes/words with <50% accuracy | Firestore weak_spots array |
| **Lesson History** | All completed lessons with scores | Firestore lessons subcollection |

**XP System:**
- Lesson completion: 50 XP base
- Perfect turn: +5 XP per turn
- Streak bonus: +20% XP if streak ≥ 7 days
- Translation bridge completion: +15 XP
- First lesson of the day: +25 XP bonus

**Level Thresholds:**
- Beginner (A1): 0–500 XP
- Elementary (A2): 500–1,500 XP
- Intermediate (B1): 1,500–4,000 XP
- Upper Intermediate (B2): 4,000–10,000 XP
- Advanced (C1): 10,000–25,000 XP
- Mastery (C2): 25,000+ XP

---

### 1.2 TRANSLATION MODULE

#### 1.2.1 Voice Translation

**Description:** Real-time spoken translation. User speaks in their native language; app transcribes, translates, and optionally speaks the translation aloud in the target language.

**Flow:**
```
User taps mic on translation screen
→ App records user speech (STT via Gemini)
→ Transcription displayed
→ Internal Translation API called
→ Translated text displayed
→ ElevenLabs speaks translation (optional — user toggle)
→ "Practice this phrase" CTA appears
```

**UI States:**
- Idle → Recording → Processing → Result
- Language swap button (native ↔ target)
- Speaker button for audio playback

---

#### 1.2.2 Text Translation

**Description:** Classic text-input translation. User types; app shows real-time translation as user types (with 300ms debounce).

**Features:**
- Character-by-character real-time translation (debounced)
- 100+ language support (per Translation API availability)
- Copy to clipboard button
- "Practice this" CTA below result
- Recent translations history (local storage, 20 items)
- Auto-detect source language option

---

#### 1.2.3 Image Translation (OCR)

**Description:** User points camera at text (menu, sign, document) → App overlays translation on image.

**Flow:**
```
User taps camera icon
→ Camera view opens (Google ML Kit OCR initializes)
→ On capture: image processed by ML Kit OCR
→ Text blocks extracted → bounding boxes identified
→ Blocks sent to Translation API
→ Translated text overlaid on original image
→ User can tap a word to see full context translation
→ "Practice these words" CTA for any recognized words
```

**OCR Modes:**
- **Instant scan:** Live camera with auto-detect overlay (premium)
- **Capture & translate:** Take photo → process (free)

---

#### 1.2.4 Face-to-Face Translation (Conversation Mode)

**Description:** Two-person real-time conversation aid. One person speaks in Language A, app translates and speaks in Language B; other person responds in Language B, app translates back to Language A.

**Flow:**
```
User selects two languages (e.g., English ↔ Japanese)
→ Speaker A button displayed (top of screen)
→ Speaker B button displayed (bottom of screen)
→ Either party taps their button, speaks
→ App STTs → translates → ElevenLabs speaks translation
→ Both parties see text translations simultaneously
→ Scroll log of conversation maintained
```

**UX Design Notes:**
- Screen rotates: top half for Person A, bottom half for Person B
- Large, friendly tap buttons — works well in noisy environments
- Auto-language detection option

---

#### 1.2.5 Phrasebook

**Description:** User-curated collection of saved phrases + pre-loaded phrase packs for common scenarios.

**Pre-loaded Packs (free):**
- Travel Basics (50 phrases)
- Restaurant & Food (40 phrases)
- Emergency & Health (30 phrases)

**Premium Packs:**
- Business Essentials (60 phrases)
- Romance & Social (40 phrases)
- Advanced Slang & Culture (50 phrases)

**User Saved Phrases:**
- Any translated/learned phrase can be "saved" to phrasebook
- Organized by language
- ElevenLabs playback for any phrase
- "Practice" button triggers 2-minute drill lesson

---

## 2. AI SYSTEM DESIGN

### 2.1 Gemini API — Usage Patterns

**System Prompt Template (Lesson Generation):**
```
You are Verba's AI language tutor. Your role is to generate a structured speaking lesson.

Context:
- User's native language: [NATIVE_LANG]
- Target language: [TARGET_LANG]
- Current level: [LEVEL]
- Goal: [GOAL_CATEGORY]
- Previous weak spots: [WEAK_SPOTS_ARRAY]
- Lesson theme: [THEME]

Generate a JSON lesson with 7 speaking turns. Each turn must include:
1. "ai_prompt_text": What the AI tutor says (in English/native lang)
2. "target_phrase": The phrase user should repeat/respond in target language
3. "phonetic_guide": IPA or readable phonetic spelling
4. "evaluation_focus": What to evaluate (accuracy/fluency/specific phoneme)
5. "success_feedback": What to say if user succeeds
6. "correction_hint": What to say if user struggles

Response format: Valid JSON only. No markdown.
```

**Feedback Evaluation Prompt:**
```
Evaluate this language learner's pronunciation attempt.

Target phrase: [TARGET_PHRASE] in [TARGET_LANGUAGE]
User's transcribed speech: [USER_TRANSCRIPTION]
Phonetic target: [PHONETIC_TARGET]
Learner level: [LEVEL]

Rate on:
1. Accuracy (0-100): Did they say the right words?
2. Pronunciation (0-100): Were phonemes correct?
3. Fluency (0-100): Was speech natural?

Return: { "accuracy": INT, "pronunciation": INT, "fluency": INT, "feedback_type": "success"|"warning"|"error", "feedback_message": STRING, "correction_note": STRING_OR_NULL }
```

**Conversation Simulation Prompt:**
```
You are roleplaying as [SCENARIO_PERSONA] in [SCENARIO_CONTEXT].
The user is practicing [TARGET_LANGUAGE] at [LEVEL] level.
Respond naturally in [TARGET_LANGUAGE]. Keep responses short (1-2 sentences).
If the user makes a grammar/pronunciation error in their transcription, gently correct it in your response.
Do not break character. Do not explain you are an AI.
```

**Gemini API Call Parameters:**
- Model: `gemini-2.0-flash` (for speed) / `gemini-2.0-pro` for premium users
- Temperature: 0.7 (lesson gen), 0.3 (feedback eval), 0.9 (conversation)
- Max tokens: 1,024 (lesson gen), 256 (feedback), 512 (conversation)
- Response format: JSON mode where possible

---

### 2.2 ElevenLabs API — Usage Patterns

**Primary Use Cases:**
1. **AI Tutor Voice:** All lesson prompts spoken by AI tutor voice
2. **Pronunciation Playback:** Correct pronunciation spoken at normal + slow speed
3. **Translation Readout:** Translated text spoken in target language accent
4. **Phrasebook Playback:** User taps play on any saved phrase

**Voice Configuration:**
- Default AI Tutor Voice: Warm, clear, neutral accent (ElevenLabs voice ID configured per target language)
  - English tutor: voice_id = "configured_english_tutor"
  - Spanish tutor: voice_id = "configured_spanish_tutor"
  - German tutor: voice_id = "configured_german_tutor"
  - (etc. — one per supported language)
- Slow playback: `speed: 0.7` parameter
- Normal playback: `speed: 1.0`
- Clarity emphasis: `stability: 0.8, similarity_boost: 0.7`

**ElevenLabs API Call:**
```
POST https://api.elevenlabs.io/v1/text-to-speech/{voice_id}
{
  "text": "[PHRASE_TO_SPEAK]",
  "model_id": "eleven_turbo_v2",
  "voice_settings": {
    "stability": 0.8,
    "similarity_boost": 0.7,
    "speed": [1.0 or 0.7]
  }
}
Returns: audio/mpeg stream → cache locally → play
```

**Caching Strategy:**
- ElevenLabs audio for lesson phrases should be **pre-generated and cached** during lesson load, not on-demand during user interaction.
- Cache key: `hash(text + voice_id + speed)`
- Cache storage: Local file system (Flutter path_provider)
- Cache TTL: 7 days — refresh if phrase text changes

---

### 2.3 Speech-to-Text (STT) Pipeline

**Primary STT: Gemini Multimodal**
- Send audio blob to Gemini with transcription instruction
- Works well for content-specific evaluation (lesson context aware)
- Used for: lesson speaking turns, vocabulary drills

**Fallback STT: Platform Native**
- iOS: SFSpeechRecognizer (offline capable)
- Android: SpeechRecognizer API
- Used when: Gemini STT fails, poor connectivity, offline mode

**STT Flow:**
```
[User stops speaking]
→ Audio buffer captured (PCM 16kHz, mono)
→ Convert to base64 or upload to temp Firebase Storage
→ Call Gemini: "Transcribe this audio. The expected phrase in [LANG] is [HINT]. Return only the transcription."
→ Receive transcription text
→ Forward to Gemini feedback evaluation
```

**Accuracy Improvement Hints:**
- Pass target phrase as context hint to STT
- Specify language code (`lang: "de-DE"` for German)
- Trim leading/trailing silence before sending

---

## 3. API MAPPING — COMPLETE FEATURE → API TABLE

| Feature | Primary APIs | Secondary APIs | Notes |
|---|---|---|---|
| **Onboarding flow** | Firebase Auth | Firestore | Auth at end of onboarding |
| **Daily speaking lesson** | Gemini (gen) + ElevenLabs (TTS) + Gemini STT | Firebase Storage (audio cache) | Core loop |
| **Pronunciation feedback** | Gemini (eval) | ElevenLabs (correction playback) | JSON eval response |
| **AI conversation simulation** | Gemini (chat) + ElevenLabs (TTS) + Gemini STT | — | Multi-turn |
| **Text translation** | Internal Translation API | — | Real-time, debounced |
| **Voice translation** | Gemini STT + Translation API + ElevenLabs | Platform native STT (fallback) | Full pipeline |
| **Image translation (OCR)** | Google ML Kit (OCR) + Translation API | — | On-device OCR |
| **Face-to-face translation** | Gemini STT + Translation API + ElevenLabs | — | Two-speaker loop |
| **Phrasebook playback** | ElevenLabs | Local cache | Pre-generated |
| **Push notifications** | Firebase Cloud Messaging (FCM) | — | Daily reminder |
| **User authentication** | Firebase Auth | Firestore | Google, Apple, Email |
| **Progress persistence** | Firestore | — | Real-time sync |
| **Lesson personalization** | Gemini + Firestore (context retrieval) | Remote Config (feature flags) | Context-aware gen |
| **Subscription management** | RevenueCat | Firebase Firestore (entitlements sync) | Premium gating |
| **Feature flags** | Firebase Remote Config | — | A/B testing, rollouts |
| **Offline mode** | Platform native STT + local Firestore | — | Graceful degradation |

---

## 4. FIREBASE USAGE — DETAILED SPECIFICATION

### 4.1 Authentication
**Providers Enabled:**
- Google Sign-In (primary on Android)
- Apple Sign-In (primary on iOS, required for App Store)
- Email/Password (fallback)
- Anonymous auth during onboarding (before committed sign-in at screen 14)

**Auth Flow:**
```
App launch
→ Firebase check: is user logged in?
  YES → Skip to home (check Firestore for onboarding completion flag)
  NO → Launch onboarding
     → Screens 1–13: Anonymous Firebase user created on screen 1
     → Screen 14: Convert anonymous user to authenticated account
     → Firestore doc created/merged
```

**Security:** Firebase Auth token sent as Bearer token for any cloud function calls.

---

### 4.2 Firestore — Collections Structure

**Collection: `users`**
```
users/{userId}
  ├── profile (sub-document)
  ├── progress (sub-document)
  ├── settings (sub-document)
  └── subscription (sub-document)

users/{userId}/lessons (sub-collection)
users/{userId}/sessions (sub-collection)  
users/{userId}/saved_phrases (sub-collection)
```

---

### 4.3 Remote Config — Feature Flags

| Flag Key | Type | Default | Purpose |
|---|---|---|---|
| `gemini_model_version` | String | "gemini-2.0-flash" | Switch model without deploy |
| `paywall_variant` | String | "A" | A/B paywall test |
| `free_lesson_limit` | Int | 3 | Free tier lesson cap |
| `onboarding_version` | String | "v1" | Onboarding A/B test |
| `elevenlabs_enabled` | Bool | true | Kill switch for TTS |
| `ocr_enabled` | Bool | true | Kill switch for OCR |
| `bridge_cta_enabled` | Bool | true | Translation → learning CTA |
| `max_retry_count` | Int | 3 | Lesson retry limit |
| `slow_playback_speed` | Float | 0.7 | ElevenLabs slow speed |

---

### 4.4 Firebase Cloud Messaging (FCM)

**Notification Types:**

| Notification ID | Trigger | Message | Deep Link |
|---|---|---|---|
| `daily_reminder` | 24h after last session | "Your streak is waiting! 🔥 Practice [LANG] today." | `/home/learn` |
| `streak_at_risk` | 22h no session | "Don't break your [N]-day streak! 5 min is all it takes." | `/home/learn` |
| `new_lesson_ready` | Weekly | "New lesson: [THEME] in [LANG]. Let's go! 🎯" | `/lesson/new` |
| `milestone_achieved` | On milestone | "🎉 You've learned 50 words in [LANG]!" | `/progress` |
| `re_engagement_d3` | Day 3 no open | "Miss [LANG]? Your plan is waiting." | `/home` |
| `re_engagement_d7` | Day 7 no open | "Don't give up! 3 minutes a day changes everything." | `/home` |

**FCM Token Management:**
- Save FCM token to Firestore on login
- Refresh token on app launch (handle token rotation)
- User can opt out in settings → set `notifications_enabled: false` in Firestore

---

## 5. PAYMENTS — RevenueCat Integration

### 5.1 Product Configuration (RevenueCat Dashboard)

**Products:**
| Product ID | Type | Price (USD) | Price (INR) | Price (EUR) |
|---|---|---|---|---|
| `verba_monthly` | Subscription | $9.99/mo | ₹799/mo | €8.99/mo |
| `verba_annual` | Subscription | $59.99/yr | ₹4,999/yr | €54.99/yr |
| `verba_lifetime` | Non-consumable | $149.99 | ₹12,999 | €129.99 |

**Offerings:**
- `default_offering` — Standard monthly/annual/lifetime (3-option paywall)
- `annual_promo_offering` — Annual highlighted, monthly hidden (for A/B)
- `trial_offering` — 7-day free trial on annual (seasonal promotion)

**Entitlements:**
- `premium_access` — Unlocks all premium features
- `pro_pack_[language]` — Per-language premium content packs (future)

### 5.2 Paywall Placement Strategy

| Placement | Trigger | Offering Shown |
|---|---|---|
| **Onboarding Paywall (Screen 15)** | After social proof | `default_offering` |
| **Lesson Limit Hit** | 3rd lesson on free | `annual_promo_offering` |
| **Feature Gate (Detailed Feedback)** | Tap detailed feedback | `default_offering` |
| **Feature Gate (Conversation Mode)** | Tap conversation | `default_offering` |
| **Settings → Upgrade** | Manual tap | `default_offering` |

### 5.3 Free vs Paid Access Matrix

| Feature | Free | Premium |
|---|---|---|
| Daily lessons (per day) | 3 | Unlimited |
| Speaking turns per lesson | 5 | 10 |
| AI lesson generation | Basic | Advanced (GPT-4 Turbo) |
| Pronunciation feedback detail | Pass/Fail | Phoneme-level breakdown |
| Translation (text) | ✅ Unlimited | ✅ Unlimited |
| Translation (voice) | ✅ 20/day | ✅ Unlimited |
| OCR image translation | ❌ | ✅ |
| Face-to-face mode | ❌ | ✅ |
| ElevenLabs premium voice | ❌ | ✅ |
| Lesson history & export | 7 days | Unlimited |
| Phrasebook packs | 3 free packs | All packs |
| AI conversation simulation | ❌ | ✅ |
| Download lessons offline | ❌ | ✅ |
| Priority AI response time | ❌ | ✅ |

### 5.4 RevenueCat Flutter Integration

**Initialization:**
```dart
await Purchases.configure(
  PurchasesConfiguration("REVENUECAT_API_KEY_PLATFORM")
    ..appUserID = firebaseUserId
);
```

**Entitlement Check:**
```dart
Future<bool> isPremium() async {
  final customerInfo = await Purchases.getCustomerInfo();
  return customerInfo.entitlements.active.containsKey('premium_access');
}
```

**Purchase Flow:**
```dart
Future<void> purchasePackage(Package package) async {
  try {
    final customerInfo = await Purchases.purchasePackage(package);
    if (customerInfo.entitlements.active.containsKey('premium_access')) {
      // Update Firestore user.subscription.is_premium = true
      // Navigate to success screen
    }
  } on PurchasesErrorCode catch (e) {
    // Handle: user_cancelled, payment_pending, etc.
  }
}
```

---

## 6. DATA STRUCTURE — COMPLETE SCHEMAS

### 6.1 User Profile Schema
```json
// users/{userId}
{
  "uid": "string",
  "email": "string",
  "display_name": "string",
  "avatar_url": "string | null",
  "created_at": "timestamp",
  "last_active": "timestamp",
  
  "profile": {
    "native_language": "string (ISO 639-1, e.g., 'en')",
    "target_language": "string (ISO 639-1, e.g., 'de')",
    "current_level": "string (A1|A2|B1|B2|C1|C2)",
    "goal_category": "string (travel|business|casual|culture|academic)",
    "daily_goal_minutes": "number (5|10|15|20)",
    "focus_areas": ["speaking", "vocabulary", "pronunciation"],
    "motivation": "string (travel|career|family|personal|other)",
    "onboarding_complete": "boolean",
    "onboarding_completed_at": "timestamp | null"
  },
  
  "progress": {
    "xp_total": "number",
    "current_level_label": "string",
    "streak_current": "number",
    "streak_longest": "number",
    "streak_last_date": "string (YYYY-MM-DD)",
    "lessons_completed": "number",
    "total_speaking_time_seconds": "number",
    "words_learned_count": "number",
    "weak_spots": ["string (phoneme or word identifiers)"],
    "strong_areas": ["string"]
  },
  
  "settings": {
    "notifications_enabled": "boolean",
    "notification_time": "string (HH:MM)",
    "theme": "string (dark|light|system)",
    "tts_speed": "number (0.7|1.0|1.25)",
    "slow_playback_default": "boolean",
    "haptic_feedback": "boolean",
    "app_language": "string (ISO 639-1)"
  },
  
  "subscription": {
    "is_premium": "boolean",
    "plan_type": "string (free|monthly|annual|lifetime|null)",
    "revenuecat_user_id": "string",
    "subscription_start": "timestamp | null",
    "subscription_end": "timestamp | null",
    "trial_used": "boolean"
  }
}
```

### 6.2 Lesson Schema
```json
// users/{userId}/lessons/{lessonId}
{
  "lesson_id": "string (UUID)",
  "created_at": "timestamp",
  "completed_at": "timestamp | null",
  "status": "string (not_started|in_progress|completed|abandoned)",
  
  "metadata": {
    "title": "string",
    "theme": "string",
    "target_language": "string",
    "level": "string",
    "goal_category": "string",
    "lesson_type": "string (daily|drill|conversation|review|cultural)",
    "estimated_duration_seconds": "number",
    "actual_duration_seconds": "number | null"
  },
  
  "content": {
    "turns": [
      {
        "turn_id": "number (1-10)",
        "ai_prompt_text": "string",
        "ai_prompt_audio_url": "string (ElevenLabs cached URL)",
        "target_phrase": "string (in target language)",
        "phonetic_guide": "string",
        "evaluation_focus": "string",
        "success_feedback": "string",
        "correction_hint": "string"
      }
    ]
  },
  
  "results": {
    "turns_completed": "number",
    "turns_perfect": "number",
    "turns_warning": "number",
    "turns_failed": "number",
    "xp_earned": "number",
    "accuracy_avg": "number (0-100)",
    "pronunciation_avg": "number (0-100)",
    "fluency_avg": "number (0-100)",
    "turn_results": [
      {
        "turn_id": "number",
        "user_transcription": "string",
        "accuracy_score": "number",
        "pronunciation_score": "number",
        "fluency_score": "number",
        "result_type": "string (success|warning|error)",
        "retries": "number",
        "time_taken_seconds": "number"
      }
    ]
  }
}
```

### 6.3 Session Schema
```json
// users/{userId}/sessions/{sessionId}
{
  "session_id": "string (UUID)",
  "session_date": "string (YYYY-MM-DD)",
  "started_at": "timestamp",
  "ended_at": "timestamp | null",
  "duration_seconds": "number",
  
  "activities": [
    {
      "type": "string (lesson|translation|drill|conversation)",
      "ref_id": "string (lesson_id or transaction_id)",
      "started_at": "timestamp",
      "duration_seconds": "number",
      "xp_earned": "number"
    }
  ],
  
  "session_xp_total": "number",
  "streak_maintained": "boolean",
  "daily_goal_met": "boolean",
  "device_info": {
    "platform": "string (ios|android)",
    "app_version": "string",
    "os_version": "string"
  }
}
```

### 6.4 Progress Tracking Schema
```json
// users/{userId}/progress_snapshots/{date}
// Written daily for historical tracking
{
  "date": "string (YYYY-MM-DD)",
  "xp_total": "number",
  "xp_today": "number",
  "streak": "number",
  "lessons_today": "number",
  "accuracy_avg_today": "number",
  "words_learned_total": "number",
  "level": "string",
  "goal_met": "boolean"
}
```

---

## 7. SYSTEM FLOW DIAGRAMS (TEXTUAL)

### 7.1 Core Speaking Loop (Detailed)
```
┌─────────────────────────────────────────────────────────────────┐
│                    SPEAKING LESSON FLOW                         │
└─────────────────────────────────────────────────────────────────┘

1. USER REQUESTS LESSON
   ├── Check Firestore: lesson_count_today < free_limit (or premium)
   ├── If limit hit → show paywall
   └── Proceed to lesson generation

2. LESSON GENERATION
   ├── Fetch user context from Firestore
   │   ├── level, goal, language, weak_spots
   │   └── last_lesson_theme (to avoid repetition)
   ├── Call Gemini API (lesson generation prompt)
   ├── Receive JSON lesson object (7 turns)
   ├── For each turn: call ElevenLabs (pre-generate all audio)
   ├── Cache audio files locally
   └── Display lesson intro screen

3. LESSON TURN LOOP (repeat for each turn)
   ├── Display target phrase + phonetic guide
   ├── Play ElevenLabs audio of AI tutor prompt
   ├── Show mic button (idle state)
   ├── User taps mic → recording begins
   │   ├── Waveform animation starts
   │   ├── Recording timer visible
   │   └── Auto-stop after 3s silence or 15s max
   ├── Audio buffer sent via STT pipeline
   │   ├── Primary: Gemini STT
   │   └── Fallback: Platform native STT
   ├── Transcription received
   ├── Send to Gemini evaluation with context
   ├── Receive: {accuracy, pronunciation, fluency, feedback_type, message}
   ├── DISPLAY FEEDBACK:
   │   ├── SUCCESS: Green ring + mascot celebrate + XP pop + next turn
   │   ├── WARNING: Yellow ring + hint text + retry option
   │   └── ERROR: Red ring + ElevenLabs plays correct pronunciation
   │       ├── Plays at 1.0x speed
   │       ├── Plays at 0.7x speed
   │       └── User retries (max 3 retries before auto-advance)
   └── Advance to next turn

4. LESSON COMPLETION
   ├── Summary screen: turns %, XP earned, streak status
   ├── Write lesson result to Firestore
   ├── Update user progress doc (XP, streak, words_learned)
   ├── Check for milestone achievements
   └── Show share / continue options
```

### 7.2 Translation → Learning Bridge Flow
```
┌─────────────────────────────────────────────────────────────────┐
│              TRANSLATION → LEARNING BRIDGE                      │
└─────────────────────────────────────────────────────────────────┘

USER OPENS TOOLS TAB
   ↓
Selects translation mode (text/voice/image)
   ↓
Performs translation
   ↓
Translation result displayed
   ↓
System checks:
   ├── Is translated language = user's target learning language?
   │   YES → Show "Practice This" CTA (animated, prominent)
   │   NO → Show "Start learning [detected lang]?" softer CTA
   └── Is user premium or free?
       └── Premium → Full bridge lesson
           Free → Teaser lesson (2 turns) → Paywall

USER TAPS "PRACTICE THIS"
   ↓
Micro-lesson generated around the exact translated phrase
(Gemini prompt: "Create a 3-turn drill for this phrase: [PHRASE]")
   ↓
Inline bottom sheet: mini speaking lesson
   ↓
User completes → +15 XP "Translation Practice Bonus"
   ↓
"Great! This phrase is now saved to your phrasebook."
   ↓
Return to translation screen
```

### 7.3 Onboarding Funnel (Data Collection Map)
```
┌─────────────────────────────────────────────────────────────────┐
│                    ONBOARDING DATA FLOW                         │
└─────────────────────────────────────────────────────────────────┘

Screen 1: Welcome
  → [Collect nothing] → Build excitement

Screen 2: Language Selection
  → [target_language] stored in local state

Screen 3: Skill Level
  → [current_level] stored in local state

Screen 4: Motivation
  → [goal_category] stored in local state

Screen 5: Daily Goal
  → [daily_goal_minutes] stored in local state

Screen 6: Focus Area
  → [focus_areas[]] stored in local state

Screen 7: Confidence Graph
  → [Display only] → "Here's where learners typically are"

Screen 8: Speed Comparison
  → [Display only] → "You'll speak 3x faster with Verba"

Screen 9: Plan Loader
  → [All local state → build personalized plan display]
  → Firebase Anonymous Auth created here

Screen 10: Outcome Preview
  → [Display only] → "In 30 days you'll be able to..."

Screen 11: Social Proof
  → [Display only] → Testimonials + ratings

Screen 12: Notifications
  → [notification_time] stored if opted in
  → FCM token requested

Screen 13: Name Input
  → [display_name] stored in local state

Screen 14: Auth Screen
  → Google / Apple / Email sign-in
  → Anonymous user converted to authenticated
  → ALL local state written to Firestore in single batch write

Screen 15: Paywall
  → RevenueCat offerings loaded
  → Conversion event tracked (Analytics)
  → Purchase or skip → navigate to home
```

---

*End of PRD 2: Features, APIs & Architecture*
