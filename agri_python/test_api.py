"""
Test script for AgriNova Backend API
Run this after starting the development server
"""

import requests
import json

BASE_URL = 'http://127.0.0.1:8000/api'

def test_user_registration():
    """Test user registration"""
    print("\n=== Testing User Registration ===")
    url = f'{BASE_URL}/auth/register/'
    data = {
        'username': 'testfarmer',
        'email': 'testfarmer@example.com',
        'password': 'TestPass123!',
        'password_confirm': 'TestPass123!',
        'first_name': 'Test',
        'last_name': 'Farmer',
        'phone_number': '9841234567',
        'district': 'Kathmandu',
        'address': 'Kathmandu-15'
    }
    
    try:
        response = requests.post(url, json=data)
        print(f"Status Code: {response.status_code}")
        print(f"Response: {json.dumps(response.json(), indent=2)}")
        if response.status_code == 201:
            return response.json().get('token')
    except Exception as e:
        print(f"Error: {str(e)}")
    return None

def test_user_login():
    """Test user login"""
    print("\n=== Testing User Login ===")
    url = f'{BASE_URL}/auth/login/'
    data = {
        'username': 'testfarmer',
        'password': 'TestPass123!'
    }
    
    try:
        response = requests.post(url, json=data)
        print(f"Status Code: {response.status_code}")
        print(f"Response: {json.dumps(response.json(), indent=2)}")
        if response.status_code == 200:
            return response.json().get('token')
    except Exception as e:
        print(f"Error: {str(e)}")
    return None

def test_get_crops(token):
    """Test getting all crops"""
    print("\n=== Testing Get All Crops ===")
    url = f'{BASE_URL}/crops/crops/'
    headers = {'Authorization': f'Token {token}'}
    
    try:
        response = requests.get(url, headers=headers)
        print(f"Status Code: {response.status_code}")
        crops = response.json()
        print(f"Total Crops: {len(crops)}")
        for crop in crops[:3]:  # Show first 3
            print(f"  - {crop['name']}: pH {crop['min_ph']}-{crop['max_ph']}")
    except Exception as e:
        print(f"Error: {str(e)}")

def test_crop_recommendation(token):
    """Test crop recommendation"""
    print("\n=== Testing Crop Recommendation ===")
    url = f'{BASE_URL}/crops/recommend/'
    headers = {'Authorization': f'Token {token}'}
    
    # Test data for Rice (monsoon season)
    data = {
        'ph_level': 6.2,
        'nitrogen': 100,
        'phosphorus': 50,
        'potassium': 50,
        'rainfall': 1800,
        'district': 'Kathmandu',
        'season': 'monsoon',
        'notes': 'Test soil sample'
    }
    
    try:
        response = requests.post(url, json=data, headers=headers)
        print(f"Status Code: {response.status_code}")
        if response.status_code == 200:
            result = response.json()
            print(f"Confidence Score: {result['recommendation']['confidence_score']}")
            print("Recommended Crops:")
            for crop in result['recommendation']['recommended_crops_details']:
                print(f"  {crop['ranking']}. {crop['crop_name']} - Score: {crop['score']}")
    except Exception as e:
        print(f"Error: {str(e)}")

def test_get_markets(token):
    """Test getting all markets"""
    print("\n=== Testing Get All Markets ===")
    url = f'{BASE_URL}/markets/markets/'
    headers = {'Authorization': f'Token {token}'}
    
    try:
        response = requests.get(url, headers=headers)
        print(f"Status Code: {response.status_code}")
        markets = response.json()
        print(f"Total Markets: {len(markets)}")
        for market in markets[:3]:  # Show first 3
            print(f"  - {market['name']} ({market['district']})")
    except Exception as e:
        print(f"Error: {str(e)}")

def test_find_nearest_market(token):
    """Test finding nearest market"""
    print("\n=== Testing Find Nearest Market ===")
    url = f'{BASE_URL}/markets/find-nearest/'
    headers = {'Authorization': f'Token {token}'}
    
    # Coordinates for Kathmandu
    data = {
        'latitude': 27.7172,
        'longitude': 85.3240,
        'district': 'Kathmandu',
        'crop_to_sell': 'Rice',
        'max_results': 3
    }
    
    try:
        response = requests.post(url, json=data, headers=headers)
        print(f"Status Code: {response.status_code}")
        if response.status_code == 200:
            result = response.json()
            print(f"Found {len(result['markets'])} nearby markets:")
            for market in result['markets']:
                print(f"  - {market['name']}")
                print(f"    Distance: {market['distance_km']} km")
                print(f"    Travel Time: {market['estimated_travel_time_minutes']} minutes")
    except Exception as e:
        print(f"Error: {str(e)}")

def run_all_tests():
    """Run all tests"""
    print("="*60)
    print("AgriNova Backend API Test Suite")
    print("="*60)
    print("\nMake sure the development server is running:")
    print("python manage.py runserver")
    print("="*60)
    
    # Test registration and login
    token = test_user_registration()
    
    if not token:
        # If registration fails (user might exist), try login
        token = test_user_login()
    
    if not token:
        print("\n❌ Could not obtain authentication token. Tests cannot continue.")
        return
    
    print(f"\n✅ Authentication successful! Token: {token[:20]}...")
    
    # Run other tests
    test_get_crops(token)
    test_crop_recommendation(token)
    test_get_markets(token)
    test_find_nearest_market(token)
    
    print("\n" + "="*60)
    print("✅ All tests completed!")
    print("="*60)

if __name__ == '__main__':
    run_all_tests()
