from rest_framework import serializers
from .models import Market, MarketPrice, MarketSearch

class MarketSerializer(serializers.ModelSerializer):
    class Meta:
        model = Market
        fields = '__all__'

class MarketPriceSerializer(serializers.ModelSerializer):
    market_name = serializers.ReadOnlyField(source='market.name')
    
    class Meta:
        model = MarketPrice
        fields = ['id', 'market', 'market_name', 'crop_name', 'price_per_kg', 
                  'unit', 'price_date', 'quality_grade', 'source']

class NearestMarketSerializer(serializers.ModelSerializer):
    distance_km = serializers.FloatField(read_only=True)
    
    class Meta:
        model = Market
        fields = ['id', 'name', 'district', 'address', 'latitude', 'longitude', 
                  'market_type', 'phone_number', 'opening_time', 'closing_time',
                  'has_cold_storage', 'has_grading_facility', 'has_packaging_facility',
                  'transportation_available', 'distance_km']

class MarketSearchSerializer(serializers.ModelSerializer):
    user = serializers.ReadOnlyField(source='user.username')
    nearest_market_details = NearestMarketSerializer(source='nearest_market', read_only=True)
    
    class Meta:
        model = MarketSearch
        fields = ['id', 'user', 'search_latitude', 'search_longitude', 
                  'search_district', 'crop_to_sell', 'nearest_market', 
                  'nearest_market_details', 'distance_km', 'search_date']
        read_only_fields = ['id', 'search_date']

class MarketSearchRequestSerializer(serializers.Serializer):
    """
    Serializer for market search request
    """
    latitude = serializers.FloatField()
    longitude = serializers.FloatField()
    district = serializers.CharField(max_length=100, required=False)
    crop_to_sell = serializers.CharField(max_length=100, required=False)
    max_results = serializers.IntegerField(default=5, min_value=1, max_value=20)
