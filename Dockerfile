# Stage 1: resolve and install the dependencies with uv into a virtual environment.
FROM ghcr.io/astral-sh/uv:0.9-python3.12-bookworm-slim AS build
ENV UV_COMPILE_BYTECODE=1 UV_LINK_MODE=copy UV_PYTHON_DOWNLOADS=never
WORKDIR /app
COPY pyproject.toml uv.lock README.md ./
RUN uv sync --frozen --no-dev --no-install-project
COPY src/ ./src/
RUN uv sync --frozen --no-dev

# Stage 2: the runtime image, without uv, as a non-root user.
# No BuildKit features (no RUN --mount): Azure Container Registry builds without BuildKit.
FROM python:3.12-slim-bookworm
# A font for the text of the PNG diagrams (resvg draws text with the system's fonts; the slim image has none).
RUN apt-get update && apt-get install --yes --no-install-recommends fonts-dejavu-core \
    && rm -rf /var/lib/apt/lists/*
RUN groupadd --system agent && useradd --system --gid agent --create-home agent
WORKDIR /app
COPY --from=build --chown=agent:agent /app/.venv /app/.venv
# The package, with its static files: src/ms_agent/static/microsoft-logo.png is served at /logo.png.
COPY --from=build --chown=agent:agent /app/src /app/src
# VM size snapshots (read by the agent) and the nightly price refresh (the scheduled job runs
# `python jobs/refresh_prices.py` in this same image).
COPY --chown=agent:agent data/ /app/data/
COPY --chown=agent:agent jobs/ /app/jobs/
# /app is not writable by the agent user: the default SQLite price store and the made files go to /tmp.
# In Azure, MS_AGENT_PRICE_DB_URL names the PostgreSQL store shared with the job, and
# MS_AGENT_FILES_BACKEND=blob keeps the files in Blob Storage.
ENV PATH="/app/.venv/bin:$PATH" PYTHONUNBUFFERED=1 PYTHONDONTWRITEBYTECODE=1 \
    MS_AGENT_PRICE_DB_URL=sqlite:////tmp/prices.sqlite3 MS_AGENT_FILES_DIR=/tmp/ms-agent-files
USER agent
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s CMD python -c \
    "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8080/healthz', timeout=4)" || exit 1
CMD ["python", "-m", "uvicorn", "ms_agent.main:create_app", "--factory", "--host", "0.0.0.0", "--port", "8080"]
