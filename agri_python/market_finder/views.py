from rest_framework import generics, status, permissions, viewsets
from rest_framework.response import Response
from rest_framework.views import APIView
from drf_yasg.utils import swagger_auto_schema
from drf_yasg import openapi
from .models import Market, MarketPrice, MarketSearch
from .serializers import (
    MarketSerializer, 
    MarketPriceSerializer, 
    MarketSearchSerializer,
    MarketSearchRequestSerializer,
    NearestMarketSerializer
)
from .market_utils import MarketFinderEngine

class MarketViewSet(viewsets.ModelViewSet):
    """
    CRUD operations for agricultural markets.
    
    Admin users can create, update, and delete markets.
    All authenticated users can view markets.
    """
    queryset = Market.objects.filter(is_active=True)
    serializer_class = MarketSerializer
    
    def get_permissions(self):
        if self.action in ['create', 'update', 'partial_update', 'destroy']:
            return [permissions.IsAdminUser()]
        return [permissions.IsAuthenticatedOrReadOnly()]

class MarketPriceViewSet(viewsets.ModelViewSet):
    """
    Manage market prices for different crops.
    """
    queryset = MarketPrice.objects.all()
    serializer_class = MarketPriceSerializer
    
    def get_permissions(self):
        if self.action in ['create', 'update', 'partial_update', 'destroy']:
            return [permissions.IsAdminUser()]
        return [permissions.IsAuthenticatedOrReadOnly()]

class NearestMarketFinderView(APIView):
    """
    Find nearest agricultural markets using Haversine formula.
    
    Calculates great-circle distance between farmer's location and all markets,
    then returns the nearest ones sorted by distance.
    """
    permission_classes = [permissions.IsAuthenticated]
    
    @swagger_auto_schema(
        operation_description="""
        Find nearest agricultural markets based on coordinates.
        
        Uses the Haversine formula to calculate accurate distances:
        d = 2r × arcsin(√(sin²(Δlat/2) + cos(lat1) × cos(lat2) × sin²(Δlon/2)))
        
        Returns markets sorted by distance with travel time estimates.
        """,
        request_body=MarketSearchRequestSerializer,
        responses={
            200: openapi.Response(
                description="Markets found successfully",
                examples={
                    "application/json": {
                        "markets": [
                            {
                                "id": 1,
                                "name": "Kalimati Market",
                                "distance_km": 2.15,
                                "estimated_travel_time_minutes": 3
                            }
                        ],
                        "search_id": 1,
                        "message": "Found 5 nearby markets"
                    }
                }
            ),
            404: "No markets found",
            500: "Error finding markets"
        }
    )
    def post(self, request):
        serializer = MarketSearchRequestSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        data = serializer.validated_data
        latitude = data['latitude']
        longitude = data['longitude']
        district = data.get('district')
        crop_to_sell = data.get('crop_to_sell')
        max_results = data.get('max_results', 5)
        
        # Find nearest markets
        try:
            nearest_markets = MarketFinderEngine.find_nearest_markets(
                latitude, 
                longitude, 
                district=district,
                max_results=max_results
            )
            
            if not nearest_markets:
                return Response({
                    'error': 'No markets found',
                    'message': 'Try expanding your search area or check if district name is correct'
                }, status=status.HTTP_404_NOT_FOUND)
            
            # Save search record
            nearest_market = nearest_markets[0]['market']
            market_search = MarketSearch.objects.create(
                user=request.user,
                search_latitude=latitude,
                search_longitude=longitude,
                search_district=district or '',
                crop_to_sell=crop_to_sell or '',
                nearest_market=nearest_market,
                distance_km=nearest_markets[0]['distance_km']
            )
            
            # Prepare response with distance information
            markets_with_distance = []
            for item in nearest_markets:
                market_data = NearestMarketSerializer(item['market']).data
                market_data['distance_km'] = item['distance_km']
                market_data['estimated_travel_time_minutes'] = MarketFinderEngine.calculate_travel_time(
                    item['distance_km']
                )
                markets_with_distance.append(market_data)
            
            return Response({
                'markets': markets_with_distance,
                'search_id': market_search.id,
                'message': f'Found {len(markets_with_distance)} nearby markets'
            }, status=status.HTTP_200_OK)
            
        except Exception as e:
            return Response({
                'error': f'Error finding markets: {str(e)}'
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

class MarketSearchHistoryView(generics.ListAPIView):
    """
    View history of market searches for the authenticated user.
    """
    serializer_class = MarketSearchSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    @swagger_auto_schema(
        operation_description="Get all past market searches for the current user"
    )
    def get(self, request, *args, **kwargs):
        return super().get(request, *args, **kwargs)
    
    def get_queryset(self):
        return MarketSearch.objects.filter(user=self.request.user)

class MarketsByDistrictView(generics.ListAPIView):
    """
    Get all markets in a specific district.
    """
    serializer_class = MarketSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]
    
    @swagger_auto_schema(
        operation_description="Get all markets in a specific district",
        manual_parameters=[
            openapi.Parameter(
                'district',
                openapi.IN_QUERY,
                description="District name to filter markets",
                type=openapi.TYPE_STRING,
                required=True
            )
        ]
    )
    def get(self, request, *args, **kwargs):
        return super().get(request, *args, **kwargs)
    
    def get_queryset(self):
        district = self.request.query_params.get('district', '')
        return Market.objects.filter(
            district__icontains=district,
            is_active=True
        )

class MarketPriceByMarketView(generics.ListAPIView):
    """
    Get price information for a specific market.
    """
    serializer_class = MarketPriceSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]
    
    @swagger_auto_schema(
        operation_description="Get all crop prices for a specific market"
    )
    def get(self, request, *args, **kwargs):
        return super().get(request, *args, **kwargs)
    
    def get_queryset(self):
        market_id = self.kwargs.get('market_id')
        return MarketPrice.objects.filter(market_id=market_id).order_by('-price_date')
