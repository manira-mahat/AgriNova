from django.urls import path
from .views import (
    UserRegistrationView,
    UserLoginView,
    UserLogoutView,
    UserProfileView,
    UserProfileDetailView
)

app_name = 'authentication'

urlpatterns = [
    path('register/', UserRegistrationView.as_view(), name='register'),
    path('login/', UserLoginView.as_view(), name='login'),
    path('logout/', UserLogoutView.as_view(), name='logout'),
    path('profile/', UserProfileView.as_view(), name='profile'),
    path('profile/detail/', UserProfileDetailView.as_view(), name='profile-detail'),
]
