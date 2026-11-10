import pytest

from math_regression_assertions import (
    assert_no_self_correction_patterns,
    assert_valid_cubic_symmetric_answer,
    assert_valid_inconsistent_answer,
    assert_valid_linear_answer,
    assert_valid_quadratic_answer,
)


def test_rejects_pixel_style_wrong_answer_nine() -> None:
    wrong = (
        "Using the identity, $a^3+b^3+c^3=3abc$. With $abc=3$, we get "
        "$a^3+b^3+c^3=9$. The answer is 9."
    )
    with pytest.raises(AssertionError):
        assert_valid_cubic_symmetric_answer(wrong)


def test_rejects_cubic_self_correction_ramble() -> None:
    wrong = (
        "**Not uniquely determined.** Wait, let's check: $a^3+b^3+c^3=9$. "
        "Actually, let's try another method."
    )
    with pytest.raises(AssertionError):
        assert_valid_cubic_symmetric_answer(wrong)


def test_accepts_correct_underdetermined_conclusion() -> None:
    correct = (
        "**No unique numerical answer.** $a^3+b^3+c^3=3abc$, but $abc$ is not "
        "fixed by $a+b+c=0$ and $a^2+b^2+c^2=6$. For example $(1,1,-2)$ gives $-6$."
    )
    assert_valid_cubic_symmetric_answer(correct)


def test_linear_fixture() -> None:
    assert_valid_linear_answer(
        "**$x = 2$**\nSubtract 3: $2x = 4$. Divide by 2: $x = 2$."
    )


def test_quadratic_fixture() -> None:
    assert_valid_quadratic_answer(
        "Factor: $(x-2)(x-3)=0$, so **$x=2$ or $x=3$**."
    )


def test_inconsistent_fixture() -> None:
    assert_valid_inconsistent_answer(
        "The equations are **inconsistent**: $x+y$ cannot equal both 1 and 2."
    )


def test_self_correction_detector() -> None:
    with pytest.raises(AssertionError):
        assert_no_self_correction_patterns("Wait, let's check the value again.")
