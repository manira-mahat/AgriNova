# AgriNova - Agriculture Advisory System

AgriNova is a comprehensive digital agriculture advisory system designed for farmers in Nepal. The system provides personalized crop recommendations based on soil conditions and helps farmers locate the nearest agricultural markets.

## Features

### 1. Crop Recommendation System
- **Decision Tree Algorithm**: Uses machine learning to recommend suitable crops
- **Soil Analysis**: Analyzes pH, nitrogen, phosphorus, potassium, and rainfall data
- **Seasonal Recommendations**: Provides crop suggestions based on season
- **Confidence Scoring**: Shows confidence level of recommendations
- **History Tracking**: Stores all soil tests and recommendations

### 2. Nearest Market Finder
- **Haversine Formula**: Calculates accurate distances between locations
- **Market Database**: Comprehensive database of agricultural markets in Nepal
- **Market Details**: Shows contact information, facilities, and operating hours
- **Distance Calculation**: Displays distance in kilometers
- **Travel Time Estimation**: Estimates travel time to markets

### 3. User Management
- **User Registration & Authentication**: Secure user accounts
- **Profile Management**: Store farmer information and preferences
- **Search History**: Track past crop recommendations and market searches

### 4. Admin Panel
- **Crop Management**: CRUD operations for crop database
- **Market Management**: Add, update, and manage market information
- **User Management**: View and manage user accounts
- **Data Analytics**: View usage statistics and recommendations

## Technology Stack

### Backend
- **Python 3.13**
- **Django 5.2.7** - Web framework
- **Django REST Framework** - API development
- **SQLite** (Development) / **MySQL** (Production) - Database
- **scikit-learn** - Machine learning (Decision Tree)
- **Pandas & NumPy** - Data processing

### Algorithms
1. **Decision Tree Classifier**
   - Criterion: Entropy (Information Gain)
   - Used for crop recommendation based on soil parameters
   
2. **Haversine Formula**
   - Calculates great-circle distance between coordinates
   - Used for finding nearest markets

## Installation & Setup

### Prerequisites
- Python 3.13 or higher
- pip package manager
- (Optional) MySQL server for production

### Step 1: Install Dependencies
```bash
pip install -r requirements.txt
```

### Step 2: Database Configuration

For **Development** (SQLite - Default):
The project is configured to use SQLite by default.

For **Production** (MySQL):
1. Create a MySQL database:
```sql
CREATE DATABASE agrinova_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

2. Update `agrinova_backend/settings.py`:
```python
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': 'agrinova_db',
        'USER': 'your_mysql_user',
        'PASSWORD': 'your_mysql_password',
        'HOST': 'localhost',
        'PORT': '3306',
    }
}
```

### Step 3: Run Migrations
```bash
python manage.py makemigrations
python manage.py migrate
```

### Step 4: Seed Database
```bash
python manage.py seed_crops
python manage.py seed_markets
```

### Step 5: Create Superuser
```bash
python manage.py createsuperuser
```

### Step 6: Run Development Server
```bash
python manage.py runserver
```

The API will be available at: `http://127.0.0.1:8000/`

## API Endpoints

### Authentication
- `POST /api/auth/register/` - Register new user
- `POST /api/auth/login/` - User login
- `POST /api/auth/logout/` - User logout
- `GET /api/auth/profile/` - Get user profile
- `PUT /api/auth/profile/` - Update user profile

### Crop Recommendation
- `GET /api/crops/crops/` - List all crops
- `POST /api/crops/crops/` - Create crop (Admin only)
- `GET /api/crops/crops/{id}/` - Get crop details
- `PUT /api/crops/crops/{id}/` - Update crop (Admin only)
- `DELETE /api/crops/crops/{id}/` - Delete crop (Admin only)
- `POST /api/crops/recommend/` - Get crop recommendation
- `GET /api/crops/recommendations/` - Get recommendation history
- `GET /api/crops/soil-data/` - Get user's soil data

