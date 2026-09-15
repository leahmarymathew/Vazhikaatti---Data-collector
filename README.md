# Vazhikatti Dataset Collector

An offline-first Flutter app for collecting campus reference imagery for **Vazhikatti: Visual Campus Navigator**.

## Offline contract

- No HTTP clients, API calls, Firebase, login, cloud storage, or sync are used by the app.
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

`lib/data` owns the SQLite-facing model and repository. `lib/services` owns validation and local file/export behavior. The record is a JSON-compatible map containing current capture fields plus reserved CV and localization fields, so a future FastAPI adapter can serialize the same model without changing the capture workflow. SIFT, ORB, AKAZE, RANSAC, matching, and localization are intentionally not implemented.# vazhikatti_dataset_collector

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
