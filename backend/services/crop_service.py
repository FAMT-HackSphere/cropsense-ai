from model_loader import predict, get_model
import logging
from services.reasoning_service import generate_scientific_explanation
from services.farming_strategy_service import get_recommendations

logger = logging.getLogger(__name__)

def predict_crop(data: dict):
    """
    Service for crop recommendation with Farming Strategy support.
    """
    land_area = data.get("land_area", 1.0)
    strategy = data.get("farming_strategy", "Seasonal Farming")
    
    try:
        # Get structured recommendations based on strategy
        strategy_result = get_recommendations(strategy, data)
        
        if "error" in strategy_result:
            return strategy_result

        # For backward compatibility and identifying the primary crop for other services
        if strategy == "Seasonal Farming":
            recs = strategy_result.get("recommendations", [])
            if not recs:
                return {"error": "No highly suitable seasonal crops found for these conditions and strategy."}
            primary_crop = recs[0]["name"]
        else:
            primary_crop = strategy_result.get("primary_crop")
            if not primary_crop:
                 return {"error": "No suitable crops found for the selected Orchard/Mixed strategy."}

        # Generate scientific explanation
        # Reasoning service can be upgraded later to handle strategy-specific text
        explanation = generate_scientific_explanation(data, primary_crop)

        # Merge results
        result = {
            "recommended_crop": primary_crop, # Keep for compatibility with rotation/fertilizer
            "strategy_data": strategy_result,
            "scientific_explanation": explanation
        }
        
        return result
        
    except Exception as e:
        logger.error(f"Crop prediction service error: {e}")
        return {"error": str(e)}
