from app.database import crud

def get_market_price(crop_name: str) -> float:
    # Try fetching from Firestore
    price = crud.get_market_price(crop_name)
    if price is not None:
        return price
    
    # Fallback default prices
    default_prices = {
        "Rice": 2.50,
        "Wheat": 2.20,
        "Maize": 1.80,
        "Cotton": 1.50
    }
    return default_prices.get(crop_name, 2.00)
