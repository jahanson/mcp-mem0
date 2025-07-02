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
# Cache mounts use uid=65534,gid=65534 (nobody user/group)
RUN --mount=type=cache,target=/tmp/.cache/pip,uid=65534,gid=65534 \
  --mount=type=cache,target=/tmp/.cache/uv,uid=65534,gid=65534 \
  pip install --upgrade pip uv

# Copy dependency files first for better layer caching
COPY pyproject.toml ./

# RUN Layer 3: [App] Application dependencies
RUN python -m venv .venv \
  && .venv/bin/pip install --no-cache-dir -e . \
  && mkdir -p /app/.mem0 && chown nobody:nobody /app/.mem0

# Copy application code last (most frequently changed)
COPY src/ ./src/

# Switch to non-root user and set home directory, MEM0 requires HOME to be set.
USER nobody
ENV HOME=/app \
  MEM0_HOME=/app/.mem0

EXPOSE ${PORT}

# Command to run the MCP server
CMD ["catatonit", "--", ".venv/bin/python", "src/main.py"]
