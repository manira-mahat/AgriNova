# AgriNova API Documentation

## Base URL
```
http://127.0.0.1:8000/api
```

## Authentication

All endpoints (except registration and login) require authentication using Token Authentication.

Include the token in the request header:
```
Authorization: Token <your_token_here>
```

---

## Authentication Endpoints

### 1. User Registration
**Endpoint:** `POST /auth/register/`

**Request Body:**
```json
{
    "username": "farmer1",
    "email": "farmer1@example.com",
    "password": "SecurePass123!",
    "password_confirm": "SecurePass123!",
    "first_name": "Ram",
    "last_name": "Sharma",
    "phone_number": "9841234567",
    "district": "Kathmandu",
    "address": "Kathmandu-15"
}
```

**Response (201 Created):**
```json
{
    "user": {
        "id": 1,
        "username": "farmer1",
        "email": "farmer1@example.com",
        "first_name": "Ram",
        "last_name": "Sharma",
        "phone_number": "9841234567",
        "district": "Kathmandu",
        "address": "Kathmandu-15"
    },
    "token": "9944b09199c62bcf9418ad846dd0e4bbdfc6ee4b",
    "message": "User registered successfully"
}
```

### 2. User Login
**Endpoint:** `POST /auth/login/`

**Request Body:**
```json
{
    "username": "farmer1",
    "password": "SecurePass123!"
}
```

**Response (200 OK):**
```json
{
    "user": {...},
    "token": "9944b09199c62bcf9418ad846dd0e4bbdfc6ee4b",
    "message": "Login successful"
}
```

### 3. User Logout
**Endpoint:** `POST /auth/logout/`

**Headers:** `Authorization: Token <token>`

**Response (200 OK):**
```json
{
    "message": "Logout successful"
}
```

### 4. Get User Profile
**Endpoint:** `GET /auth/profile/`

**Headers:** `Authorization: Token <token>`

**Response (200 OK):**
```json
{
    "id": 1,
    "username": "farmer1",
    "email": "farmer1@example.com",
    "first_name": "Ram",
    "last_name": "Sharma",
    "phone_number": "9841234567",
    "district": "Kathmandu",
    "address": "Kathmandu-15",
    "profile": {
        "farm_size": 2.5,
        "farming_experience": 10,
        "preferred_crops": "Rice, Wheat, Maize",
        "latitude": 27.7172,
        "longitude": 85.3240
    }
}
```

---

## Crop Management Endpoints

### 5. List All Crops
**Endpoint:** `GET /crops/crops/`

**Headers:** `Authorization: Token <token>`

**Response (200 OK):**
```json
[
    {
        "id": 1,
        "name": "Rice",
        "scientific_name": "Oryza sativa",
        "description": "Staple cereal crop requiring flooded fields",
        "min_ph": 5.5,
        "max_ph": 7.0,
        "min_nitrogen": 80,
        "max_nitrogen": 120,
        "min_phosphorus": 40,
        "max_phosphorus": 60,
        "min_potassium": 40,
        "max_potassium": 60,
        "min_rainfall": 1200,
        "max_rainfall": 2500,
        "suitable_seasons": "monsoon, summer",
        "growth_duration": 120,
        "yield_per_hectare": 4000.0,
        "market_price": 35.0
    },
    ...
]
```

### 6. Get Crop Details
**Endpoint:** `GET /crops/crops/{id}/`

**Headers:** `Authorization: Token <token>`

**Response (200 OK):**
```json
{
    "id": 1,
    "name": "Rice",
    ...
}
```

### 7. Search Crops
**Endpoint:** `GET /crops/search/?search={query}`

**Headers:** `Authorization: Token <token>`

**Example:** `/crops/search/?search=rice`

---

## Crop Recommendation Endpoints

### 8. Get Crop Recommendation
**Endpoint:** `POST /crops/recommend/`

**Headers:** `Authorization: Token <token>`

**Request Body:**
```json
{
    "ph_level": 6.2,
    "nitrogen": 100,
    "phosphorus": 50,
    "potassium": 50,
    "rainfall": 1800,
    "district": "Kathmandu",
    "season": "monsoon",
    "notes": "First soil test of the year"
}
```

**Valid Seasons:** `spring`, `summer`, `monsoon`, `autumn`, `winter`

**Response (200 OK):**
```json
{
    "recommendation": {
        "id": 1,
        "user": "farmer1",
        "soil_data_details": {
            "id": 1,
            "user": "farmer1",
            "ph_level": 6.2,
            "nitrogen": 100.0,
            "phosphorus": 50.0,
            "potassium": 50.0,
            "rainfall": 1800.0,
            "district": "Kathmandu",
            "season": "monsoon",
            "test_date": "2025-10-27T10:30:00Z",
            "notes": "First soil test of the year"
        },
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
            },
            {
                "crop_name": "Cucumber",
                "crop_description": "Warm season vegetable",
                "score": 0.65,
                "ranking": 3
            }
        ],
        "algorithm_used": "Decision Tree",
        "confidence_score": 0.95,
        "created_at": "2025-10-27T10:30:00Z",
        "is_active": true
    },
    "message": "Crop recommendation generated successfully"
}
```

### 9. Get Recommendation History
**Endpoint:** `GET /crops/recommendations/`

**Headers:** `Authorization: Token <token>`

**Response (200 OK):**
```json
[
    {
        "id": 1,
        "user": "farmer1",
        "soil_data_details": {...},
        "recommended_crops_details": [...],
        "algorithm_used": "Decision Tree",
        "confidence_score": 0.95,
        "created_at": "2025-10-27T10:30:00Z"
    },
    ...
]
```

### 10. Get Specific Recommendation
**Endpoint:** `GET /crops/recommendations/{id}/`

