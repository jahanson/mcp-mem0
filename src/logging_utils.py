from loguru import logger
import sys, os, logging

LOG_FORMAT = (
    "<cyan>{time:YYYY-MM-DD HH:mm:ss}</cyan> | "
    "{level.icon} <level>{level: <8}</level> | "
    "<level>{message}</level>"
)

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
    colorize=True,
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
