from fastapi import APIRouter, HTTPException
from app.schemas.economics_schema import EconomicAnalysisRequest, EconomicAnalysisResponse
from app.services import economics_service

router = APIRouter()

@router.post("/economic-analysis", response_model=EconomicAnalysisResponse)
async def economic_analysis(data: EconomicAnalysisRequest):
    try:
        return economics_service.calculate_economics(data)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
