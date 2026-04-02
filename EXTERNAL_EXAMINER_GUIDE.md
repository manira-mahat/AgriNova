# AgriNova External Examiner Guide

This guide is prepared for viva, demonstration, and technical defense.
It is updated to match the current codebase state.

## 1. Quick Facts (Examiner Snapshot)

- Project: AgriNova (Agriculture Advisory + Market Finder)
- Frontend: Flutter (mobile app)
- Backend: Django REST Framework
- Auth: Token authentication (DRF Token)
- Current DB setup: SQLite (development configuration)
- API docs: Swagger and ReDoc
- Core advisory logic:
  - Crop recommendation: Rule-based scoring engine in prediction path
  - Nearest market finder: Haversine formula

Important clarification:
- The codebase includes DecisionTreeClassifier training utilities.
- Live recommendation response path currently uses rule-based scoring via calculate_suitability_scores inside predict.
- API response stores algorithm_used as "Decision Tree" for recommendation records.


## 2. What to Say in 30 Seconds

AgriNova is a mobile-first advisory platform for farmers. A user submits soil and season data; the system ranks suitable crops using a deterministic scoring algorithm based on crop requirement ranges. The user can also search nearest markets using Haversine distance from coordinates. The backend is modularized into authentication, crop_recommendation, and market_finder apps with token-based access and role-based endpoint control.


## 3. Current Architecture

### 3.1 Application Layers
- Presentation layer: Flutter app
- Service layer: Django REST APIs
- Data layer: SQLite in current dev setup

### 3.2 Backend Apps
- authentication
  - register/login/logout
  - profile and profile/detail
  - admin user listing and non-admin deletion
- crop_recommendation
  - crop CRUD
  - soil-data CRUD (user-scoped)
  - recommend, recommendations history/detail, crop search
- market_finder
  - market CRUD
  - market price CRUD
  - find-nearest, search-history, by-district, market-specific prices

### 3.3 Auth and Permissions
- Default DRF permission: IsAuthenticated
- Public/AllowAny endpoints: register/login (in their views)
- Admin-only operations: create/update/delete for crops/markets/prices, admin user list/delete


## 4. Crop Recommendation: Real Runtime Logic

### 4.1 Actual Runtime Flow
1. User calls POST /api/crops/recommend/
2. Request validated by CropRecommendationRequestSerializer
3. SoilData record is saved
4. Engine predict(...) is called
5. predict(...) computes scores using calculate_suitability_scores(...)
6. Results are ranked, filtered, saved into CropRecommendation and RecommendationScore
7. API returns ranked recommendations + confidence

### 4.2 Rule-Based Scoring Core
For each crop (season-compatible only):
- Compute parameter score for pH, N, P, K, rainfall
- If within optimal range: score 1.0
- If outside range: penalize by distance from boundary
- Final score: average of 5 parameter scores (equal weighting)
- Rank descending
- Filter threshold around 0.3 for recommendation inclusion

### 4.3 Why This Matters in Viva
- Deterministic and explainable output
- No dependence on historical labeled user outcomes
- Easy to audit and validate with domain experts
- Suitable for small curated crop datasets

### 4.4 ML Utilities Present in Code
The engine has:
- prepare_training_data
- train_model
- season encoding

These support optional Decision Tree experimentation, but recommendation generation path for current API is rule-based scoring.

### 4.5 Exactly Where Data Comes From and How Recommendation Is Produced

This is the direct answer for viva questions like:
- "From where is recommendation data coming?"
- "Where is algorithm used in code?"
- "How is data shown on screen?"

Data source for recommendation:
1. Crop requirement dataset stored in Crop table (seeded from management command).
2. Live user input from form fields (pH, N, P, K, rainfall, season, district).

Code path (backend):

```python
# views.py (recommend endpoint)
recommendations = crop_recommendation_engine.predict(
  data['ph_level'],
  data['nitrogen'],
  data['phosphorus'],
  data['potassium'],
  data['rainfall'],
  data['season']
)
```

```python
# recommendation_engine.py (runtime recommendation path)
def predict(self, ph_level, nitrogen, phosphorus, potassium, rainfall, season):
  season_encoded = self._encode_season(season)
  scores = self.calculate_suitability_scores(
    [ph_level, nitrogen, phosphorus, potassium, rainfall, season_encoded]
  )
  recommended = [s for s in scores if s['score'] >= 0.3]
  return recommended[:5]
```

```python
# recommendation_engine.py (scoring core)
def calculate_suitability_scores(self, input_data):
  crops = Crop.objects.all()
  # For each crop: season check -> parameter scores -> weighted average -> ranking
```

