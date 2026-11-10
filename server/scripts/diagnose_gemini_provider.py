#!/usr/bin/env python3
"""Minimal live Gemini provider diagnostic (no secrets logged)."""

from __future__ import annotations

import logging
import sys
import time
from pathlib import Path

# Allow `from app...` when run as `python scripts/diagnose_gemini_provider.py`.
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from google import genai
from google.genai import types

from app.config import Settings
from app.gemini_client import _PROVIDER_TIMEOUT_MS, solve_question

logging.basicConfig(level=logging.INFO, format="%(levelname)s %(name)s: %(message)s")


def _interactions_retry_summary(client: genai.Client) -> dict[str, object]:
    from google.genai._gaos.google_genai import _translate_retry_config

    http_options = client._api_client._http_options
    retry = _translate_retry_config(http_options)
    return {
        "http_timeout_ms": http_options.timeout,
        "api_version": http_options.api_version,
        "base_url": http_options.base_url,
        "parent_retry_options_set": http_options.retry_options is not None,
        "interactions_max_retries": retry.max_retries,
        "interactions_retry_strategy": retry.strategy,
        "interactions_retry_connection_errors": retry.retry_connection_errors,
        "interactions_backoff_max_elapsed_ms": (
            retry.backoff.max_elapsed_time if retry.backoff else None
        ),
    }


def main() -> int:
    settings = Settings()
    client = genai.Client(
        api_key=settings.gemini_api_key,
        http_options=types.HttpOptions(timeout=_PROVIDER_TIMEOUT_MS),
    )
    try:
        from google.genai._gaos._hooks.google_genai_auth import (
            GOOGLE_GENAI_API_REVISION,
        )
    except ImportError:
        api_revision = "unknown"
    else:
        api_revision = GOOGLE_GENAI_API_REVISION

    print("=== SolveLens Gemini provider diagnostic ===")
    print(f"model: {settings.gemini_model}")
    print(f"gemini_api_version (http): {client._api_client._http_options.api_version}")
    print(f"interactions_api_revision: {api_revision}")
    print(f"configured_timeout_ms: {_PROVIDER_TIMEOUT_MS}")
    print(f"max_output_tokens: {settings.max_output_tokens}")
    retry_info = _interactions_retry_summary(client)
    for key, value in retry_info.items():
        print(f"{key}: {value}")

    question = "2x + 3 = 7"
    print(f"\nCalling solve_question({question!r}) ...")
    started = time.perf_counter()
    try:
        answer = solve_question(settings, question)
    except Exception as exc:
        elapsed = time.perf_counter() - started
        print(f"elapsed_s: {elapsed:.2f}")
        print(f"exception_type: {type(exc).__name__}")
        print(f"exception: {exc!r}")
        return 1
    else:
        elapsed = time.perf_counter() - started
        print(f"elapsed_s: {elapsed:.2f}")
        print(f"answer_preview: {answer[:120]!r}")
        return 0
    finally:
        client.close()


if __name__ == "__main__":
    raise SystemExit(main())
