# Logging with Loguru

This project uses [Loguru](https://loguru.readthedocs.io/) for structured, colored logging throughout the application. Loguru provides a simple yet powerful logging interface with automatic formatting, colors, and structured output.

## Overview

The logging configuration is centralized in `src/logging_utils.py` and provides:
- **Colored output** with level-specific colors
- **Structured format** with timestamps, level indicators, and messages
- **Standard library integration** that redirects stdlib logging to Loguru
- **Configurable async logging** via environment variables

## Log Levels and Colors

The following log levels are available with their corresponding colors:

| Level | Color | Description | Usage |
|-------|-------|-------------|-------|
| `DEBUG` | Blue | Detailed diagnostic information | Debugging code flow, variable values |
| `INFO` | Cyan | General informational messages | Application status, normal operations |
| `WARNING` | Yellow | Warning messages for potential issues | Deprecated features, recoverable errors |
| `ERROR` | Red | Error messages for failures | Exceptions, failed operations |
| `CRITICAL` | Magenta | Critical system errors | System failures, unrecoverable errors |

## Changing Log Levels

### Environment Variables

You can control logging behavior using these environment variables:

```bash
# Enable asynchronous logging (default: disabled)
LOG_ASYNC=1

# Set minimum log level (configured in code, default: DEBUG)
# This would typically be set in logging_utils.py
```

### Programmatic Configuration

To change the log level programmatically, modify the `level` parameter in `src/logging_utils.py`:

```python
from loguru import logger

# Remove existing handlers
logger.remove()

# Add new handler with different level
logger.add(
    sys.stdout,
    colorize=True,
    format=LOG_FORMAT,
    level="INFO",  # Change this to desired level
    enqueue=os.getenv("LOG_ASYNC", "0") == "1",
)
```

### Runtime Log Level Changes

You can also change log levels at runtime:

```python
from loguru import logger

# Enable/disable specific levels
logger.disable("DEBUG")  # Disable DEBUG messages
logger.enable("DEBUG")   # Re-enable DEBUG messages

# Or filter by level
logger.add(sys.stdout, level="WARNING")  # Only WARNING and above
```

## Usage Examples

### Basic Logging

```python
from loguru import logger

# Different log levels
logger.debug("Detailed debugging information")
logger.info("General information about application state")
logger.warning("Something unexpected happened")
logger.error("An error occurred")
logger.critical("Critical system failure")
```

### Structured Logging

```python
from loguru import logger

# Add context to logs
logger.bind(user_id=123, action="login").info("User logged in")

# Log with extra data
logger.info("Processing request", extra={"request_id": "abc123", "endpoint": "/api/memories"})
```

### Exception Logging

```python
from loguru import logger

try:
    # Some operation that might fail
    result = risky_operation()
except Exception as e:
    # Log the full exception with traceback
    logger.exception("Failed to perform operation")
    # Or log with custom message
    logger.error("Operation failed: {}", str(e))
```

## Log Format

The current log format is defined in `src/logging_utils.py`:

```python
LOG_FORMAT = (
    "<cyan>{time:YYYY-MM-DD HH:mm:ss}</cyan> | "
    "{level.icon} <level>{level: <8}</level> | "
    "<level>{message}</level>"
)
```

This produces output like:
```
2025-01-02 10:30:45 | ℹ️ INFO     | Starting MCP server
2025-01-02 10:30:46 | ⚠️ WARNING  | Configuration file not found, using defaults
2025-01-02 10:30:47 | ❌ ERROR    | Failed to connect to database
```

## Best Practices

1. **Use appropriate log levels**: Don't log everything as INFO
2. **Include context**: Use structured logging with relevant data
3. **Avoid logging sensitive data**: Never log passwords, API keys, or personal information
4. **Use logger.exception()** for exception handling to get full tracebacks
5. **Be consistent**: Use the same logging patterns throughout the codebase

## Integration with Standard Library

The logging configuration automatically redirects standard library logging to Loguru, so existing libraries that use the standard `logging` module will work seamlessly with our Loguru setup.

## Async Logging

For high-performance applications, you can enable asynchronous logging by setting the `LOG_ASYNC=1` environment variable. This prevents logging from blocking the main thread.

## Troubleshooting

### No Log Output
- Check that the log level is set appropriately
- Ensure the logger hasn't been disabled for specific levels
- Verify that `logger.remove()` hasn't removed all handlers

### Performance Issues
- Consider enabling async logging with `LOG_ASYNC=1`
- Increase the log level to reduce output volume
- Consider adding filters for noisy modules

### Colors Not Showing
- Ensure your terminal supports ANSI colors
- Check that `colorize=True` is set in the logger configuration
- Some CI/CD environments may not support colored output
