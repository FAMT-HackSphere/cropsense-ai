from fastapi import APIRouter, HTTPException
from services.fertilizer_service import recommend_fertilizer

router = APIRouter()

@router.post("/fertilizer")
async def recommend_fertilizer_endpoint(data: dict):
    result = recommend_fertilizer(data)
    if "error" in result:
        raise HTTPException(status_code=400, detail=result["error"])
    return result
