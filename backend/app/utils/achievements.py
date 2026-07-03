from app.utils.db import query, query_one, execute


async def check_and_unlock(user_id: int):
    # Get user stats
    stats = await query_one(
        """
        SELECT u.total_points, u.longest_streak,
               COUNT(DISTINCT up.task_id) as tasks_completed
        FROM users u
        LEFT JOIN user_progress up ON u.id = up.user_id AND up.is_completed = 1
        WHERE u.id = ?
        GROUP BY u.id
        """,
        [user_id],
    )
    if not stats:
        return

    # Get locked achievements
    locked = await query(
        """
        SELECT * FROM achievements
        WHERE id NOT IN (
            SELECT achievement_id FROM user_achievements WHERE user_id = ?
        )
        """,
        [user_id],
    )

    for achievement in locked:
        req_type = achievement["requirement_type"]
        req_value = achievement["requirement_value"]
        should_unlock = False

        if req_type == "tasks_completed":
            should_unlock = (stats["tasks_completed"] or 0) >= req_value
        elif req_type == "points":
            should_unlock = (stats["total_points"] or 0) >= req_value
        elif req_type == "streak":
            should_unlock = (stats["longest_streak"] or 0) >= req_value
        elif req_type == "category_master":
            should_unlock = await _check_category_master(user_id)

        if should_unlock:
            await execute(
                "INSERT INTO user_achievements (user_id, achievement_id) VALUES (?, ?)",
                [user_id, achievement["id"]],
            )
            # Bonus points for achievement
            await execute(
                "UPDATE users SET total_points = total_points + 100 WHERE id = ?",
                [user_id],
            )


async def _check_category_master(user_id: int) -> bool:
    result = await query_one(
        """
        SELECT COUNT(*) as count FROM (
            SELECT t.category_id FROM tasks t
            LEFT JOIN user_progress up ON t.id = up.task_id AND up.user_id = ? AND up.is_completed = 1
            GROUP BY t.category_id
            HAVING COUNT(t.id) = COUNT(up.task_id)
        )
        """,
        [user_id],
    )
    return (result["count"] if result else 0) > 0
