import logging
import time

import httpx
from google import genai
from google.genai import types

from app.config import Settings

logger = logging.getLogger(__name__)

_SYSTEM_PROMPT = (
    "You are SolveLens, a rigorous math solver for students. Reason internally; "
    "output only the final solution—no greetings, closings, scratch work, "
    "abandoned attempts, or phrases like \"Wait\", \"Actually\", or "
    "\"let's try another method\".\n"
    "\n"
    "Workflow (internal): identify what is asked; decide if it is uniquely "
    "determined, underdetermined, or inconsistent. If underdetermined or "
    "inconsistent, state that in the opening line, give one short reason or "
    "one counterexample, then stop—no forced numerical answer. If unique, "
    "state the answer first, then the minimum steps to verify it (one path "
    "only). Every number you publish must follow from the givens; never invent "
    "an unfixed parameter (e.g. a product of variables the equations do not "
    "determine).\n"
    "\n"
    "Style: direct, about 50–120 words unless the problem truly needs more. "
    "Markdown and LaTeX: $...$ inline, $$...$$ display; do not nest $ math "
    "inside other math delimiters. Non-math questions: briefly say you solve "
    "math problems.\n"
    "\n"
    "Example — unique:\n"
    "Q: 2x + 3 = 7\n"
    "A: **$x = 2$**\n"
    "Subtract 3: $2x = 4$. Divide by 2: $x = 2$.\n"
    "\n"
    "Example — underdetermined:\n"
    "Q: a + b + c = 0; a² + b² + c² = 6. Find a³ + b³ + c³\n"
    "A: **No unique numerical answer.** With $a+b+c=0$, "
    "$a^3+b^3+c^3=3abc$. The givens fix $ab+bc+ca=-3$ but not $abc$, so the "
    "sum is not uniquely determined (e.g. $(1,1,-2)$ gives $-6$)."
)

_PROVIDER_TIMEOUT_MS = 30_000


def _gemini_http_options() -> types.HttpOptions:
    """Single-attempt provider calls with a bounded per-request timeout."""
    return types.HttpOptions(
        timeout=_PROVIDER_TIMEOUT_MS,
        retry_options=types.HttpRetryOptions(
            # SDK: 0/1 = no retries. NextGen interactions map attempts → max_retries
            # directly, so 0 yields one HTTP attempt (no timeout retry stacking).
            attempts=0,
        ),
    )


def solve_question(settings: Settings, question: str) -> str:
    client = genai.Client(
        api_key=settings.gemini_api_key,
        http_options=_gemini_http_options(),
    )
    started = time.perf_counter()
    logger.info(
        "gemini interactions.create start model=%s timeout_ms=%s "
        "max_output_tokens=%s question_len=%s",
        settings.gemini_model,
        _PROVIDER_TIMEOUT_MS,
        settings.max_output_tokens,
        len(question),
    )
    try:
        interaction = client.interactions.create(
            model=settings.gemini_model,
            input=question,
            system_instruction=_SYSTEM_PROMPT,
            generation_config={
                "max_output_tokens": settings.max_output_tokens,
            },
        )
    except httpx.TimeoutException as exc:
        logger.warning(
            "gemini interactions.create httpx timeout after %.2fs: %s",
            time.perf_counter() - started,
            type(exc).__name__,
        )
        raise ProviderTimeoutError()
    except httpx.HTTPError as exc:
        logger.warning(
            "gemini interactions.create transport failure after %.2fs type=%s",
            time.perf_counter() - started,
            type(exc).__name__,
        )
        raise ProviderConnectionError()
    except Exception as exc:
        # Provider exception messages can contain request metadata. Log only the
        # exception class; never emit raw provider messages or request details.
        logger.warning(
            "gemini interactions.create failed after %.2fs exc_type=%s",
            time.perf_counter() - started,
            type(exc).__name__,
        )
        if _is_provider_timeout(exc):
            raise ProviderTimeoutError()
        if _is_provider_connection(exc):
            raise ProviderConnectionError()
        status_code = getattr(exc, "status_code", None)
        if status_code == 429:
            raise ProviderRateLimitedError()
        if status_code is not None:
            raise ProviderError()
        raise ProviderError()
    finally:
        client.close()

    text = (interaction.output_text or "").strip()
    logger.info(
        "gemini interactions.create ok after %.2fs output_chars=%s",
        time.perf_counter() - started,
        len(text),
    )
    if not text:
        raise EmptyProviderResponseError()
    return text


def _is_provider_timeout(exc: BaseException) -> bool:
    return type(exc).__name__ == "APITimeoutError"


def _is_provider_connection(exc: BaseException) -> bool:
    return type(exc).__name__ == "APIConnectionError"


class ProviderError(Exception):
    pass


class ProviderTimeoutError(ProviderError):
    pass


class ProviderConnectionError(ProviderError):
    pass


class ProviderRateLimitedError(ProviderError):
    pass


class EmptyProviderResponseError(ProviderError):
    pass
