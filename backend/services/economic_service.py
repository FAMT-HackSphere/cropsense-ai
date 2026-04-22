from model_loader import predict, get_model
import logging

logger = logging.getLogger(__name__)

def analyze_economics(data: dict):
    """
    Service for economic analysis.
    """
    land_area = data.get("land_area", 1.0)
    print(f"Scaling results using land area: {land_area}")
    
    try:
        # Prepare features
        # le_crop_type_econ, scaler_econ are available
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
        
        # Prediction might be predicted profit or cost (assuming numeric prediction)
        prediction = predict("economic_model", features)
        result_val = float(prediction[0])

        # Base calculation (per acre)
        base_seed = data.get("seed_cost", 0)
        base_fert = data.get("fertilizer_cost", 0)
        base_labor = data.get("labor_cost", 0)
        base_irrigation = data.get("irrigation_cost", 0)
        
        total_cost_per_acre = base_seed + base_fert + base_labor + base_irrigation
        revenue_per_acre = data.get("yield_amount", 1.0) * data.get("market_price", 0.0)
        profit_per_acre = revenue_per_acre - total_cost_per_acre
        
        # Scaled values
        total_cost = total_cost_per_acre * land_area
        revenue = revenue_per_acre * land_area
        profit = profit_per_acre * land_area
        
        return {
            "total_cost": round(total_cost, 2),
            "revenue": round(revenue, 2),
            "profit": round(profit, 2),
            "roi": (profit / total_cost * 100) if total_cost > 0 else 0
        }
    except Exception as e:
        logger.error(f"Economic analysis service error: {e}")
        return {"error": str(e)}
