from fastapi import APIRouter, Depends, Query
from app.middleware.auth import get_current_user
from app.utils.db import query

router = APIRouter(prefix="/leaderboard", tags=["Leaderboard"])


@router.get("/global")
async def global_leaderboard(limit: int = Query(50, le=100), user=Depends(get_current_user)):
    leaderboard = await query(
        """
        SELECT u.id, u.username, u.display_name, u.avatar_url,
               u.total_points, u.current_streak,
               COUNT(DISTINCT up.task_id) as tasks_completed,
               ROW_NUMBER() OVER (ORDER BY u.total_points DESC) as rank
        FROM users u
        LEFT JOIN user_progress up ON u.id = up.user_id AND up.is_completed = 1
        GROUP BY u.id
        ORDER BY u.total_points DESC
        LIMIT ?
        """,
        [limit],
    )
    return {"leaderboard": leaderboard}


@router.get("/category/{category_id}")
async def category_leaderboard(category_id: int, limit: int = Query(50, le=100), user=Depends(get_current_user)):
    leaderboard = await query(
        """
        SELECT u.id, u.username, u.display_name,
               SUM(up.points_earned) as category_points,
               COUNT(DISTINCT up.task_id) as tasks_completed,
               ROW_NUMBER() OVER (ORDER BY SUM(up.points_earned) DESC) as rank
        FROM users u
        JOIN user_progress up ON u.id = up.user_id AND up.is_completed = 1
        JOIN tasks t ON up.task_id = t.id
        WHERE t.category_id = ?
        GROUP BY u.id
        ORDER BY category_points DESC
        LIMIT ?
        """,
        [category_id, limit],
    )
    return {"categoryId": category_id, "leaderboard": leaderboard}
