# OpenWave

OpenWave is a Flutter Android music streaming app built incrementally. This repository currently contains **Phase 1: Foundation MVP** only.

## Phase 1 Scope

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

Not included yet:

- Firebase
- Spotify login
- Music playback
- Offline downloads
- AI recommendations
- Cloud Functions
- External music APIs

## Folder Structure

```text
lib/
  core/
    navigation/
  features/
    home/
    library/
    search/
    splash/
  models/
  providers/
  services/
  theme/
  widgets/
```

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
dist/openwave-v0.1-foundation-debug.apk
```

## GitHub Actions

The workflow at `.github/workflows/android-apk.yml` runs:

- `flutter pub get`
- `flutter analyze`
- `flutter test`
- `flutter build apk --debug`
- uploads `app-debug.apk` as a workflow artifact

## Versioning

Suggested commit message:

```text
feat: build OpenWave phase 1 foundation
```

Suggested tag:

```text
v0.1-foundation
```
