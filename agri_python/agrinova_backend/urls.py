"""
URL configuration for agrinova_backend project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/5.2/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path, include, re_path
from rest_framework.authtoken import views as authtoken_views
from rest_framework import permissions
from drf_yasg.views import get_schema_view
from drf_yasg import openapi

# Swagger/OpenAPI Schema Configuration
schema_view = get_schema_view(
    openapi.Info(
        title="AgriNova API",
        default_version='v1',
        description="""
        # AgriNova - Agriculture Advisory System API
        
        A comprehensive digital agriculture advisory system for farmers in Nepal.
        
        ## Features
        - **User Authentication**: Register, login, and manage user profiles
        - **Crop Recommendations**: AI-powered crop suggestions using Decision Tree algorithm
        - **Market Finder**: Find nearest agricultural markets using Haversine formula
        - **History Tracking**: View past recommendations and market searches
        
        ## Authentication
        This API uses Token-based authentication. Include the token in the Authorization header:
        ```
        Authorization: Token <your_token_here>
        ```
        
        ## Endpoints Overview
        - `/api/auth/` - Authentication endpoints
        - `/api/crops/` - Crop management and recommendations
        - `/api/markets/` - Market finder and management
        """,
        terms_of_service="https://www.agrinova.com/terms/",
        contact=openapi.Contact(email="support@agrinova.com"),
        license=openapi.License(name="Academic License"),
    ),
    public=True,
    permission_classes=(permissions.AllowAny,),
)

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/auth/', include('authentication.urls')),
    path('api/crops/', include('crop_recommendation.urls')),
    path('api/markets/', include('market_finder.urls')),
    path('api-token-auth/', authtoken_views.obtain_auth_token),
    
    # Swagger/OpenAPI Documentation URLs
    re_path(r'^swagger(?P<format>\.json|\.yaml)$', schema_view.without_ui(cache_timeout=0), name='schema-json'),
    path('swagger/', schema_view.with_ui('swagger', cache_timeout=0), name='schema-swagger-ui'),
    path('redoc/', schema_view.with_ui('redoc', cache_timeout=0), name='schema-redoc'),
    path('', schema_view.with_ui('swagger', cache_timeout=0), name='api-root'),  # Root redirects to Swagger
]
