from rest_framework import serializers
from .models import Crop, SoilData, CropRecommendation, RecommendationScore

class CropSerializer(serializers.ModelSerializer):
    class Meta:
        model = Crop
        fields = '__all__'

class SoilDataSerializer(serializers.ModelSerializer):
    user = serializers.ReadOnlyField(source='user.username')
    
    class Meta:
        model = SoilData
        fields = ['id', 'user', 'ph_level', 'nitrogen', 'phosphorus', 'potassium', 
                  'rainfall', 'temperature', 'humidity', 'district', 'season', 'test_date', 'notes']
        read_only_fields = ['id', 'test_date']

class RecommendationScoreSerializer(serializers.ModelSerializer):
    crop_name = serializers.ReadOnlyField(source='crop.name')
    crop_description = serializers.ReadOnlyField(source='crop.description')
    
    class Meta:
        model = RecommendationScore
        fields = ['crop_name', 'crop_description', 'score', 'ranking']

class CropRecommendationSerializer(serializers.ModelSerializer):
    user = serializers.ReadOnlyField(source='user.username')
    soil_data_details = SoilDataSerializer(source='soil_data', read_only=True)
    recommended_crops_details = RecommendationScoreSerializer(
        source='recommendationscore_set', 
        many=True, 
        read_only=True
    )
    
    class Meta:
        model = CropRecommendation
        fields = ['id', 'user', 'soil_data', 'soil_data_details', 
                  'recommended_crops_details', 'algorithm_used', 
                  'confidence_score', 'created_at', 'is_active']
        read_only_fields = ['id', 'created_at']

class CropRecommendationRequestSerializer(serializers.Serializer):
    """
    Serializer for crop recommendation request
    """
    ph_level = serializers.FloatField(min_value=0, max_value=14)
    nitrogen = serializers.FloatField(min_value=0)
    phosphorus = serializers.FloatField(min_value=0)
    potassium = serializers.FloatField(min_value=0)
    rainfall = serializers.FloatField(min_value=0)
    temperature = serializers.FloatField(required=False, allow_null=True)
    humidity = serializers.FloatField(min_value=0, max_value=100, required=False, allow_null=True)
    district = serializers.CharField(max_length=100)
    season = serializers.ChoiceField(choices=Crop.SEASONS)
    notes = serializers.CharField(required=False, allow_blank=True)
