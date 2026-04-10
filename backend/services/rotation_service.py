from model_loader import predict, get_model
import logging

logger = logging.getLogger(__name__)

def recommend_rotation(data: dict):
    """
    Service for crop rotation recommendation.
    """
    try:
        # Prepare features
        # le_prev_crop, le_season_rot, scaler_rot are available
        le_crop = get_model("le_prev_crop")
        le_season = get_model("le_season_rot")
        
        prev_crop_encoded = 0
        if le_crop:
            try:
                # Try original, then capitalized, then default 0
                val = data.get("current_crop", "Rice")
                try:
                    prev_crop_encoded = le_crop.transform([val])[0]
                except:
                    prev_crop_encoded = le_crop.transform([val.capitalize()])[0]
            except:
                prev_crop_encoded = 0
                
        season_encoded = 0
        if le_season:
            try:
                val = data.get("season", "Kharif")
                try:
                    season_encoded = le_season.transform([val])[0]
                except:
                    season_encoded = le_season.transform([val.capitalize()])[0]
            except:
                season_encoded = 0

        features = {
            "Previous Crop Encoded": prev_crop_encoded,
            "Current Soil N": data.get("nitrogen", 50),
            "Current Soil P": data.get("phosphorus", 50),
            "Current Soil K": data.get("potassium", 50),
            "Soil pH": data.get("ph", 6.5),
            "Season Encoded": season_encoded,
            "Soil Moisture": data.get("moisture", 50)
        }

        prediction = predict("crop_rotation_model", features)
        
        # Map back prediction
        le_next = get_model("le_prev_crop") # Assuming same encoder for next crop
        if le_next:
            label = le_next.inverse_transform(prediction)[0]
        else:
            label = str(prediction[0])

        return {
            "recommended_next_crop": label.capitalize(),
            "soil_benefit": "Improves organic matter and Nitrogen levels."
        }
    except Exception as e:
        logger.error(f"Crop rotation service error: {e}")
        return {"error": str(e)}
