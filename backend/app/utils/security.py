import os
import bcrypt
from datetime import datetime, timedelta, timezone
from jose import JWTError, jwt
from dotenv import load_dotenv

load_dotenv()

SECRET_KEY = os.getenv("JWT_SECRET", "changethis_in_production")
ALGORITHM = "HS256"
EXPIRE_DAYS = int(os.getenv("JWT_EXPIRE_DAYS", "7"))


def hash_password(password: str) -> str:
    return bcrypt.hashpw(password.encode(), bcrypt.gensalt()).decode()


def verify_password(plain: str, hashed: str) -> bool:
    return bcrypt.checkpw(plain.encode(), hashed.encode())


def create_token(user_id: int, username: str) -> str:
    payload = {
        "userId": user_id,
        "username": username,
        "exp": datetime.now(timezone.utc) + timedelta(days=EXPIRE_DAYS),
    }
    return jwt.encode(payload, SECRET_KEY, algorithm=ALGORITHM)


def decode_token(token: str) -> dict | None:
    try:
        return jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
    except JWTError:
        return None
