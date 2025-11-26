# AgriNova System Architecture

## System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        AgriNova System                          │
└─────────────────────────────────────────────────────────────────┘

┌───────────────┐         ┌──────────────────┐         ┌──────────────┐
│               │         │                  │         │              │
│  Flutter      │◄───────►│  Django REST API │◄───────►│   SQLite/    │
│  Mobile App   │  HTTP   │    (Backend)     │         │   MySQL DB   │
│               │         │                  │         │              │
└───────────────┘         └──────────────────┘         └──────────────┘
                                   │
                    ┌──────────────┼──────────────┐
                    │              │              │
            ┌───────▼──────┐ ┌────▼─────┐ ┌─────▼──────┐
            │ Decision Tree│ │ Haversine│ │  User Auth │
            │  Algorithm   │ │  Formula │ │   System   │
            └──────────────┘ └──────────┘ └────────────┘
```

## Application Layers

### 1. Frontend Layer (Flutter - To be developed)
```
┌─────────────────────────────────────────┐
│  User Interface (Mobile App)            │
├─────────────────────────────────────────┤
│ • Login/Register Screen                 │
│ • Dashboard                             │
│ • Soil Input Form                       │
│ • Crop Recommendation Display           │
│ • Market Finder Screen                  │
│ • Map View                              │
│ • History & Profile                     │
└─────────────────────────────────────────┘
```

### 2. API Layer (Django REST Framework)
```
┌─────────────────────────────────────────┐
│  REST API Endpoints                     │
├─────────────────────────────────────────┤
│ /api/auth/*        - Authentication     │
│ /api/crops/*       - Crop Management    │
│ /api/markets/*     - Market Finder      │
└─────────────────────────────────────────┘
```

### 3. Business Logic Layer
```
┌─────────────────────────────────────────┐
│  Django Apps                            │
├─────────────────────────────────────────┤
│ • authentication/                       │
│   ├─ User Management                    │
│   └─ Token Authentication               │
│                                         │
│ • crop_recommendation/                  │
│   ├─ Crop CRUD                          │
│   ├─ Soil Data Management               │
│   └─ Decision Tree Engine               │
│                                         │
│ • market_finder/                        │
│   ├─ Market CRUD                        │
│   └─ Haversine Calculator               │
└─────────────────────────────────────────┘
```

### 4. Data Layer
```
┌─────────────────────────────────────────┐
│  Database Models                        │
├─────────────────────────────────────────┤
│ • CustomUser                            │
│ • UserProfile                           │
│ • Crop                                  │
│ • SoilData                              │
│ • CropRecommendation                    │
│ • Market                                │
│ • MarketPrice                           │
│ • MarketSearch                          │
└─────────────────────────────────────────┘
```

## Data Flow Diagrams

### Crop Recommendation Flow
```
User Input (Soil Parameters)
        ↓
  API Request (POST /api/crops/recommend/)
        ↓
  Save to SoilData table
        ↓
  Decision Tree Algorithm
        ↓
  Calculate Suitability Scores
        ↓
  Rank Crops by Score
        ↓
  Save to CropRecommendation table
        ↓
  Return Top 5 Crops
        ↓
  Display to User
```

### Market Finder Flow
```
User Input (Latitude, Longitude)
        ↓
  API Request (POST /api/markets/find-nearest/)
        ↓
  Get All Active Markets from DB
        ↓
  For Each Market:
    Calculate Distance (Haversine Formula)
        ↓
  Sort by Distance
        ↓
  Get Top N Results
        ↓
  Save to MarketSearch table
        ↓
  Return Markets with Distances
        ↓
  Display on Map/List
```

## Algorithm Implementations

### 1. Decision Tree Algorithm
```
Input: [pH, N, P, K, Rainfall, Season]
         ↓
   Encode Season → Numeric
         ↓
   For Each Crop in Database:
     • Check season compatibility
     • Calculate parameter scores:
       - pH Score
       - Nitrogen Score
       - Phosphorus Score
       - Potassium Score
       - Rainfall Score
     • Weighted Average = Overall Score
         ↓
   Filter Crops (score >= 0.3)
         ↓
   Sort by Score (descending)
         ↓
   Return Top 5 Crops with Rankings
```

### 2. Haversine Formula
```
Input: (lat1, lon1, lat2, lon2)
         ↓
   Convert to Radians
         ↓
   Calculate Differences:
     Δlat = lat2 - lat1
     Δlon = lon2 - lon1
         ↓
   Apply Formula:
     a = sin²(Δlat/2) + cos(lat1) × cos(lat2) × sin²(Δlon/2)
     c = 2 × arcsin(√a)
     d = R × c  (R = 6371 km)
         ↓
   Return Distance in km
```

## Database Schema Relationships

```
CustomUser ───┬──► UserProfile (1:1)
              │
              ├──► SoilData (1:N)
              │
              ├──► CropRecommendation (1:N)
              │
              └──► MarketSearch (1:N)

Crop ◄───────────► RecommendationScore ◄─── CropRecommendation
                   (M:N through table)

Market ───┬──► MarketPrice (1:N)
          │
          └──► MarketSearch (1:N)

SoilData ◄────── CropRecommendation (N:1)
```

## API Request/Response Flow

### Example: Crop Recommendation

**Request:**
```http
POST /api/crops/recommend/
Authorization: Token abc123...
Content-Type: application/json

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

**Processing:**
```
1. Validate Token → Get User
2. Validate Input Data
3. Create SoilData Record
4. Run Decision Tree Algorithm
5. Calculate Crop Scores
6. Create CropRecommendation Record
7. Create RecommendationScore Records
8. Serialize Response
```

**Response:**
```json
{
  "recommendation": {
    "id": 1,
    "confidence_score": 0.95,
    "recommended_crops_details": [
      {
        "crop_name": "Rice",
        "score": 0.95,
        "ranking": 1
      }
    ]
  },
  "message": "Success"
}
```

## Security Architecture

```
┌─────────────────────────────────────────┐
│  Security Layers                        │
├─────────────────────────────────────────┤
│ 1. Token Authentication                 │
│    • Each user gets unique token        │
│    • Token required for all requests    │
│                                         │
│ 2. Permission System                    │
│    • Admin: Full CRUD access            │
│    • User: Limited to own data          │
│                                         │
│ 3. Django Security Features             │
│    • Password hashing (PBKDF2)          │
│    • CSRF protection                    │
│    • SQL injection prevention (ORM)     │
│    • XSS protection                     │
│                                         │
│ 4. CORS Configuration                   │
│    • Allowed origins for Flutter app    │
└─────────────────────────────────────────┘
```

## Deployment Architecture (Future)

```
┌──────────────────────────────────────────────────┐
│                   Production                     │
├──────────────────────────────────────────────────┤
│                                                  │
│  ┌─────────────┐         ┌──────────────┐      │
│  │  Flutter    │         │   Django     │      │
│  │  Web/APK    │◄───────►│  on Heroku   │      │
│  │             │  HTTPS  │  or AWS      │      │
│  └─────────────┘         └──────┬───────┘      │
│                                  │               │
│                          ┌───────▼────────┐     │
│                          │   MySQL DB     │     │
│                          │   (Cloud)      │     │
│                          └────────────────┘     │
│                                                  │
└──────────────────────────────────────────────────┘
```

## File Structure Tree

```
agri_python/
│
├── agrinova_backend/           # Main project
│   ├── __init__.py
│   ├── settings.py            # Configuration
│   ├── urls.py                # Main URL routing
│   ├── wsgi.py               # WSGI config
│   └── asgi.py               # ASGI config
│
├── authentication/            # Auth app
│   ├── models.py             # CustomUser, UserProfile
│   ├── views.py              # Register, Login, Profile
│   ├── serializers.py        # API serializers
│   ├── urls.py               # Auth URLs
│   ├── admin.py              # Admin config
│   └── migrations/           # DB migrations
│
├── crop_recommendation/       # Crop app
│   ├── models.py             # Crop, SoilData, Recommendation
│   ├── views.py              # Crop CRUD, Recommend API
│   ├── serializers.py        # API serializers
│   ├── urls.py               # Crop URLs
│   ├── admin.py              # Admin config
│   ├── recommendation_engine.py  # Decision Tree
│   ├── management/commands/
│   │   └── seed_crops.py     # Seed command
│   └── migrations/
│
├── market_finder/            # Market app
│   ├── models.py             # Market, MarketPrice, Search
│   ├── views.py              # Market CRUD, Find API
│   ├── serializers.py        # API serializers
│   ├── urls.py               # Market URLs
│   ├── admin.py              # Admin config
│   ├── market_utils.py       # Haversine formula
│   ├── management/commands/
│   │   └── seed_markets.py   # Seed command
│   └── migrations/
│
├── manage.py                 # Django CLI
├── db.sqlite3               # Database (dev)
├── requirements.txt         # Python packages
├── README.md                # Full documentation
├── API_DOCUMENTATION.md     # API reference
├── QUICK_START.md          # Quick guide
├── ARCHITECTURE.md         # This file
└── test_api.py             # Test script
```

## Technologies Used

| Layer | Technology | Purpose |
|-------|-----------|---------|
| Frontend | Flutter | Mobile app (to be developed) |
| Backend | Django 5.2.7 | Web framework |
| API | Django REST Framework | RESTful APIs |
| Database | SQLite/MySQL | Data storage |
| ML | scikit-learn | Decision Tree |
| Math | NumPy/Pandas | Data processing |
| Auth | Token Auth | User authentication |
| CORS | django-cors-headers | Cross-origin requests |

## Performance Considerations

### Optimization Strategies
1. **Database Indexing** - On frequently queried fields
2. **Query Optimization** - Use select_related, prefetch_related
3. **Caching** - Redis for frequently accessed data (future)
4. **Pagination** - Limit API response sizes
5. **Async Processing** - For heavy computations (future)

### Scalability
- **Horizontal**: Add more app servers
- **Vertical**: Increase server resources
- **Database**: Move to MySQL/PostgreSQL for production
- **CDN**: For static files
- **Load Balancer**: Distribute traffic

---

This architecture provides a solid foundation for the AgriNova agriculture advisory system, with clear separation of concerns and room for future enhancements.
