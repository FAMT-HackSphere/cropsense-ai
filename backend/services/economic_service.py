from model_loader import predict, get_model
import logging

logger = logging.getLogger(__name__)

def analyze_economics(data: dict):
    """
    Service for economic analysis using ML.
    """
    try:
        # Prepare features
        # le_crop_type_econ, scaler_econ are available
        features = {
            "crop_type": data.get("crop_name"),
            "yield_amount": data.get("yield_amount"),
            "market_price": data.get("market_price", 0.0)
        }
        
        # Validation
        for k, v in features.items():
            if v is None:
                return {"error": f"Missing value for {k}"}
        
        # Encoding
        le_econ = get_model("le_crop_type_econ")
        
        crop_encoded = 0
        if le_econ:
            try:
                val = data.get("crop_name", "Rice")
                try:
                    crop_encoded = le_econ.transform([val])[0]
                except:
                    crop_encoded = le_econ.transform([val.capitalize()])[0]
            except:
                pass
            
        features = {
            "Crop Type Encoded": crop_encoded,
            "Seed Cost": data.get("seed_cost", 0),
            "Fertilizer Cost": data.get("fertilizer_cost", 0),
            "Labor Cost": data.get("labor_cost", 0),
            "Irrigation Cost": data.get("irrigation_cost", 0),
            "Expected Yield": data.get("yield_amount", 1.0),
            "Market Price per ton": data.get("market_price", 0.0)
        }

        prediction = predict("economic_model", features)
        
        # Prediction might be predicted profit or cost
        result_val = float(prediction[0])

        total_cost = data.get("seed_cost", 0) + data.get("fertilizer_cost", 0) + data.get("labor_cost", 0) + data.get("irrigation_cost", 0)
        revenue = features["Expected Yield"] * features["Market Price per ton"]
        
        return {
            "total_cost": total_cost,
            "revenue": revenue,
            "predicted_profit": result_val,
            "roi": (result_val / total_cost * 100) if total_cost > 0 else 0
        }
    except Exception as e:
        logger.error(f"Economic analysis service error: {e}")
        return {"error": str(e)}
