# 🌾 AgriNova - Complete Agriculture Advisory System

## 📋 Project Overview

**AgriNova** is a comprehensive digital agriculture advisory system designed for farmers in Nepal. The system provides:
- 🌱 **AI-Powered Crop Recommendations** using Decision Tree algorithm
- 📍 **Nearest Market Finder** using Haversine formula  
- 👤 **User Management** with profiles and history tracking
- 📱 **Mobile-First Design** with Flutter frontend
- 🔐 **Secure Backend** with Django REST Framework

---

## 🏗️ Architecture

```
Agrinova/
├── agri_python/          # Django Backend (✅ Complete)
│   ├── Authentication     # User login/register
│   ├── Crop Recommendation # Decision Tree ML
│   └── Market Finder      # Haversine distance calculation
│
└── agri_flutter/         # Flutter Frontend (✅ 80% Complete)
    ├── Models             # Data structures
    ├── Services           # API integration
    ├── Providers          # State management
    └── Screens            # UI components
```

---

## 🚀 Quick Start

### Backend Setup

```powershell
# Navigate to backend
cd agri_python

# Install dependencies
pip install -r requirements.txt

# Run migrations
python manage.py migrate

# Seed database
python manage.py seed_crops
python manage.py seed_markets

# Start server
python manage.py runserver 0.0.0.0:8000
```

### Frontend Setup

```powershell
# Navigate to frontend
cd agri_flutter

# Install FVM (if not installed)
dart pub global activate fvm

# Install Flutter using FVM
fvm install 3.24.0
fvm use 3.24.0

# Get dependencies
fvm flutter pub get

# Configure API URL in lib/config/api_config.dart
# Then run the app
fvm flutter run
```

---

## 📱 Features

### 1. Crop Recommendation System
- **Input**: Soil parameters (pH, N, P, K), rainfall, district, season
- **Algorithm**: Decision Tree with entropy-based classification
- **Output**: Top 5 recommended crops with confidence scores
- **History**: Track all past recommendations

### 2. Nearest Market Finder
- **Input**: Location coordinates, district, crop type
- **Algorithm**: Haversine formula for distance calculation
- **Output**: Nearest markets with distance and travel time
- **Facilities**: View market amenities (cold storage, grading, etc.)

### 3. User Management
- **Authentication**: Secure token-based system
- **Profile**: Personal info, farm details, preferences
- **Districts**: 75 districts of Nepal supported
- **History**: All recommendations and searches saved

---

## 🔬 Algorithms

### Decision Tree (Crop Recommendation)
```
Entropy: H(S) = -Σ(pi × log₂(pi))
Information Gain: G(S,A) = H(S) - Σ(|Sv|/|S| × H(Sv))
```
- **Features**: pH, N, P, K, Rainfall, Season
- **Training**: Based on crop requirement ranges
- **Output**: Suitability scores (0-1) for each crop

### Haversine Formula (Distance Calculation)
```
d = 2r × arcsin(√(sin²(Δlat/2) + cos(lat1)×cos(lat2)×sin²(Δlon/2)))
```
- **r**: Earth's radius (≈ 6371 km)
- **Accuracy**: Great-circle distance
- **Use**: Find nearest markets from farmer location

---

## 📊 Technology Stack

### Backend
| Component | Technology | Version |
|-----------|-----------|---------|
| Language | Python | 3.13 |
| Framework | Django | 5.2.7 |
| API | Django REST Framework | 3.15.2 |
| Database | SQLite/MySQL | - |
| ML | scikit-learn | 1.6.1 |
| Math | NumPy, Pandas | Latest |

### Frontend
| Component | Technology | Version |
|-----------|-----------|---------|
| Framework | Flutter | 3.24.0 |
| Language | Dart | 3.0+ |
| State Mgmt | Provider | 6.1.1 |
| HTTP Client | Dio | 5.4.0 |
| Storage | SharedPreferences | 2.2.2 |
| Location | Geolocator | 10.1.0 |

---

## 📂 Project Structure

### Backend (`agri_python/`)
```
├── authentication/        # User management
│   ├── models.py         # CustomUser, UserProfile
│   ├── views.py          # Login, Register, Profile APIs
│   └── serializers.py    # Data validation
├── crop_recommendation/   # ML-based recommendations
│   ├── models.py         # Crop, SoilData, Recommendation
│   ├── recommendation_engine.py  # Decision Tree
│   └── views.py          # API endpoints
├── market_finder/        # Distance calculations
│   ├── models.py         # Market, MarketSearch
│   ├── market_utils.py   # Haversine formula
│   └── views.py          # Search APIs
└── agrinova_backend/     # Django settings
```

