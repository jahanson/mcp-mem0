FROM python:3.13.5-alpine

ARG PORT=8050

# Add OCI labels for image metadata
LABEL org.opencontainers.image.source="https://github.com/jahanson/mcp-mem0" \
    org.opencontainers.image.description="An MCP server implementation using Mem0." \
    org.opencontainers.image.licenses="MIT"

WORKDIR /app

# RUN Layer 1: [APK] System dependencies
RUN apk add --no-cache ca-certificates catatonit

# RUN Layer 2: [Python] System Python dependencies
RUN --mount=type=cache,target=/root/.cache/pip \
    --mount=type=cache,target=/.cache/uv \
    pip install --upgrade pip uv \
    && mkdir -p /.cache/uv && chown nobody:nobody /.cache/uv

# Copy the application files
COPY . .

# RUN Layer 3: [App] Application dependencies
RUN python -m venv .venv \
    && .venv/bin/pip install --no-cache-dir -e . \
    && mkdir -p /.mem0 /app/.mem0 && chown nobody:nobody /.mem0 /app/.mem0

# Switch to non-root user and set MEM0_HOME to writable directory
USER nobody
ENV MEM0_HOME=/app/.mem0

EXPOSE ${PORT}

# Command to run the MCP server
CMD ["catatonit", "--", ".venv/bin/python", "src/main.py"]
