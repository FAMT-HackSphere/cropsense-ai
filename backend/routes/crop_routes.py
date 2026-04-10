from fastapi import APIRouter, HTTPException
from services.crop_service import predict_crop

router = APIRouter()

@router.post("/crop")
async def predict_crop_endpoint(data: dict):
    result = predict_crop(data)
    if "error" in result:
        raise HTTPException(status_code=400, detail=result["error"])
    return result
