FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# System deps for psycopg2 and docling (libpq, curl)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        cron \
        libpq-dev \
        curl && \
    rm -rf /var/lib/apt/lists/*

# Install Python deps first to leverage layer caching
COPY pyproject.toml uv.lock* README.md ./
RUN pip install --upgrade pip && \
    pip install --no-cache-dir uv && \
    uv pip install --system . && \
    uv cache clean

# Copy source
COPY app ./app
COPY main.py .

CMD ["sh", "-c", "uv run --frozen app/database/create_tables.py && uv run --frozen main.py 24 10"]
