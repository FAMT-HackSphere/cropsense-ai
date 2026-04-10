from fastapi import APIRouter, HTTPException
from app.schemas.fertilizer_schema import (
    FertilizerRecommendRequest,
    FertilizerRecommendResponse
)
from app.services import fertilizer_service

router = APIRouter()

@router.post("/recommend-fertilizer", response_model=FertilizerRecommendResponse)
async def recommend_fertilizer(data: FertilizerRecommendRequest):
    try:
        return fertilizer_service.recommend_fertilizer(data)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))