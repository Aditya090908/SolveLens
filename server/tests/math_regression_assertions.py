"""Semantic checks for math regression fixtures and opt-in live Gemini tests."""

import re

LINEAR_QUESTION = "2x + 3 = 7"
QUADRATIC_QUESTION = "x² - 5x + 6 = 0"
CUBIC_SYMMETRIC_QUESTION = (
    "a + b + c = 0; a² + b² + c² = 6. Find a³ + b³ + c³"
)
INCONSISTENT_QUESTION = "x + y = 1 and x + y = 2. Find x and y."

# Rough upper bound for a concise SolveLens reply (~120 words + light LaTeX).
DEFAULT_MAX_ANSWER_CHARS = 1600
CUBIC_MAX_ANSWER_CHARS = 1600

NOT_UNIQUELY_DETERMINED_PATTERN = re.compile(
    r"not\s+uniquely\s+determined|underdetermin|not\s+unique(?:ly)?|"
    r"cannot\s+be\s+determin|not\s+(?:uniquely\s+)?determined|"
    r"infinitely\s+many|multiple\s+(?:values|solutions|answers)|"
    r"not\s+enough\s+information|do\s+not\s+uniquely|"
    r"is\s+not\s+uniquely|not\s+fixed\b|no\s+unique\s+numerical",
    re.IGNORECASE,
)

CUBIC_SUM_EQUALS_NINE_PATTERN = re.compile(
    r"(?:a\s*\^?\s*3\s*\+\s*b\s*\^?\s*3\s*\+\s*c\s*\^?\s*3|a³\s*\+\s*b³\s*\+\s*c³)"
    r"[^.\n]{0,60}?=\s*9\b",
    re.IGNORECASE,
)

FORCED_NUMERIC_CUBIC_SUM_PATTERN = re.compile(
    r"a\s*\^?\s*3\s*\+\s*b\s*\^?\s*3\s*\+\s*c\s*\^?\s*3\s*=\s*-?\d+(?:\.\d+)?\b",
    re.IGNORECASE,
)

INVENTED_ABC_EQUALS_THREE_PATTERN = re.compile(
    r"abc\s*=\s*3\b",
    re.IGNORECASE,
)

ANSWER_IS_NINE_PATTERN = re.compile(
    r"(?:answer|result|therefore|thus|value)\s*(?:is|=)\s*9\b",
    re.IGNORECASE,
)

SELF_CORRECTION_PATTERN = re.compile(
    r"\bwait\b,|\bactually\b,|let'?s\s+(?:try|check|re-evaluate|use\s+another)|"
    r"another\s+method|^\s*\*\*correction",
    re.IGNORECASE | re.MULTILINE,
)

INCONSISTENT_PATTERN = re.compile(
    r"inconsistent|contradiction|contradict|cannot\s+(?:all\s+)?be\s+satisfied|"
    r"no\s+(?:solution|solutions|values?\s+of\s+x)|impossible\s+to\s+satisfy",
    re.IGNORECASE,
)


def assert_reasonably_concise(answer: str, max_chars: int = DEFAULT_MAX_ANSWER_CHARS) -> None:
    assert len(answer) <= max_chars, (
        f"Expected at most {max_chars} characters; got {len(answer)}: "
        f"{answer[:300]}..."
    )


def assert_no_self_correction_patterns(answer: str) -> None:
    match = SELF_CORRECTION_PATTERN.search(answer)
    assert match is None, (
        f"Must not contain self-correction/abandoned-solution phrasing; "
        f"matched {match.group()!r} in: {answer[:500]}"
    )


def assert_valid_linear_answer(answer: str) -> None:
    lower = answer.lower()
    assert "x" in lower and re.search(r"\b2\b", answer), (
        f"Expected x = 2; got: {answer[:500]}"
    )
    assert not NOT_UNIQUELY_DETERMINED_PATTERN.search(answer), (
        f"Linear equation should be uniquely solvable; got: {answer[:500]}"
    )
    assert_reasonably_concise(answer)


def assert_valid_quadratic_answer(answer: str) -> None:
    assert re.search(r"\b2\b", answer) and re.search(r"\b3\b", answer), (
        f"Expected roots 2 and 3; got: {answer[:500]}"
    )
    assert not NOT_UNIQUELY_DETERMINED_PATTERN.search(answer), (
        f"Quadratic should have definite roots; got: {answer[:500]}"
    )
    assert_reasonably_concise(answer)


def assert_valid_cubic_symmetric_answer(answer: str) -> None:
    """Raise AssertionError when a reply mishandles this underdetermined system."""
    assert NOT_UNIQUELY_DETERMINED_PATTERN.search(answer), (
        "Expected a clear statement that a³+b³+c³ is not uniquely determined; "
        f"got: {answer[:500]}"
    )
    assert not CUBIC_SUM_EQUALS_NINE_PATTERN.search(answer), (
        "Must not claim a³+b³+c³ = 9; "
        f"got: {answer[:500]}"
    )
    assert not INVENTED_ABC_EQUALS_THREE_PATTERN.search(answer), (
        "Must not invent abc = 3; "
        f"got: {answer[:500]}"
    )
    assert not ANSWER_IS_NINE_PATTERN.search(answer), (
        "Must not state the answer is 9; "
        f"got: {answer[:500]}"
    )
    assert not FORCED_NUMERIC_CUBIC_SUM_PATTERN.search(answer), (
        "Must not force a single numeric value for a³+b³+c³; "
        f"got: {answer[:500]}"
    )
    assert_no_self_correction_patterns(answer)
    assert_reasonably_concise(answer, CUBIC_MAX_ANSWER_CHARS)


def assert_valid_inconsistent_answer(answer: str) -> None:
    assert INCONSISTENT_PATTERN.search(answer), (
        f"Expected inconsistency called out; got: {answer[:500]}"
    )
    # Should not assert a unique (x, y) pair as the solution.
    assert not re.search(
        r"(?:x|y)\s*=\s*-?\d+(?:\.\d+)?\s*(?:,|and)\s*(?:x|y)\s*=\s*-?\d+",
        answer,
        re.IGNORECASE,
    ), f"Must not invent a solution pair; got: {answer[:500]}"
    assert_reasonably_concise(answer)
