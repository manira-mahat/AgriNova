from rest_framework import generics, status, permissions
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.authtoken.models import Token
from django.contrib.auth import authenticate, get_user_model
from drf_yasg.utils import swagger_auto_schema
from drf_yasg import openapi
from .serializers import (
    UserSerializer, 
    UserRegistrationSerializer, 
    UserLoginSerializer,
    UserProfileSerializer
)
from .models import UserProfile

User = get_user_model()

class UserRegistrationView(generics.CreateAPIView):
    """
    Register a new user account.
    
    Creates a new user with the provided credentials and returns an authentication token.
    """
    queryset = User.objects.all()
    serializer_class = UserRegistrationSerializer
    permission_classes = [permissions.AllowAny]
    
    @swagger_auto_schema(
        operation_description="Register a new user and receive authentication token",
        responses={
            201: openapi.Response(
                description="User registered successfully",
                examples={
                    "application/json": {
                        "user": {
                            "id": 1,
                            "username": "farmer1",
                            "email": "farmer1@example.com"
                        },
                        "token": "9944b09199c62bcf9418ad846dd0e4bbdfc6ee4b",
                        "message": "User registered successfully"
                    }
                }
            ),
            400: "Invalid input data"
        }
    )
    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
        
        # Create token for the user
        token, created = Token.objects.get_or_create(user=user)
        
        return Response({
            'user': UserSerializer(user).data,
            'token': token.key,
            'message': 'User registered successfully'
        }, status=status.HTTP_201_CREATED)

class UserLoginView(APIView):
    """
    Login with username and password to receive authentication token.
    """
    permission_classes = [permissions.AllowAny]
    
    @swagger_auto_schema(
        operation_description="Login with username and password",
        request_body=UserLoginSerializer,
        responses={
            200: openapi.Response(
                description="Login successful",
                examples={
                    "application/json": {
                        "token": "9944b09199c62bcf9418ad846dd0e4bbdfc6ee4b",
                        "message": "Login successful"
                    }
                }
            ),
            401: "Invalid credentials"
        }
    )
    def post(self, request):
        serializer = UserLoginSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        username = serializer.validated_data['username']
        password = serializer.validated_data['password']
        
        user = authenticate(username=username, password=password)
        
        if user is not None:
            token, created = Token.objects.get_or_create(user=user)
            return Response({
                'user': UserSerializer(user).data,
                'token': token.key,
                'message': 'Login successful'
            }, status=status.HTTP_200_OK)
        else:
            return Response({
                'error': 'Invalid credentials'
            }, status=status.HTTP_401_UNAUTHORIZED)

class UserLogoutView(APIView):
    """
    Logout by deleting the authentication token.
    """
    permission_classes = [permissions.IsAuthenticated]
    
    @swagger_auto_schema(
        operation_description="Logout and invalidate authentication token",
        responses={
            200: "Logout successful"
        }
    )
    def post(self, request):
        # Delete the user's token
        request.user.auth_token.delete()
        return Response({
            'message': 'Logout successful'
        }, status=status.HTTP_200_OK)

class UserProfileView(generics.RetrieveUpdateAPIView):
    """
    Retrieve or update the authenticated user's profile.
    """
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    @swagger_auto_schema(
        operation_description="Get authenticated user's profile"
    )
    def get(self, request, *args, **kwargs):
        return super().get(request, *args, **kwargs)
    
    @swagger_auto_schema(
        operation_description="Update authenticated user's profile"
    )
    def put(self, request, *args, **kwargs):
        return super().put(request, *args, **kwargs)
    
    @swagger_auto_schema(
        operation_description="Partially update authenticated user's profile"
    )
    def patch(self, request, *args, **kwargs):
        return super().patch(request, *args, **kwargs)
    
    def get_object(self):
        return self.request.user

class UserProfileDetailView(generics.RetrieveUpdateAPIView):
    """
    Retrieve or update extended user profile information.
    """
    serializer_class = UserProfileSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_object(self):
        profile, created = UserProfile.objects.get_or_create(user=self.request.user)
        return profile