### Market Finder
- `GET /api/markets/markets/` - List all markets
- `POST /api/markets/markets/` - Create market (Admin only)
- `GET /api/markets/markets/{id}/` - Get market details
- `POST /api/markets/find-nearest/` - Find nearest markets
- `GET /api/markets/search-history/` - Get search history
- `GET /api/markets/by-district/?district={name}` - Get markets by district

## API Usage Examples

### 1. User Registration
```json
POST /api/auth/register/
{
    "username": "farmer1",
    "email": "farmer1@example.com",
    "password": "securepassword",
    "password_confirm": "securepassword",
    "first_name": "Ram",
    "last_name": "Sharma",
    "phone_number": "9841234567",
    "district": "Kathmandu",
    "address": "Kathmandu-15"
}
```

### 2. Get Crop Recommendation
```json
POST /api/crops/recommend/
Headers: Authorization: Token <your_token>
{
    "ph_level": 6.5,
    "nitrogen": 90,
    "phosphorus": 45,
    "potassium": 45,
    "rainfall": 1800,
    "district": "Kathmandu",
    "season": "monsoon",
    "notes": "First soil test"
}
```

Response:
```json
{
    "recommendation": {
        "id": 1,
        "user": "farmer1",
        "recommended_crops_details": [
            {
                "crop_name": "Rice",
                "crop_description": "Staple cereal crop requiring flooded fields",
                "score": 0.95,
                "ranking": 1
            },
            {
                "crop_name": "Maize",
                "crop_description": "Versatile cereal crop",
                "score": 0.78,
                "ranking": 2
            }
        ],
        "algorithm_used": "Decision Tree",
        "confidence_score": 0.95,
        "created_at": "2025-10-27T10:30:00Z"
    },
    "message": "Crop recommendation generated successfully"
}
```

### 3. Find Nearest Markets
```json
POST /api/markets/find-nearest/
Headers: Authorization: Token <your_token>
{
    "latitude": 27.7172,
    "longitude": 85.3240,
    "district": "Kathmandu",
    "crop_to_sell": "Rice",
    "max_results": 5
}
```

Response:
```json
{
    "markets": [
        {
            "id": 1,
            "name": "Kalimati Fruit and Vegetable Market",
            "district": "Kathmandu",
            "address": "Kalimati, Kathmandu",
            "market_type": "wholesale",
            "phone_number": "01-4272345",
            "distance_km": 2.15,
            "estimated_travel_time_minutes": 3,
            "has_cold_storage": true
        }
    ],
    "message": "Found 5 nearby markets"
}
```

## Decision Tree Algorithm

The crop recommendation system uses a Decision Tree classifier with the following approach:

1. **Training Data**: Generated from crop requirements in database
2. **Features**: pH, Nitrogen, Phosphorus, Potassium, Rainfall, Season
3. **Target**: Crop name
4. **Scoring**: Calculates suitability score (0-1) for each crop
5. **Ranking**: Returns top 5 recommended crops

### Mathematical Formulation

**Entropy (Impurity Measure)**:
```
H(S) = -Σ(pi × log₂(pi))
```

**Information Gain**:
```
G(S,A) = H(S) - Σ(|Sv|/|S| × H(Sv))
```

## Haversine Formula

Used to calculate the distance between two points on Earth:

```
d = 2r × arcsin(√(sin²(Δlat/2) + cos(lat1) × cos(lat2) × sin²(Δlon/2)))
```

Where:
- r = Earth's radius (≈ 6371 km)
- Δlat = lat2 - lat1
- Δlon = lon2 - lon1

## Project Structure

