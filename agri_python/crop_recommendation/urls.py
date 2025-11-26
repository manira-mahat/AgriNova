from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    CropViewSet,
    SoilDataViewSet,
    CropRecommendationView,
    CropRecommendationHistoryView,
    CropRecommendationDetailView,
    CropSearchView
)

app_name = 'crop_recommendation'

router = DefaultRouter()
router.register(r'crops', CropViewSet, basename='crop')
router.register(r'soil-data', SoilDataViewSet, basename='soil-data')

urlpatterns = [
    path('', include(router.urls)),
    path('recommend/', CropRecommendationView.as_view(), name='recommend'),
    path('recommendations/', CropRecommendationHistoryView.as_view(), name='recommendation-history'),
    path('recommendations/<int:pk>/', CropRecommendationDetailView.as_view(), name='recommendation-detail'),
    path('search/', CropSearchView.as_view(), name='crop-search'),
]
