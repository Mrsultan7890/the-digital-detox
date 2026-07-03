from fastapi import APIRouter, Depends
from app.middleware.auth import get_current_user
from app.models.schemas import UpdateProfileRequest
from app.utils.db import query, query_one, execute
from app.utils.streak import get_streak_info

router = APIRouter(prefix="/users", tags=["Users"])


@router.get("/profile")
async def get_profile(user=Depends(get_current_user)):
    profile = await query_one(
        """SELECT id, username, email, display_name, avatar_url, total_points,
                  hint_coins, current_streak, longest_streak, created_at, is_premium
           FROM users WHERE id = ?""",
        [user["userId"]],
    )
    return {"user": profile}


@router.get("/progress")
async def get_progress(user=Depends(get_current_user)):
    user_id = user["userId"]

    total = await query_one(
        "SELECT COUNT(*) as tasks_completed, SUM(points_earned) as total_points FROM user_progress WHERE user_id = ? AND is_completed = 1",
        [user_id],
    )

    by_category = await query(
        """
        SELECT c.id as category_id, c.name as category_name, c.icon,
               COUNT(DISTINCT CASE WHEN up.is_completed = 1 THEN t.id END) as completed,
               COUNT(DISTINCT t.id) as total
        FROM categories c
        LEFT JOIN tasks t ON c.id = t.category_id
        LEFT JOIN user_progress up ON t.id = up.task_id AND up.user_id = ?
        GROUP BY c.id ORDER BY c.sort_order
        """,
        [user_id],
    )

    return {
        "progress": {
            "totalTasksCompleted": total["tasks_completed"] if total else 0,
            "totalPoints": total["total_points"] if total else 0,
            "categoriesProgress": by_category,
        }
    }


@router.get("/achievements")
async def get_achievements(user=Depends(get_current_user)):
    achievements = await query(
        """
        SELECT a.id, a.name, a.description, a.icon,
               CASE WHEN ua.id IS NOT NULL THEN 1 ELSE 0 END as unlocked,
               ua.unlocked_at
        FROM achievements a
        LEFT JOIN user_achievements ua ON a.id = ua.achievement_id AND ua.user_id = ?
        ORDER BY unlocked DESC, a.id
        """,
        [user["userId"]],
    )
    return {"achievements": achievements}


@router.get("/streak")
async def get_streak(user=Depends(get_current_user)):
    info = await get_streak_info(user["userId"])
    return {"streak": info}


@router.put("/profile")
async def update_profile(body: UpdateProfileRequest, user=Depends(get_current_user)):
    user_id = user["userId"]
    if body.displayName:
        await execute("UPDATE users SET display_name = ? WHERE id = ?", [body.displayName, user_id])
    if body.avatarUrl is not None:
        await execute("UPDATE users SET avatar_url = ? WHERE id = ?", [body.avatarUrl, user_id])
    return {"success": True, "message": "Profile updated"}
