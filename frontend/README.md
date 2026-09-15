# Vazhikatti Dataset Collector

An offline-first Flutter app for collecting campus reference imagery for **Vazhikatti: Visual Campus Navigator**.

## Offline contract

- Local storage is always the source of truth. Optional HTTPS synchronization runs after local save and never blocks capture.
- Photos are copied into the app documents directory under `VazhikattiDataset/images/<session>/`.
- Session and capture metadata are stored in local SQLite (`vazhikatti.sqlite`).
- A capture is rejected when required image, GPS, accuracy, heading, pitch/roll, hierarchy, node, direction, or dataset split metadata is missing.
- GPS is recorded as rough global positioning only. Floor and node are explicitly selected and stored as ground truth.

## Run on Android

```powershell
flutter pub get
flutter test
flutter run
```

Accept camera and location permissions on the phone. The app remains usable without internet; when sensors are unavailable it explains what must be fixed instead of fabricating values.

## Export

Use **Export** to create and share a local ZIP containing `images/`, `metadata.csv`, `metadata.json`, `sessions.json`, `nodes.json`, and `README.txt`. Export is the only supported way to move data out of the app.

## Architecture

`lib/data` owns SQLite and models. `lib/services/storage` owns local files/export, `lib/services/validation` owns capture gates, and `lib/services/api` plus `lib/services/sync` own optional synchronization. Override the endpoint with `--dart-define=API_BASE_URL=...`. Upload failure leaves the image locally with `failed` state for retry. SIFT, ORB, AKAZE, RANSAC, matching, and localization are intentionally not implemented.

The deployed Render free instance has ephemeral filesystem storage and is development/testing infrastructure only; the phone remains the permanent dataset copy.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
