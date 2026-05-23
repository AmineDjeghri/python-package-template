import sys
import timeit
from typing import Optional

from loguru import logger as loguru_logger
from pydantic import SecretStr
from pydantic_settings import BaseSettings, SettingsConfigDict
from pydantic import Field


# --- GLOBAL & ENVIRONMENT VARIABLES
class Settings(BaseSettings):
    """Settings class for the application."""

    # if .env is present, it will override the environment variables
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    # use .get_secret_value() to get the value
    EXAMPLE_API_KEY: Optional[SecretStr] = Field(default=None, description="the api key")
    EXAMPLE_ENDPOINT: Optional[str] = Field(default=None, description="the endpoint")

    DEV_MODE: bool = False


def time_function(func):
    def wrapper(*args, **kwargs):
        start_time = timeit.default_timer()
        result = func(*args, **kwargs)

        end_time = timeit.default_timer()
        execution_time = round(end_time - start_time, 2)
        if "reason" in result:
            result["reason"] = f" Execution time: {execution_time}s | " + result["reason"]

        if "output" in result:
            result["output"] = f" Execution time: {execution_time}s | " + result["output"]
        logger.debug(f"Function {func.__name__} took {execution_time} seconds to execute.")

        return result

    return wrapper


def initialize():
    settings = Settings()
    loguru_logger.remove()

    if settings.DEV_MODE:
        loguru_logger.add(sys.stderr, level="TRACE")
    else:
        loguru_logger.add(sys.stderr, level="INFO")

    return settings, loguru_logger


settings, logger = initialize()
