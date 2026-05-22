# Verba - AI Language Learning App

Verba is an AI-powered language learning companion built with Flutter. It utilizes cutting-edge AI technologies to provide interactive voice conversations, personalized learning paths, and instant translations, gamifying the language learning journey.

## Features
- **AI Conversations**: Practice speaking with Gemini-powered AI responses.
- **Natural Voice Output**: Uses ElevenLabs TTS for human-like speech.
- **Multi-Modal Translation**: Voice, text, and image (OCR) translation tools.
- **Gamified Learning**: Earn XP, build streaks, and unlock achievements.
- **Premium Subscription**: Handled via RevenueCat.

## Tech Stack
- **Framework**: Flutter
- **State Management**: Riverpod (`flutter_riverpod`)
- **Backend & Auth**: Firebase (Auth, Firestore, Storage, Cloud Functions)
- **AI Models**: Google Gemini (LLM) & ElevenLabs (TTS/Voice)
- **In-App Purchases**: RevenueCat
- **Routing**: go_router

---

## Getting Started

### Prerequisites
Before you begin, ensure you have the following installed:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (latest stable version recommended)
- [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/)
- An active Firebase project
- Firebase CLI access for deploying Cloud Functions
- RevenueCat public SDK keys for app builds

### 1. Clone the repository
```bash
git clone https://github.com/sanskarkhedkar/verba.git
cd verba
git checkout dev
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Environment Variables
The Flutter app should only receive client-safe configuration. Gemini, ElevenLabs,
and Google Translate keys must stay in Firebase Functions secrets, not in `.env`.

Create a `.env` file in the root of the project directory with the following keys:
```env
FIREBASE_ANDROID_API_KEY=your_firebase_android_api_key_here
FIREBASE_IOS_API_KEY=your_firebase_ios_api_key_here
REVENUECAT_API_KEY_IOS=your_revenuecat_ios_key_here
REVENUECAT_API_KEY_ANDROID=your_revenuecat_android_key_here
```

### 4. Firebase Configuration
To connect the app to Firebase, you need to add your platform-specific configuration files:
- **Android**: Place your `google-services.json` file inside `android/app/`.
- **iOS**: Place your `GoogleService-Info.plist` file inside `ios/Runner/`.

*Note: These files are ignored by git.*

### 5. Firebase Functions Secrets
Set the server-side secrets before deploying Functions:
```bash
firebase functions:secrets:set GEMINI_API_KEY
firebase functions:secrets:set ELEVENLABS_API_KEY
firebase functions:secrets:set GOOGLE_TRANSLATE_API_KEY
firebase deploy --only functions
```

### 6. Code Generation (Optional)
If you modify Riverpod models or Freezed classes, you may need to run the build runner to regenerate the code:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 7. Run the App
Launch an emulator or connect a physical device, then run:
```bash
flutter run
```

---

## Project Structure
The project follows a feature-first architecture to keep things modular and scalable:
- `lib/core/`: Common utilities, themes, services, and shared widgets.
- `lib/features/`: Contains feature modules (e.g., `learn`, `speak`, `home`, `profile`, `tools`).
- `lib/main.dart`: The entry point of the application.
