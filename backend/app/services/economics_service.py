from app.schemas.economics_schema import EconomicAnalysisRequest, EconomicAnalysisResponse
from app.database import crud

def calculate_economics(data: EconomicAnalysisRequest) -> EconomicAnalysisResponse:
    # Use provided market price or fetch from Firestore
    market_price = data.market_price
    if market_price is None:
        market_price = crud.get_market_price(data.crop_name)
        if market_price is None:
            # Default or error if Price not found in DB
            market_price = 0.0
            
    total_cost = data.seed_cost + data.fertilizer_cost + data.labor_cost + data.irrigation_cost
    revenue = data.yield_amount * market_price
    profit = revenue - total_cost
    roi = (profit / total_cost) * 100 if total_cost > 0 else 0
    
    result = EconomicAnalysisResponse(
        total_cost=total_cost,
        revenue=revenue,
        profit=profit,
        roi=roi
    )
    
    # Save to history tracking in Firestore
    crud.save_history({
        "user_input": data.dict(),
        "prediction_result": result.dict(),
        "type": "economic_analysis"
    })
    
    return result

