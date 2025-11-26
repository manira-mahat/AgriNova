from django.contrib import admin
from .models import Crop, SoilData, CropRecommendation, RecommendationScore

@admin.register(Crop)
class CropAdmin(admin.ModelAdmin):
    list_display = ['name', 'scientific_name', 'growth_duration', 'yield_per_hectare', 'market_price']
    list_filter = ['suitable_seasons']
    search_fields = ['name', 'scientific_name']
    ordering = ['name']

@admin.register(SoilData)
class SoilDataAdmin(admin.ModelAdmin):
    list_display = ['user', 'district', 'season', 'ph_level', 'nitrogen', 'phosphorus', 'potassium', 'test_date']
    list_filter = ['season', 'district', 'test_date']
    search_fields = ['user__username', 'district']
    date_hierarchy = 'test_date'

@admin.register(CropRecommendation)
class CropRecommendationAdmin(admin.ModelAdmin):
    list_display = ['user', 'algorithm_used', 'confidence_score', 'created_at', 'is_active']
    list_filter = ['algorithm_used', 'is_active', 'created_at']
    search_fields = ['user__username']
    date_hierarchy = 'created_at'

@admin.register(RecommendationScore)
class RecommendationScoreAdmin(admin.ModelAdmin):
    list_display = ['recommendation', 'crop', 'score', 'ranking']
    list_filter = ['ranking']
    search_fields = ['crop__name', 'recommendation__user__username']

