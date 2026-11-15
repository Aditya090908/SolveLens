# Contributing to SolveLens

Thanks for your interest in improving SolveLens. Contributions that make the app more reliable, understandable, accessible, or easier to run are welcome.

## Before you start

1. Check existing issues and pull requests to avoid duplicating work.
2. For a substantial change, open an issue first to discuss the approach.
3. Keep changes focused and explain the user or developer problem they solve.
4. Never commit API keys, passwords, real `.env` files, or personal data.

## Development setup

Follow the setup instructions in the main [README](README.md). The project has two independently testable parts:

- Flutter application at the repository root
- FastAPI backend in `server/`

## Validate your changes

Run the relevant checks before opening a pull request.

From the repository root:

```bash
flutter analyze
flutter test
```

From the `server/` directory, with the backend dependencies installed:

```bash
pytest
```

If a change affects both parts, run checks for both. If a check cannot be run, mention that clearly in the pull request.

## Pull request checklist

- [ ] The change has a clear, focused purpose.
- [ ] Related tests were added or updated where appropriate.
- [ ] Documentation was updated when behavior or setup changed.
- [ ] No secrets or generated build files are included.
- [ ] The pull request explains what changed and how it was validated.

## Commit and review expectations

Use descriptive commit messages and keep unrelated changes out of the same pull request. Be respectful and constructive when discussing feedback. Maintainers may ask for changes before merging.

Thanks for helping make SolveLens better!
