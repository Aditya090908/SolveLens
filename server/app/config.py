from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8")

    gemini_api_key: str
    gemini_model: str = "gemini-3.5-flash-lite"
    max_question_length: int = 4000
    max_output_tokens: int = 640


def get_settings() -> Settings:
    return Settings()
