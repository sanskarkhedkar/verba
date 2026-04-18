# Verba

Verba is a Flutter app for AI-powered language learning and translation. The project includes onboarding flows, speaking practice, text and voice translation tools, and multi-platform Flutter targets.

## Prerequisites

- Flutter SDK compatible with Dart `>=3.3.0 <4.0.0`
- Android Studio or VS Code with Flutter/Dart plugins
- Android SDK for Android builds
- Xcode for iOS/macOS builds on macOS

Check your local environment first:

```bash
flutter doctor
```

## Clone And Install

```bash
git clone https://github.com/sanskarkhedkar/verba.git
cd verba
flutter pub get
```

## Required API Keys

The app reads API keys from compile-time environment variables in [lib/services/app_config.dart](/h:/Sanskar/Work/Coding/Verba/lib/services/app_config.dart):

- `OPENAI_API_KEY`
- `ELEVENLABS_API_KEY`
- `GOOGLE_TRANSLATE_API_KEY`

Pass them with `--dart-define` when running the app.

Example:

```bash
flutter run ^
  --dart-define=OPENAI_API_KEY=your_openai_key ^
  --dart-define=ELEVENLABS_API_KEY=your_elevenlabs_key ^
  --dart-define=GOOGLE_TRANSLATE_API_KEY=your_google_translate_key
```

Windows PowerShell also works as a single line:

```powershell
flutter run --dart-define=OPENAI_API_KEY=your_openai_key --dart-define=ELEVENLABS_API_KEY=your_elevenlabs_key --dart-define=GOOGLE_TRANSLATE_API_KEY=your_google_translate_key
```

## Running The App

Start a device or emulator, then run:

```bash
flutter run
```

To target a specific platform:

```bash
flutter devices
flutter run -d <device-id>
```

## Android Setup

1. Install Android Studio and the Android SDK.
2. Accept Android licenses:

```bash
flutter doctor --android-licenses
```

3. Start an emulator from Android Studio or connect a physical device with USB debugging enabled.
4. Verify setup:

```bash
flutter doctor
```

`android/local.properties` is intentionally ignored in Git. Flutter recreates it locally based on your SDK installation.

## Project Structure

- `lib/main.dart`: app entry point
- `lib/app.dart`: root app widget
- `lib/features/`: feature-specific UI and providers
- `lib/services/`: API and platform integrations
- `lib/shared/widgets/`: reusable UI components
- `assets/`: images, icons, and animations

## Useful Commands

```bash
flutter pub get
flutter analyze
flutter test
flutter clean
```

## Notes

- The repo excludes generated build output and machine-specific files through [.gitignore](/h:/Sanskar/Work/Coding/Verba/.gitignore).
- `pubspec.lock` is committed, which is normal for Flutter app repositories.
- If API keys are missing, features backed by external services will not work correctly.
