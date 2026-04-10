from app.schemas.rotation_schema import CropRotationRequest, CropRotationResponse
from app.database import crud

def suggest_crop_rotation(data: CropRotationRequest) -> CropRotationResponse:
    # Suggest next crop using crop rotation rules
    rotation_rules = {
        "Rice": "Wheat",
        "Wheat": "Legumes",
        "Legumes": "Maize",
        "Maize": "Rice"
    }
    next_crop = rotation_rules.get(data.current_crop, "Legumes")
    result = CropRotationResponse(
        recommended_next_crop=next_crop,
        soil_benefit="Nitrogen Fixation" if next_crop == "Legumes" else "Soil Organic Matter Improve"
    )
    
    # Save to history tracking in Firestore
    crud.save_history({
        "user_input": data.dict(),
        "prediction_result": result.dict(),
        "type": "crop_rotation"
    })
    
    return result

