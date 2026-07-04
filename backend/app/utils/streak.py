from datetime import datetime, date
from app.utils.db import query_one, execute


async def update_streak(user_id: int):
    user = await query_one(
        "SELECT current_streak, longest_streak, last_login FROM users WHERE id = ?",
        [user_id],
    )
    if not user:
        return

    today = date.today()
    current_streak = user["current_streak"] or 0
    longest_streak = user["longest_streak"] or 0
    last_login = user["last_login"]

    if last_login:
        try:
            last_date = datetime.fromisoformat(last_login.replace(' ', 'T')).date()
        except ValueError:
            last_date = None

        if last_date is None:
            current_streak = 1
        else:
            diff = (today - last_date).days
            if diff == 0:
                return
            elif diff == 1:
                current_streak += 1
            else:
                current_streak = 1
    else:
        current_streak = 1  # first login

    if current_streak > longest_streak:
        longest_streak = current_streak

    # Award bonus every 7 days
    if current_streak % 7 == 0:
        bonus_points = (current_streak // 7) * 50
        bonus_coins = current_streak // 7
        await execute(
            "UPDATE users SET total_points = total_points + ?, hint_coins = hint_coins + ? WHERE id = ?",
            [bonus_points, bonus_coins, user_id],
        )

    await execute(
        "UPDATE users SET current_streak = ?, longest_streak = ? WHERE id = ?",
        [current_streak, longest_streak, user_id],
    )


async def get_streak_info(user_id: int) -> dict:
    user = await query_one(
        "SELECT current_streak, longest_streak FROM users WHERE id = ?",
        [user_id],
    )
    current = user["current_streak"] if user else 0
    longest = user["longest_streak"] if user else 0
    next_reward = ((current // 7) + 1) * 7

    return {
        "currentStreak": current,
        "longestStreak": longest,
        "nextReward": next_reward,
        "daysUntilReward": next_reward - current,
    }
