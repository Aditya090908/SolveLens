# AGENTS.md

Vanilla Flutter counter-template app. Single package (`publish_to: none`), no monorepo, no CI, no codegen. Entrypoint: `lib/main.dart`. Only test: `test/widget_test.dart`.

## Commands

- Deps: `flutter pub get` (SDK constraint: Dart `^3.13.3` per `pubspec.yaml`; run `flutter --version` to confirm)
- Analyze: `flutter analyze` (lints: `flutter_lints@6` via `analysis_options.yaml`)
- Test all: `flutter test`
- Single test file: `flutter test test/widget_test.dart`
- Single test name: `flutter test test/widget_test.dart --plain-name "Counter increments smoke test"`
- Run: `flutter run` (use `-d <device>` when multiple devices; `flutter devices` to list)

## Conventions / gotchas

- `analysis_options.yaml` excludes `build/** android/** ios/** web/** windows/** macos/** linux/**` — `flutter analyze` effectively only checks `lib/` + `test/`. Don't add hand-written Dart under platform dirs.
- Platform folders (`android/ ios/ web/ linux/ macos/ windows/`) are stock template output; prefer `flutter build <platform>` / `flutter create` regeneration over hand-editing.
- `pubspec.yaml` deps are minimal (`flutter`, `cupertino_icons`); `flutter pub upgrade --major-versions` is the documented upgrade path.