**Headers:** `Authorization: Token <token>`

---

## Market Finder Endpoints

### 11. List All Markets
**Endpoint:** `GET /markets/markets/`

**Headers:** `Authorization: Token <token>`

**Response (200 OK):**
```json
[
    {
        "id": 1,
        "name": "Kalimati Fruit and Vegetable Market",
        "district": "Kathmandu",
        "address": "Kalimati, Kathmandu",
        "latitude": 27.699,
        "longitude": 85.288,
        "market_type": "wholesale",
        "contact_person": "Market Manager",
        "phone_number": "01-4272345",
        "email": "",
        "opening_time": "04:00:00",
        "closing_time": "20:00:00",
        "operating_days": "Every day",
        "has_cold_storage": true,
        "has_grading_facility": true,
        "has_packaging_facility": true,
        "transportation_available": true,
        "is_active": true
    },
    ...
]
```

### 12. Get Market Details
**Endpoint:** `GET /markets/markets/{id}/`

**Headers:** `Authorization: Token <token>`

### 13. Find Nearest Markets
**Endpoint:** `POST /markets/find-nearest/`

**Headers:** `Authorization: Token <token>`

**Request Body:**
```json
{
    "latitude": 27.7172,
    "longitude": 85.3240,
    "district": "Kathmandu",
    "crop_to_sell": "Rice",
    "max_results": 5
}
```

**Response (200 OK):**
```json
{
    "markets": [
        {
            "id": 1,
            "name": "Kalimati Fruit and Vegetable Market",
            "district": "Kathmandu",
            "address": "Kalimati, Kathmandu",
            "latitude": 27.699,
            "longitude": 85.288,
            "market_type": "wholesale",
            "phone_number": "01-4272345",
            "opening_time": "04:00:00",
            "closing_time": "20:00:00",
            "has_cold_storage": true,
            "has_grading_facility": true,
            "has_packaging_facility": true,
            "transportation_available": true,
            "distance_km": 2.15,
            "estimated_travel_time_minutes": 3
        },
        {
            "id": 2,
            "name": "Balkhu Fruit Market",
            "district": "Kathmandu",
            "address": "Balkhu, Kathmandu",
            "latitude": 27.682,
            "longitude": 85.295,
            "market_type": "wholesale",
            "phone_number": "01-4231234",
            "distance_km": 3.8,
            "estimated_travel_time_minutes": 6
        }
    ],
    "search_id": 1,
    "message": "Found 2 nearby markets"
}
```

### 14. Get Markets by District
**Endpoint:** `GET /markets/by-district/?district={district_name}`

**Headers:** `Authorization: Token <token>`

**Example:** `/markets/by-district/?district=Kathmandu`

### 15. Get Market Search History
**Endpoint:** `GET /markets/search-history/`

**Headers:** `Authorization: Token <token>`

**Response (200 OK):**
```json
[
    {
        "id": 1,
        "user": "farmer1",
        "search_latitude": 27.7172,
        "search_longitude": 85.324,
        "search_district": "Kathmandu",
        "crop_to_sell": "Rice",
        "nearest_market": 1,
        "nearest_market_details": {...},
        "distance_km": 2.15,
        "search_date": "2025-10-27T11:00:00Z"
    },
    ...
]
```

---

## Error Responses

### 400 Bad Request
```json
{
    "error": "Invalid input data",
    "details": {
        "ph_level": ["This field is required."]
    }
}
```

### 401 Unauthorized
```json
{
    "detail": "Authentication credentials were not provided."
}
```

### 404 Not Found
```json
{
    "error": "No suitable crops found for the given parameters",
    "soil_data_id": 1
}
```

### 500 Internal Server Error
```json
{
    "error": "Error generating recommendation: <error message>"
}
```

---

## Sample Soil Parameters for Testing

### Rice (Monsoon Season)
```json
{
    "ph_level": 6.2,
    "nitrogen": 100,
    "phosphorus": 50,
    "potassium": 50,
    "rainfall": 1800,
    "season": "monsoon"
}
```

### Wheat (Winter Season)
```json
{
    "ph_level": 6.8,
    "nitrogen": 90,
    "phosphorus": 40,
    "potassium": 40,
    "rainfall": 550,
    "season": "winter"
}
```

### Potato (Winter Season)
```json
{
    "ph_level": 5.8,
    "nitrogen": 120,
    "phosphorus": 65,
    "potassium": 135,
    "rainfall": 600,
    "season": "winter"
}
```

### Tomato (Summer Season)
```json
{
    "ph_level": 6.5,
    "nitrogen": 120,
    "phosphorus": 65,
    "potassium": 175,
    "rainfall": 500,
    "season": "summer"
}
```

---

## Sample Coordinates for Nepal

| Location | Latitude | Longitude |
|----------|----------|-----------|
| Kathmandu | 27.7172 | 85.3240 |
| Pokhara | 28.2096 | 83.9856 |
| Chitwan | 27.5291 | 84.3542 |
| Bhaktapur | 27.6710 | 85.4298 |
| Lalitpur | 27.6669 | 85.3240 |
| Dhading | 27.8667 | 84.9000 |
| Biratnagar | 26.4839 | 87.2718 |

---

## Notes

1. All timestamps are in ISO 8601 format (UTC)
2. Distances are calculated using the Haversine formula
3. Token authentication is required for all protected endpoints
4. Admin users have additional permissions for CRUD operations on crops and markets
5. The Decision Tree algorithm uses entropy-based information gain
6. Confidence scores range from 0.0 to 1.0 (higher is better)
7. Crop suitability scores range from 0.0 to 1.0

---

For more information, see the main README.md file.
