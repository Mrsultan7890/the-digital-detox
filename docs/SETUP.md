# Digital Detox - Setup & Development Guide

## 📋 Project Overview

Digital Detox is an educational puzzle game that encourages mindful internet usage through research-based challenges, quizzes, and puzzles across multiple categories.

## 🏗️ Architecture

```
┌─────────────────┐
│  Flutter App    │ ← User Interface
│  (Mobile)       │
└────────┬────────┘
         │ HTTP/REST
         ↓
┌─────────────────┐
│  Dart Backend   │ ← API Server (Shelf)
│  (Render.com)   │
└────────┬────────┘
         │ SQL
         ↓
┌─────────────────┐
│  Turso DB       │ ← SQLite Database
│  (Edge)         │
└─────────────────┘
```

## 🚀 Getting Started

### Prerequisites

1. **Flutter SDK** (3.0+)
   ```bash
   # Download from: https://flutter.dev/docs/get-started/install
   flutter --version
   ```

2. **Dart SDK** (3.0+)
   ```bash
   dart --version
   ```

3. **Turso CLI**
   ```bash
   # Install Turso CLI
   curl -sSfL https://get.tur.so/install.sh | bash
   
   # Login to Turso
   turso auth login
   ```

### Backend Setup

1. **Navigate to backend directory**
   ```bash
   cd backend
   ```

2. **Install dependencies**
   ```bash
   dart pub get
   ```

3. **Create Turso database**
   ```bash
   # Create database
   turso db create digital-detox
   
   # Get database URL
   turso db show digital-detox --url
   
   # Create auth token
   turso db tokens create digital-detox
   ```

4. **Setup environment variables**
   ```bash
   cp .env.example .env
   # Edit .env and add your Turso credentials
   ```

5. **Initialize database**
   ```bash
   # Connect to database shell
   turso db shell digital-detox
   
   # Run schema
   .read ../database/schema.sql
   
   # Run seed data
   .read ../database/seed.sql
   
   # Exit shell
   .quit
   ```

6. **Run backend locally**
   ```bash
   dart run bin/server.dart
   # Server will start on http://localhost:8080
   ```

### Mobile App Setup

1. **Navigate to mobile-app directory**
   ```bash
   cd mobile-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Update API base URL** (for local development)
   Edit `lib/services/api_service.dart`:
   ```dart
   static const String baseUrl = 'http://localhost:8080/api'; // For emulator
   // Or use your computer's IP for physical device
   static const String baseUrl = 'http://192.168.x.x:8080/api';
   ```

4. **Run the app**
   ```bash
   # For Android
   flutter run
   
   # For iOS (Mac only)
   flutter run -d ios
   
   # For web
   flutter run -d chrome
   ```

## 📦 Deployment

### Backend Deployment (Render.com)

1. **Create new Web Service on Render**
   - Connect your GitHub repository
   - Select "Docker" or "Native Environment"

2. **Configure build settings**
   - Build Command: `cd backend && dart pub get`
   - Start Command: `cd backend && dart run bin/server.dart`

3. **Set environment variables**
   - `PORT`: (Render provides this)
   - `TURSO_DATABASE_URL`: Your Turso database URL
   - `TURSO_AUTH_TOKEN`: Your Turso auth token
   - `JWT_SECRET`: Generate a secure secret

4. **Deploy**
   - Render will auto-deploy on git push

### Mobile App Deployment

**Android:**
```bash
flutter build apk --release
# APK will be at: build/app/outputs/flutter-apk/app-release.apk
```

**iOS:**
```bash
flutter build ios --release
# Follow Xcode signing and upload to App Store
```

## 🗂️ Project Structure

```
the-digital-detox/
├── mobile-app/              # Flutter frontend
│   ├── lib/
│   │   ├── config/         # Theme, routes, constants
│   │   ├── models/         # Data models
│   │   ├── providers/      # State management (Riverpod)
│   │   ├── screens/        # UI screens
│   │   ├── services/       # API services
│   │   ├── utils/          # Helper functions
│   │   └── widgets/        # Reusable widgets
│   └── assets/             # Images, animations
│
├── backend/                 # Dart backend
│   ├── lib/
│   │   ├── models/         # Data models
│   │   ├── routes/         # API routes
│   │   ├── middleware/     # Middleware functions
│   │   └── utils/          # Database, helpers
│   └── bin/
│       └── server.dart     # Entry point
│
├── database/                # Database files
│   ├── schema.sql          # Database schema
│   └── seed.sql            # Initial data
│
└── docs/                    # Documentation
    └── SETUP.md            # This file
```

## 🎮 Game Features Implementation Status

- [x] Project structure
- [x] Database schema
- [x] Backend API skeleton
- [x] Mobile app UI screens
- [ ] Authentication (JWT)
- [ ] Task submission & validation
- [ ] Hint system
- [ ] Leaderboard
- [ ] Daily challenges
- [ ] Achievements system
- [ ] Streak tracking
- [ ] Push notifications

## 🔧 Development Tips

1. **Hot reload in Flutter**
   - Press `r` in terminal for hot reload
   - Press `R` for hot restart

2. **Test backend endpoints**
   ```bash
   curl http://localhost:8080/health
   curl http://localhost:8080/api/tasks/categories
   ```

3. **View Turso database**
   ```bash
   turso db shell digital-detox
   SELECT * FROM users;
   ```

## 📚 API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user
- `POST /api/auth/refresh` - Refresh token

### Tasks
- `GET /api/tasks/categories` - Get all categories
- `GET /api/tasks/category/:id` - Get tasks by category
- `GET /api/tasks/:id` - Get specific task
- `POST /api/tasks/:id/submit` - Submit answer
- `POST /api/tasks/:id/hint` - Get hint
- `GET /api/tasks/daily` - Get daily challenge

### User
- `GET /api/users/profile` - Get user profile
- `GET /api/users/progress` - Get user progress
- `GET /api/users/achievements` - Get achievements
- `PUT /api/users/profile` - Update profile

### Leaderboard
- `GET /api/leaderboard/global` - Global leaderboard
- `GET /api/leaderboard/category/:id` - Category leaderboard

## 🐛 Troubleshooting

**Issue: Flutter not found**
```bash
export PATH="$PATH:/path/to/flutter/bin"
```

**Issue: Backend can't connect to Turso**
- Check your `.env` file
- Verify Turso auth token is valid
- Test connection: `turso db shell digital-detox`

**Issue: App can't reach backend**
- For Android emulator, use `10.0.2.2` instead of `localhost`
- For iOS simulator, `localhost` works
- For physical device, use your computer's IP address

## 📄 License

MIT License - Feel free to use this project for learning!

## 👥 Contributing

Contributions welcome! Feel free to submit issues and pull requests.
