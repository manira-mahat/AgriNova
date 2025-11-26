from rest_framework import generics, status, permissions, viewsets
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.decorators import action
from django.db import transaction
from drf_yasg.utils import swagger_auto_schema
from drf_yasg import openapi
from .models import Crop, SoilData, CropRecommendation, RecommendationScore
from .serializers import (
    CropSerializer, 
    SoilDataSerializer, 
    CropRecommendationSerializer,
    CropRecommendationRequestSerializer
)
from .recommendation_engine import crop_recommendation_engine

class CropViewSet(viewsets.ModelViewSet):
    """
    CRUD operations for crops.
    
    Admin users can create, update, and delete crops.
    All authenticated users can view crops.
    """
    queryset = Crop.objects.all()
    serializer_class = CropSerializer
    
    def get_permissions(self):
        if self.action in ['create', 'update', 'partial_update', 'destroy']:
            return [permissions.IsAdminUser()]
        return [permissions.IsAuthenticatedOrReadOnly()]
    
    @swagger_auto_schema(
        operation_description="List all crops with their soil and climate requirements"
    )
    def list(self, request, *args, **kwargs):
        return super().list(request, *args, **kwargs)
    
    @swagger_auto_schema(
        operation_description="Get details of a specific crop"
    )
    def retrieve(self, request, *args, **kwargs):
        return super().retrieve(request, *args, **kwargs)

class SoilDataViewSet(viewsets.ModelViewSet):
    """
    Manage soil test data.
    
    Users can view and manage their own soil test records.
    """
    serializer_class = SoilDataSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        # Users can only see their own soil data
        return SoilData.objects.filter(user=self.request.user)
    
    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

class CropRecommendationView(APIView):
    """
    Get AI-powered crop recommendations based on soil parameters.
    
    Uses Decision Tree algorithm to analyze soil conditions and recommend suitable crops.
    """
    permission_classes = [permissions.IsAuthenticated]
    
    @swagger_auto_schema(
        operation_description="""
        Get crop recommendations based on soil parameters.
        
        The system analyzes:
        - Soil pH level
        - Nitrogen content (N)
        - Phosphorus content (P)
        - Potassium content (K)
        - Rainfall data
        - Season
        
        Returns top 5 recommended crops with suitability scores.
        """,
        request_body=CropRecommendationRequestSerializer,
        responses={
            200: openapi.Response(
                description="Recommendation generated successfully",
                examples={
                    "application/json": {
                        "recommendation": {
                            "id": 1,
                            "confidence_score": 0.95,
                            "recommended_crops_details": [
                                {
                                    "crop_name": "Rice",
                                    "score": 0.95,
                                    "ranking": 1
                                }
                            ]
                        },
                        "message": "Crop recommendation generated successfully"
                    }
                }
            ),
            404: "No suitable crops found",
            500: "Error generating recommendation"
        }
    )
    @transaction.atomic
    def post(self, request):
        serializer = CropRecommendationRequestSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        data = serializer.validated_data
        
        # Save soil data
        soil_data = SoilData.objects.create(
            user=request.user,
            ph_level=data['ph_level'],
            nitrogen=data['nitrogen'],
            phosphorus=data['phosphorus'],
            potassium=data['potassium'],
            rainfall=data['rainfall'],
            district=data['district'],
            season=data['season'],
            notes=data.get('notes', '')
        )
        
        # Get recommendations from engine
        try:
            recommendations = crop_recommendation_engine.predict(
                data['ph_level'],
                data['nitrogen'],
                data['phosphorus'],
                data['potassium'],
                data['rainfall'],
                data['season']
            )
            
            if not recommendations:
                return Response({
                    'error': 'No suitable crops found for the given parameters',
                    'soil_data_id': soil_data.id
                }, status=status.HTTP_404_NOT_FOUND)
            
            # Calculate confidence score
            confidence = crop_recommendation_engine.get_confidence_score(recommendations)
            
            # Create recommendation record
            crop_recommendation = CropRecommendation.objects.create(
                user=request.user,
                soil_data=soil_data,
                algorithm_used='Decision Tree',
                confidence_score=confidence
            )
            
            # Save recommended crops with scores
            for rec in recommendations:
                RecommendationScore.objects.create(
                    recommendation=crop_recommendation,
                    crop=rec['crop'],
                    score=rec['score'],
                    ranking=rec['ranking']
                )
            
            # Return response
            recommendation_serializer = CropRecommendationSerializer(crop_recommendation)
            
            return Response({
                'recommendation': recommendation_serializer.data,
                'message': 'Crop recommendation generated successfully'
            }, status=status.HTTP_200_OK)
            
        except Exception as e:
            return Response({
                'error': f'Error generating recommendation: {str(e)}',
                'soil_data_id': soil_data.id
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

class CropRecommendationHistoryView(generics.ListAPIView):
    """
    View history of crop recommendations for the authenticated user.
    """
    serializer_class = CropRecommendationSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    @swagger_auto_schema(
        operation_description="Get all past crop recommendations for the current user"
    )
    def get(self, request, *args, **kwargs):
        return super().get(request, *args, **kwargs)
    
    def get_queryset(self):
        return CropRecommendation.objects.filter(user=self.request.user)

class CropRecommendationDetailView(generics.RetrieveAPIView):
    """
    View details of a specific crop recommendation.
    """
    serializer_class = CropRecommendationSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        return CropRecommendation.objects.filter(user=self.request.user)

class CropSearchView(generics.ListAPIView):
    """
    Search crops by name.
    """
    serializer_class = CropSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]
    
    @swagger_auto_schema(
        operation_description="Search crops by name",
        manual_parameters=[
            openapi.Parameter(
                'search',
                openapi.IN_QUERY,
                description="Search term for crop name",
                type=openapi.TYPE_STRING
            )
        ]
    )
    def get(self, request, *args, **kwargs):
        return super().get(request, *args, **kwargs)
    
    def get_queryset(self):
        queryset = Crop.objects.all()
        search = self.request.query_params.get('search', None)
        if search:
            queryset = queryset.filter(name__icontains=search)
        return queryset
