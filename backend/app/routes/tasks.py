from fastapi import APIRouter, Depends, HTTPException
from app.middleware.auth import get_current_user
from app.models.schemas import SubmitAnswerRequest, HintRequest
from app.utils.db import query, query_one, execute
from app.utils.achievements import check_and_unlock
from app.utils.daily_challenge import get_todays_challenge, generate_daily_challenge, is_completed_today, award_bonus

router = APIRouter(prefix="/tasks", tags=["Tasks"])


@router.get("/categories")
async def get_categories(user=Depends(get_current_user)):
    categories = await query("SELECT * FROM categories ORDER BY sort_order")
    return {"categories": categories}


@router.get("/daily")
async def get_daily_challenge(user=Depends(get_current_user)):
    challenge = await get_todays_challenge()
    if not challenge:
        await generate_daily_challenge()
        challenge = await get_todays_challenge()

    completed = await is_completed_today(user["userId"]) if challenge else False
    return {"challenge": challenge, "completed": completed}


@router.get("/category/{category_id}")
async def get_tasks_by_category(category_id: int, user=Depends(get_current_user)):
    tasks = await query(
        """
        SELECT t.id, t.title, t.description, t.difficulty, t.level_number,
               t.task_type, t.points_reward, t.time_limit, t.is_daily_challenge,
               CASE WHEN up.is_completed = 1 THEN 1 ELSE 0 END as completed
        FROM tasks t
        LEFT JOIN user_progress up ON t.id = up.task_id AND up.user_id = ?
        WHERE t.category_id = ?
        ORDER BY t.level_number
        """,
        [user["userId"], category_id],
    )
    return {"categoryId": category_id, "tasks": tasks}


@router.get("/{task_id}")
async def get_task(task_id: int, user=Depends(get_current_user)):
    task = await query_one(
        """
        SELECT t.id, t.title, t.description, t.difficulty, t.level_number,
               t.task_type, t.question, t.points_reward, t.time_limit,
               CASE WHEN up.is_completed = 1 THEN 1 ELSE 0 END as completed,
               up.hints_used
        FROM tasks t
        LEFT JOIN user_progress up ON t.id = up.task_id AND up.user_id = ?
        WHERE t.id = ?
        """,
        [user["userId"], task_id],
    )
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")
    return task


@router.post("/{task_id}/submit")
async def submit_answer(task_id: int, body: SubmitAnswerRequest, user=Depends(get_current_user)):
    user_id = user["userId"]
    user_answer = body.answer.strip().lower()

    task = await query_one(
        "SELECT id, correct_answer, points_reward FROM tasks WHERE id = ?",
        [task_id],
    )
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")

    # Check already completed
    progress = await query_one(
        "SELECT is_completed FROM user_progress WHERE user_id = ? AND task_id = ?",
        [user_id, task_id],
    )
    if progress and progress["is_completed"] == 1:
        return {"correct": True, "pointsEarned": 0, "alreadyCompleted": True, "message": "Already completed!"}

    correct_answer = task["correct_answer"].strip().lower()
    is_correct = user_answer == correct_answer
    points_earned = task["points_reward"] if is_correct else 0

    if is_correct:
        if progress:
            await execute(
                "UPDATE user_progress SET is_completed=1, completed_at=CURRENT_TIMESTAMP, time_taken=?, points_earned=? WHERE user_id=? AND task_id=?",
                [body.timeTaken or 0, points_earned, user_id, task_id],
            )
        else:
            await execute(
                "INSERT INTO user_progress (user_id, task_id, is_completed, time_taken, points_earned, completed_at) VALUES (?,?,1,?,?,CURRENT_TIMESTAMP)",
                [user_id, task_id, body.timeTaken or 0, points_earned],
            )
        await execute(
            "UPDATE users SET total_points = total_points + ? WHERE id = ?",
            [points_earned, user_id],
        )
        await award_bonus(user_id, task_id)
        await check_and_unlock(user_id)
    else:
        if progress:
            await execute(
                "UPDATE user_progress SET attempts = attempts + 1 WHERE user_id=? AND task_id=?",
                [user_id, task_id],
            )
        else:
            await execute(
                "INSERT INTO user_progress (user_id, task_id, attempts) VALUES (?,?,1)",
                [user_id, task_id],
            )

    return {
        "correct": is_correct,
        "pointsEarned": points_earned,
        "message": "Correct! Well done! 🎉" if is_correct else "Incorrect. Try again! 💪",
    }


@router.post("/{task_id}/hint")
async def get_hint(task_id: int, body: HintRequest, user=Depends(get_current_user)):
    user_id = user["userId"]

    user_data = await query_one("SELECT hint_coins FROM users WHERE id = ?", [user_id])
    if not user_data or user_data["hint_coins"] < 1:
        raise HTTPException(status_code=403, detail="Not enough hint coins")

    if body.hintLevel not in (1, 2, 3):
        raise HTTPException(status_code=400, detail="Invalid hint level")
    hint_col = f"hint_{body.hintLevel}"
    task = await query_one(f"SELECT {hint_col} as hint FROM tasks WHERE id = ?", [task_id])

    if not task or not task["hint"]:
        raise HTTPException(status_code=404, detail="Hint not available")

    await execute("UPDATE users SET hint_coins = hint_coins - 1 WHERE id = ?", [user_id])
    await execute(
        "INSERT INTO user_progress (user_id, task_id, hints_used) VALUES (?,?,1) ON CONFLICT(user_id, task_id) DO UPDATE SET hints_used = hints_used + 1",
        [user_id, task_id],
    )

    return {"hint": task["hint"], "coinsRemaining": user_data["hint_coins"] - 1}
