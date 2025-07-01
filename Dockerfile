FROM python:3.13.5-alpine

ARG PORT=8050

WORKDIR /app

# RUN Layer 1: [APK] System dependencies
RUN apk add --no-cache ca-certificates catatonit

# RUN Layer 2: [Python] System Python dependencies
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --upgrade pip uv

# Copy the application files
COPY . .

# RUN Layer 3: [App] Application dependencies
RUN python -m venv .venv \
    && .venv/bin/pip install --no-cache-dir -e .

# Switch to non-root user
USER nobody

EXPOSE ${PORT}

# Command to run the MCP server
CMD ["catatonit", "--", "uv", "run", "src/main.py"]
