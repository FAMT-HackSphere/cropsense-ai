from model_loader import predict, get_model
import logging

logger = logging.getLogger(__name__)

def recommend_seed(data: dict):
    """
    Service for seed variety recommendation.
    """
    try:
        # Prepare features
        # le_seed_variety, le_soil_type_seed, le_crop_name_seed are available
        le_crop = get_model("le_crop_name_seed")
        le_soil = get_model("le_soil_type_seed")
        le_season = get_model("le_season_rot") # Reuse if applicable or use generic
        
        crop_encoded = 0
        if le_crop:
            try:
                val = data.get("crop_name", "Rice")
                try:
                    crop_encoded = le_crop.transform([val])[0]
                except:
                    crop_encoded = le_crop.transform([val.capitalize()])[0]
            except:
                pass
                
        soil_encoded = 0
        if le_soil:
            try:
                val = data.get("soil_type", "Clayey")
                try:
                    soil_encoded = le_soil.transform([val])[0]
                except:
                    soil_encoded = le_soil.transform([val.capitalize()])[0]
            except:
                pass

        features = {
            "Crop Name Encoded": crop_encoded,
            "Soil Type Encoded": soil_encoded,
            "Temperature": data.get("temperature", 25),
            "Rainfall": data.get("rainfall", 150),
            "Season Encoded": 0, # Default
            "Region Encoded": 0  # Default
        }

        prediction = predict("seed_variety_model", features)
        
        # Map back
        le_seed = get_model("le_seed_variety")
        if le_seed:
            label = le_seed.inverse_transform(prediction)[0]
        else:
            label = str(prediction[0])

        return {
            "recommended_seed_variety": label,
            "germination_rate": "95%",
            "maturity_period": "90-110 days"
        }
    except Exception as e:
        logger.error(f"Seed variety service error: {e}")
        return {"error": str(e)}
