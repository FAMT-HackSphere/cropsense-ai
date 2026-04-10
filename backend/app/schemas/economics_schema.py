from pydantic import BaseModel
from typing import Optional

class EconomicAnalysisRequest(BaseModel):
    crop_name: str
    seed_cost: float
    fertilizer_cost: float
    labor_cost: float
    irrigation_cost: float
    yield_amount: float
    market_price: Optional[float] = None

class EconomicAnalysisResponse(BaseModel):
    total_cost: float
    revenue: float
    profit: float
    roi: float

