from fastapi import APIRouter, HTTPException
from services.seed_service import recommend_seed

router = APIRouter()

@router.post("/seed")
async def recommend_seed_endpoint(data: dict):
    result = recommend_seed(data)
    if "error" in result:
        raise HTTPException(status_code=400, detail=result["error"])
    return result
