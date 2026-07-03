import random
from datetime import date
from app.utils.db import query, query_one, execute


async def generate_daily_challenge():
    today = str(date.today())

    existing = await query_one(
        "SELECT id FROM daily_challenges WHERE challenge_date = ?", [today]
    )
    if existing:
        return

    tasks = await query(
        "SELECT id FROM tasks WHERE difficulty IN ('intermediate', 'advanced', 'expert')"
    )
    if not tasks:
        return

    task = random.choice(tasks)
    bonus = random.randint(20, 50)

    await execute(
        "INSERT INTO daily_challenges (task_id, challenge_date, bonus_points) VALUES (?, ?, ?)",
        [task["id"], today, bonus],
    )


async def get_todays_challenge() -> dict | None:
    today = str(date.today())
    return await query_one(
        """
        SELECT t.id, t.title, t.description, t.question, t.difficulty,
               t.points_reward, dc.bonus_points, dc.challenge_date
        FROM daily_challenges dc
        JOIN tasks t ON dc.task_id = t.id
        WHERE dc.challenge_date = ?
        """,
        [today],
    )


async def is_completed_today(user_id: int) -> bool:
    today = str(date.today())
    result = await query_one(
        """
        SELECT up.is_completed FROM daily_challenges dc
        JOIN user_progress up ON dc.task_id = up.task_id AND up.user_id = ?
        WHERE dc.challenge_date = ? AND up.is_completed = 1
        """,
        [user_id, today],
    )
    return result is not None


async def award_bonus(user_id: int, task_id: int):
    today = str(date.today())
    challenge = await query_one(
        "SELECT bonus_points FROM daily_challenges WHERE task_id = ? AND challenge_date = ?",
        [task_id, today],
    )
    if not challenge:
        return
    await execute(
        "UPDATE users SET total_points = total_points + ? WHERE id = ?",
        [challenge["bonus_points"], user_id],
    )
