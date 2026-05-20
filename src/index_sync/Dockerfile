FROM python:3.11-slim

WORKDIR /app

COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

COPY pyproject.toml ./
COPY uv.lock* ./

RUN uv sync --no-dev --frozen

COPY src/ ./src/

ENV PYTHONPATH=/app
ENV PYTHONUNBUFFERED=1

# Container App job — runs to completion, no long-lived server
CMD ["uv", "run", "python", "-m", "src.index_sync.worker"]
