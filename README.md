# Hayyak (حيّك)

An Arabic-first Flutter community app that helps residents discover neighborhoods, follow local activity, share needs and ads, and find routes around their area. Built during a software development internship (summer 2025).

## Features

- **Neighborhood discovery**: suggested and nearby neighborhoods, details pages, favorites, and star ratings with written reviews.
- **Community content**: upcoming events, residents' ads, community needs, and photo-based neighborhood updates.
- **Community chat**: create and join community groups.
- **Route search**: pick a start and destination on an OpenStreetMap map, view the route, and open directions in Google Maps.
- **Accounts**: email/password sign-up and login with Firebase Authentication, plus profile completion and editing.
- **Contact and complaints**: a form for residents to send feedback to the administrators.
- **Admin panel**: manage users, neighborhoods, reviews, and complaints.
- **Arabic RTL interface** with light and dark themes.

## Tech stack

| Area | Technology |
|---|---|
| Framework | Flutter (Dart 3.8+) |
| Backend | Firebase Authentication, Firebase Realtime Database |
| Maps and location | `flutter_map`, OpenStreetMap tiles, `latlong2`, `geolocator` |
| State and UI | `provider`, `google_fonts`, `animated_text_kit`, `flutter_rating_bar` |
| Other | `image_picker`, `url_launcher`, `flutter_local_notifications` |

## Getting started

Firebase credentials are **not** included in this repository. You need your own Firebase project to run the app.

### 1. Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.8 or newer
- A Firebase project with **Authentication (Email/Password)** and **Realtime Database** enabled

### 2. Install dependencies

```bash
git clone <your-repo-url>
cd hayyak
flutter pub get
```

### 3. Connect your Firebase project

**Dart config (all platforms)**

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

This generates `lib/firebase_options.dart`. If you prefer to do it by hand, copy `lib/firebase_options.example.dart` to `lib/firebase_options.dart` and fill in your values.

**Android**: download `google-services.json` from the Firebase console and place it in `android/app/` (see `android/app/google-services.json.example` for the expected shape).

**iOS**: download `GoogleService-Info.plist` and place it in `ios/Runner/`.

The files above are listed in `.gitignore`, so they are never committed.

### 4. Run

The app reads your Realtime Database URL from a build-time variable:

```bash
flutter run --dart-define=DATABASE_URL=https://<your-project-id>-default-rtdb.firebaseio.com
```

## Project structure

```
lib/
  main.dart                  App entry point, theme, and routes
  config.dart                Realtime Database URL (set via --dart-define)
  firebase_options.example.dart   Template for your Firebase config
  *_page.dart                One file per screen (home, community, chat, admin, ...)
  custom_*.dart              Shared header, drawer, and bottom navigation
  theme.dart, theme_provider.dart
assets/images/               Logos and illustrations
android/ ios/ web/ macos/ windows/   Platform runners
```

## Security note

Before deploying this app to real users, configure strict Realtime Database security rules and send authenticated requests. The default test-mode rules are not suitable for production.

## Status

Prototype built for learning and demonstration purposes.
