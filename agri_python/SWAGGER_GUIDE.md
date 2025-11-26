# Swagger/OpenAPI Documentation Guide

## Overview

AgriNova API now includes interactive Swagger/OpenAPI documentation using `drf-yasg`. This provides a user-friendly interface to explore and test all API endpoints.

---

## Accessing Swagger Documentation

### 1. Swagger UI (Recommended)
```
http://127.0.0.1:8000/swagger/
```

**Features:**
- Interactive API explorer
- Try out endpoints directly
- View request/response examples
- Test authentication
- See all available parameters

### 2. ReDoc (Alternative View)
```
http://127.0.0.1:8000/redoc/
```

**Features:**
- Clean, three-panel design
- Better for reading documentation
- Responsive layout
- Search functionality

### 3. OpenAPI Schema (JSON/YAML)
```
http://127.0.0.1:8000/swagger.json
http://127.0.0.1:8000/swagger.yaml
```

**Use for:**
- Generating client libraries
- Importing to Postman
- API specifications
- Integration with tools

### 4. Root URL
```
http://127.0.0.1:8000/
```

Automatically redirects to Swagger UI

---

## Using Swagger UI

### Step 1: Access Swagger
Start your server and navigate to:
```
http://127.0.0.1:8000/swagger/
```

### Step 2: Explore Endpoints
Browse through the organized endpoint sections:
- **authentication** - User registration, login, profile
- **crop_recommendation** - Crop management and recommendations
- **market_finder** - Market finding and management

### Step 3: Test Without Authentication
Some endpoints are public:
- GET `/api/crops/crops/` - View all crops
- GET `/api/markets/markets/` - View all markets

Click on an endpoint → Click "Try it out" → Click "Execute"

### Step 4: Authenticate
For protected endpoints:

