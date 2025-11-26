"""
Market Finder Utilities
Includes Haversine formula for calculating distances
"""

import math
from .models import Market

class MarketFinderEngine:
    """
    Engine to find nearest markets using Haversine formula
    """
    
    @staticmethod
    def haversine_distance(lat1, lon1, lat2, lon2):
        """
        Calculate the great circle distance between two points 
        on the earth (specified in decimal degrees)
        
        Formula:
        d = 2r × arcsin(√(sin²(Δlat/2) + cos(lat1) × cos(lat2) × sin²(Δlon/2)))
        
        where:
        - r = Earth's radius (≈ 6371 km)
        - Δlat = lat2 - lat1
        - Δlon = lon2 - lon1
        
        Returns distance in kilometers
        """
        # Earth's radius in kilometers
        R = 6371.0
        
        # Convert coordinates from degrees to radians
        lat1_rad = math.radians(lat1)
        lon1_rad = math.radians(lon1)
        lat2_rad = math.radians(lat2)
        lon2_rad = math.radians(lon2)
        
        # Calculate differences
        dlat = lat2_rad - lat1_rad
        dlon = lon2_rad - lon1_rad
        
        # Haversine formula
        a = (math.sin(dlat / 2) ** 2 + 
             math.cos(lat1_rad) * math.cos(lat2_rad) * 
             math.sin(dlon / 2) ** 2)
        
        c = 2 * math.asin(math.sqrt(a))
        
        # Calculate distance
        distance = R * c
        
        return round(distance, 2)
    
    @staticmethod
    def find_nearest_markets(latitude, longitude, district=None, max_results=5):
        """
        Find nearest markets to given coordinates
        
        Args:
            latitude: User's latitude
            longitude: User's longitude
            district: Optional district filter
            max_results: Maximum number of results to return
            
        Returns:
            List of markets with distances, sorted by proximity
        """
        # Get active markets
        markets_query = Market.objects.filter(is_active=True)
        
        # Filter by district if provided
        if district:
            markets_query = markets_query.filter(district__icontains=district)
        
        markets = markets_query.all()
        
        # Calculate distances for all markets
        market_distances = []
        for market in markets:
            distance = MarketFinderEngine.haversine_distance(
                latitude, longitude,
                market.latitude, market.longitude
            )
            
            market_distances.append({
                'market': market,
                'distance_km': distance
            })
        
        # Sort by distance
        market_distances.sort(key=lambda x: x['distance_km'])
        
        # Return top N results
        return market_distances[:max_results]
    
    @staticmethod
    def find_markets_by_district(district, max_results=10):
        """
        Find markets in a specific district
        """
        markets = Market.objects.filter(
            district__icontains=district,
            is_active=True
        )[:max_results]
        
        return [{'market': m, 'distance_km': None} for m in markets]
    
    @staticmethod
    def calculate_travel_time(distance_km, avg_speed_kmh=40):
        """
        Estimate travel time based on distance
        Assumes average speed of 40 km/h for rural roads
        
        Returns time in minutes
        """
        if distance_km == 0:
            return 0
        
        hours = distance_km / avg_speed_kmh
        minutes = hours * 60
        
        return round(minutes, 0)
    
    @staticmethod
    def get_market_details_with_distance(market, user_lat, user_lon):
        """
        Get market details with calculated distance from user location
        """
        distance = MarketFinderEngine.haversine_distance(
            user_lat, user_lon,
            market.latitude, market.longitude
        )
        
        travel_time = MarketFinderEngine.calculate_travel_time(distance)
        
        return {
            'market': market,
            'distance_km': distance,
            'estimated_travel_time_minutes': travel_time
        }


# Example Nepal coordinates for reference
NEPAL_DISTRICTS_COORDS = {
    'Kathmandu': {'lat': 27.7172, 'lon': 85.3240},
    'Pokhara': {'lat': 28.2096, 'lon': 83.9856},
    'Lalitpur': {'lat': 27.6669, 'lon': 85.3240},
    'Bhaktapur': {'lat': 27.6710, 'lon': 85.4298},
    'Chitwan': {'lat': 27.5291, 'lon': 84.3542},
    'Dhading': {'lat': 27.8667, 'lon': 84.9000},
    'Kaski': {'lat': 28.2380, 'lon': 83.9956},
    'Morang': {'lat': 26.4839, 'lon': 87.2718},
    'Jhapa': {'lat': 26.6544, 'lon': 87.8439},
    'Sunsari': {'lat': 26.6260, 'lon': 87.1718},
}
