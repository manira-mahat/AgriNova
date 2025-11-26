from django.core.management.base import BaseCommand
from crop_recommendation.models import Crop

class Command(BaseCommand):
    help = 'Seeds the database with sample crop data for Nepal'

    def handle(self, *args, **kwargs):
        self.stdout.write('Seeding crop data...')
        
        crops_data = [
            {
                'name': 'Rice',
                'scientific_name': 'Oryza sativa',
                'description': 'Staple cereal crop requiring flooded fields',
                'min_ph': 5.5, 'max_ph': 7.0,
                'min_nitrogen': 80, 'max_nitrogen': 120,
                'min_phosphorus': 40, 'max_phosphorus': 60,
                'min_potassium': 40, 'max_potassium': 60,
                'min_rainfall': 1200, 'max_rainfall': 2500,
                'suitable_seasons': 'monsoon, summer',
                'growth_duration': 120,
                'yield_per_hectare': 4000,
                'market_price': 35
            },
            {
                'name': 'Wheat',
                'scientific_name': 'Triticum aestivum',
                'description': 'Winter cereal crop, requires cool climate',
                'min_ph': 6.0, 'max_ph': 7.5,
                'min_nitrogen': 80, 'max_nitrogen': 100,
                'min_phosphorus': 30, 'max_phosphorus': 50,
                'min_potassium': 30, 'max_potassium': 50,
                'min_rainfall': 450, 'max_rainfall': 650,
                'suitable_seasons': 'winter, autumn',
                'growth_duration': 120,
                'yield_per_hectare': 3500,
                'market_price': 30
            },
            {
                'name': 'Maize',
                'scientific_name': 'Zea mays',
                'description': 'Versatile cereal crop, adaptable to various conditions',
                'min_ph': 5.5, 'max_ph': 7.5,
                'min_nitrogen': 60, 'max_nitrogen': 80,
                'min_phosphorus': 25, 'max_phosphorus': 35,
                'min_potassium': 25, 'max_potassium': 35,
                'min_rainfall': 500, 'max_rainfall': 800,
                'suitable_seasons': 'summer, spring',
                'growth_duration': 90,
                'yield_per_hectare': 5000,
                'market_price': 28
            },
            {
                'name': 'Potato',
                'scientific_name': 'Solanum tuberosum',
                'description': 'Tuberous crop, requires cool climate',
                'min_ph': 5.0, 'max_ph': 6.5,
                'min_nitrogen': 100, 'max_nitrogen': 150,
                'min_phosphorus': 50, 'max_phosphorus': 80,
                'min_potassium': 120, 'max_potassium': 150,
                'min_rainfall': 500, 'max_rainfall': 700,
                'suitable_seasons': 'winter, autumn',
                'growth_duration': 90,
                'yield_per_hectare': 20000,
                'market_price': 40
            },
            {
                'name': 'Tomato',
                'scientific_name': 'Solanum lycopersicum',
                'description': 'Popular vegetable crop, requires moderate climate',
                'min_ph': 6.0, 'max_ph': 7.0,
                'min_nitrogen': 100, 'max_nitrogen': 150,
                'min_phosphorus': 50, 'max_phosphorus': 80,
                'min_potassium': 150, 'max_potassium': 200,
                'min_rainfall': 400, 'max_rainfall': 600,
                'suitable_seasons': 'spring, summer, autumn',
                'growth_duration': 75,
                'yield_per_hectare': 40000,
                'market_price': 60
            },
            {
                'name': 'Cauliflower',
                'scientific_name': 'Brassica oleracea',
                'description': 'Cool season vegetable',
                'min_ph': 6.0, 'max_ph': 7.0,
                'min_nitrogen': 120, 'max_nitrogen': 180,
                'min_phosphorus': 60, 'max_phosphorus': 90,
                'min_potassium': 100, 'max_potassium': 140,
                'min_rainfall': 600, 'max_rainfall': 750,
                'suitable_seasons': 'winter, autumn',
                'growth_duration': 70,
                'yield_per_hectare': 18000,
                'market_price': 45
            },
            {
                'name': 'Cabbage',
                'scientific_name': 'Brassica oleracea var. capitata',
                'description': 'Cool season leafy vegetable',
                'min_ph': 6.0, 'max_ph': 7.5,
                'min_nitrogen': 100, 'max_nitrogen': 140,
                'min_phosphorus': 50, 'max_phosphorus': 75,
                'min_potassium': 80, 'max_potassium': 120,
                'min_rainfall': 600, 'max_rainfall': 800,
                'suitable_seasons': 'winter, autumn',
                'growth_duration': 80,
                'yield_per_hectare': 25000,
                'market_price': 35
            },
            {
                'name': 'Lentil',
                'scientific_name': 'Lens culinaris',
                'description': 'Pulse crop, nitrogen fixer',
                'min_ph': 6.0, 'max_ph': 8.0,
                'min_nitrogen': 20, 'max_nitrogen': 40,
                'min_phosphorus': 40, 'max_phosphorus': 60,
                'min_potassium': 30, 'max_potassium': 50,
                'min_rainfall': 350, 'max_rainfall': 500,
                'suitable_seasons': 'winter',
                'growth_duration': 110,
                'yield_per_hectare': 1500,
                'market_price': 120
            },
            {
                'name': 'Mustard',
                'scientific_name': 'Brassica juncea',
                'description': 'Oilseed and vegetable crop',
                'min_ph': 6.0, 'max_ph': 7.5,
                'min_nitrogen': 60, 'max_nitrogen': 80,
                'min_phosphorus': 30, 'max_phosphorus': 40,
                'min_potassium': 20, 'max_potassium': 30,
                'min_rainfall': 400, 'max_rainfall': 600,
                'suitable_seasons': 'winter, autumn',
                'growth_duration': 90,
                'yield_per_hectare': 1200,
                'market_price': 100
            },
            {
                'name': 'Cucumber',
                'scientific_name': 'Cucumis sativus',
                'description': 'Warm season vegetable',
                'min_ph': 6.0, 'max_ph': 7.0,
                'min_nitrogen': 80, 'max_nitrogen': 120,
                'min_phosphorus': 40, 'max_phosphorus': 60,
                'min_potassium': 60, 'max_potassium': 80,
                'min_rainfall': 500, 'max_rainfall': 700,
                'suitable_seasons': 'summer, spring',
                'growth_duration': 50,
                'yield_per_hectare': 35000,
                'market_price': 50
            },
            {
                'name': 'Onion',
                'scientific_name': 'Allium cepa',
                'description': 'Bulb vegetable, requires well-drained soil',
                'min_ph': 6.0, 'max_ph': 7.5,
                'min_nitrogen': 100, 'max_nitrogen': 150,
                'min_phosphorus': 50, 'max_phosphorus': 75,
                'min_potassium': 80, 'max_potassium': 100,
                'min_rainfall': 400, 'max_rainfall': 550,
                'suitable_seasons': 'winter, spring',
                'growth_duration': 100,
                'yield_per_hectare': 30000,
                'market_price': 55
            },
            {
                'name': 'Chili',
                'scientific_name': 'Capsicum annuum',
                'description': 'Hot pepper, requires warm climate',
                'min_ph': 6.0, 'max_ph': 7.0,
                'min_nitrogen': 80, 'max_nitrogen': 120,
                'min_phosphorus': 50, 'max_phosphorus': 70,
                'min_potassium': 60, 'max_potassium': 80,
                'min_rainfall': 600, 'max_rainfall': 1250,
                'suitable_seasons': 'summer, monsoon',
                'growth_duration': 120,
                'yield_per_hectare': 10000,
                'market_price': 80
            },
        ]
        
        created_count = 0
        updated_count = 0
        
        for crop_data in crops_data:
            crop, created = Crop.objects.update_or_create(
                name=crop_data['name'],
                defaults=crop_data
            )
            
            if created:
                created_count += 1
                self.stdout.write(self.style.SUCCESS(f'Created: {crop.name}'))
            else:
                updated_count += 1
                self.stdout.write(self.style.WARNING(f'Updated: {crop.name}'))
        
        self.stdout.write(self.style.SUCCESS(
            f'\nSeeding complete! Created: {created_count}, Updated: {updated_count}'
        ))