1. **Register a User** (if you don't have one):
   - Go to `POST /api/auth/register/`
   - Click "Try it out"
   - Fill in the request body:
     ```json
     {
       "username": "testuser",
       "email": "test@example.com",
       "password": "TestPass123!",
       "password_confirm": "TestPass123!",
       "first_name": "Test",
       "last_name": "User",
       "district": "Kathmandu"
     }
     ```
   - Click "Execute"
   - Copy the `token` from the response

2. **Login** (if you have an account):
   - Go to `POST /api/auth/login/`
   - Click "Try it out"
   - Enter credentials:
     ```json
     {
       "username": "testuser",
       "password": "TestPass123!"
     }
     ```
   - Click "Execute"
   - Copy the `token` from the response

3. **Add Token to Swagger**:
   - Click the green "Authorize" button at the top right
   - In the dialog, enter: `Token <your_token_here>`
   - Example: `Token 9944b09199c62bcf9418ad846dd0e4bbdfc6ee4b`
   - Click "Authorize"
   - Click "Close"

Now all protected endpoints will use your authentication token!

### Step 5: Test Crop Recommendation
1. Go to `POST /api/crops/recommend/`
2. Click "Try it out"
3. Fill in soil parameters:
   ```json
   {
     "ph_level": 6.2,
     "nitrogen": 100,
     "phosphorus": 50,
     "potassium": 50,
     "rainfall": 1800,
     "district": "Kathmandu",
     "season": "monsoon",
     "notes": "Test recommendation"
   }
   ```
4. Click "Execute"
5. View the recommended crops with scores!

### Step 6: Test Market Finder
1. Go to `POST /api/markets/find-nearest/`
2. Click "Try it out"
3. Enter coordinates:
   ```json
   {
     "latitude": 27.7172,
     "longitude": 85.3240,
     "district": "Kathmandu",
     "max_results": 5
   }
   ```
4. Click "Execute"
5. View nearest markets with distances!

---

## Swagger Features

### 1. Request Body Examples
- Each endpoint shows example request bodies
- JSON schema validation
- Required fields marked

### 2. Response Examples
- Success responses (200, 201)
- Error responses (400, 401, 404, 500)
- Real-world example data

### 3. Parameter Documentation
- Path parameters (e.g., `/api/crops/crops/{id}/`)
- Query parameters (e.g., `?search=rice`)
- Request body parameters

### 4. Schema Definitions
- View all data models
- Field types and constraints
- Relationships between models

### 5. Authentication Documentation
- Token authentication explained
- How to obtain tokens
- How to use tokens in requests

---

## Swagger Sections

### Authentication APIs
```
POST /api/auth/register/     - Register new user
POST /api/auth/login/        - Login user
POST /api/auth/logout/       - Logout user
GET  /api/auth/profile/      - Get user profile
PUT  /api/auth/profile/      - Update user profile
```

### Crop Recommendation APIs
```
GET    /api/crops/crops/             - List all crops
POST   /api/crops/crops/             - Create crop (Admin)
GET    /api/crops/crops/{id}/        - Get crop details
PUT    /api/crops/crops/{id}/        - Update crop (Admin)
DELETE /api/crops/crops/{id}/        - Delete crop (Admin)
POST   /api/crops/recommend/         - Get recommendation
GET    /api/crops/recommendations/   - View history
GET    /api/crops/search/            - Search crops
```

### Market Finder APIs
```
GET    /api/markets/markets/              - List all markets
POST   /api/markets/markets/              - Create market (Admin)
GET    /api/markets/markets/{id}/         - Get market details
POST   /api/markets/find-nearest/         - Find nearest markets
GET    /api/markets/search-history/       - View search history
GET    /api/markets/by-district/          - Filter by district
```

---

## Benefits of Swagger Documentation

### For Developers
- ✅ Interactive testing without Postman
- ✅ Instant API exploration
- ✅ Auto-generated from code
- ✅ Always up-to-date
- ✅ No manual documentation needed

### For Frontend Developers
- ✅ Clear API contracts
- ✅ Request/response examples
- ✅ Type definitions
- ✅ Error handling guidance
- ✅ Authentication flow

### For API Consumers
- ✅ Try before integrating
- ✅ Understand data structures
- ✅ Test edge cases
- ✅ Validate assumptions
- ✅ Debug issues

### For Documentation
- ✅ Single source of truth
- ✅ No outdated docs
- ✅ Shareable link
- ✅ Professional appearance
- ✅ Standard format (OpenAPI)

---

## Advanced Usage

### 1. Import to Postman
1. Get the schema: `http://127.0.0.1:8000/swagger.json`
2. In Postman: File → Import → Link
3. Paste the URL
4. All endpoints imported!

### 2. Generate Client Code
Use OpenAPI Generator:
```bash
# For Flutter/Dart
openapi-generator-cli generate -i http://127.0.0.1:8000/swagger.json -g dart -o ./dart-client

# For JavaScript
openapi-generator-cli generate -i http://127.0.0.1:8000/swagger.json -g javascript -o ./js-client

# For Python
openapi-generator-cli generate -i http://127.0.0.1:8000/swagger.json -g python -o ./python-client
```

### 3. Share with Team
- Share the Swagger URL
- Export to JSON/YAML
- Generate PDF documentation

### 4. CI/CD Integration
- Validate API changes
- Generate docs automatically
- Deploy to documentation site

---

## Customization

The Swagger configuration is in `agrinova_backend/urls.py`:

```python
schema_view = get_schema_view(
    openapi.Info(
        title="AgriNova API",
        default_version='v1',
        description="Agriculture Advisory System API",
        contact=openapi.Contact(email="support@agrinova.com"),
        license=openapi.License(name="Academic License"),
    ),
    public=True,
    permission_classes=(permissions.AllowAny,),
)
```

### Change Title/Description
Edit the `openapi.Info()` parameters in `urls.py`.

### Add More Documentation
Use `@swagger_auto_schema` decorator in views:
```python
from drf_yasg.utils import swagger_auto_schema
from drf_yasg import openapi

@swagger_auto_schema(
    operation_description="Detailed description here",
    responses={
        200: "Success",
        404: "Not found"
    }
)
def your_view(self, request):
    ...
```

---

## Sample Test Flow

### Complete Workflow Example:

1. **Start Server**
   ```bash
   python manage.py runserver
   ```

2. **Open Swagger**
   ```
   http://127.0.0.1:8000/swagger/
   ```

3. **Register User**
   - POST `/api/auth/register/`
   - Get token

4. **Authorize**
   - Click "Authorize"
   - Enter: `Token <your_token>`

5. **Get All Crops**
   - GET `/api/crops/crops/`
   - See 12 crops

6. **Get Recommendation**
   - POST `/api/crops/recommend/`
   - Enter soil data
   - Get crop suggestions

7. **Find Markets**
   - POST `/api/markets/find-nearest/`
   - Enter coordinates
   - Get nearest markets

8. **View History**
   - GET `/api/crops/recommendations/`
   - GET `/api/markets/search-history/`

---

## Troubleshooting

### Issue: "Authorization" button not working
**Solution:** Make sure to include "Token " prefix:
```
Token 9944b09199c62bcf9418ad846dd0e4bbdfc6ee4b
NOT just: 9944b09199c62bcf9418ad846dd0e4bbdfc6ee4b
```

### Issue: Getting 401 Unauthorized
**Solution:** 
1. Login first to get a valid token
2. Click "Authorize" and add token
3. Token format: `Token <your_token>`

### Issue: Swagger page not loading
**Solution:**
1. Make sure server is running
2. Check if `drf-yasg` is installed
3. Check `INSTALLED_APPS` in settings.py

### Issue: Changes not reflected
**Solution:**
1. Restart the server
2. Hard refresh browser (Ctrl+Shift+R)
3. Clear browser cache

---

## Production Considerations

### Disable in Production
For security, you might want to disable Swagger in production:

```python
# urls.py
from django.conf import settings

if settings.DEBUG:
    urlpatterns += [
        path('swagger/', schema_view.with_ui('swagger', cache_timeout=0)),
        path('redoc/', schema_view.with_ui('redoc', cache_timeout=0)),
    ]
```

### Protect with Authentication
Make Swagger require authentication:

```python
schema_view = get_schema_view(
    openapi.Info(...),
    public=False,  # Changed from True
    permission_classes=(permissions.IsAuthenticated,),
)
```

---

## Quick Reference

| URL | Purpose |
|-----|---------|
| `/swagger/` | Interactive Swagger UI |
| `/redoc/` | ReDoc documentation |
| `/swagger.json` | OpenAPI JSON schema |
| `/swagger.yaml` | OpenAPI YAML schema |
| `/` | Redirects to Swagger |

---

## Next Steps

1. ✅ Explore all endpoints in Swagger
2. ✅ Test crop recommendations
3. ✅ Test market finder
4. ✅ Export schema for Flutter integration
5. ✅ Share Swagger link with team

---

**Swagger is now fully integrated with AgriNova!** 🎉

Access it at: **http://127.0.0.1:8000/swagger/**

---

*For more information, see:*
- [drf-yasg Documentation](https://drf-yasg.readthedocs.io/)
- [OpenAPI Specification](https://swagger.io/specification/)
- [Swagger UI](https://swagger.io/tools/swagger-ui/)
