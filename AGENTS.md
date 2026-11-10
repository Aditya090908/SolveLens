# AGENTS.md

Vanilla Flutter app (`publish_to: none`), single package. Entrypoint: `lib/main.dart`. Phase 3 adds a Python FastAPI proxy under `server/` and HTTP from Flutter to that proxy (no API keys in the app).

## Commands

- Deps: `flutter pub get` (SDK constraint: Dart `^3.13.3` per `pubspec.yaml`; run `flutter --version` to confirm)
- Analyze: `flutter analyze` (lints: `flutter_lints@6` via `analysis_options.yaml`)
- Test all: `flutter test`
- Widget tests: `flutter test test/widget_test.dart`
- Remote service unit tests: `flutter test test/remote_solve_service_test.dart`
- Run: `flutter run` (use `-d <device>` when multiple devices; `flutter devices` to list)
- Run against local proxy (Android emulator → host):  
  `flutter run -d <device> --dart-define=SOLVELENS_API_BASE_URL=http://10.0.2.2:8080`
- Widget tests use `FakeSolveService` by default; no `--dart-define` needed for CI.

## Server (Phase 3)

See `server/README.md`. Local run:

```bash
cd server && python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env   # GEMINI_API_KEY and GEMINI_MODEL — never in Flutter
uvicorn app.main:app --host 0.0.0.0 --port 8080 --reload
pytest   # server API tests (from server/, venv active)
```

## Conventions / gotchas

- `analysis_options.yaml` excludes `build/** android/** ios/** web/** windows/** macos/** linux/**` — `flutter analyze` effectively only checks `lib/` + `test/`. Don't add hand-written Dart under platform dirs.
- Platform folders are stock template output; prefer `flutter build <platform>` / `flutter create` regeneration over hand-editing.
- Never put `GEMINI_API_KEY` in Flutter, APK, or `--dart-define`. Only `SOLVELENS_API_BASE_URL` and optional `SOLVELENS_USE_FAKE_SOLVER` belong in dart-define.
