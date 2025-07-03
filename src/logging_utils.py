from loguru import logger
import sys, os, logging

LOG_FORMAT = "<green>{time:YYYY-MM-DD HH:mm:ss.SSS}</green> | <level>{level}</level> | {message}"

COLOR_LEVELS = {
    "DEBUG": "blue",
    "INFO": "cyan",
    "WARNING": "yellow",
    "ERROR": "red",
    "CRITICAL": "magenta",
}

# Remove default handler and add our own
logger.remove()
logger.add(
    sys.stdout,
    colorize=not sys.platform.startswith("win"),
    format=LOG_FORMAT,
    level="DEBUG",
    enqueue=os.getenv("LOG_ASYNC", "0") == "1",
)

# Redirect stdlib logging -> loguru (so existing libraries still work)
class InterceptHandler(logging.Handler):
    def emit(self, record):
        logger_opt = logger.bind(request_id="stdlib")
        logger_opt.log(record.levelno, record.getMessage())

logging.basicConfig(handlers=[InterceptHandler()], level=0, force=True)
