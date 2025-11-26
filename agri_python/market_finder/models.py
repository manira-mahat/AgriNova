from django.db import models
from authentication.models import CustomUser
import math

class Market(models.Model):
    """
    Model to store agricultural market information
    """
    name = models.CharField(max_length=200)
    district = models.CharField(max_length=100)
    address = models.TextField()
    
    # Location coordinates
    latitude = models.FloatField(help_text="Market latitude")
    longitude = models.FloatField(help_text="Market longitude")
    
    # Market details
    MARKET_TYPES = [
        ('wholesale', 'Wholesale Market'),
        ('retail', 'Retail Market'),
        ('collection', 'Collection Center'),
        ('cooperative', 'Cooperative Market'),
    ]
    market_type = models.CharField(max_length=20, choices=MARKET_TYPES)
    
    # Contact information
    contact_person = models.CharField(max_length=100, blank=True)
    phone_number = models.CharField(max_length=15, blank=True)
    email = models.EmailField(blank=True)
    
    # Operating schedule
    opening_time = models.TimeField(null=True, blank=True)
    closing_time = models.TimeField(null=True, blank=True)
    operating_days = models.CharField(max_length=100, help_text="e.g., Monday-Friday", blank=True)
    
    # Market features
    has_cold_storage = models.BooleanField(default=False)
    has_grading_facility = models.BooleanField(default=False)
    has_packaging_facility = models.BooleanField(default=False)
    transportation_available = models.BooleanField(default=False)
    
    # Metadata
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return f"{self.name} - {self.district}"
    
    def calculate_distance(self, lat, lon):
        """
        Calculate distance using Haversine formula
        """
        # Earth's radius in kilometers
        R = 6371.0
        
        # Convert coordinates to radians
        lat1_rad = math.radians(self.latitude)
        lon1_rad = math.radians(self.longitude)
        lat2_rad = math.radians(lat)
        lon2_rad = math.radians(lon)
        
        # Calculate differences
        dlat = lat2_rad - lat1_rad
        dlon = lon2_rad - lon1_rad
        
        # Haversine formula
        a = math.sin(dlat/2)**2 + math.cos(lat1_rad) * math.cos(lat2_rad) * math.sin(dlon/2)**2
        c = 2 * math.asin(math.sqrt(a))
        distance = R * c
        
        return round(distance, 2)
    
    class Meta:
        ordering = ['district', 'name']

class MarketPrice(models.Model):
    """
    Model to store market prices for different crops
    """
    market = models.ForeignKey(Market, on_delete=models.CASCADE, related_name='prices')
    crop_name = models.CharField(max_length=100)
    
    # Price information
    price_per_kg = models.FloatField(help_text="Price per kg in NPR")
    unit = models.CharField(max_length=20, default='kg')
    
    # Price metadata
    price_date = models.DateField()
    source = models.CharField(max_length=100, blank=True, help_text="Source of price information")
    
    # Quality grade
    QUALITY_GRADES = [
        ('premium', 'Premium'),
        ('standard', 'Standard'),
        ('below_standard', 'Below Standard'),
    ]
    quality_grade = models.CharField(max_length=20, choices=QUALITY_GRADES, default='standard')
    
    created_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return f"{self.crop_name} - {self.market.name} - NPR {self.price_per_kg}/{self.unit}"
    
    class Meta:
        ordering = ['-price_date', 'crop_name']
        unique_together = ['market', 'crop_name', 'price_date', 'quality_grade']

class MarketSearch(models.Model):
    """
    Model to store user's market search history
    """
    user = models.ForeignKey(CustomUser, on_delete=models.CASCADE, related_name='market_searches')
    
    # Search parameters
    search_latitude = models.FloatField()
    search_longitude = models.FloatField()
    search_district = models.CharField(max_length=100, blank=True)
    crop_to_sell = models.CharField(max_length=100, blank=True)
    
    # Search results
    nearest_market = models.ForeignKey(Market, on_delete=models.SET_NULL, null=True, blank=True)
    distance_km = models.FloatField(null=True, blank=True)
    
    # Metadata
    search_date = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return f"{self.user.username} - {self.search_district} - {self.search_date.date()}"
    
    class Meta:
        ordering = ['-search_date']
