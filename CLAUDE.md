# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Commands

```bash
flutter pub get          # Install dependencies
flutter run              # Run on connected device/emulator
flutter build apk        # Build Android APK
flutter build ios        # Build iOS app
flutter analyze          # Static analysis
flutter test             # Run tests (test/ directory is currently empty)
```

## Architecture Overview

This is a Flutter app called **Tese** — a dual-role video/music streaming and content creation platform with integrated payments. The package name is `smacredit`.

### Two User Roles

- **Client (consumer)**: code lives in `lib/client/` — browse channels, watch/listen to content, follow creators, manage library, view live events
- **Content Creator**: code lives in `lib/src/content-creator/` — manage channels/playlists, upload videos, track analytics, receive payouts

### State Management

Uses `mvc_pattern` with `ValueNotifier` for reactive state:
- `setting` — global app config loaded from `assets/cfg/app_settings.json`
- `currentuser` — logged-in user (defined in `lib/src/repositories/user_repository.dart`)
- `themeNotifier` — dark/light mode toggle
- `uploadProgressMap` — tracks ongoing file uploads

Global state notifiers are defined in `lib/src/repositories/settings_repository.dart`.

### Routing

All named routes are defined in `lib/src/Route_generator.dart` (~60 screens). Navigation uses named routes with `RouteSettings` arguments to pass data between screens. A `RouteObserver` tracks the current route to control mini-player visibility.

### Authentication Flow

1. Splash → OTP/email verification → KYC (document scan + liveness detection) → JWT issued
2. JWT stored in `SharedPreferences` via `TokenService`
3. Custom HTTP interceptor (`lib/src/auth/repository/inteceptor.dart`) auto-renews tokens before expiry
4. Uses `RetryClient` wrapper (8 attempts) for automatic retry on network failures

### API Layer

- Base URL configured in `assets/cfg/app_settings.json` (`api_base_url` for production, `server_api_base_url` for staging)
- `http` package for standard requests; `dio` for file uploads (multipart/form-data)
- CloudFront cookie management for video streaming (`CloudFrontCookieNotifier` in `lib/client/models/cookie_manager.dart`)

### Audio/Video Players

- `MyAudioHandler` (extends `BaseAudioHandler` from `audio_service`) handles background audio playback
- `GlobalAudioProgressBar` mini-player overlays all screens except the full player
- Video playback uses `chewie` + `video_player`; live streaming uses `ant_media_flutter`
- Upload management: `TeseUploadManager` singleton in `lib/src/content-creator/controller/upload_manager.dart`

### Key Third-Party Integrations

- **Payments**: `smat_pay_payment_plugin` (custom package)
- **Firebase**: Auth, Firestore, Cloud Messaging (project: `tese-eba00`)
- **ML Kit**: Text recognition for ID/document verification
- **Biometrics**: Liveness detection, local authentication
- **Local DB**: `sqflite` for download tracking (`lib/client/downloads/downloaddb.dart`)
- **Responsive UI**: `flutter_screenutil` (design base: 390×844)

### Environment Configuration

No build flavors. Environment is switched via logic in `app_settings.json` — production uses `https://api.tese.africa/api`, staging uses `http://178.63.147.134:8005/api`. The storage base URL is separate from the API URL.
