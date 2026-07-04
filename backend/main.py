import os
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv
from app.routes import auth, tasks, users, leaderboard

load_dotenv()

app = FastAPI(title="Digital Detox API", version="1.0.0")

_allowed_origins = os.getenv("ALLOWED_ORIGINS", "http://localhost:3000").split(",")

app.add_middleware(
    CORSMiddleware,
    allow_origins=_allowed_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router, prefix="/api")
app.include_router(tasks.router, prefix="/api")
app.include_router(users.router, prefix="/api")
app.include_router(leaderboard.router, prefix="/api")


@app.get("/health")
async def health():
    return {"status": "ok", "message": "Digital Detox API is running! 🚀"}
