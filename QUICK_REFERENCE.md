# ⚡ AgriNova Quick Reference

## 🚀 One-Command Setup

### Backend
```powershell
cd agri_python
pip install -r requirements.txt; python manage.py migrate; python manage.py seed_crops; python manage.py seed_markets; python manage.py runserver 0.0.0.0:8000
```

### Frontend
```powershell
cd agri_flutter
.\setup.ps1
```

---

## 🔑 Key Commands

### Backend
```powershell
# Start server
python manage.py runserver 0.0.0.0:8000

# Create superuser
python manage.py createsuperuser

# Access admin
# http://127.0.0.1:8000/admin/
```

### Frontend
```powershell
# Get dependencies
fvm flutter pub get

# Run app
fvm flutter run

# Build APK
fvm flutter build apk --release

# Clean build
fvm flutter clean
```

---

## 📍 Important URLs

| Service | URL | Purpose |
|---------|-----|---------|
| Backend API | http://127.0.0.1:8000/api/ | REST API |
| Admin Panel | http://127.0.0.1:8000/admin/ | Django admin |
| API Docs | http://127.0.0.1:8000/swagger/ | Swagger UI |

### For Android Emulator
- Backend: `http://10.0.2.2:8000/api/`

### For Physical Device
- Backend: `http://YOUR_COMPUTER_IP:8000/api/`
- Find IP: `ipconfig` (Windows) or `ifconfig` (Mac/Linux)

---

## 🎯 Test Credentials

### Create Test User
```powershell
# Via API
POST http://127.0.0.1:8000/api/auth/register/

# Via Django shell
python manage.py createsuperuser
```

---

## 📊 Sample Test Data

### Crop Recommendation
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

### Market Search
```json
{
  "latitude": 27.7172,
  "longitude": 85.3240,
  "district": "Kathmandu",
  "max_results": 5
}
```

---

## 🐛 Quick Troubleshooting

### Backend Issues
```powershell
# Port already in use
# Kill process on port 8000
netstat -ano | findstr :8000
taskkill /PID <PID> /F

# Database issues
python manage.py flush
python manage.py migrate
python manage.py seed_crops
python manage.py seed_markets
```

### Frontend Issues
```powershell
# Dependencies issues
fvm flutter clean
fvm flutter pub get

# Build issues
fvm flutter clean
fvm flutter pub get
fvm flutter run

# FVM issues
fvm list
fvm use 3.24.0
```

### Connection Issues
1. Check backend is running: Visit http://127.0.0.1:8000/api/
2. Check API URL in `lib/config/api_config.dart`
3. For emulator, use `10.0.2.2` instead of `localhost`
4. For device, ensure same WiFi network
5. Check firewall allows port 8000

---

## 📂 File Locations

### Configuration Files
```
Backend:
- agri_python/agrinova_backend/settings.py (Django settings)
- agri_python/requirements.txt (Dependencies)

Frontend:
- agri_flutter/lib/config/api_config.dart (API URL)
- agri_flutter/pubspec.yaml (Flutter dependencies)
- agri_flutter/.fvm/fvm_config.json (Flutter version)
```

### Important Screens
```
Frontend:
- lib/screens/splash_screen.dart (Entry point)
- lib/screens/auth/login_screen.dart (Login)
- lib/screens/auth/register_screen.dart (Register)
- lib/screens/home/home_screen.dart (Dashboard)
```

---

## 🎨 Key Models

### Backend
```python
# Authentication
CustomUser, UserProfile

# Crops
Crop, SoilData, CropRecommendation

# Markets
Market, MarketPrice, MarketSearch
```

### Frontend
```dart
// lib/models/
User, UserProfile
Crop, SoilData, CropRecommendation
Market, MarketSearchHistory
```

---

## 🔧 Configuration Checklist

### Before Running
- [ ] Backend installed: `pip install -r requirements.txt`
- [ ] Database migrated: `python manage.py migrate`
- [ ] Data seeded: `seed_crops` and `seed_markets`
- [ ] FVM installed: `dart pub global activate fvm`
- [ ] Flutter installed: `fvm install 3.24.0`
- [ ] Dependencies: `fvm flutter pub get`
- [ ] API URL configured in `api_config.dart`

### For Testing
- [ ] Backend running on port 8000
- [ ] Test user created
- [ ] Mobile device/emulator ready
- [ ] Network connection working
- [ ] Firewall allows connections

---

## 📱 Device Setup

### Android Emulator
```powershell
# List available emulators
flutter emulators

# Launch emulator
flutter emulators --launch <emulator_id>

# Or use Android Studio > AVD Manager
```

### Physical Device
1. Enable Developer Options
2. Enable USB Debugging
3. Connect via USB
4. Check: `fvm flutter devices`

---

## 💾 Backup Commands

```powershell
# Backup database
copy agri_python\db.sqlite3 agri_python\db.sqlite3.backup

# Export data
python manage.py dumpdata > backup.json

# Restore data
python manage.py loaddata backup.json
```

---

## 📈 Performance Tips

### Backend
- Use MySQL instead of SQLite for production
- Enable caching
- Optimize database queries
- Use pagination for large results

### Frontend
- Use `const` widgets where possible
- Implement lazy loading
- Cache API responses
- Optimize images

---

## 🎯 Common Tasks

### Add New Crop
```python
# Via Django admin
http://127.0.0.1:8000/admin/

# Via shell
python manage.py shell
from crop_recommendation.models import Crop
crop = Crop(name='NewCrop', ...)
crop.save()
```

### Add New Market
```python
# Via Django admin
http://127.0.0.1:8000/admin/

# Via shell
python manage.py shell
from market_finder.models import Market
market = Market(name='NewMarket', ...)
market.save()
```

### Update User Profile
```dart
// In Flutter
final authProvider = Provider.of<AuthProvider>(context, listen: false);
await authProvider.updateProfile(
  firstName: 'Ram',
  lastName: 'Sharma',
  // ... other fields
);
```

---

## 📚 Documentation Quick Links

- **README**: Project overview
- **SETUP_GUIDE**: Detailed setup instructions  
- **PROJECT_STATUS**: Implementation status
- **API_DOCUMENTATION**: All API endpoints
- **ARCHITECTURE**: System architecture

---

## ⚡ Development Workflow

1. Start backend server
2. Open Android Studio / VS Code
3. Start emulator or connect device
4. Run `fvm flutter run`
5. Make changes and hot reload (press `r` in terminal)
6. Test features
7. Build release: `fvm flutter build apk`

---

## 🎉 Quick Wins

### Test Backend Working
```powershell
# Open browser
http://127.0.0.1:8000/api/crops/crops/

# Should see list of crops in JSON
```

### Test Frontend Working
```powershell
fvm flutter run

# Should see splash screen → login screen
```

### Test Integration
1. Start backend
2. Create test user via admin or API
3. Run Flutter app
4. Login with test credentials
5. Navigate through screens

---

**🌾 AgriNova - Quick Reference Guide**

*Copy this file for quick access to common commands and configurations!*
