from pydantic import BaseModel

class FertilizerRecommendRequest(BaseModel):
    crop_name: str
    nitrogen: float
    phosphorus: float
    potassium: float

class FertilizerRecommendResponse(BaseModel):
    recommended_fertilizer: str
    eco_friendly_option: str
    quantity: float
