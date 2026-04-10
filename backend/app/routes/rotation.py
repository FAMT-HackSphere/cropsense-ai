from fastapi import APIRouter, HTTPException
from app.schemas.rotation_schema import CropRotationRequest, CropRotationResponse
from app.services import rotation_service

router = APIRouter()

@router.post("/crop-rotation", response_model=CropRotationResponse)
async def crop_rotation(data: CropRotationRequest):
    try:
        return rotation_service.suggest_crop_rotation(data)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
