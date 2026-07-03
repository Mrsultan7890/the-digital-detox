import aiosqlite
import os
from pathlib import Path

DB_PATH = os.getenv(
    "DB_PATH",
    str(Path(__file__).resolve().parent.parent.parent.parent / "database" / "game.db")
)


async def _get_conn():
    conn = await aiosqlite.connect(DB_PATH)
    conn.row_factory = aiosqlite.Row
    await conn.execute("PRAGMA journal_mode=WAL")
    await conn.execute("PRAGMA foreign_keys=ON")
    return conn


async def query(sql: str, params: list = []) -> list[dict]:
    async with aiosqlite.connect(DB_PATH) as conn:
        conn.row_factory = aiosqlite.Row
        await conn.execute("PRAGMA foreign_keys=ON")
        async with conn.execute(sql, params) as cursor:
            rows = await cursor.fetchall()
            return [dict(row) for row in rows]


async def execute(sql: str, params: list = []) -> int:
    async with aiosqlite.connect(DB_PATH) as conn:
        await conn.execute("PRAGMA foreign_keys=ON")
        cursor = await conn.execute(sql, params)
        await conn.commit()
        return cursor.rowcount


async def query_one(sql: str, params: list = []) -> dict | None:
    results = await query(sql, params)
    return results[0] if results else None
