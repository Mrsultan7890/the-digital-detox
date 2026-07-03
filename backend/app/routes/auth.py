from fastapi import APIRouter, HTTPException, status
from app.models.schemas import RegisterRequest, LoginRequest
from app.utils.db import query_one, execute
from app.utils.security import hash_password, verify_password, create_token
from app.utils.streak import update_streak
from app.utils.achievements import check_and_unlock

router = APIRouter(prefix="/auth", tags=["Auth"])


@router.post("/register")
async def register(body: RegisterRequest):
    if not body.username.strip():
        raise HTTPException(status_code=400, detail="Username is required")
    if "@" not in body.email:
        raise HTTPException(status_code=400, detail="Valid email is required")
    if len(body.password) < 6:
        raise HTTPException(status_code=400, detail="Password must be at least 6 characters")

    existing = await query_one(
        "SELECT id FROM users WHERE username = ? OR email = ?",
        [body.username, body.email],
    )
    if existing:
        raise HTTPException(status_code=409, detail="Username or email already exists")

    hashed = hash_password(body.password)
    await execute(
        "INSERT INTO users (username, email, password_hash, display_name) VALUES (?, ?, ?, ?)",
        [body.username, body.email, hashed, body.username],
    )

    user = await query_one("SELECT id, username, email FROM users WHERE username = ?", [body.username])
    token = create_token(user["id"], user["username"])

    return {"success": True, "token": token, "user": user}


@router.post("/login")
async def login(body: LoginRequest):
    user = await query_one(
        """SELECT id, username, email, password_hash, total_points, hint_coins, current_streak
           FROM users WHERE username = ? OR email = ?""",
        [body.username, body.username],
    )

    if not user or not verify_password(body.password, user["password_hash"]):
        raise HTTPException(status_code=401, detail="Invalid credentials")

    await execute(
        "UPDATE users SET last_login = CURRENT_TIMESTAMP WHERE id = ?",
        [user["id"]],
    )

    await update_streak(user["id"])
    await check_and_unlock(user["id"])

    token = create_token(user["id"], user["username"])

    return {
        "success": True,
        "token": token,
        "user": {
            "id": user["id"],
            "username": user["username"],
            "email": user["email"],
            "totalPoints": user["total_points"],
            "hintCoins": user["hint_coins"],
            "currentStreak": user["current_streak"],
        },
    }
