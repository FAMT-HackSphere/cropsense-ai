from fastapi import APIRouter, HTTPException
from services.rotation_service import recommend_rotation

router = APIRouter()

@router.post("/rotation")
async def recommend_rotation_endpoint(data: dict):
    result = recommend_rotation(data)
    if "error" in result:
        raise HTTPException(status_code=400, detail=result["error"])
    return result
