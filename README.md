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

## Demo accounts

All demo accounts use the password `hvp12345` (seeded in `lib/data/mock/mock_db.dart`).

| Login | Role |
|---|---|
| `minh` / `student@hvp.demo` | Member (Minh Nguyễn) |
| `an@hvp.demo` | Member (An Trần, has a pending renewal) |
| `reception@hvp.demo` | Receptionist |
| `coach@hvp.demo` | Coach |
| `admin@hvp.demo` | Admin |

Role Selection is still shown after login so any account can open any demo UI.

## Auth, membership and lifecycle (UC1–3, UC14–17)

These screens use repository interfaces (`lib/data/repositories/`). The
current implementation is an in-memory mock (`lib/data/mock/`) that follows
`docs/HVP- System Documents/5. Databases/hvp_schema.sql`: idempotency keys,
monthly caps, freeze logs, comeback cycles and audit logs. Replace the mock
with HTTP implementations in `lib/app/repositories.dart` when the Node.js API
is ready.

Demo script:

1. Log in as `minh` → Student → Home → **Membership Card** → send a renewal request.
2. Staff → **Gia hạn** tab → approve it (early renewal: next package is SCHEDULED, +50 Marks).
3. Admin → Manage → **Lifecycle demo**:
   - `+11 ngày` → `Chạy job hết hạn`: the scheduled package takes over.
   - `Dùng hết số buổi` → `Chạy job hết hạn`: member is FROZEN, Marks kept but locked;
     Home shows *YOUR MARKS ARE WAITING* and check-in is blocked with a renewal CTA.
   - `+365 ngày` → `Chạy job inactive`: account becomes INACTIVE (warning first at `+335`).
   - `Vắng 15 ngày` → `SESSION_COMPLETED`: +50 DP comeback bonus; `Gửi lại sự kiện` is skipped (MSG33).
4. Approving a new renewal unfreezes the Marks and reactivates an INACTIVE account.

Tests: `flutter test` (UC rules are in `test/hung/`).
