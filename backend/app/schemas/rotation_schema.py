from pydantic import BaseModel

class CropRotationRequest(BaseModel):
    current_crop: str
    season: str

class CropRotationResponse(BaseModel):
    recommended_next_crop: str
    soil_benefit: str
