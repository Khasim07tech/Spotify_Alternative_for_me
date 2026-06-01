# KX Wave Release Guide

## Local Release Build

Create a local upload keystore:

```powershell
.\scripts\create_release_keystore.ps1
```

Build signed release artifacts:

```powershell
.\scripts\build_release_artifacts.ps1
```

Outputs:

```text
dist/kx-wave-v1.0-production-release.apk
dist/kx-wave-v1.0-production-release.aab
```

The local keystore and `android/key.properties` are ignored by Git.

## GitHub Actions Release Secrets

Add these repository secrets to build signed release artifacts in CI:

```text
ANDROID_KEYSTORE_BASE64
ANDROID_KEYSTORE_PASSWORD
ANDROID_KEY_ALIAS
ANDROID_KEY_PASSWORD
```

`ANDROID_KEYSTORE_BASE64` is the base64 text of the upload keystore file.

## Firebase Rules

Deploy Firestore and Storage rules after configuring Firebase:

```bash
firebase deploy --only firestore:rules,storage
```

## Production Checklist

- Configure real Firebase Android values through `--dart-define`.
- Add Google sign-in SHA-1/SHA-256 fingerprints.
- Configure Spotify redirect URI `https://kxwave.app/spotify-auth`.
- Add Jamendo client id for Creative Commons search.
- Test playback on a physical Android device.
- Keep Spotify for analytics only; never stream Spotify audio.