How data is persisted:
1. User input is stored in SoilData.
2. Final recommendation metadata is stored in CropRecommendation.
3. Each ranked crop score is stored in RecommendationScore.

How data is shown in app (frontend flow):
1. Form screen sends data to provider.
2. Provider calls service.
3. Service calls POST crops/recommend API.
4. JSON response is mapped to Recommendation model.
5. Provider stores currentRecommendation and notifies listeners.
6. Result screen reads provider state and renders recommendation values.

Minimal frontend path snippet:

```dart
// crop_service.dart
final response = await ApiService.post("crops/recommend/", data);
return Recommendation.fromJson(response['recommendation']);
```

```dart
// crop_provider.dart
_currentRecommendation = await CropService.getRecommendation(data);
notifyListeners();
```

```dart
// crop_result_screen.dart
final recommendation = cropProvider.currentRecommendation;
Text(recommendation?.cropName ?? 'N/A')
```

One-line viva answer:
"Recommendation data comes from Crop requirement ranges in the database plus user soil input; the algorithm is executed in crop_recommendation/recommendation_engine.py via predict -> calculate_suitability_scores, and the result is returned by the recommend API then shown by Flutter Provider state in the result screen."


## 5. Nearest Market Finder Logic

### 5.1 Formula Used
Haversine distance between user lat/lon and market lat/lon.

### 5.2 API Flow
1. User calls POST /api/markets/find-nearest/
2. Request validated (lat/lon, optional district, max_results)
3. Active markets fetched, optionally district-filtered
4. Distances computed and sorted
5. Search history persisted
6. Results returned with estimated travel time

### 5.3 Complexity Note
- Distance calculation: O(n) over filtered markets
- Sorting: O(n log n)
- Overall dominated by sorting for larger n


## 6. Data Model Defense Points

Key entities to mention in viva:
- CustomUser, UserProfile
- Crop
- SoilData
- CropRecommendation
- RecommendationScore (through/ranking table)
- Market
- MarketPrice
- MarketSearch

Why RecommendationScore exists:
- Stores per-crop score and rank per recommendation event
- Makes output traceable and auditable


## 7. API Surface (High Value Endpoints)

Authentication:
- POST /api/auth/register/
- POST /api/auth/login/
- POST /api/auth/logout/
- GET/PUT/PATCH /api/auth/profile/
- GET/PUT/PATCH /api/auth/profile/detail/
- GET /api/auth/users/ (admin)
- DELETE /api/auth/users/<id>/ (admin)

Crop module:
- /api/crops/crops/
- /api/crops/soil-data/
- POST /api/crops/recommend/
- GET /api/crops/recommendations/
- GET /api/crops/recommendations/<id>/
- GET /api/crops/search/?search=<term>

Market module:
- /api/markets/markets/
- /api/markets/prices/
- POST /api/markets/find-nearest/
- GET /api/markets/search-history/
- GET /api/markets/by-district/?district=<name>
- GET /api/markets/markets/<market_id>/prices/

Docs:
- /swagger/
- /redoc/


## 8. Demo Plan for External Examiner

1. Start backend and open Swagger.
2. Register user and login to obtain token.
3. Authorize token in Swagger.
4. Call crop recommendation endpoint with sample values.
5. Show recommendation history endpoint.
6. Call nearest market endpoint with sample coordinates.
7. Show search-history endpoint.
8. Login as admin and demonstrate one admin-only CRUD operation.
9. Show permission denial behavior with non-admin token.
10. Explain algorithm path from request to stored ranking.


## 9. Deep Viva Questions and Strong Answers

### 9.1 Architecture and Design

1) Q: Why did you choose Flutter + Django instead of an all-JS stack?
A: Flutter gives a consistent mobile UI and strong DX for forms/stateful screens; Django REST gives robust auth, ORM, and fast API development. For this scope, separation was productive and maintainable.

2) Q: Why split backend into 3 apps?
A: To separate concerns: authentication, recommendation, and market logic evolve independently, making testing, permissions, and maintenance cleaner.

3) Q: Which architectural pattern is this backend following?
A: Practical layered architecture with domain modules: serializer (validation), view (orchestration), model (persistence), utility/engine (algorithmic logic).

4) Q: Where is business logic placed and why?
A: Recommendation and market distance logic are in engine/utility modules to avoid fat views and keep logic testable and reusable.

5) Q: How does the mobile app stay decoupled from backend internals?
A: Through stable REST contracts and JSON payloads. Frontend only depends on endpoint contracts, not ORM/model internals.

