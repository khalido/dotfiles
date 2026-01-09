---
name: python
description: Python development preferences. Use when writing Python code, CLI tools, APIs, or scripts.
---

# Python Development

## Philosophy

Readable, concise code. Function names and type hints should make purpose clear without verbose docstrings.

## Tooling

- **Package manager**: [`uv`](https://docs.astral.sh/uv/llms.txt) - new projects: `uv init --python 3.14`
- **Linting/formatting**: `ruff`
- **Testing**: `pytest`
- **Logging**: `loguru`

## Preferred Libraries

| Purpose | Library |
|---------|---------|
| CLI tools | `typer` |
| CLI output | `rich` (when needed) |
| HTTP clients | `httpx` |
| Web APIs | `fastapi` + `uvicorn` |
| DataFrames | `polars` |
| ORM | `sqlmodel` (Pydantic + SQLAlchemy) |

## Code Style

- Type hints on function signatures
- Small, focused functions
- `pathlib` for paths
- `dataclasses` or Pydantic for structured data
- SQLite for prototyping, Postgres for prod

## Docstrings

Minimal but useful. Skip verbose Google/NumPy style. Answer: "what does this return in practice?"
```python
def fetch_weather(city: str) -> dict[str, float]:
    """Get current weather from OpenWeatherMap API.

    Returns {"temp": 24.5, "humidity": 65.0, "wind_speed": 12.3}
    """
```

Include: what it does (if name isn't obvious), what's actually returned (not just the type), optional example for complex functions.

## Google APIs

Use Google SDKs directly (gspread and similar wrappers are outdated/unmaintained).
```bash
uv add google-api-python-client google-auth-httplib2 google-auth-oauthlib
```

Refs: [Sheets quickstart](https://developers.google.com/workspace/sheets/api/quickstart/python), [reading values](https://developers.google.com/workspace/sheets/api/guides/values#python)

## Local Testing

Expose local servers via Cloudflare tunnel:
```bash
cloudflared tunnel --url http://localhost:8000
```

## Deployment

Railway for FastAPI projects. Volumes required for persistent files (SQLite db, credentials.json).

Ref: [Railway LLM docs](https://docs.railway.com/api/llms-docs.md)
