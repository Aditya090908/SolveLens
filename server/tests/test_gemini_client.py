from unittest.mock import MagicMock, patch

import httpx
import pytest

from app.config import Settings
from app.gemini_client import (
    EmptyProviderResponseError,
    ProviderConnectionError,
    ProviderError,
    ProviderRateLimitedError,
    ProviderTimeoutError,
    _PROVIDER_TIMEOUT_MS,
    _SYSTEM_PROMPT,
    solve_question,
)


def test_system_prompt_requires_direct_concise_math_style() -> None:
    prompt = _SYSTEM_PROMPT.lower()
    assert "50" in prompt and "120" in prompt
    assert "underdetermin" in prompt or "not uniquely" in prompt or "no unique" in prompt
    assert "inconsistent" in prompt
    assert "markdown" in prompt or "latex" in prompt
    assert "wait" in prompt
    assert "nest" in prompt and "$" in prompt
    assert "uniquely" in prompt or "unique" in prompt
    assert "invent" in prompt or "never invent" in prompt.replace("  ", " ")
    assert "example" in prompt
    assert "2x + 3 = 7" in _SYSTEM_PROMPT
    assert "a + b + c = 0" in _SYSTEM_PROMPT


def test_default_max_output_tokens_is_concise() -> None:
    assert Settings.model_fields["max_output_tokens"].default == 640


def _settings() -> Settings:
    return Settings(
        gemini_api_key="test-key",
        gemini_model="gemini-3.5-flash-lite",
        max_output_tokens=128,
    )


@patch("app.gemini_client.genai.Client")
def test_solve_question_configures_provider_timeout_and_no_retries(
    mock_client_cls: MagicMock,
) -> None:
    mock_client = MagicMock()
    mock_client_cls.return_value = mock_client
    mock_interaction = MagicMock()
    mock_interaction.output_text = "ok"
    mock_client.interactions.create.return_value = mock_interaction

    solve_question(_settings(), "2+2")

    mock_client_cls.assert_called_once()
    http_options = mock_client_cls.call_args.kwargs["http_options"]
    assert http_options.timeout == _PROVIDER_TIMEOUT_MS
    assert _PROVIDER_TIMEOUT_MS == 30_000
    assert http_options.retry_options is not None
    assert http_options.retry_options.attempts == 0


@patch("app.gemini_client.genai.Client")
def test_solve_question_maps_api_timeout_error(mock_client_cls: MagicMock) -> None:
    mock_client = MagicMock()
    mock_client_cls.return_value = mock_client

    class APITimeoutError(Exception):
        pass

    mock_client.interactions.create.side_effect = APITimeoutError("deadline exceeded")

    with pytest.raises(ProviderTimeoutError):
        solve_question(_settings(), "hi")


@patch("app.gemini_client.genai.Client")
def test_solve_question_returns_output_text(mock_client_cls: MagicMock) -> None:
    mock_client = MagicMock()
    mock_client_cls.return_value = mock_client
    mock_interaction = MagicMock()
    mock_interaction.output_text = "  4  "
    mock_client.interactions.create.return_value = mock_interaction

    answer = solve_question(_settings(), "2+2")

    assert answer == "4"
    mock_client.interactions.create.assert_called_once()
    call_kwargs = mock_client.interactions.create.call_args.kwargs
    assert call_kwargs["model"] == "gemini-3.5-flash-lite"
    assert call_kwargs["input"] == "2+2"
    assert "SolveLens" in call_kwargs["system_instruction"]
    assert call_kwargs["generation_config"] == {"max_output_tokens": 128}
    mock_client.close.assert_called_once()


@patch("app.gemini_client.genai.Client")
def test_solve_question_empty_output(mock_client_cls: MagicMock) -> None:
    mock_client = MagicMock()
    mock_client_cls.return_value = mock_client
    mock_interaction = MagicMock()
    mock_interaction.output_text = "   "
    mock_client.interactions.create.return_value = mock_interaction

    with pytest.raises(EmptyProviderResponseError):
        solve_question(_settings(), "hi")


@patch("app.gemini_client.genai.Client")
def test_solve_question_maps_httpx_timeout(mock_client_cls: MagicMock) -> None:
    mock_client = MagicMock()
    mock_client_cls.return_value = mock_client
    mock_client.interactions.create.side_effect = httpx.TimeoutException("timed out")

    with pytest.raises(ProviderTimeoutError):
        solve_question(_settings(), "hi")


@patch("app.gemini_client.genai.Client")
def test_solve_question_maps_rate_limit_status(mock_client_cls: MagicMock) -> None:
    mock_client = MagicMock()
    mock_client_cls.return_value = mock_client
    exc = Exception("rate limited")
    exc.status_code = 429
    mock_client.interactions.create.side_effect = exc

    with pytest.raises(ProviderRateLimitedError):
        solve_question(_settings(), "hi")


@patch("app.gemini_client.genai.Client")
def test_solve_question_maps_other_api_status(mock_client_cls: MagicMock) -> None:
    mock_client = MagicMock()
    mock_client_cls.return_value = mock_client
    exc = Exception("server error")
    exc.status_code = 500
    mock_client.interactions.create.side_effect = exc

    with pytest.raises(ProviderError):
        solve_question(_settings(), "hi")


@patch("app.gemini_client.genai.Client")
def test_solve_question_maps_httpx_connect_error(mock_client_cls: MagicMock) -> None:
    mock_client = MagicMock()
    mock_client_cls.return_value = mock_client
    request = httpx.Request("POST", "https://example.com")
    mock_client.interactions.create.side_effect = httpx.ConnectError(
        "connection failed",
        request=request,
    )

    with pytest.raises(ProviderConnectionError):
        solve_question(_settings(), "hi")


@patch("app.gemini_client.genai.Client")
def test_provider_exception_message_is_not_written_to_logs(
    mock_client_cls: MagicMock,
    caplog: pytest.LogCaptureFixture,
) -> None:
    mock_client = MagicMock()
    mock_client_cls.return_value = mock_client
    mock_client.interactions.create.side_effect = Exception(
        "sensitive request metadata"
    )

    with pytest.raises(ProviderError):
        solve_question(_settings(), "hi")

    assert "sensitive request metadata" not in caplog.text
    assert "exc_type=Exception" in caplog.text
    mock_client.close.assert_called_once()
