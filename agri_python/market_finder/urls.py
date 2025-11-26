from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    MarketViewSet,
    MarketPriceViewSet,
    NearestMarketFinderView,
    MarketSearchHistoryView,
    MarketsByDistrictView,
    MarketPriceByMarketView
)

app_name = 'market_finder'

router = DefaultRouter()
router.register(r'markets', MarketViewSet, basename='market')
router.register(r'prices', MarketPriceViewSet, basename='market-price')

urlpatterns = [
    path('', include(router.urls)),
    path('find-nearest/', NearestMarketFinderView.as_view(), name='find-nearest'),
    path('search-history/', MarketSearchHistoryView.as_view(), name='search-history'),
    path('by-district/', MarketsByDistrictView.as_view(), name='by-district'),
    path('markets/<int:market_id>/prices/', MarketPriceByMarketView.as_view(), name='market-prices'),
]
