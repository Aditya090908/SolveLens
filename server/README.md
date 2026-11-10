# SolveLens Phase 3 — AI proxy (local development)

FastAPI service that holds the Gemini API key server-side and exposes a single solve endpoint for the Flutter app.

**Architecture:** Flutter → FastAPI → Google Gemini API (Interactions).

**Do not** put `GEMINI_API_KEY` in the Flutter app, APK, or `--dart-define`.

## Default model

**`gemini-3.5-flash-lite`** — a stable, cost-efficient Gemini model for high-throughput workloads ([model card](https://ai.google.dev/gemini-api/docs/models/gemini-3.5-flash-lite)). Override with `GEMINI_MODEL` in `.env`.

## API surface used

- [Gemini Interactions API](https://ai.google.dev/gemini-api/docs/interactions-overview) via the official [`google-genai`](https://googleapis.github.io/python-genai/) Python SDK (`client.interactions.create`).
- Stateless request per solve: `model`, `input` (user question), `system_instruction`, `generation_config.max_output_tokens`.
- Response: `interaction.output_text` → JSON `{ "answer": "..." }` to the app.

Streaming, vision, tools, conversation history, and auth are **out of scope** for Phase 3.

## Setup

```bash
cd server
python3 -m venv .venv
source .venv/bin/activate   # Windows: .venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env
# Edit .env: set GEMINI_API_KEY (and optionally GEMINI_MODEL)
```

## Run locally

```bash
source .venv/bin/activate
uvicorn app.main:app --host 0.0.0.0 --port 8080 --reload
```

Health check: `GET http://127.0.0.1:8080/health`

## Solve endpoint

```bash
curl -sS -X POST "http://127.0.0.1:8080/v1/solve" \
  -H 'Content-Type: application/json' \
  -d '{"question":"Solve 2x + 3 = 7. Show steps briefly."}'
```

Success `200`:

```json
{ "answer": "..." }
```

Errors:

```json
{ "error": { "code": "invalid_request", "message": "..." } }
```

## Tests

```bash
source .venv/bin/activate
pytest
```

The default test suite uses mocked provider responses and offline regression fixtures. Live Gemini regression tests are opt-in and require both `GEMINI_API_KEY` and `SOLVELENS_GEMINI_LIVE_TESTS=1`; they may consume API quota.

## Flutter app (local E2E)

Android emulator → host machine:

```bash
flutter run -d <device> \
  --dart-define=SOLVELENS_API_BASE_URL=http://10.0.2.2:8080
```

Linux/desktop against local server:

```bash
flutter run --dart-define=SOLVELENS_API_BASE_URL=http://127.0.0.1:8080
```

Widget/unit tests use a fake solver (no network, no API key):

```bash
flutter test
```

## Environment variables

| Variable | Required | Description |
|----------|----------|-------------|
| `GEMINI_API_KEY` | Yes | Gemini API key; server only |
| `GEMINI_MODEL` | No | Default `gemini-3.5-flash-lite` |
| `PORT` | No | Default `8080` when using uvicorn CLI |
| `MAX_QUESTION_LENGTH` | No | Default `4000` |
| `MAX_OUTPUT_TOKENS` | No | Default `640` output-token cap |

## Deployment

Not part of Phase 3. After local E2E works, deploy this service behind HTTPS and point the app at the public base URL (still no key in the app).
