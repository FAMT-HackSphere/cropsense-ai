import logging

logger = logging.getLogger(__name__)

# Deterministic Rotation Mappings
ROTATION_RULES = {
    "rice": {
        "next": "Chickpea",
        "reason": "Rice depletes Nitrogen significantly. Chickpea is a legume that fixes atmospheric Nitrogen, restoring soil fertility naturally.",
        "duration": "110-120 days"
    },
    "cotton": {
        "next": "Blackgram",
        "reason": "Cotton is a long-duration, nutrient-heavy crop. Blackgram (Urad) helps in soil recovery and breaks pest cycles.",
        "duration": "80-90 days"
    },
    "maize": {
        "next": "Soybean",
        "reason": "Maize is high in Nitrogen demand. Soybean replenishes soil Nitrogen and improves organic matter content.",
        "duration": "100-110 days"
    },
    "wheat": {
        "next": "Mustard",
        "reason": "Rotating with Mustard helps break the monoculture of cereals, improves soil health, and has low water requirements.",
        "duration": "110-120 days"
    },
    "groundnut": {
        "next": "Maize",
        "reason": "Groundnut fixes Nitrogen; following it with Maize allows the cereal to utilize the residual soil Nitrogen efficiently.",
        "duration": "110-120 days"
    },
    "soybean": {
        "next": "Wheat",
        "reason": "Soybean leaves the soil enriched with Nitrogen, which provides an excellent foundation for the subsequent wheat crop.",
        "duration": "120-130 days"
    }
}

DEFAULT_ROTATION = {
    "next": "Green Gram (Moong)",
    "reason": "Moong is a versatile, short-duration legume that improves soil health through Nitrogen fixation and organic enrichment.",
    "duration": "70-80 days"
}

def recommend_rotation(data: dict):
    """
    Service for deterministic crop rotation recommendation.
    """
    try:
        prev_crop = data.get("current_crop", "").lower().strip()
        
        # Priority mapping
        rule = ROTATION_RULES.get(prev_crop, DEFAULT_ROTATION)
        
        return {
            "recommended_next_crop": rule["next"],
            "benefit": rule["reason"],
            "rotation_duration": rule["duration"],
            "scientific_explanation": f"Based on the previous cultivation of {prev_crop.capitalize()}, rotating with {rule['next']} is recommended because {rule['reason']}"
        }

    except Exception as e:
        logger.error(f"Crop rotation service error: {e}")
        return {"error": str(e)}
