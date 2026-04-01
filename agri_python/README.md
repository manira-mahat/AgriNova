# AgriNova Backend (Django + DRF)

Backend API for AgriNova, a digital agriculture advisory system.

This service provides:
- token-based authentication and profile management
- crop recommendation based on soil/rainfall input (Decision Tree engine)
- nearest market finder using the Haversine formula
- admin CRUD for crops, markets, and market prices
- interactive API documentation (Swagger / ReDoc)

## Tech Stack

- Python 3.9+
- Django 5.2.7
- Django REST Framework 3.15.2
- django-cors-headers 4.6.0
- drf-yasg 1.21.8
- scikit-learn 1.6.1
- pandas 2.2.3
- numpy 2.2.1
- Database: SQLite (default in current settings)

## Project Apps

- `authentication`: user registration/login/logout, profile, admin user listing/deletion
- `crop_recommendation`: crop dataset CRUD, soil data, recommendation generation/history
- `market_finder`: markets CRUD, market prices CRUD, nearest market search/history

## Setup

1. Install dependencies:

```bash
pip install -r requirements.txt
```

2. Run migrations:

```bash
python manage.py migrate
```

3. Seed initial data:

```bash
python manage.py seed_crops
python manage.py seed_markets
```

4. (Optional) create admin user:

```bash
python manage.py createsuperuser
```

5. Start server:

```bash
python manage.py runserver
```

Default local URL:

```text
http://127.0.0.1:8000/
```

## API Documentation

- Swagger UI: `/swagger/`
- ReDoc: `/redoc/`
- OpenAPI JSON/YAML: `/swagger.json` or `/swagger.yaml`
- Root (`/`) currently opens Swagger UI

## Authentication

The API uses DRF token authentication.

- Register/login endpoints return a token.
- Send token in headers:

```text
Authorization: Token <your_token>
```

There is also a DRF token endpoint:

- `POST /api-token-auth/`

## Base Route Groups

- `/api/auth/`
- `/api/crops/`
- `/api/markets/`

## Endpoints

### Authentication (`/api/auth/`)

- `POST register/` - create user account
- `POST login/` - login and get token
- `POST logout/` - invalidate current token (auth required)
- `GET profile/` - get basic user profile (auth required)
- `PUT profile/` - update basic profile (auth required)
- `PATCH profile/` - partial update basic profile (auth required)
- `GET profile/detail/` - get extended profile fields (auth required)
- `PUT profile/detail/` - update extended profile fields (auth required)
- `PATCH profile/detail/` - partial update extended profile fields (auth required)
- `GET users/` - list users (admin only)
- `DELETE users/<id>/` - delete non-admin user (admin only)

### Crop Recommendation (`/api/crops/`)

- `GET crops/` - list crops
- `POST crops/` - create crop (admin only)
- `GET crops/<id>/` - crop detail
- `PUT crops/<id>/` - update crop (admin only)
- `PATCH crops/<id>/` - partial update crop (admin only)
- `DELETE crops/<id>/` - delete crop (admin only)

- `GET soil-data/` - list current user soil records (auth required)
- `POST soil-data/` - create soil record for current user (auth required)
- `GET soil-data/<id>/` - soil record detail (owner only)
- `PUT soil-data/<id>/` - update soil record (owner only)
- `PATCH soil-data/<id>/` - partial update soil record (owner only)
- `DELETE soil-data/<id>/` - delete soil record (owner only)

- `POST recommend/` - generate crop recommendation from input (auth required)
- `GET recommendations/` - recommendation history (auth required)
- `GET recommendations/<id>/` - recommendation detail (auth required)
- `GET search/?search=<name>` - search crops by name

### Market Finder (`/api/markets/`)

- `GET markets/` - list active markets
- `POST markets/` - create market (admin only)
- `GET markets/<id>/` - market detail
- `PUT markets/<id>/` - update market (admin only)
- `PATCH markets/<id>/` - partial update market (admin only)
- `DELETE markets/<id>/` - delete market (admin only)

- `GET prices/` - list market prices
- `POST prices/` - create market price (admin only)
- `GET prices/<id>/` - market price detail
- `PUT prices/<id>/` - update market price (admin only)
- `PATCH prices/<id>/` - partial update market price (admin only)
- `DELETE prices/<id>/` - delete market price (admin only)

- `POST find-nearest/` - nearest market search by coordinates (auth required)
- `GET search-history/` - current user market search history (auth required)
- `GET by-district/?district=<name>` - filter markets by district
- `GET markets/<market_id>/prices/` - list prices for one market

## Recommendation Input (Current)

`POST /api/crops/recommend/` expects:

```json
{
  "ph_level": 6.5,
  "nitrogen": 90,
  "phosphorus": 45,
  "potassium": 45,
  "rainfall": 1800,
  "temperature": 24,
  "humidity": 65,
  "district": "Kathmandu",
  "season": "Summer",
  "notes": "Optional note"
}
```

## Nearest Market Input (Current)

`POST /api/markets/find-nearest/` expects:

```json
{
  "latitude": 27.7172,
  "longitude": 85.3240,
  "district": "Kathmandu",
  "crop_to_sell": "Rice",
  "max_results": 5
}
```

## Key Models

- `authentication.CustomUser`
- `authentication.UserProfile`
- `crop_recommendation.Crop`
- `crop_recommendation.SoilData`
- `crop_recommendation.CropRecommendation`
- `crop_recommendation.RecommendationScore`
- `market_finder.Market`
- `market_finder.MarketPrice`
- `market_finder.MarketSearch`

## Notes

- Current settings use SQLite (`db.sqlite3`) for local development.
- CORS is currently open for development (`CORS_ALLOW_ALL_ORIGINS = True`).
- Default REST permission is authenticated access unless endpoint overrides it.
