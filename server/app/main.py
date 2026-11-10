from typing import Annotated

from fastapi import Depends, FastAPI, HTTPException, Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field

from app.config import Settings, get_settings
from app.errors import error_response
from app.gemini_client import (
    EmptyProviderResponseError,
    ProviderConnectionError,
    ProviderError,
    ProviderRateLimitedError,
    ProviderTimeoutError,
    solve_question,
)

app = FastAPI(title="SolveLens API", version="1.0.0")


class SolveRequest(BaseModel):
    question: str = Field(..., min_length=1)


class SolveResponse(BaseModel):
    answer: str


def get_settings_dep() -> Settings:
    return get_settings()


@app.exception_handler(HTTPException)
async def http_exception_handler(
    _request: Request, exc: HTTPException
) -> JSONResponse:
    detail = exc.detail
    if isinstance(detail, dict) and "error" in detail:
        return JSONResponse(status_code=exc.status_code, content=detail)
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "error": {
                "code": "internal_error",
                "message": "An unexpected error occurred.",
            },
        },
    )


@app.exception_handler(RequestValidationError)
async def validation_exception_handler(
    _request: Request, exc: RequestValidationError
) -> JSONResponse:
    return JSONResponse(
        status_code=400,
        content={
            "error": {
                "code": "invalid_request",
                "message": "A non-empty question is required.",
            },
        },
    )


@app.get("/health")
async def health() -> dict[str, str]:
    return {"status": "ok"}


@app.post("/v1/solve", response_model=SolveResponse)
async def solve(
    body: SolveRequest,
    settings: Annotated[Settings, Depends(get_settings_dep)],
) -> SolveResponse:
    question = body.question.strip()
    if not question:
        raise error_response(400, "invalid_request", "A non-empty question is required.")
    if len(question) > settings.max_question_length:
        raise error_response(
            400,
            "question_too_long",
            f"Question must be at most {settings.max_question_length} characters.",
        )

    try:
        answer = solve_question(settings, question)
    except ProviderRateLimitedError:
        raise error_response(
            429,
            "rate_limited",
            "The AI service is busy. Please try again shortly.",
        )
    except ProviderTimeoutError:
        raise error_response(
            504,
            "provider_timeout",
            "The AI service timed out. Please try again.",
        )
    except ProviderConnectionError:
        raise error_response(
            502,
            "provider_error",
            "Could not reach the AI service. Please try again.",
        )
    except EmptyProviderResponseError:
        raise error_response(
            502,
            "provider_error",
            "The AI service returned an empty response.",
        )
    except ProviderError:
        raise error_response(
            502,
            "provider_error",
            "The AI service encountered an error.",
        )

    return SolveResponse(answer=answer)
