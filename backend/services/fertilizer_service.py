from model_loader import predict, get_model
import logging

logger = logging.getLogger(__name__)

def recommend_fertilizer(data: dict):
    """
    Service for fertilizer recommendation.
    """
    try:
        # Prepare features for fertilizer recommendation
        # Based on available encoders: le_crop_type_fert.pkl
        # Encoding for Crop Type if needed
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
        # Check le_crop_type_fert or similar
        # Fallback to standard 7-class fertilizer mapping if numeric
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
            "quantity": 20.0
        }
    except Exception as e:
        logger.error(f"Fertilizer recommendation service error: {e}")
        return {"error": str(e)}
