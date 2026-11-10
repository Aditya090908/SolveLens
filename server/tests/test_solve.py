from unittest.mock import patch

import pytest
from fastapi.testclient import TestClient

from app.gemini_client import (
    EmptyProviderResponseError,
    ProviderConnectionError,
    ProviderError,
    ProviderRateLimitedError,
    ProviderTimeoutError,
)
from app.config import Settings
from app.main import app, get_settings_dep

client = TestClient(app)


def test_health() -> None:
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_solve_empty_question() -> None:
    response = client.post("/v1/solve", json={"question": "   "})
    assert response.status_code == 400
    body = response.json()
    assert body["error"]["code"] == "invalid_request"


def test_solve_missing_question() -> None:
    response = client.post("/v1/solve", json={})
    assert response.status_code == 400
    assert response.json()["error"]["code"] == "invalid_request"


@patch("app.main.solve_question", return_value="x = 2")
def test_solve_success(_mock_solve: object) -> None:
    response = client.post(
        "/v1/solve",
        json={"question": "Solve 2x + 3 = 7"},
    )
    assert response.status_code == 200
    assert response.json() == {"answer": "x = 2"}


@patch(
    "app.main.solve_question",
    side_effect=ProviderRateLimitedError(),
)
def test_solve_rate_limited(_mock_solve: object) -> None:
    response = client.post("/v1/solve", json={"question": "2+2"})
    assert response.status_code == 429
    assert response.json()["error"]["code"] == "rate_limited"


@patch(
    "app.main.solve_question",
    side_effect=ProviderTimeoutError(),
)
def test_solve_provider_timeout(_mock_solve: object) -> None:
    response = client.post("/v1/solve", json={"question": "2+2"})
    assert response.status_code == 504
    assert response.json()["error"]["code"] == "provider_timeout"


@patch(
    "app.main.solve_question",
    side_effect=ProviderConnectionError(),
)
def test_solve_provider_connection(_mock_solve: object) -> None:
    response = client.post("/v1/solve", json={"question": "2+2"})
    assert response.status_code == 502
    assert response.json()["error"]["code"] == "provider_error"


@patch(
    "app.main.solve_question",
    side_effect=EmptyProviderResponseError(),
)
def test_solve_empty_provider_response(_mock_solve: object) -> None:
    response = client.post("/v1/solve", json={"question": "2+2"})
    assert response.status_code == 502
    body = response.json()
    assert body["error"]["code"] == "provider_error"
    assert "empty" in body["error"]["message"].lower()


@patch("app.main.solve_question", side_effect=ProviderError())
def test_solve_provider_error(_mock_solve: object) -> None:
    response = client.post("/v1/solve", json={"question": "2+2"})
    assert response.status_code == 502
    assert response.json()["error"]["code"] == "provider_error"


def test_solve_question_too_long() -> None:
    app.dependency_overrides[get_settings_dep] = lambda: Settings(
        gemini_api_key="test-key",
        max_question_length=10,
    )
    try:
        response = client.post("/v1/solve", json={"question": "12345678901"})
        assert response.status_code == 400
        assert response.json()["error"]["code"] == "question_too_long"
    finally:
        app.dependency_overrides.clear()
