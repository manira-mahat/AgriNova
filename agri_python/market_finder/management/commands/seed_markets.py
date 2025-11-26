from django.core.management.base import BaseCommand
from market_finder.models import Market
from datetime import time

class Command(BaseCommand):
    help = 'Seeds the database with sample market data for Nepal'

    def handle(self, *args, **kwargs):
        self.stdout.write('Seeding market data...')
        
        markets_data = [
            {
                'name': 'Kalimati Fruit and Vegetable Market',
                'district': 'Kathmandu',
                'address': 'Kalimati, Kathmandu',
                'latitude': 27.6990,
                'longitude': 85.2880,
                'market_type': 'wholesale',
                'contact_person': 'Market Manager',
                'phone_number': '01-4272345',
                'opening_time': time(4, 0),
                'closing_time': time(20, 0),
                'operating_days': 'Every day',
                'has_cold_storage': True,
                'has_grading_facility': True,
                'has_packaging_facility': True,
                'transportation_available': True,
                'is_active': True
            },
            {
                'name': 'Balkhu Fruit Market',
                'district': 'Kathmandu',
                'address': 'Balkhu, Kathmandu',
                'latitude': 27.6820,
                'longitude': 85.2950,
                'market_type': 'wholesale',
                'phone_number': '01-4231234',
                'opening_time': time(5, 0),
                'closing_time': time(18, 0),
                'operating_days': 'Every day',
                'has_cold_storage': False,
                'has_grading_facility': True,
                'has_packaging_facility': False,
                'transportation_available': True,
                'is_active': True
            },
            {
                'name': 'Pokhara Agricultural Market',
                'district': 'Kaski',
                'address': 'Chipledhunga, Pokhara',
                'latitude': 28.2096,
                'longitude': 83.9856,
                'market_type': 'wholesale',
                'phone_number': '061-521234',
                'opening_time': time(6, 0),
                'closing_time': time(18, 0),
                'operating_days': 'Every day',
                'has_cold_storage': True,
                'has_grading_facility': True,
                'has_packaging_facility': True,
                'transportation_available': True,
                'is_active': True
            },
            {
                'name': 'Bhaktapur Haat Bazaar',
                'district': 'Bhaktapur',
                'address': 'Bhaktapur Durbar Square Area',
                'latitude': 27.6710,
                'longitude': 85.4298,
                'market_type': 'retail',
                'phone_number': '01-6610234',
                'opening_time': time(7, 0),
                'closing_time': time(19, 0),
                'operating_days': 'Monday-Saturday',
                'has_cold_storage': False,
                'has_grading_facility': False,
                'has_packaging_facility': False,
                'transportation_available': False,
                'is_active': True
            },
            {
                'name': 'Lalitpur Vegetable Collection Center',
                'district': 'Lalitpur',
                'address': 'Jawalakhel, Lalitpur',
                'latitude': 27.6669,
                'longitude': 85.3140,
                'market_type': 'collection',
                'phone_number': '01-5521234',
                'opening_time': time(5, 0),
                'closing_time': time(17, 0),
                'operating_days': 'Every day',
                'has_cold_storage': True,
                'has_grading_facility': True,
                'has_packaging_facility': True,
                'transportation_available': True,
                'is_active': True
            },
            {
                'name': 'Chitwan Agricultural Cooperative Market',
                'district': 'Chitwan',
                'address': 'Bharatpur-10, Chitwan',
                'latitude': 27.6801,
                'longitude': 84.4336,
                'market_type': 'cooperative',
                'phone_number': '056-522123',
                'opening_time': time(6, 0),
                'closing_time': time(18, 0),
                'operating_days': 'Every day',
                'has_cold_storage': True,
                'has_grading_facility': True,
                'has_packaging_facility': True,
                'transportation_available': True,
                'is_active': True
            },
            {
                'name': 'Dhading Wholesale Market',
                'district': 'Dhading',
                'address': 'Dhading Besi',
                'latitude': 27.8667,
                'longitude': 84.9000,
                'market_type': 'wholesale',
                'phone_number': '010-560123',
                'opening_time': time(6, 0),
                'closing_time': time(17, 0),
                'operating_days': 'Every day',
                'has_cold_storage': False,
                'has_grading_facility': True,
                'has_packaging_facility': False,
                'transportation_available': True,
                'is_active': True
            },
            {
                'name': 'Biratnagar Agricultural Market',
                'district': 'Morang',
                'address': 'Biratnagar-6, Morang',
                'latitude': 26.4839,
                'longitude': 87.2718,
                'market_type': 'wholesale',
                'phone_number': '021-525123',
                'opening_time': time(5, 0),
                'closing_time': time(18, 0),
                'operating_days': 'Every day',
                'has_cold_storage': True,
                'has_grading_facility': True,
                'has_packaging_facility': True,
                'transportation_available': True,
                'is_active': True
            },
            {
                'name': 'Jhapa Vegetable Market',
                'district': 'Jhapa',
                'address': 'Damak, Jhapa',
                'latitude': 26.6544,
                'longitude': 87.7039,
                'market_type': 'wholesale',
                'phone_number': '023-580123',
                'opening_time': time(6, 0),
                'closing_time': time(18, 0),
                'operating_days': 'Every day',
                'has_cold_storage': False,
                'has_grading_facility': True,
                'has_packaging_facility': False,
                'transportation_available': True,
                'is_active': True
            },
            {
                'name': 'Inaruwa Collection Center',
                'district': 'Sunsari',
                'address': 'Inaruwa, Sunsari',
                'latitude': 26.6260,
                'longitude': 87.1718,
                'market_type': 'collection',
                'phone_number': '025-560234',
                'opening_time': time(6, 0),
                'closing_time': time(17, 0),
                'operating_days': 'Every day',
                'has_cold_storage': True,
                'has_grading_facility': True,
                'has_packaging_facility': True,
                'transportation_available': True,
                'is_active': True
            },
        ]
        
        created_count = 0
        updated_count = 0
        
        for market_data in markets_data:
            market, created = Market.objects.update_or_create(
                name=market_data['name'],
                defaults=market_data
            )
            
            if created:
                created_count += 1
                self.stdout.write(self.style.SUCCESS(f'Created: {market.name}'))
            else:
                updated_count += 1
                self.stdout.write(self.style.WARNING(f'Updated: {market.name}'))
        
        self.stdout.write(self.style.SUCCESS(
            f'\nSeeding complete! Created: {created_count}, Updated: {updated_count}'
        ))
