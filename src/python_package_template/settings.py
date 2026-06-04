import sys
import timeit
from typing import Optional

from loguru import logger as _loguru_logger
from pydantic import Field, SecretStr
from pydantic_settings import BaseSettings, SettingsConfigDict
from pydantic import AliasChoices


# --- GLOBAL & ENVIRONMENT VARIABLES
class ApplicationSettings(BaseSettings):
    """Configuration for python-package-template.

    Values are read from environment variables and optionally
    overridden by a ``.env`` file.
    """

    # if .env is present, it will override the environment variables
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    # use .get_secret_value() to get the value
    EXAMPLE_API_KEY: Optional[SecretStr] = Field(default=None, description="the api key")
    EXAMPLE_ENDPOINT: Optional[str] = Field(default=None, description="the endpoint")

    logging_level: str = Field(
        default="DEBUG",
        validation_alias=AliasChoices("LOGGING_LEVEL", "logging_level"),
        description="Log level (TRACE, DEBUG, INFO, WARNING, ERROR, CRITICAL)",
    )

    def model_post_init(self, __context):
        """Called after model initialization."""
        pass


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


def _initialize_logger(settings: ApplicationSettings):
    """Initialize the loguru logger with app-specific configuration."""
    level = settings.logging_level

    try:
        _loguru_logger.remove(0)
    except ValueError:
        pass

    _loguru_logger.add(
        sys.stderr,
        level=level,
        filter=lambda record: record["extra"].get("name") == "python_package_template",
    )

    return _loguru_logger.bind(name="python_package_template")


settings = ApplicationSettings()
logger = _initialize_logger(settings)