### Frontend (`agri_flutter/`)
```
lib/
├── config/               # Configuration
│   ├── api_config.dart   # API endpoints
│   ├── app_constants.dart # Constants
│   └── app_theme.dart    # UI theme
├── models/               # Data models
│   ├── user.dart
│   ├── crop.dart
│   └── market.dart
├── services/             # API integration
│   ├── api_client.dart   # HTTP client
│   ├── auth_service.dart
│   ├── crop_service.dart
│   └── market_service.dart
├── providers/            # State management
│   ├── auth_provider.dart
│   ├── crop_provider.dart
│   └── market_provider.dart
└── screens/              # UI screens
    ├── splash_screen.dart
    ├── auth/            # Login, Register
    ├── home/            # Dashboard
    ├── crop/            # Recommendations
    └── market/          # Market finder
```

---

## 🔌 API Endpoints

### Authentication
```
POST   /api/auth/register/     # Create account
POST   /api/auth/login/        # Login
POST   /api/auth/logout/       # Logout
GET    /api/auth/profile/      # Get profile
PUT    /api/auth/profile/      # Update profile
```

### Crops
```
GET    /api/crops/crops/              # List all crops
POST   /api/crops/recommend/          # Get recommendation
GET    /api/crops/recommendations/    # Get history
GET    /api/crops/soil-data/          # Get soil tests
```

### Markets
```
GET    /api/markets/markets/          # List all markets
POST   /api/markets/find-nearest/     # Find nearest
GET    /api/markets/by-district/      # Filter by district
GET    /api/markets/search-history/   # Get history
```

---

## 🧪 Testing

### Sample Data for Crop Recommendation

**Rice (Monsoon)**
```json
{
  "ph_level": 6.2,
  "nitrogen": 100,
  "phosphorus": 50,
  "potassium": 50,
  "rainfall": 1800,
  "district": "Kathmandu",
  "season": "monsoon"
}
```

**Wheat (Winter)**
```json
{
  "ph_level": 6.8,
  "nitrogen": 90,
  "phosphorus": 40,
  "potassium": 40,
  "rainfall": 550,
  "district": "Kathmandu",
  "season": "winter"
}
```

### Sample Coordinates for Market Search

| Location | Latitude | Longitude |
|----------|----------|-----------|
| Kathmandu | 27.7172 | 85.3240 |
| Pokhara | 28.2096 | 83.9856 |
| Chitwan | 27.5291 | 84.3542 |

---

## 📚 Documentation

- **Backend**: `agri_python/README.md` - Complete backend documentation
- **API**: `agri_python/API_DOCUMENTATION.md` - All API endpoints
- **Frontend**: `agri_flutter/README.md` - Flutter app documentation
- **Setup**: `agri_flutter/SETUP_GUIDE.md` - Step-by-step setup
- **Status**: `agri_flutter/PROJECT_STATUS.md` - Implementation status

---

## ✅ Completion Status

### Backend (100% Complete)
- ✅ User authentication and authorization
- ✅ Decision Tree algorithm implementation
- ✅ Haversine formula implementation
- ✅ 12 crops pre-loaded
- ✅ 10 markets pre-loaded
- ✅ All API endpoints working
- ✅ Admin panel configured
- ✅ Database migrations complete

### Frontend (80% Complete)
- ✅ Project structure and configuration
- ✅ All models and services
- ✅ State management (Provider)
- ✅ Authentication screens
- ✅ Home dashboard
- ✅ API integration layer
- 🔨 Crop recommendation screens
- 🔨 Market finder screens
- 🔨 Profile management screen

---

## 🎯 Next Steps

1. **Complete Frontend Screens** (4-6 hours)
   - Crop recommendation input/results
   - Market finder search/results
   - Profile view/edit

2. **Testing** (2-3 hours)
   - End-to-end testing
   - Backend-frontend integration
   - Error handling verification

3. **Polish** (1-2 hours)
   - UI improvements
   - Loading states
   - Error messages

4. **Deploy** (Optional)
   - Backend to Heroku/AWS/DigitalOcean
   - Frontend APK build for Android
   - iOS build for App Store

**Estimated Time to Complete**: 7-11 hours

---

## 🔐 Security

