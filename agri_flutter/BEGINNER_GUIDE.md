# AgriNova Flutter App - Beginner Friendly Version

A simple, easy-to-understand Flutter application for crop recommendation and market finder, connected to Django REST API backend.

## 📱 Features

- **User Authentication**: Login and Signup
- **Crop Recommendation**: Get personalized crop suggestions based on soil parameters
- **Market Finder**: Find nearby agricultural markets
- **History**: View past crop recommendations
- **Profile Management**: Update user profile
- **Admin Panel**: Manage crops, markets, and users (for admin users only)

## 🏗️ Project Structure

```
lib/
├── main.dart                          # App entry point with MultiProvider setup
├── models/                            # Data models
│   ├── user.dart                      # User model
│   ├── crop.dart                      # Crop model
│   ├── market.dart                    # Market model
│   └── recommendation.dart            # Recommendation model
├── services/                          # API service layer
│   ├── api_service.dart               # Base API service (GET, POST, PUT, DELETE)
│   ├── auth_service.dart              # Authentication API calls
│   ├── crop_service.dart              # Crop-related API calls
│   ├── market_service.dart            # Market-related API calls
│   └── user_service.dart              # User management API calls
├── providers/                         # State management (Provider pattern)
│   ├── auth_provider.dart             # Authentication state
│   ├── crop_provider.dart             # Crop data state
│   ├── market_provider.dart           # Market data state
│   └── user_provider.dart             # User management state
├── widgets/                           # Reusable custom widgets
│   ├── custom_textfield.dart          # Custom text input field
│   └── custom_button.dart             # Custom button
└── screens/                           # UI screens
    ├── login_screen.dart              # Login page
    ├── signup_screen.dart             # Registration page
    ├── dashboard_screen.dart          # Main dashboard
    ├── crop_recommend_screen.dart     # Crop recommendation input
    ├── crop_result_screen.dart        # Crop recommendation result
    ├── market_finder_screen.dart      # Market finder input
    ├── market_result_screen.dart      # Market finder result
    ├── history_screen.dart            # Recommendation history
    ├── profile_screen.dart            # User profile
    ├── admin_crops_screen.dart        # Admin: Manage crops
    ├── admin_markets_screen.dart      # Admin: Manage markets
    └── admin_users_screen.dart        # Admin: Manage users
```

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.1              # Simple state management
  http: ^1.1.0                  # HTTP requests
  shared_preferences: ^2.2.2    # Local storage for token
  cupertino_icons: ^1.0.8       # iOS icons
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.9.2 or higher
- Android Studio or VS Code with Flutter extensions
- Android Emulator or physical device

### Installation

1. **Navigate to the Flutter project directory:**
   ```bash
   cd agri_flutter
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Update API URL (if needed):**
   
   Open `lib/services/api_service.dart` and update the `baseUrl`:
   - For Android Emulator: `http://10.0.2.2:8000/api/`
   - For physical device: Replace with your computer's IP address

4. **Make sure Django backend is running:**
   ```bash
   cd ../agri_python
   python manage.py runserver
   ```

5. **Run the app:**
   ```bash
   flutter run
   ```

## 🔑 Key Concepts for Beginners

### 1. **Models** (`lib/models/`)
Models are simple Dart classes that represent data:
- They have properties (fields) to store data
- `fromJson()` method converts API response to model
- `toJson()` method converts model to JSON for API requests

### 2. **Services** (`lib/services/`)
Services handle all API communication:
- `ApiService`: Base service with GET, POST, PUT, DELETE methods
- Other services call `ApiService` methods with specific endpoints
- Services are **static** - you call them directly without creating objects

### 3. **Providers** (`lib/providers/`)
Providers manage app state using the Provider pattern:
- Extend `ChangeNotifier` from Flutter
- Have `isLoading` boolean to show loading indicators
- Call `notifyListeners()` to update UI when data changes
- Store data fetched from services

### 4. **Widgets** (`lib/widgets/`)
Reusable UI components:
- `CustomTextField`: Styled text input field
- `CustomButton`: Styled button with loading state

