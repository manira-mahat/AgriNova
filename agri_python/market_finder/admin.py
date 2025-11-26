from django.contrib import admin
from .models import Market, MarketPrice, MarketSearch

@admin.register(Market)
class MarketAdmin(admin.ModelAdmin):
    list_display = ['name', 'district', 'market_type', 'phone_number', 'is_active']
    list_filter = ['market_type', 'district', 'is_active', 'has_cold_storage']
    search_fields = ['name', 'district', 'address']
    ordering = ['district', 'name']

@admin.register(MarketPrice)
class MarketPriceAdmin(admin.ModelAdmin):
    list_display = ['crop_name', 'market', 'price_per_kg', 'unit', 'quality_grade', 'price_date']
    list_filter = ['quality_grade', 'price_date', 'market']
    search_fields = ['crop_name', 'market__name']
    date_hierarchy = 'price_date'

@admin.register(MarketSearch)
class MarketSearchAdmin(admin.ModelAdmin):
    list_display = ['user', 'search_district', 'crop_to_sell', 'nearest_market', 'distance_km', 'search_date']
    list_filter = ['search_district', 'search_date']
    search_fields = ['user__username', 'search_district', 'crop_to_sell']
    date_hierarchy = 'search_date'

