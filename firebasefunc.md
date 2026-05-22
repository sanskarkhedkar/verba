# Firebase Functions Migration Notes

This document explains what changed, why it changed, and what you need to do next to deploy the Firebase Functions backend.

## Why This Was Needed

The app was previously using these sensitive API keys from the Flutter client:

- `GEMINI_API_KEY`
- `ELEVENLABS_API_KEY`
- `GOOGLE_TRANSLATE_API_KEY`

Any key bundled into a Flutter mobile or web build can be extracted from the app. Moving these API calls to Firebase Functions keeps the real provider keys on Firebase servers instead of shipping them inside the app.

RevenueCat and Firebase client keys can remain in `.env` because they are client SDK keys, not private backend secrets.

## What Changed

### 1. Added Firebase Functions Backend

New files:

- `firebase.json`
- `.firebaserc`
- `functions/package.json`
- `functions/package-lock.json`
- `functions/index.js`

The Firebase project is configured as:

```json
{
  "default": "verba-translation-app"
}
```

The functions runtime is Node.js 20.

### 2. Added Callable Functions

The backend now exposes callable Firebase Functions for the app:

- `generateLesson`
  - Calls Gemini to generate a 7-turn lesson.

- `evaluateSpeech`
  - Calls Gemini to evaluate pronunciation, accuracy, and fluency.

- `transcribeAudio`
  - Sends recorded WAV audio to Gemini multimodal transcription.

- `detectLanguage`
  - Calls Google Translate language detection.

- `translateText`
  - Calls Google Translate text translation.

- `synthesizeSpeech`
  - Calls ElevenLabs and returns MP3 audio as base64.

All of these functions require the user to be signed into Firebase Auth, including anonymous users.

### 3. Added Flutter Firebase Functions Wrapper

New file:

- `lib/core/services/firebase_functions_service.dart`

This wrapper calls Firebase callable functions from Flutter and normalizes the response into `Map<String, dynamic>`.

### 4. Refactored Existing Flutter Services

Updated files:

- `lib/core/services/gemini_service.dart`
- `lib/core/services/elevenlabs_service.dart`
- `lib/core/services/translation_service.dart`

These services now call Firebase Functions instead of calling Gemini, ElevenLabs, or Google Translate directly.

The rest of the app can keep using the same service methods:

- `generateLesson(...)`
- `evaluateSpeech(...)`
- `transcribeAudio(...)`
- `translateText(...)`
- `speak(...)`
- `speakSlow(...)`

### 5. Removed Sensitive Client Constants

Updated file:

- `lib/core/constants/api_constants.dart`

Removed client-side access to:

- Gemini API key
- ElevenLabs API key
- Google Translate API key
- Direct Gemini endpoint
- Direct ElevenLabs endpoint
- Direct Google Translate endpoint

### 6. Cleaned Local `.env`

The local `.env` was scrubbed so it no longer contains:

- `GEMINI_API_KEY`
- `ELEVENLABS_API_KEY`
- `GOOGLE_TRANSLATE_API_KEY`

Your Flutter `.env` should only keep client-safe values like:

```env
FIREBASE_ANDROID_API_KEY=...
FIREBASE_IOS_API_KEY=...
REVENUECAT_API_KEY_IOS=...
REVENUECAT_API_KEY_ANDROID=...
```

## Request Flow Now

Before:

```text
Flutter app -> Gemini / ElevenLabs / Google Translate directly
```

After:

```text
Flutter app -> Firebase Callable Function -> Gemini / ElevenLabs / Google Translate
```

This means the app only knows the Firebase project config. The actual provider keys live in Firebase Functions secrets.

## What You Need To Do Next

### 1. Install Firebase CLI

If you do not already have it:

```bash
npm install -g firebase-tools
```

Then log in:

```bash
firebase login
```

### 2. Confirm Firebase Project

From the repo root:

```bash
firebase projects:list
firebase use verba-translation-app
```

If `firebase use` fails, run:

```bash
firebase use --add
```

Then select `verba-translation-app`.

### 3. Set Firebase Function Secrets

Run these from the repo root:

```bash
firebase functions:secrets:set GEMINI_API_KEY
firebase functions:secrets:set ELEVENLABS_API_KEY
firebase functions:secrets:set GOOGLE_TRANSLATE_API_KEY
```

Firebase will prompt you to paste each secret value. These values are stored server-side and are not committed to git.

### 4. Install Functions Dependencies

This has already been done locally, but if you are on another machine run:

```bash
cd functions
npm install
cd ..
```

### 5. Deploy Functions

From the repo root:

```bash
firebase deploy --only functions
```

After deploy, Firebase will print the deployed function names.

### 6. Run The Flutter App

Make sure `.env` still has the Firebase and RevenueCat client values, then run:

```bash
flutter pub get
flutter run
```

## Important Firebase Auth Requirement

The functions reject unauthenticated calls. The app already signs users in anonymously during onboarding, so normal app flows should work.

If you test a screen before Firebase Auth has created a user, function calls may fail with:

```text
unauthenticated
```

In that case, complete onboarding or sign in before testing AI, translation, or TTS features.

## Verification Already Done

These checks passed locally:

```bash
flutter analyze
flutter test
node --check functions/index.js
npm audit --audit-level=high
```

`npm audit` still reports moderate advisories inside the Firebase Functions SDK dependency tree. There were no high or critical advisories.

## Files You Should Commit

Commit these new or changed files:

- `.firebaserc`
- `firebase.json`
- `functions/index.js`
- `functions/package.json`
- `functions/package-lock.json`
- `lib/core/services/firebase_functions_service.dart`
- `lib/core/services/gemini_service.dart`
- `lib/core/services/elevenlabs_service.dart`
- `lib/core/services/translation_service.dart`
- `lib/core/constants/api_constants.dart`
- `pubspec.yaml`
- `pubspec.lock`
- `README.md`
- `CLAUDE.md`
- `firebasefunc.md`

Do not commit:

- `.env`
- `functions/node_modules/`
- real API key values

## Quick Deployment Checklist

```text
[x] Firebase CLI installed
[x] Logged in with firebase login
[x] Correct project selected: verba-translation-app
[x] GEMINI_API_KEY secret set
[x] ELEVENLABS_API_KEY secret set
[x] GOOGLE_TRANSLATE_API_KEY secret set
[x] firebase deploy --only functions completed
[ ] Flutter app tested after deploy
```