### 9.2 Recommendation Algorithm

6) Q: Is recommendation ML or rule-based?
A: Current API prediction path is rule-based scoring. ML training utilities exist but are not the primary runtime decision path.

7) Q: Why keep ML utilities if runtime is rule-based?
A: They support future experimentation and comparison, but current deployment prioritizes explainability and deterministic behavior.

8) Q: Explain the scoring function in one sentence.
A: Each parameter gets a score based on distance to crop-optimal range; the overall crop score is the mean of parameter scores.

9) Q: Why equal weights for pH, N, P, K, rainfall?
A: Simplicity and interpretability for baseline version. Weight tuning is a planned extension once field feedback accumulates.

10) Q: What is the threshold role (around 0.3)?
A: It filters low-quality matches. If all are low, fallback keeps top options to avoid empty output and preserve user guidance.

11) Q: What are algorithm strengths?
A: Explainable, deterministic, low-data dependency, easy to validate with domain experts.

12) Q: What are algorithm weaknesses?
A: Static thresholds/weights, no adaptive learning from outcomes, sensitivity to curated range quality.

13) Q: How would you validate recommendation quality scientifically?
A: Collect farmer outcomes (yield, failure rates), run offline evaluation against baseline methods, and calibrate ranges/weights or add hybrid ML.

14) Q: How do you handle season mismatch?
A: Crops not suitable for the selected season are skipped before scoring.

15) Q: Why is confidence score top recommendation score?
A: It is a simple proxy for best fit quality. Future versions can include margin-based confidence and uncertainty bands.

16) Q: Can this algorithm overfit?
A: Not in ML sense, since runtime path is deterministic rules; quality risk is from poorly specified ranges, not overfitting.

17) Q: How do you support explainability to non-technical users?
A: By showing parameter-wise fit messages and rank/score. This can be further improved with reason codes per parameter.

18) Q: Why store recommendation results instead of recomputing always?
A: Auditability, user history, reproducibility, and analytics.

19) Q: If two crops tie in score, how is ranking handled?
A: Sorting is deterministic by score order; explicit tie-break strategies can be added (market price, growth duration, local preference).

20) Q: What happens if crop table is empty?
A: Recommendation cannot produce valid output; system returns error/no suitable crop response path.

### 9.3 Input Validation and Data Integrity

21) Q: How do you prevent impossible pH values?
A: Serializer enforces min/max bounds (0 to 14).

22) Q: How do you prevent negative nutrient values?
A: Serializer uses min_value=0 for N, P, K, and rainfall.

23) Q: How do you restrict humidity values?
A: Humidity validator uses 0 to 100.

24) Q: Why validate at serializer layer?
A: Centralized API boundary validation with clear client errors before business logic execution.

25) Q: What ensures soil records are user-scoped?
A: SoilDataViewSet queryset filters by request.user.

26) Q: Could one user read another user's recommendation detail?
A: Recommendation detail queryset is user-filtered, preventing cross-user access.

27) Q: Are model constraints enough, or do you need serializer checks too?
A: Both are useful: serializer for API input clarity and model constraints for persistence-level safety.

### 9.4 Security and Auth

28) Q: Why token auth instead of JWT?
A: DRF Token is simpler for this scope and sufficient for session-like mobile API access; JWT can be added later for advanced token lifecycle.

29) Q: Where are admin restrictions enforced?
A: In view permissions (IsAdminUser) for admin-sensitive CRUD actions.

30) Q: What are current security weaknesses in settings?
A: Development config has DEBUG=True, ALLOWED_HOSTS='*', and CORS_ALLOW_ALL_ORIGINS=True. Production hardening is required.

31) Q: How do you invalidate user session?
A: Logout endpoint deletes auth token.

32) Q: Why keep SessionAuthentication with TokenAuthentication?
A: Supports browsable API/dev convenience while token supports mobile client.

33) Q: What is one immediate production fix?
A: Disable DEBUG, restrict hosts/CORS, rotate secrets, and enforce HTTPS.

### 9.5 Market Finder and Geo Logic

34) Q: Why Haversine instead of Euclidean distance?
A: Haversine approximates great-circle distance on Earth, suitable for latitude/longitude points.

35) Q: Why not road-network distance?
A: Requires map routing APIs or road graph data. Haversine is simpler and acceptable baseline for nearest estimation.

36) Q: Can district filtering hide closer markets in neighboring districts?
A: Yes, district filter narrows candidate set intentionally. User can search without district for strict nearest.

