from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import CustomUser, UserProfile

@admin.register(CustomUser)
class CustomUserAdmin(UserAdmin):
    list_display = ['username', 'email', 'first_name', 'last_name', 'district', 'phone_number']
    list_filter = ['is_staff', 'is_active', 'district']
    search_fields = ['username', 'email', 'first_name', 'last_name', 'district']
    
    fieldsets = UserAdmin.fieldsets + (
        ('Additional Info', {'fields': ('phone_number', 'district', 'address')}),
    )
    
    add_fieldsets = UserAdmin.add_fieldsets + (
        ('Additional Info', {'fields': ('phone_number', 'district', 'address')}),
    )

@admin.register(UserProfile)
class UserProfileAdmin(admin.ModelAdmin):
    list_display = ['user', 'farm_size', 'farming_experience', 'latitude', 'longitude']
    list_filter = ['farming_experience']
    search_fields = ['user__username', 'user__email']

