# OpenWave

OpenWave is a Flutter Android music streaming app built incrementally. This repository currently contains **Phase 3: Music Player**.

## Phase 1 Foundation

Included:

- Flutter Android project setup
- Material 3 dark theme
- Riverpod app state
- Splash screen
- Bottom navigation
- Home, Search, and Library screens
- Spotify-inspired responsive UI
- Mini player UI placeholder
- Trending cards, search UI, and playlist cards
- Clean folder architecture
- GitHub Actions workflow for debug APK builds

## Phase 2 Authentication

Included:

- Firebase app bootstrap for Android
- Firebase Authentication service behind an `AuthService` interface
- Email/password login
- Email/password registration
- Google login
- Riverpod auth state provider
- Auth gate before the main app shell
- Sign out action from Library

Firebase credentials are configurable and are not committed as secrets.

## Phase 3 Music Player

Included:

- `just_audio` playback service
- Background playback with `just_audio_background`
- Android notification controls
- Copyright-safe public-domain demo tracks
- Tap-to-play from Home and Search
- Live mini player controls
- Full Now Playing screen
- Seek bar, play/pause, previous/next, shuffle, and repeat controls

The bundled demo streams are public-domain recordings sourced from Wikimedia Commons and Internet Archive metadata pages.

## Not Included Yet

- Offline downloads
- AI recommendations
- Cloud Functions
- External music APIs
- Spotify login

## Folder Structure

```text
lib/
  core/
    firebase/
    navigation/
  features/
    auth/
    home/
    library/
    player/
    search/
    splash/
  models/
  providers/
  services/
  theme/
  widgets/
```

## Firebase Setup

1. Create a Firebase project.
2. Add an Android app with package name:

```text
com.openwave.openwave
```

3. Enable Authentication providers in Firebase Console:

- Email/Password
- Google

4. Add your debug SHA-1/SHA-256 fingerprints to the Firebase Android app:

```powershell
cd android
.\gradlew signingReport
```

5. Build with your Firebase values:

```powershell
flutter build apk --debug `
  --dart-define=FIREBASE_ANDROID_API_KEY="your-api-key" `
  --dart-define=FIREBASE_ANDROID_APP_ID="your-android-app-id" `
  --dart-define=FIREBASE_MESSAGING_SENDER_ID="your-sender-id" `
  --dart-define=FIREBASE_PROJECT_ID="your-project-id" `
  --dart-define=FIREBASE_STORAGE_BUCKET="your-project-id.appspot.com" `
  --dart-define=GOOGLE_SERVER_CLIENT_ID="your-web-client-id.apps.googleusercontent.com"
```

For GitHub Actions production auth builds, store those values as repository secrets and pass them as `--dart-define` values in the workflow.

## Local Development

Use Flutter 3.41.9 or newer stable.

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

## Build Debug APK

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

The debug APK is generated at:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

On this Windows workspace, a helper script is available:

```powershell
.\scripts\build_debug_apk.ps1
```

It also copies the APK to:

```text
dist/openwave-v0.3-player-debug.apk
```

## GitHub Actions

The workflow at `.github/workflows/android-apk.yml` runs:

- `flutter pub get`
- `flutter analyze`
- `flutter test`
- `flutter build apk --debug`
- uploads `app-debug.apk` as a workflow artifact

## Versioning

Latest tag:

```text
v0.3-player
```

Previous auth tag:

```text
v0.2-auth
```

Previous foundation tag:

```text
v0.1-foundation
```