```
agri_python/
├── agrinova_backend/          # Main project settings
│   ├── settings.py
│   ├── urls.py
│   └── wsgi.py
├── authentication/            # User authentication app
│   ├── models.py             # CustomUser, UserProfile
│   ├── views.py              # Login, Register, Profile
│   ├── serializers.py
│   └── urls.py
├── crop_recommendation/       # Crop recommendation app
│   ├── models.py             # Crop, SoilData, Recommendation
│   ├── views.py              # Crop CRUD, Recommendation API
│   ├── serializers.py
│   ├── recommendation_engine.py  # Decision Tree algorithm
│   ├── urls.py
│   └── management/commands/
│       └── seed_crops.py     # Seed crop data
├── market_finder/            # Market finder app
│   ├── models.py             # Market, MarketPrice, MarketSearch
│   ├── views.py              # Market API, Nearest finder
│   ├── serializers.py
│   ├── market_utils.py       # Haversine formula
│   ├── urls.py
│   └── management/commands/
│       └── seed_markets.py   # Seed market data
├── manage.py
├── requirements.txt
├── README.md
└── Documentation.txt         # Original project documentation
```

## Database Models

### CustomUser
- Username, email, password
- Phone number, district, address
- Extends Django's AbstractUser

### Crop
- Name, scientific name, description
- Soil requirements (pH, NPK ranges)
- Rainfall requirements
- Suitable seasons
- Growth duration, yield, market price

### SoilData
- User reference
- pH level, nitrogen, phosphorus, potassium, rainfall
- District, season
- Test date, notes

### CropRecommendation
- User reference
- Soil data reference
- Recommended crops with scores
- Algorithm used, confidence score
- Creation timestamp

### Market
- Name, district, address
- Latitude, longitude
- Market type (wholesale, retail, collection, cooperative)
- Contact information
- Operating hours, facilities
- Haversine distance calculation method

## Admin Panel

Access the Django admin panel at: `http://127.0.0.1:8000/admin/`

Features:
- Manage crops, markets, and users
- View recommendations and search history
- Add/update/delete records
- Filter and search functionality

## Frontend Development (Flutter)

The backend API is ready to integrate with a Flutter mobile application. The API follows RESTful principles and returns JSON responses.

Recommended Flutter packages:
- `http` or `dio` - HTTP client
- `provider` or `riverpod` - State management
- `flutter_map` - Map display
- `shared_preferences` - Local storage

## Testing

### Test Crop Recommendation
Use the following sample data:

**For Rice** (Monsoon Season):
- pH: 6.2
- Nitrogen: 100
- Phosphorus: 50
- Potassium: 50
- Rainfall: 1800

**For Wheat** (Winter Season):
- pH: 6.8
- Nitrogen: 90
- Phosphorus: 40
- Potassium: 40
- Rainfall: 550

**For Potato** (Winter Season):
- pH: 5.8
- Nitrogen: 120
- Phosphorus: 65
- Potassium: 135
- Rainfall: 600

### Test Market Finder
Sample coordinates:
- Kathmandu: 27.7172, 85.3240
- Pokhara: 28.2096, 83.9856
- Chitwan: 27.5291, 84.3542

## Security Considerations

1. **Authentication**: Token-based authentication
2. **Permissions**: Different access levels for users and admins
3. **CORS**: Configured for Flutter app integration
4. **Password**: Django's built-in password hashing
5. **SQL Injection**: Prevented by Django ORM

**For Production**:
- Set `DEBUG = False` in settings.py
- Use environment variables for secret keys
- Configure proper ALLOWED_HOSTS
- Use HTTPS
- Implement rate limiting

## Future Enhancements

1. Weather forecasting integration
2. Pest and disease detection (Image recognition)
3. Market price prediction
4. Fertilizer recommendation
5. Crop calendar and reminders
6. Community forum
7. Multi-language support (Nepali)
8. SMS notifications
9. Offline mode support
10. Integration with government databases

## Contributing

This is an academic project. For improvements or suggestions, please:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

This project is developed for academic purposes as part of an agriculture technology initiative for Nepal.

## Contact & Support

For questions or support:
- Project Documentation: See `Documentation.txt`
- Django Documentation: https://docs.djangoproject.com/
- Django REST Framework: https://www.django-rest-framework.org/

## Acknowledgments

- Decision Tree algorithm based on scikit-learn
- Haversine formula for geodesic distance calculation
- Agricultural data curated for Nepal's farming conditions
- Inspired by the need to modernize agriculture in Nepal

---

**AgriNova** - Empowering Farmers with Data-Driven Decisions
