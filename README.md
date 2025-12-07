
ai-news-aggregator-project

Daily pipeline that scrapes AI news (YouTube, OpenAI RSS, Anthropic RSS), stores it in Postgres, summarizes with OpenAI, ranks, and emails a digest.

## Run locally
1) Create `.env` from `app/example.env` and fill `OPENAI_API_KEY`, `MY_EMAIL`, `APP_PASSWORD`. Keep `POSTGRES_HOST=localhost` for local.
2) Start Postgres (or use Docker below).
3) Install deps: `uv pip install --system .`
4) Create tables: `uv run app/database/create_tables.py`
5) Run pipeline: `uv run main.py 24 10` (hours window, top N for email)

## Run with Docker
1) Copy `app/example.env` to `app/.env` and fill secrets. `POSTGRES_HOST` will be overridden to `postgres` in compose.
2) Build and run: `docker compose up --build`
   - Postgres runs as `postgres` service.
   - `app` service waits for Postgres health, then creates tables and runs `uv run main.py 24 10` once.
   - `scheduler` service installs a cron entry to run `uv run main.py 24 10` daily at 07:00 UTC. Logs are in `scheduler` service (`docker compose logs -f scheduler`).
3) Stop: `docker compose down`
4) To start only the database (no app builds): `docker compose up postgres`
5) To start app + scheduler: `docker compose --profile app up --build`

## Notes
- Requires OpenAI Responses API access.
- Email sending uses Gmail SMTP; use an app password.
- `docling` may need extra system deps depending on converter features. The Docker image installs base build tools and libpq; add more if conversion fails.