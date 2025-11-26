from django.contrib.auth.models import AbstractUser
from django.db import models

class CustomUser(AbstractUser):
    """
    Custom User model extending Django's AbstractUser
    """
    phone_number = models.CharField(max_length=15, blank=True, null=True)
    district = models.CharField(max_length=100, blank=True, null=True)
    address = models.TextField(blank=True, null=True)
    date_created = models.DateTimeField(auto_now_add=True)
    date_updated = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return f"{self.username} - {self.district}"

class UserProfile(models.Model):
    """
    Extended profile information for farmers
    """
    user = models.OneToOneField(CustomUser, on_delete=models.CASCADE, related_name='profile')
    farm_size = models.FloatField(help_text="Farm size in hectares", null=True, blank=True)
    farming_experience = models.IntegerField(help_text="Years of farming experience", null=True, blank=True)
    preferred_crops = models.TextField(help_text="Comma-separated list of preferred crops", blank=True)
    latitude = models.FloatField(null=True, blank=True)
    longitude = models.FloatField(null=True, blank=True)
    
    def __str__(self):
        return f"{self.user.username}'s Profile"
