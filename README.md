# HVP Boxing Flutter Prototype

UI-only member prototype based on `app.html` and the supplied SRS. It has no backend, API, camera, database, or persistent storage.

## Required software

- Flutter SDK (includes Dart and the `flutter` command)
- VS Code with Flutter and Dart extensions
- Chrome for the fastest web preview
- Android Studio only if an Android emulator or Android SDK is needed
- Xcode is required only for iOS builds, and only on macOS

## Run

```bash
flutter pub get
flutter run -d chrome
```

If platform folders are not present yet, run this once from the project root:

```bash
flutter create .
```

The demo login accepts `minh` as the username. Any password is accepted for the prototype flow.
