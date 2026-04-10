from app.schemas.fertilizer_schema import FertilizerRecommendRequest, FertilizerRecommendResponse
from app.database import crud

def recommend_fertilizer(data: FertilizerRecommendRequest) -> FertilizerRecommendResponse:
    # Rule-based logic initially
    if data.nitrogen < 50:
        result = FertilizerRecommendResponse(
            recommended_fertilizer="Urea",
            eco_friendly_option="Compost",
            quantity=25.0
        )
    elif data.phosphorus < 20:
        result = FertilizerRecommendResponse(
            recommended_fertilizer="DAP",
            eco_friendly_option="Rock Phosphate",
            quantity=15.0
        )
    else:
        result = FertilizerRecommendResponse(
            recommended_fertilizer="NPK 19-19-19",
            eco_friendly_option="Vermicompost",
            quantity=20.0
        )
    
    # Save to history tracking in Firestore
    crud.save_history({
        "user_input": data.dict(),
        "prediction_result": result.dict(),
        "type": "fertilizer_recommendation"
    })
    
    return result