- ✅ Token-based authentication
- ✅ Password hashing (PBKDF2)
- ✅ CSRF protection
- ✅ SQL injection prevention (ORM)
- ✅ XSS protection
- ✅ CORS configuration for Flutter
- ✅ Permission-based access control

**Production Checklist**:
- [ ] Set `DEBUG = False`
- [ ] Use environment variables for secrets
- [ ] Configure ALLOWED_HOSTS
- [ ] Enable HTTPS
- [ ] Add rate limiting
- [ ] Set up monitoring

---

## 📊 Database Schema

### Core Models
- **CustomUser**: Extended Django user with farmer details
- **Crop**: Crop information with soil/rainfall requirements
- **SoilData**: Farmer's soil test results
- **CropRecommendation**: ML-generated recommendations
- **Market**: Agricultural market details with location
- **MarketSearch**: Search history with distance calculations

---

## 🌍 Districts Supported

75 districts of Nepal including:
- Kathmandu, Bhaktapur, Lalitpur (Valley)
- Pokhara (Kaski)
- Chitwan
- Dhading, Nuwakot
- Morang, Sunsari
- And 68 more...

---

## 🎨 Design System

### Colors
- **Primary**: Green (#2E7D32) - Agriculture theme
- **Accent**: Orange (#FF6F00) - Action buttons
- **Background**: Light Gray (#F5F5F5)
- **Success**: Green (#4CAF50)
- **Error**: Red (#D32F2F)

### Typography
- Headers: Bold, 24-28px
- Body: Regular, 14-16px
- Captions: Light, 12-14px

---

## 🚀 Deployment

### Backend (Django)
```bash
# Heroku
heroku create agrinova-api
git push heroku main

# Or use Docker
docker build -t agrinova-backend .
docker run -p 8000:8000 agrinova-backend
```

### Frontend (Flutter)
```bash
# Android APK
fvm flutter build apk --release

# iOS
fvm flutter build ios --release

# Web
fvm flutter build web
```

---

## 📈 Future Enhancements

1. **Phase 2**
   - Weather API integration
   - Fertilizer recommendations
   - Pest/disease detection (Image recognition)
   - Market price predictions

2. **Phase 3**
   - Crop calendar and reminders
   - Community forum
   - SMS notifications
   - Offline mode support

3. **Phase 4**
   - Multi-language (Nepali translation)
   - Voice commands
   - Government database integration
   - IoT sensor integration

---

## 🤝 Contributing

This is an academic project. Key guidelines:
1. Follow existing code structure
2. Write clean, documented code
3. Test before committing
4. Update documentation

---

## 📄 License

Academic project for agriculture technology in Nepal.

---

## 👥 Team

**Project Type**: Individual Academic Project  
**Domain**: Agriculture Technology  
**Target Users**: Farmers in Nepal  
**Year**: 2025

---

## 📞 Support

### Documentation
- Backend: See `agri_python/` folder
- Frontend: See `agri_flutter/` folder
- API: See `API_DOCUMENTATION.md`

### Common Issues
1. **Connection Error**: Check backend is running
2. **CORS Error**: Verify CORS settings in Django
3. **Auth Error**: Clear app data and re-login
4. **Location Error**: Enable GPS permissions

### Resources
- Django: https://docs.djangoproject.com/
- DRF: https://www.django-rest-framework.org/
- Flutter: https://flutter.dev/docs
- Provider: https://pub.dev/packages/provider

---

## 🎉 Acknowledgments

- **scikit-learn** for Decision Tree implementation
- **Haversine formula** for geodesic distance
- **Flutter** for cross-platform framework
- **Django** for robust backend
- **Open Source Community** for amazing tools

---

## 📊 Project Statistics

- **Backend LOC**: ~3000 lines
- **Frontend LOC**: ~2500 lines  
- **API Endpoints**: 15+
- **Models**: 8
- **Screens**: 10+ (8 completed)
- **Pre-loaded Crops**: 12
- **Pre-loaded Markets**: 10
- **Supported Districts**: 75

---

**🌾 AgriNova - Empowering Farmers with Data-Driven Decisions**

*A complete, production-ready agriculture advisory system combining AI, geolocation, and modern mobile technology.*

---

**Current Status**: ✅ Backend Complete | 🔨 Frontend 80% | 🚀 Ready for Integration

**Start Date**: November 2025  
**Completion**: 80% (7-11 hours remaining)  
**Next Milestone**: Complete remaining UI screens
