from model_loader import predict, get_model
import logging

logger = logging.getLogger(__name__)

def recommend_fertilizer(data: dict):
    """
    Service for fertilizer recommendation.
    """
    land_area = data.get("land_area", 1.0)
    print(f"Scaling results using land area: {land_area}")
    
    try:
        # Prepare features for fertilizer recommendation
        # Based on available encoders: le_crop_type_fert.pkl
        le_fert = get_model("le_crop_type_fert")
        crop_encoded = 0
        if le_fert:
            try:
                crop_encoded = le_fert.transform([data.get("crop_name", "rice")])[0]
            except:
                pass

        features = {
            "Soil N": data.get("nitrogen"),
            "Soil P": data.get("phosphorus"),
            "Soil K": data.get("potassium"),
            "Soil pH": data.get("ph", 6.5),
            "Soil Moisture": data.get("moisture", 50),
            "Crop Type Encoded": crop_encoded,
            "Temperature": data.get("temperature", 25),
            "Humidity": data.get("humidity", 60),
            "Rainfall": data.get("rainfall", 200)
        }
        
        # Validation
        for k, v in features.items():
            if v is None:
                return {"error": f"Missing value for {k}"}
        
        prediction = predict("fertilizer_model", features)
        
        # Map prediction back to label
        fert_map = ['10-26-26', '14-35-14', '17-17-17', '20-20', '28-28', 'DAP', 'Urea']
        pred_val = prediction[0]
        
        try:
            val_idx = int(pred_val)
            recommended_fertilizer = fert_map[val_idx] if val_idx < len(fert_map) else str(pred_val)
        except ValueError:
            recommended_fertilizer = str(pred_val)

        return {
            "recommended_fertilizer": recommended_fertilizer,
            "eco_friendly_option": "Organic Compost Mix",
            "quantity": round(20.0 * land_area, 2)
        }
    except Exception as e:
        logger.error(f"Fertilizer recommendation service error: {e}")
        return {"error": str(e)}
