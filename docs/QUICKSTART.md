# Digital Detox - Quick Start Guide

## 🚀 5-Minute Setup

### Step 1: Install Prerequisites

```bash
# Check if Dart is installed
dart --version

# If not installed, download from: https://dart.dev/get-dart
```

### Step 2: Setup Turso Database

```bash
# Install Turso CLI
curl -sSfL https://get.tur.so/install.sh | bash

# Login
turso auth login

# Create database
turso db create digital-detox

# Get database URL (copy this)
turso db show digital-detox --url

# Create auth token (copy this)
turso db tokens create digital-detox
```

### Step 3: Initialize Database

```bash
# Open database shell
turso db shell digital-detox

# Run this command in the shell:
.read database/schema.sql

# Then run:
.read database/seed.sql

# Exit
.quit
```

### Step 4: Setup Backend

```bash
cd backend

# Install dependencies
dart pub get

# Create .env file
cat > .env << EOF
PORT=8080
TURSO_DATABASE_URL=libsql://your-database-url.turso.io
TURSO_AUTH_TOKEN=your_auth_token_here
JWT_SECRET=super_secret_change_in_production_12345
EOF

# Edit .env and paste your actual Turso URL and token

# Run server
dart run bin/server.dart
```

Server should start on http://localhost:8080

### Step 5: Test Backend

```bash
# Health check
curl http://localhost:8080/health

# Register user
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","email":"test@example.com","password":"password123"}'

# You should get a token in response!
```

## 🧪 Testing the API

### 1. Register a User
```bash
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "player1",
    "email": "player1@example.com",
    "password": "pass123"
  }'
```

### 2. Submit Answer
```bash
curl -X POST http://localhost:8080/api/tasks/1/submit \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{"answer": "Tokyo"}'
```

## 🎯 What's Working Now

✅ User registration & login
✅ JWT authentication  
✅ Task submission & validation
✅ Points awarding
✅ Hint system
✅ Progress tracking
✅ Leaderboard

Happy coding! 🎮