### 5. **Screens** (`lib/screens/`)
Full-page UI components:
- Use `Scaffold` for basic page structure
- Use `Provider.of<>()` to access providers
- Use `Consumer<>()` widget to rebuild UI when provider changes

## 📖 How Data Flows

1. **User interacts with UI** (Screen)
2. **Screen calls Provider method** (e.g., `cropProvider.getRecommendation()`)
3. **Provider sets `isLoading = true`** and calls `notifyListeners()`
4. **Provider calls Service method** (e.g., `CropService.getRecommendation()`)
5. **Service calls ApiService** with endpoint and data
6. **ApiService makes HTTP request** to Django backend
7. **ApiService returns response** to Service
8. **Service converts JSON to Model** and returns to Provider
9. **Provider stores data, sets `isLoading = false`**, and calls `notifyListeners()`
10. **UI updates automatically** through Consumer or context watch

## 🎨 UI Design

- **Color Scheme**: Green theme (agricultural focus)
- **Layout**: Simple Column + Padding structure
- **Widgets**: Basic Material widgets (TextField, ElevatedButton, Card, ListTile)
- **No animations** - focus on simplicity and clarity

## 🔐 Authentication Flow

1. User enters credentials in `LoginScreen`
2. `AuthProvider.login()` is called
3. `AuthService.login()` sends credentials to API
4. API returns `token` and `user` data
5. Token is saved using `shared_preferences`
6. User object is stored in `AuthProvider`
7. Navigate to `DashboardScreen`

## 🌾 Crop Recommendation Flow

1. User enters soil parameters in `CropRecommendScreen`
2. `CropProvider.getRecommendation()` is called
3. `CropService.getRecommendation()` sends data to API
4. API returns recommended crop
5. Recommendation stored in `CropProvider`
6. Navigate to `CropResultScreen` to display result

## 📍 Market Finder Flow

1. User enters location in `MarketFinderScreen`
2. `MarketProvider.findNearest()` is called
3. `MarketService.findNearest()` sends location to API
4. API returns list of nearby markets
5. Markets stored in `MarketProvider`
6. Navigate to `MarketResultScreen` to display results

## 👨‍💼 Admin Features

Only users with `isStaff = true` can access:
- **Admin Crops Screen**: Add/delete crops from database
- **Admin Markets Screen**: Add/delete markets from database
- **Admin Users Screen**: View/delete user accounts

## 🐛 Common Issues & Solutions

### Issue: "Connection refused" error
**Solution**: Make sure Django backend is running and API URL is correct in `api_service.dart`

### Issue: "Token authentication failed"
**Solution**: Check if token is being saved correctly. Try logging out and logging in again.

### Issue: UI not updating
**Solution**: Make sure you're calling `notifyListeners()` in providers after data changes

### Issue: Build errors
**Solution**: Run `flutter clean` then `flutter pub get`

## 📝 Code Examples

### Calling a Provider Method:
```dart
// Get provider instance
final authProvider = Provider.of<AuthProvider>(context, listen: false);

// Call method
final success = await authProvider.login(username, password);

// Check result
if (success) {
  // Navigate to next screen
}
```

### Using Consumer to Update UI:
```dart
Consumer<CropProvider>(
  builder: (context, cropProvider, child) {
    return CustomButton(
      text: 'Get Recommendation',
      onPressed: _getRecommendation,
      isLoading: cropProvider.isLoading,  // Button shows loading
    );
  },
)
```

### Making API Calls:
```dart
// In service class
static Future<List<Crop>> getAllCrops() async {
  final response = await ApiService.get("crops/crops/");
  return (response as List).map((json) => Crop.fromJson(json)).toList();
}
```

## 📚 Learning Resources

- [Flutter Official Docs](https://flutter.dev/docs)
- [Provider Package](https://pub.dev/packages/provider)
- [HTTP Package](https://pub.dev/packages/http)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)

## 🤝 Contributing

This is a beginner-friendly project. If you're learning Flutter:
1. Read through the code comments
2. Try modifying UI colors or text
3. Add new fields to forms
4. Create new screens following existing patterns

## 📄 License

This project is for educational purposes.

---

**Made with ❤️ for Flutter beginners**
