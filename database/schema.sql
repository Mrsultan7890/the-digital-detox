-- Digital Detox Game Database Schema

-- Users Table
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT UNIQUE NOT NULL,
    email TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    display_name TEXT,
    avatar_url TEXT,
    total_points INTEGER DEFAULT 0,
    hint_coins INTEGER DEFAULT 10,
    current_streak INTEGER DEFAULT 0,
    longest_streak INTEGER DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    last_login DATETIME,
    is_premium BOOLEAN DEFAULT 0
);

-- Categories Table
CREATE TABLE categories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT,
    icon TEXT,
    color TEXT,
    sort_order INTEGER
);

-- Levels/Tasks Table
CREATE TABLE tasks (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    category_id INTEGER NOT NULL,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    difficulty TEXT CHECK(difficulty IN ('beginner', 'intermediate', 'advanced', 'expert')),
    level_number INTEGER NOT NULL,
    task_type TEXT CHECK(task_type IN ('search_quest', 'quiz', 'cipher', 'image_hunt', 'fact_check', 'timeline', 'connection')),
    question TEXT NOT NULL,
    correct_answer TEXT NOT NULL,
    hint_1 TEXT,
    hint_2 TEXT,
    hint_3 TEXT,
    points_reward INTEGER DEFAULT 10,
    time_limit INTEGER, -- in seconds, NULL for no limit
    reference_links TEXT, -- JSON array of helpful links
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    is_daily_challenge BOOLEAN DEFAULT 0,
    FOREIGN KEY (category_id) REFERENCES categories(id)
);

-- Quiz Options (for multiple choice tasks)
CREATE TABLE quiz_options (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    task_id INTEGER NOT NULL,
    option_text TEXT NOT NULL,
    is_correct BOOLEAN DEFAULT 0,
    sort_order INTEGER,
    FOREIGN KEY (task_id) REFERENCES tasks(id)
);

-- User Progress Table
CREATE TABLE user_progress (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    task_id INTEGER NOT NULL,
    is_completed BOOLEAN DEFAULT 0,
    attempts INTEGER DEFAULT 0,
    hints_used INTEGER DEFAULT 0,
    time_taken INTEGER, -- in seconds
    points_earned INTEGER DEFAULT 0,
    completed_at DATETIME,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (task_id) REFERENCES tasks(id),
    UNIQUE(user_id, task_id)
);

-- Achievements Table
CREATE TABLE achievements (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT,
    icon TEXT,
    requirement_type TEXT, -- 'streak', 'points', 'tasks_completed', 'category_master'
    requirement_value INTEGER,
    badge_image TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- User Achievements Table
CREATE TABLE user_achievements (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    achievement_id INTEGER NOT NULL,
    unlocked_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (achievement_id) REFERENCES achievements(id),
    UNIQUE(user_id, achievement_id)
);

-- Daily Challenges Table
CREATE TABLE daily_challenges (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    task_id INTEGER NOT NULL,
    challenge_date DATE NOT NULL,
    bonus_points INTEGER DEFAULT 20,
    FOREIGN KEY (task_id) REFERENCES tasks(id),
    UNIQUE(challenge_date)
);

-- Leaderboard View
CREATE VIEW leaderboard AS
SELECT 
    u.id,
    u.username,
    u.display_name,
    u.avatar_url,
    u.total_points,
    u.current_streak,
    COUNT(DISTINCT up.task_id) as tasks_completed,
    RANK() OVER (ORDER BY u.total_points DESC) as rank
FROM users u
LEFT JOIN user_progress up ON u.id = up.user_id AND up.is_completed = 1
GROUP BY u.id
ORDER BY u.total_points DESC;

-- Indexes for performance
CREATE INDEX idx_user_progress_user_id ON user_progress(user_id);
CREATE INDEX idx_user_progress_task_id ON user_progress(task_id);
CREATE INDEX idx_tasks_category ON tasks(category_id);
CREATE INDEX idx_tasks_difficulty ON tasks(difficulty);
CREATE INDEX idx_users_points ON users(total_points DESC);
