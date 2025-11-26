# AgriNova Flutter Setup Guide

## ✅ Complete Beginner-Friendly Flutter App for AgriNova Backend

This is a **simple, easy-to-understand** Flutter application that connects to your Django REST API backend.

## 📋 What's Included

### ✅ All 13 Screens Created:
1. **Login Screen** - User authentication
2. **Signup Screen** - User registration
3. **Dashboard Screen** - Main menu
4. **Crop Recommend Screen** - Input soil parameters
5. **Crop Result Screen** - Show recommended crop
6. **Market Finder Screen** - Input location
7. **Market Result Screen** - Show nearby markets
8. **History Screen** - View past recommendations
9. **Profile Screen** - Edit user profile
10. **Admin Crops Screen** - Manage crops (admin only)
11. **Admin Markets Screen** - Manage markets (admin only)
12. **Admin Users Screen** - Manage users (admin only)

### ✅ All Components Created:
- **4 Data Models**: User, Crop, Market, Recommendation
- **5 Service Classes**: ApiService, AuthService, CropService, MarketService, UserService
- **4 Provider Classes**: AuthProvider, CropProvider, MarketProvider, UserProvider
- **2 Custom Widgets**: CustomTextField, CustomButton
- **Main App**: Configured with MultiProvider

## 🚀 Quick Start

### 1. Make Sure Backend is Running

```bash
cd agri_python
python manage.py runserver
```

### 2. Install Flutter Dependencies

```bash
cd agri_flutter
flutter pub get
```

### 3. Update API URL (if using physical device)

Open `lib/services/api_service.dart` and change:

```dart
static const String baseUrl = "http://10.0.2.2:8000/api/";  // Android Emulator
```

To your computer's IP address:

```dart
static const String baseUrl = "http://192.168.1.XXX:8000/api/";  // Physical Device
```

### 4. Run the App

```bash
flutter run
```

## 📱 Testing the App

### Login as Admin:
1. Create superuser in Django: `python manage.py createsuperuser`
2. Login with those credentials
3. You'll see Admin panel options in Dashboard

### Test Crop Recommendation:
1. Go to Dashboard → Crop Recommendation
2. Enter values:
   - Nitrogen: 90
   - Phosphorus: 42
   - Potassium: 43
   - Temperature: 20.8
   - Humidity: 82
   - pH: 6.5
   - Rainfall: 202
3. Click "Get Recommendation"

### Test Market Finder:
1. Go to Dashboard → Market Finder
2. Enter location (e.g., Latitude: 13.0827, Longitude: 80.2707)
3. Set radius: 10 km
4. Click "Find Markets"

## 🏗️ Project Architecture (Simple!)

```
Data Flow:
Screen → Provider → Service → ApiService → Django API
                ↓
           notifyListeners()
                ↓
           UI Updates!
```

## 📦 Dependencies Used

- **provider**: Simple state management
- **http**: HTTP requests to backend
- **shared_preferences**: Save auth token locally

## 🎨 UI Features

- **Green Color Theme**: Agricultural feel
- **Simple Layouts**: Column + Padding
- **Loading Indicators**: On all API calls
- **Error Messages**: SnackBar notifications
- **Clean Navigation**: MaterialPageRoute

## 🔐 Authentication

- Token-based authentication
- Token saved in shared_preferences
- Auto-logout on token expiry

## 🐛 Troubleshooting

### "Connection Refused" Error
- Make sure Django backend is running
- Check API URL in `api_service.dart`
- For Android Emulator: use `10.0.2.2`
- For iOS Simulator: use `localhost`
- For Physical Device: use your computer's IP

### Build Errors
```bash
flutter clean
flutter pub get
flutter run
```

### Token Issues
- Logout and login again
- Check Django backend logs

## 📖 Learning the Code

Start by reading files in this order:

1. **lib/models/user.dart** - See how data models work
2. **lib/services/api_service.dart** - Understand HTTP requests
3. **lib/services/auth_service.dart** - See how services call API
4. **lib/providers/auth_provider.dart** - Learn state management
5. **lib/screens/login_screen.dart** - See UI and Provider usage

## 📝 Code is Beginner-Friendly

- Clear variable names
- Simple logic flow
- No complex patterns
- Comments where needed
- No animations or advanced widgets

## ✅ What You Can Do

- ✅ Login and Signup
- ✅ Get crop recommendations
- ✅ Find nearby markets
- ✅ View recommendation history
- ✅ Update profile
- ✅ Admin: Manage crops, markets, users

## 🎯 Next Steps

1. Run `flutter pub get`
2. Make sure Django backend is running
3. Run `flutter run`
4. Create a test user via signup
5. Test all features!

## 📚 Read More

- See `BEGINNER_GUIDE.md` for detailed explanations
- All code uses simple patterns you can easily modify
- Try changing colors in screens to learn Flutter UI

---

**Everything is ready to run! 🎉**

Just ensure your Django backend is running and execute `flutter run`.
