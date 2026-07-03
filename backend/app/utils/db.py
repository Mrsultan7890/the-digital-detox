import os
import httpx
from dotenv import load_dotenv

load_dotenv()

TURSO_URL = os.getenv("TURSO_DATABASE_URL", "")
TURSO_TOKEN = os.getenv("TURSO_AUTH_TOKEN", "")


async def query(sql: str, params: list = []) -> list[dict]:
    async with httpx.AsyncClient() as client:
        response = await client.post(
            TURSO_URL,
            headers={
                "Authorization": f"Bearer {TURSO_TOKEN}",
                "Content-Type": "application/json",
            },
            json={"statements": [{"q": sql, "params": params}]},
        )
        response.raise_for_status()
        data = response.json()
        return _parse_results(data)


async def execute(sql: str, params: list = []) -> int:
    async with httpx.AsyncClient() as client:
        response = await client.post(
            TURSO_URL,
            headers={
                "Authorization": f"Bearer {TURSO_TOKEN}",
                "Content-Type": "application/json",
            },
            json={"statements": [{"q": sql, "params": params}]},
        )
        response.raise_for_status()
        data = response.json()
        return data[0].get("results", {}).get("rows_affected", 0)


async def query_one(sql: str, params: list = []) -> dict | None:
    results = await query(sql, params)
    return results[0] if results else None


def _parse_results(data: list) -> list[dict]:
    try:
        result = data[0].get("results", {})
        if not result or not result.get("rows"):
            return []
        columns = result["columns"]
        rows = result["rows"]
        return [dict(zip(columns, row)) for row in rows]
    except Exception as e:
        print(f"❌ Error parsing results: {e}")
        return []
