from typing import Any

from fastapi import HTTPException


def error_response(status_code: int, code: str, message: str) -> HTTPException:
    return HTTPException(
        status_code=status_code,
        detail={"error": {"code": code, "message": message}},
    )


def error_body_from_http_exception(exc: HTTPException) -> dict[str, Any]:
    detail = exc.detail
    if isinstance(detail, dict) and "error" in detail:
        return detail
    return {
        "error": {
            "code": "internal_error",
            "message": "An unexpected error occurred.",
        },
    }
