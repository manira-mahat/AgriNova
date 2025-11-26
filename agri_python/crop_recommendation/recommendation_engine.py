"""
Decision Tree Algorithm for Crop Recommendation
Based on soil pH, NPK values, rainfall, and season
"""

from sklearn.tree import DecisionTreeClassifier
from sklearn.preprocessing import LabelEncoder
import numpy as np
import pandas as pd
from .models import Crop

class CropRecommendationEngine:
    """
    Crop Recommendation Engine using Decision Tree Algorithm
    """
    
    def __init__(self):
        self.model = None
        self.label_encoder = LabelEncoder()
        self.season_encoder = LabelEncoder()
        self.is_trained = False
    
    def prepare_training_data(self):
        """
        Prepare training data from crop database
        Creates synthetic training samples based on crop requirements
        """
        crops = Crop.objects.all()
        
        if not crops.exists():
            return None, None
        
        training_data = []
        labels = []
        
        for crop in crops:
            # Get suitable seasons
            seasons = [s.strip() for s in crop.suitable_seasons.split(',')]
            
            # Generate samples for each season
            for season in seasons:
                # Generate multiple samples with variations within optimal ranges
                num_samples = 5
                
                for _ in range(num_samples):
                    # Generate values within optimal ranges
                    ph = np.random.uniform(crop.min_ph, crop.max_ph)
                    n = np.random.uniform(crop.min_nitrogen, crop.max_nitrogen)
                    p = np.random.uniform(crop.min_phosphorus, crop.max_phosphorus)
                    k = np.random.uniform(crop.min_potassium, crop.max_potassium)
                    rainfall = np.random.uniform(crop.min_rainfall, crop.max_rainfall)
                    
                    # Encode season
                    season_encoded = self._encode_season(season)
                    
                    training_data.append([ph, n, p, k, rainfall, season_encoded])
                    labels.append(crop.name)
        
        if not training_data:
            return None, None
        
        X = np.array(training_data)
        y = self.label_encoder.fit_transform(labels)
        
        return X, y
    
    def _encode_season(self, season):
        """
        Encode season as numeric value
        """
        season_map = {
            'spring': 0,
            'summer': 1,
            'monsoon': 2,
            'autumn': 3,
            'winter': 4
        }
        return season_map.get(season.lower(), 0)
    
    def train_model(self):
        """
        Train the Decision Tree model
        """
        X, y = self.prepare_training_data()
        
        if X is None or y is None:
            return False
        
        # Create and train Decision Tree classifier
        self.model = DecisionTreeClassifier(
            criterion='entropy',  # Use information gain
            max_depth=10,
            min_samples_split=5,
            random_state=42
        )
        
        self.model.fit(X, y)
        self.is_trained = True
        
        return True
    
    def calculate_suitability_scores(self, input_data):
        """
        Calculate suitability scores for all crops based on input parameters
        Returns list of (crop_name, score, ranking)
        """
        crops = Crop.objects.all()
        scores = []
        
        ph, n, p, k, rainfall, season = input_data
        
        for crop in crops:
            # Check if season is suitable
            seasons = [s.strip().lower() for s in crop.suitable_seasons.split(',')]
            season_names = ['spring', 'summer', 'monsoon', 'autumn', 'winter']
            input_season = season_names[int(season)] if 0 <= season < len(season_names) else 'unknown'
            
            if input_season not in seasons:
                continue
            
            # Calculate individual parameter scores (0-1 scale)
            ph_score = self._calculate_parameter_score(ph, crop.min_ph, crop.max_ph)
            n_score = self._calculate_parameter_score(n, crop.min_nitrogen, crop.max_nitrogen)
            p_score = self._calculate_parameter_score(p, crop.min_phosphorus, crop.max_phosphorus)
            k_score = self._calculate_parameter_score(k, crop.min_potassium, crop.max_potassium)
            rain_score = self._calculate_parameter_score(rainfall, crop.min_rainfall, crop.max_rainfall)
            
            # Overall score (weighted average)
            overall_score = (ph_score * 0.2 + 
                           n_score * 0.2 + 
                           p_score * 0.2 + 
                           k_score * 0.2 + 
                           rain_score * 0.2)
            
            scores.append({
                'crop': crop,
                'score': round(overall_score, 3)
            })
        
        # Sort by score descending
        scores.sort(key=lambda x: x['score'], reverse=True)
        
        # Add ranking
        for idx, item in enumerate(scores, 1):
            item['ranking'] = idx
        
        return scores
    
    def _calculate_parameter_score(self, value, min_val, max_val):
        """
        Calculate score for a single parameter
        1.0 if within optimal range
        Decreases as value moves away from optimal range
        """
        if min_val <= value <= max_val:
            return 1.0
        
        # Calculate distance from optimal range
        if value < min_val:
            distance = min_val - value
            penalty_factor = min_val * 0.5  # 50% deviation threshold
        else:
            distance = value - max_val
            penalty_factor = max_val * 0.5
        
        if penalty_factor == 0:
            return 0.0
        
        # Score decreases with distance
        score = max(0.0, 1.0 - (distance / penalty_factor))
        return score
    
    def predict(self, ph_level, nitrogen, phosphorus, potassium, rainfall, season):
        """
        Predict suitable crops for given soil parameters
        Returns list of recommended crops with scores
        """
        # Encode season
        season_encoded = self._encode_season(season)
        
        # Prepare input
        input_features = np.array([[ph_level, nitrogen, phosphorus, potassium, 
                                   rainfall, season_encoded]])
        
        # Calculate detailed suitability scores
        scores = self.calculate_suitability_scores(
            [ph_level, nitrogen, phosphorus, potassium, rainfall, season_encoded]
        )
        
        # Filter out crops with very low scores (< 0.3)
        recommended = [s for s in scores if s['score'] >= 0.3]
        
        if not recommended:
            # If no good matches, return top 3 anyway
            recommended = scores[:3] if len(scores) >= 3 else scores
        
        # Return top 5 recommendations
        return recommended[:5]
    
    def get_confidence_score(self, recommendations):
        """
        Calculate overall confidence score based on recommendations
        """
        if not recommendations:
            return 0.0
        
        # Confidence based on top recommendation score
        top_score = recommendations[0]['score']
        return round(top_score, 3)


# Global instance
crop_recommendation_engine = CropRecommendationEngine()
