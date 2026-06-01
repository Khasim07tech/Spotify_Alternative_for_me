# Changelog

## 1.0.2 - Data Import

- Added Spotify data export import without OAuth or Client ID.
- Supports JSON, CSV, and TXT taste files.
- Converts imported tracks, artists, playlists, and recent listening history into KX recommendations.

## 1.0.1 - QA Fix

- Made Home songs playable offline with bundled KX audio demo loops.
- Added asset playback handling in the audio service.
- Added Spotify Sync demo mode when `SPOTIFY_CLIENT_ID` is not configured.
- Made Library Artists and Albums filters switch real content.
- Hardened playback controls so failures surface as user-visible messages.

## 1.0.0 - Production

- Added release APK and AAB build scripts.
- Added local upload-keystore generation.
- Added signed release Gradle configuration.
- Added Firebase Firestore and Storage security rules.
- Added optional GitHub Actions signed release build support.
- Documented production setup and deployment steps.

## 0.9.0 - Optimization

- Added voice search, skeleton loaders, lyrics/listening notes, and streaming API cache.

## 0.8.0 - Weekly Updates

- Added cached weekly recommendations, refresh history, and optional scheduled Firebase Function source.
