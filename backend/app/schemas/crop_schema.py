from pydantic import BaseModel
from typing import Optional

class CropPredictRequest(BaseModel):
    state: str
    district: str
    soil_type: str
    nitrogen: float
    phosphorus: float
    potassium: float
    ph: float
    rainfall: float
    temperature: float
    humidity: float
    season: str
    land_size: float
    budget: float
    irrigation: bool
    previous_crop: Optional[str] = None

class CropPredictResponse(BaseModel):
    recommended_crop: str
    seed_variety: str
    expected_yield: float
