# AgriNova - Quick Start Guide

## Running the Application

### Option 1: Using Helper Scripts (Recommended - Works from any directory!)

From **anywhere** in the AgriNova project, you can run:

```bash
# Run Flutter app
./run_flutter.sh run

# Run Django backend
./run_backend.sh
```

### Option 2: Manual Commands

**Terminal 1 - Django Backend:**
```bash
cd agri_python
uv run python manage.py runserver 0.0.0.0:8000
```

**Terminal 2 - Flutter App:**
```bash
cd agri_flutter
flutter run
```

## Common Commands

### Flutter Commands (from project root)
```bash
# Run the app
./run_flutter.sh run

# Hot reload (press 'r' in the terminal while app is running)
# Hot restart (press 'R' in the terminal while app is running)

# Clean build
./run_flutter.sh clean
./run_flutter.sh pub get

# List devices
./run_flutter.sh devices

# List emulators
./run_flutter.sh emulators

# Launch emulator
flutter emulators --launch Pixel_9_Pro
```

### Django Commands (from agri_python directory)
```bash
cd agri_python

# Run server
uv run python manage.py runserver 0.0.0.0:8000

# Create superuser
uv run python manage.py createsuperuser

# Make migrations
uv run python manage.py makemigrations

# Apply migrations
uv run python manage.py migrate
```

## Troubleshooting

### "No pubspec.yaml file found" Error
**Problem:** Running `flutter run` from wrong directory.

**Solution:** Always use one of these methods:
1. Use the helper script: `./run_flutter.sh run` (from project root)
2. Change to Flutter directory first: `cd agri_flutter && flutter run`
3. Use absolute path in terminal commands

### Emulator Not Starting
```bash
# List available emulators
flutter emulators

# Launch Android emulator
flutter emulators --launch Pixel_9_Pro

# Wait 15 seconds, then run app
flutter run
```

## Project Structure
```
AgriNova/
├── run_flutter.sh      # Helper script to run Flutter
├── run_backend.sh      # Helper script to run Django
├── agri_flutter/       # Flutter frontend
│   └── lib/
│       ├── main.dart
│       ├── screens/
│       ├── widgets/
│       ├── providers/
│       └── services/
└── agri_python/        # Django backend
    ├── manage.py
    ├── agrinova_backend/
    ├── authentication/
    ├── crop_recommendation/
    └── market_finder/
```

## Quick Reference

- **Backend URL:** http://0.0.0.0:8000
- **Admin Panel:** http://0.0.0.0:8000/admin
- **API Docs:** http://0.0.0.0:8000/swagger

## Features
- ✅ Splash Screen
- ✅ User Authentication (Login/Register)
- ✅ Bottom Navigation (Home, Crops, Markets, History, Profile)
- ✅ Crop Recommendations
- ✅ Market Finder
- ✅ User Profile Management
- ✅ Logout Functionality
