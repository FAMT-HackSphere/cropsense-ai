import os
import json
import logging
from model_loader import predict_proba, get_classes, get_model

logger = logging.getLogger(__name__)

# Load configuration data
DATA_PATH = os.path.join(os.path.dirname(os.path.dirname(__file__)), "data", "farming_data.json")

def load_farming_data():
    try:
        with open(DATA_PATH, "r") as f:
            return json.load(f)
    except Exception as e:
        logger.error(f"Failed to load farming data: {e}")
        return {}

FARM_DATA = load_farming_data()

def get_recommendations(strategy, input_data):
    """
    Main entry point for farming strategy recommendations.
    """
    # Normalize input keys
    try:
        land_area = float(input_data.get("land_area", 1.0) or 1.0)
    except:
        land_area = 1.0

    norm_data = {
        "N": input_data.get("nitrogen", 50),
        "P": input_data.get("phosphorus", 50),
        "K": input_data.get("potassium", 50),
        "temperature": input_data.get("temperature", 25),
        "humidity": input_data.get("humidity", 60),
        "ph": input_data.get("ph", 6.5),
        "rainfall": input_data.get("rainfall", 100),
        "land_area": land_area
    }

    if strategy == "Orchard Farming":
        return _get_orchard_recommendations(norm_data)
    elif strategy == "Mixed Farming (Orchard + Seasonal Intercrop)":
        return _get_mixed_recommendations(norm_data)
    
    # Handle Seasonal Strategies
    return _get_strategy_based_seasonal(strategy, norm_data)

def _get_top_n_crops_raw(input_data, category_filter=None, n=10):
    """
    Gets top N crops filtered by category from ML model.
    """
    # Model features exclusion: land_area should not be passed to the model
    model_features = ["N", "P", "K", "temperature", "humidity", "ph", "rainfall"]
    filtered_input = {k: input_data[k] for k in model_features if k in input_data}
    
    probabilities = predict_proba("crop_recommendation_model", filtered_input)
    classes = get_classes("crop_recommendation_model")

    if not probabilities or not classes:
        return []

    crop_probs = []
    for i in range(len(probabilities)):
        crop_probs.append({"crop": classes[i], "probability": probabilities[i]})

    crop_probs.sort(key=lambda x: x["probability"], reverse=True)

    categories = FARM_DATA.get("crop_categories", {})
    if category_filter:
        valid_crops = categories.get(category_filter, [])
        return [cp for cp in crop_probs if cp["crop"] in valid_crops][:n]
    
    return crop_probs[:n]

def _get_strategy_based_seasonal(strategy, input_data):
    """
    Filters and ranks seasonal crops based on the specific farming strategy.
    """
    # Get more raw candidates to allow filtering
    raw_candidates = _get_top_n_crops_raw(input_data, category_filter="seasonal_crops", n=15)
    details = FARM_DATA.get("seasonal_crops_details", {})
    
    scored_candidates = []
    for candidate in raw_candidates:
        name = candidate["crop"]
        meta = details.get(name)
        if not meta: continue
        
        score = candidate["probability"] * 100 # base score from ML
        
        # Apply strategy weightings
        if strategy == "Short-Term Profit":
            # Prefer duration < 120 and high market demand
            if meta["duration"] <= 120: score += 20
            score += meta["market_demand"] * 2
        
        elif strategy == "Long-Term Soil Health":
            # Prefer N-fixing crops
            if meta["nitrogen_fixing"]: score += 40
            else: score -= 10
            
        elif strategy == "High Yield Intensive":
            # Prefer high input cost/commercial crops
            if meta["input_cost"] == "High": score += 25
            if meta["water"] == "High": score += 10
            
        elif strategy == "Low Investment Farming":
            # Prefer Low input cost
            if meta["input_cost"] == "Low": score += 30
            
        elif strategy == "Water Saving Farming":
            # Filter ONLY Low/Moderate water usage
            if meta["water"] == "High": score -= 50
            if meta["water"] == "Low": score += 30
            
        elif strategy == "Organic Farming":
            if meta["nitrogen_fixing"]: score += 20
            if meta["input_cost"] == "Low": score += 10

        scored_candidates.append({
            "name": name,
            "final_score": score,
            "probability": round(candidate["probability"] * 100, 1),
            "meta": meta
        })

    # Sort by strategic score
    scored_candidates.sort(key=lambda x: x["final_score"], reverse=True)
    top_3 = scored_candidates[:3]
    
    companions = FARM_DATA.get("companion_crop_map", {})
    results = []
    for item in top_3:
        m = item["meta"]
        results.append({
            "name": item["name"].capitalize(),
            "probability": item["probability"],
            "duration": f"{m['duration']} days",
            "water_requirement": m["water"],
            "seed_rate": m["seed_rate"],
            "season": m["season"],
            "companion_crops": companions.get(item["name"], [])
        })

    return {
        "strategy": strategy,
        "recommendations": results
    }

def _get_orchard_recommendations(input_data):
    top_orchard = _get_top_n_crops_raw(input_data, category_filter="orchard_crops", n=1)
    if not top_orchard:
        return {"error": "No suitable orchard crops found."}
    
    crop_name = top_orchard[0]["crop"]
    metrics = FARM_DATA.get("orchard_metrics", {}).get(crop_name, {})
    land_area = input_data["land_area"]
    
    plants_per_acre = metrics.get("plants_per_acre", 60)
    total_plants = int(plants_per_acre * land_area)
    investment = metrics.get("initial_investment_per_acre", 50000) * land_area
    
    return {
        "strategy": "Orchard Farming",
        "primary_crop": crop_name.capitalize(),
        "spacing": metrics.get("spacing", "8m x 8m"),
        "plants_per_acre": plants_per_acre,
        "total_plants": total_plants,
        "bearing_start": f"{metrics.get('bearing_start', 4)} years",
        "full_production": f"{metrics.get('full_production', 8)} years",
        "lifespan": f"{metrics.get('lifespan', 30)} years",
        "initial_investment": f"Estimated INR {investment:,.2f}",
        "yield_timeline": [
            {"year": metrics.get('bearing_start', 4), "yield_percent": "10-20%"},
            {"year": metrics.get('bearing_start', 4) + 2, "yield_percent": "50-60%"},
            {"year": metrics.get('full_production', 8), "yield_percent": "100%"}
        ]
    }

def _get_mixed_recommendations(input_data):
    orchard_res = _get_orchard_recommendations(input_data)
    if "error" in orchard_res:
        return orchard_res
    
    crop_name = orchard_res["primary_crop"].lower()
    intercrops = FARM_DATA.get("intercrop_map", {}).get(crop_name, ["vegetables", "pulses"])
    
    orchard_age = int(input_data.get("orchard_age", 0))
    status = "Heavy intercropping allowed"
    if orchard_age >= 8:
        status = "Minimal intercropping suggested (shaded canopy)"
        intercrops = intercrops[:1]
    elif orchard_age >= 4:
        status = "Moderate intercropping allowed"
        intercrops = intercrops[:2]
        
    orchard_res["strategy"] = "Mixed Farming"
    orchard_res["intercropping_status"] = status
    orchard_res["recommended_intercrops"] = [ic.capitalize() for ic in intercrops]
    
    return orchard_res