37) Q: How is travel time estimated?
A: A simple average speed assumption converts distance to minutes. It is an estimate, not live traffic routing.

38) Q: What if no active markets match?
A: API returns not found style response with guidance message.

39) Q: Complexity of nearest search?
A: O(n) distance computations + O(n log n) sorting.

40) Q: How to optimize for large market datasets?
A: Use spatial indexing/geohash prefiltering, bounding boxes, and database-level geospatial queries.

### 9.6 Database and Persistence

41) Q: Why SQLite currently?
A: Simplicity for development and academic demonstration.

42) Q: Why might SQLite be a bottleneck in production?
A: Write concurrency and scaling constraints for high traffic.

43) Q: Recommended production migration target?
A: PostgreSQL or MySQL with managed backups and monitoring.

44) Q: Why normalize recommendation scores into separate table?
A: Supports one-to-many ranking records per recommendation event.

45) Q: How do you ensure historical traceability?
A: Each recommendation/search event is persisted with timestamp and linked entities.

46) Q: What backup strategy would you propose?
A: Daily snapshots, point-in-time recovery where possible, and migration/versioned schema management.

### 9.7 API and Error Handling

47) Q: How does the recommendation endpoint handle runtime failures?
A: Wraps generation in try/except and returns 500 with error message and saved soil_data_id for traceability.

48) Q: Why save SoilData before recommendation computation?
A: Preserves user input event even if recommendation fails; useful for diagnostics/history.

49) Q: Is returning raw exception text safe?
A: Useful in development but should be sanitized in production to avoid leakage.

50) Q: How are API docs generated?
A: drf-yasg schema generation with Swagger and ReDoc routes.

51) Q: Why include request/response examples in swagger annotations?
A: Improves API usability, testing speed, and examiner clarity.

52) Q: How do you version APIs?
A: Current endpoints are grouped by module; formal versioning strategy (v1 path namespace) can be introduced for long-term compatibility.

### 9.8 Testing Strategy

53) Q: What levels of testing are needed here?
A: Unit (serializers/engines), integration (API + DB), and end-to-end flows from auth to recommendation/market history.

54) Q: Which edge cases are critical for recommendation tests?
A: Boundary pH values, zero nutrients, out-of-range rainfall, season mismatch, empty crop dataset.

55) Q: Which edge cases are critical for market tests?
A: Invalid coordinates, no markets found, district filter edge, max_results limits.

56) Q: What security tests should be included?
A: Unauthorized access checks, admin endpoint denial for non-admin tokens, token invalidation behavior.

57) Q: How do you test data isolation?
A: Verify user A cannot access user B soil/recommendation/search history.

58) Q: What is one regression risk after algorithm changes?
A: Score distribution shifts affecting rank stability and user trust; requires baseline comparison tests.

### 9.9 Performance and Scalability

59) Q: Current likely bottlenecks?
A: Per-request crop scoring loop for larger datasets, nearest search sorting for large market lists, unoptimized dev DB.

60) Q: How to improve recommendation throughput?
A: Cache crop requirement structures, optimize query patterns, precompute normalization constants.

61) Q: How to improve nearest market throughput?
A: Geospatial indexing and candidate prefiltering before sorting.

62) Q: Would async tasks help?
A: Yes for non-blocking heavy computations/analytics, though current real-time scoring is lightweight.

63) Q: What metrics would you monitor in production?
A: Request latency, error rates, DB query time, recommendation success rate, auth failures.

### 9.10 Product and Domain Questions

64) Q: Why is explainability crucial for farmers?
A: Advisory trust depends on understandable reasons, not black-box outputs.

65) Q: How do you localize for Nepali farming contexts?
A: Curated crops, district fields, and planned local language support.

66) Q: What happens if user input quality is poor?
A: Recommendation quality degrades; system should add validation hints and guidance prompts.

67) Q: Can user preferences be integrated?
A: Yes, as secondary ranking factors (market price, growth duration, preferred crops).

68) Q: How would you incorporate weather forecast?
A: Add forecast API ingestion and adjust scoring with forecast-aware modifiers.

69) Q: How can recommendation fairness be discussed?
A: Ensure no arbitrary bias in ranking factors, keep logic transparent and auditable.

70) Q: What is the practical impact of market module?
A: Translates recommendation into action by reducing market discovery friction.

### 9.11 Deployment and Operations

71) Q: Minimal production checklist?
A: DEBUG false, restricted hosts/CORS, HTTPS, secret management, DB migration, logging, backups, health checks.

72) Q: How do you handle configuration differences by environment?
A: Use environment variables and split settings modules.

