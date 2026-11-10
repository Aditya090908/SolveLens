import os

import pytest

from app.config import Settings
from app.gemini_client import solve_question
from math_regression_assertions import (
    CUBIC_SYMMETRIC_QUESTION,
    INCONSISTENT_QUESTION,
    LINEAR_QUESTION,
    QUADRATIC_QUESTION,
    assert_valid_cubic_symmetric_answer,
    assert_valid_inconsistent_answer,
    assert_valid_linear_answer,
    assert_valid_quadratic_answer,
)

CUBIC_LIVE_RUNS = 5


def _live_tests_enabled() -> bool:
    return os.environ.get("SOLVELENS_GEMINI_LIVE_TESTS") == "1"


def _live_settings() -> Settings:
    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        pytest.skip("GEMINI_API_KEY is not set")
    return Settings(gemini_api_key=api_key)


@pytest.mark.skipif(
    not _live_tests_enabled(),
    reason="Set SOLVELENS_GEMINI_LIVE_TESTS=1 to run live Gemini regression",
)
def test_live_linear_unique() -> None:
    answer = solve_question(_live_settings(), LINEAR_QUESTION)
    assert_valid_linear_answer(answer)


@pytest.mark.skipif(
    not _live_tests_enabled(),
    reason="Set SOLVELENS_GEMINI_LIVE_TESTS=1 to run live Gemini regression",
)
def test_live_quadratic_unique() -> None:
    answer = solve_question(_live_settings(), QUADRATIC_QUESTION)
    assert_valid_quadratic_answer(answer)


@pytest.mark.skipif(
    not _live_tests_enabled(),
    reason="Set SOLVELENS_GEMINI_LIVE_TESTS=1 to run live Gemini regression",
)
def test_live_cubic_symmetric_underdetermined_repeated() -> None:
    settings = _live_settings()
    for run in range(1, CUBIC_LIVE_RUNS + 1):
        answer = solve_question(settings, CUBIC_SYMMETRIC_QUESTION)
        try:
            assert_valid_cubic_symmetric_answer(answer)
        except AssertionError as exc:
            raise AssertionError(f"Live cubic run {run}/{CUBIC_LIVE_RUNS} failed: {exc}") from exc


@pytest.mark.skipif(
    not _live_tests_enabled(),
    reason="Set SOLVELENS_GEMINI_LIVE_TESTS=1 to run live Gemini regression",
)
def test_live_inconsistent_system() -> None:
    answer = solve_question(_live_settings(), INCONSISTENT_QUESTION)
    assert_valid_inconsistent_answer(answer)
