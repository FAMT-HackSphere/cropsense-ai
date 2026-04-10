from fastapi import APIRouter, HTTPException
from services.economic_service import analyze_economics

router = APIRouter()

@router.post("/economic")
async def analyze_economics_endpoint(data: dict):
    result = analyze_economics(data)
    if "error" in result:
        raise HTTPException(status_code=400, detail=result["error"])
    return result