73) Q: Why add centralized logging?
A: For diagnosis, incident response, and quality auditing.

74) Q: What CI checks should run on every commit?
A: Lint, unit tests, API contract tests, and migration checks.

75) Q: How would you roll out schema changes safely?
A: Backward-compatible migrations, staged deployment, and rollback plan.

### 9.12 Advanced Follow-Up Questions

76) Q: If an examiner says this is not Decision Tree in production, how do you answer?
A: Correct. Runtime ranking currently uses deterministic rule scoring. DecisionTreeClassifier utilities exist as optional/future path. The report should clearly separate present runtime logic from experimental components.

77) Q: Why still store algorithm_used as "Decision Tree"?
A: Historical naming in model record. It should be revised to reflect actual runtime strategy (for example "Rule-Based Scoring") to avoid ambiguity.

78) Q: How would you compare rule-based vs ML objectively?
A: Use held-out outcome dataset and compare recommendation precision/recall or yield-oriented utility metrics, plus explainability and maintenance cost.

79) Q: What is your plan to move from heuristic to hybrid model?
A: Keep rule-based baseline, collect outcome labels, build hybrid ranker combining hard agronomic constraints + learned reranking.

80) Q: How would you defend this as academically valid?
A: It is a complete software-engineering solution with domain-driven algorithm design, validated API architecture, role-based security, persistence, and explainable decision logic.

### 9.13 Previous Questions (Retained) With Updated Answers

These are the earlier common viva questions retained intentionally, with answers updated to match current implementation flow.

Q: Is this a Machine Learning project?
A: The current runtime recommendation flow is rule-based scoring. The engine compares user soil values against crop requirement ranges and ranks crops. DecisionTreeClassifier utilities exist in code, but the live recommend API path uses predict -> calculate_suitability_scores.

Q: Why not use Machine Learning directly in production flow?
A: For the current version, explainability and deterministic output were prioritized. The rule-based method is transparent for farmers and easy to validate with crop requirement ranges. ML utilities are kept for future experiments when larger real outcome data is available.

Q: How does the algorithm work?
A: User submits pH, N, P, K, rainfall, season. Backend filters crops by season, computes per-parameter suitability scores, averages them with equal weight, sorts descending, filters weak matches, stores ranking, and returns top results.

Q: What if user enters invalid input data?
A: Serializer validation rejects invalid payloads (for example pH outside 0-14, negative nutrients, humidity outside 0-100). The API returns validation errors before recommendation logic runs.

Q: How accurate is the system?
A: Accuracy depends on quality of crop requirement ranges and user input quality. Since logic is deterministic and range-based, recommendations are consistent and explainable. For stronger scientific accuracy claims, field outcome data and comparative evaluation are planned.

Q: From where is data being recommended?
A: From Crop requirement records in the database (seeded data) plus live user soil input submitted at recommend endpoint. The algorithm uses both to compute score and ranking.

Q: Where is the algorithm used in code?
A: In crop_recommendation/views.py the recommend endpoint calls crop_recommendation_engine.predict(...). Inside recommendation_engine.py, predict invokes calculate_suitability_scores, which performs runtime scoring and ranking.

Q: How is the recommended data shown in app?
A: API response is mapped in crop_service.dart, saved in CropProvider as currentRecommendation, and rendered in crop_result_screen.dart after notifyListeners triggers UI rebuild.


## 10. Short High-Impact Answers (Use in Rapid Viva)

- "Current recommendation path is deterministic and explainable, not black-box ML."
- "Prediction and persistence are auditable through recommendation and score tables."
- "Security is token-based with explicit admin-only controls on sensitive CRUD routes."
- "Nearest market search uses Haversine baseline; road-network routing is future work."
- "The architecture is modular and can evolve to hybrid intelligence without rewriting core APIs."


## 11. Known Gaps and Honest Defense

- Development settings are not hardened for production yet.
- Dataset size is limited and curated; scaling needs richer regional data.
- Travel-time estimate is heuristic, not live traffic aware.
- Algorithm metadata label in records should be aligned with actual runtime logic.

These do not invalidate the project; they define clear and defensible future roadmap items.


## 12. Final Defense Statement

AgriNova is a practical, explainable, and modular advisory platform that solves a real
workflow gap by combining crop recommendation and market discovery in one mobile-backed
system. The project demonstrates strong full-stack engineering, defensible algorithmic
choices, and a credible path for production and research-grade enhancements.

---
Prepared for: External Examiner
Project: AgriNova Agriculture Advisory System
Updated on: 01 April 2026
Version: 2.0
