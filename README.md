# OpenWave

KX Wave is a Flutter Android music streaming app built incrementally. This repository currently contains **v1.0.1 QA Fix**.

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

## Phase 4 Streaming

Included:

- KX Wave futuristic cyber-tech branding
- Neon cyan and premium dark UI accents
- Adaptive Android KX icon
- Audius API trending and search integration
- Jamendo API integration through `JAMENDO_CLIENT_ID`
- Streaming search loading/error states
- Streaming trending songs
- Artist detail pages
- Playlist detail pages
- Dynamic playback queue for streamed songs
- Firebase placeholder fallback so invalid demo API keys no longer block app entry

## Phase 5 Offline Downloads

Included:

- Legal streaming track downloads
- Local app-document cache
- Persistent download manifest
- Download progress indicators
- Downloaded songs screen
- Offline playback from local file URIs
- Secure per-install cache marker via platform secure storage
- Low-memory streamed file writes

## Phase 6 Spotify Sync

Included:

- Spotify OAuth with PKCE
- Android callback URI: `kxwave://spotify-auth`
- Secure token storage
- Top tracks, top artists, genres, playlists, and recently played sync
- Firestore taste profile storage when Firebase is configured
- Cached taste profile display
- Spotify analytics only; Spotify music is never streamed by KX Wave

## Phase 7 AI Recommendations

Included:

- AI Discovery bottom navigation tab
- Weekly recommendation mix
- Mood playlists
- Similar artist signals
- Spotify taste profile ranking when synced
- Open-catalog fallback recommendations when Spotify is not configured
- Recommendation playback from legal/open tracks only

## Phase 8 Weekly Updates

Included:

- Weekly recommendation refresh schedule
- Cached recommendation packs to reduce API usage
- Manual refresh from the AI Discovery screen
- Refresh history
- Notification-style in-app update status
- Safer playable fallback catalog for low-connectivity devices
- Conservative Audius filtering for copyright-safe/open-license tracks
- Optional Firebase scheduled function source in `functions/`

## Phase 9 Optimization

Included:

- Voice search with Android microphone permission
- Lyrics/listening-notes panel in Now Playing
- Skeleton loaders for faster perceived search loading
- In-memory streaming API cache
- Reduced repeat network calls for trending/search/playlists
- Continued source-error hardening for legal/open playback

## v1.0 Production

Included:

- Signed release APK build configuration
- Release AAB build configuration
- Local upload-keystore generation script
- GitHub Actions support for signed release artifacts
- Firebase Firestore and Storage rules
- Production release guide
- Changelog
- Debug APK still available for direct installation testing

## v1.0.1 QA Fix

Included:

- Bundled playable KX demo audio for Home songs
- Offline-safe asset playback
- Spotify Sync demo mode when no `SPOTIFY_CLIENT_ID` is configured
- Working Artists and Albums Library filters
- Playback control error handling

## Not Included Yet

- Play Store publishing automation

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
    spotify/
    player/
    recommendations/
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

## Streaming API Setup

Audius works without a key. Jamendo requires a free developer client id:

```powershell
flutter build apk --debug `
  --dart-define=JAMENDO_CLIENT_ID="your-jamendo-client-id"
```

## Spotify Sync Setup

Create a Spotify developer app and add this redirect URI:

```text
kxwave://spotify-auth
```

Build or run with:

```powershell
flutter build apk --debug `
  --dart-define=SPOTIFY_CLIENT_ID="your-spotify-client-id" `
  --dart-define=SPOTIFY_REDIRECT_URI="kxwave://spotify-auth"
```

KX Wave uses Spotify only to analyze listening taste. Playback still comes from legal/open sources already integrated in the app.

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
dist/kx-wave-v1.0.1-qa-fix-debug.apk
```

## Build Release APK and AAB

Create a local signing key:

```powershell
.\scripts\create_release_keystore.ps1
```

Build release artifacts:

```powershell
.\scripts\build_release_artifacts.ps1
```

Outputs:

```text
dist/kx-wave-v1.0.1-qa-fix-release.apk
dist/kx-wave-v1.0.1-qa-fix-release.aab
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
v1.0.1-qa-fix
```

Previous production tag:

```text
v1.0-production
```

Previous optimization tag:

```text
v0.9-optimization
```

Previous weekly updates tag:

```text
v0.8-weekly-updates
```

Previous AI recommendations tag:

```text
v0.7-ai-recommendations
```

Previous Spotify sync tag:

```text
v0.6-spotify-sync
```

Previous offline-downloads tag:

```text
v0.5-offline-downloads
```

Previous streaming tag:

```text
v0.4-streaming
```

Previous player tag:

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
