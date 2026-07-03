from pydantic import BaseModel, EmailStr


class RegisterRequest(BaseModel):
    username: str
    email: str
    password: str


class LoginRequest(BaseModel):
    username: str
    password: str


class SubmitAnswerRequest(BaseModel):
    answer: str
    timeTaken: int | None = None


class HintRequest(BaseModel):
    hintLevel: int = 1


class UpdateProfileRequest(BaseModel):
    displayName: str | None = None
    avatarUrl: str | None = None
