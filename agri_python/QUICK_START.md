# AgriNova - Quick Start Guide

## Getting Started in 5 Minutes

### Step 1: Install Dependencies
```powershell
pip install -r requirements.txt
```

### Step 2: Initialize Database
```powershell
python manage.py migrate
```

### Step 3: Load Sample Data
```powershell
python manage.py seed_crops
python manage.py seed_markets
```

### Step 4: Create Admin User (Optional)
```powershell
python manage.py createsuperuser
```

### Step 5: Start the Server
```powershell
python manage.py runserver
```

Server will start at: **http://127.0.0.1:8000/**

---

## Quick API Test

### 1. Register a User
```powershell
curl -X POST http://127.0.0.1:8000/api/auth/register/ -H "Content-Type: application/json" -d '{\"username\":\"testfarmer\",\"email\":\"test@example.com\",\"password\":\"Test123!\",\"password_confirm\":\"Test123!\",\"first_name\":\"Test\",\"last_name\":\"Farmer\",\"district\":\"Kathmandu\"}'
```

### 2. Login
```powershell
curl -X POST http://127.0.0.1:8000/api/auth/login/ -H "Content-Type: application/json" -d '{\"username\":\"testfarmer\",\"password\":\"Test123!\"}'
```

Save the token from response!

### 3. Get Crops
```powershell
curl -X GET http://127.0.0.1:8000/api/crops/crops/ -H "Authorization: Token YOUR_TOKEN_HERE"
```

### 4. Get Crop Recommendation
```powershell
curl -X POST http://127.0.0.1:8000/api/crops/recommend/ -H "Authorization: Token YOUR_TOKEN_HERE" -H "Content-Type: application/json" -d '{\"ph_level\":6.2,\"nitrogen\":100,\"phosphorus\":50,\"potassium\":50,\"rainfall\":1800,\"district\":\"Kathmandu\",\"season\":\"monsoon\"}'
```

### 5. Find Nearest Market
```powershell
curl -X POST http://127.0.0.1:8000/api/markets/find-nearest/ -H "Authorization: Token YOUR_TOKEN_HERE" -H "Content-Type: application/json" -d '{\"latitude\":27.7172,\"longitude\":85.3240,\"district\":\"Kathmandu\",\"max_results\":3}'
```

---

## Using the Test Script

A Python test script is included:

```powershell
python test_api.py
```

This will automatically:
- Register a test user
- Login and get token
- Test all major API endpoints
- Display results

---

## Access Admin Panel

1. Create superuser (if not done):
```powershell
python manage.py createsuperuser
```

2. Start server and visit:
```
http://127.0.0.1:8000/admin/
```

3. Login with superuser credentials

From admin panel you can:
- View all crops and markets
- Add/edit/delete data
- View user recommendations
- Manage user accounts

---

## Sample Data for Testing

### Crop Recommendation Test Data

**For Rice (Monsoon):**
- pH: 6.2
- Nitrogen: 100
- Phosphorus: 50
- Potassium: 50
- Rainfall: 1800
- Season: monsoon

**For Wheat (Winter):**
- pH: 6.8
- Nitrogen: 90
- Phosphorus: 40
- Potassium: 40
- Rainfall: 550
- Season: winter

**For Potato (Winter):**
- pH: 5.8
- Nitrogen: 120
- Phosphorus: 65
- Potassium: 135
- Rainfall: 600
- Season: winter

### Market Finder Test Coordinates

**Kathmandu:** 27.7172, 85.3240
**Pokhara:** 28.2096, 83.9856
**Chitwan:** 27.5291, 84.3542

---

## Project Structure Overview

```
agri_python/
├── agrinova_backend/          # Project settings
├── authentication/            # User auth
├── crop_recommendation/       # Crop recommendation
├── market_finder/            # Market finder
├── manage.py                 # Django management
├── requirements.txt          # Dependencies
├── README.md                 # Full documentation
├── API_DOCUMENTATION.md      # API docs
├── QUICK_START.md           # This file
└── test_api.py              # Test script
```

---

## What's Included?

✅ **12 Crops** - Rice, Wheat, Maize, Potato, Tomato, etc.
✅ **10 Markets** - Across Nepal (Kathmandu, Pokhara, Chitwan, etc.)
✅ **Decision Tree Algorithm** - For crop recommendations
✅ **Haversine Formula** - For distance calculations
✅ **REST API** - Complete with authentication
✅ **Admin Panel** - Full data management
✅ **Test Script** - Automated API testing

---

## Key Features

1. **User Authentication** - Register, login, profile management
2. **Crop Recommendation** - AI-powered suggestions based on soil
3. **Market Finder** - Find nearest markets with distances
4. **History Tracking** - All recommendations and searches saved
5. **Admin CRUD** - Full data management capabilities

---

## API Endpoints Summary

### Authentication
- POST `/api/auth/register/` - Register
- POST `/api/auth/login/` - Login
- POST `/api/auth/logout/` - Logout
- GET `/api/auth/profile/` - Get profile

### Crops
- GET `/api/crops/crops/` - List crops
- POST `/api/crops/recommend/` - Get recommendation
- GET `/api/crops/recommendations/` - View history

### Markets
- GET `/api/markets/markets/` - List markets
- POST `/api/markets/find-nearest/` - Find nearest
- GET `/api/markets/search-history/` - View searches

---

## Troubleshooting

### Database Error
```powershell
# Delete database and restart
rm db.sqlite3
python manage.py migrate
python manage.py seed_crops
python manage.py seed_markets
```

### Module Not Found
```powershell
# Reinstall dependencies
pip install -r requirements.txt
```

### Port Already in Use
```powershell
# Use different port
python manage.py runserver 8001
```

---

## Next Steps

1. ✅ Backend is ready
2. 📱 Create Flutter mobile app
3. 🔗 Connect Flutter to API
4. 🚀 Deploy to production

See **README.md** for full documentation!
See **API_DOCUMENTATION.md** for complete API reference!

---

**AgriNova** - Smart Agriculture for Nepal 🌾
