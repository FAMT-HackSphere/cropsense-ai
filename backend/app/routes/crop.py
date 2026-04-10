from fastapi import APIRouter, HTTPException
from app.schemas.crop_schema import CropPredictRequest, CropPredictResponse
from app.services import predictor

router = APIRouter()

@router.post("/predict-crop", response_model=CropPredictResponse)
async def predict_crop(data: CropPredictRequest):
    try:
        result = predictor.predict_crop(data)
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
