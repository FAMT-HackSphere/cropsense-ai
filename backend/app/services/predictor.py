import joblib
import os
import numpy as np
from app.schemas.crop_schema import CropPredictRequest, CropPredictResponse
from app.database import crud

# Service for handling ML prediction logic

import sys

# Ensure ml models are accessible at the root level
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "../../../")))

def predict_crop(data: CropPredictRequest) -> CropPredictResponse:
    try:
        # Pydantic validation handles parsing inputs.
        # Ensure column order matches training data: N, P, K, temperature, humidity, ph, rainfall
        input_data = {
            "N": data.nitrogen,
            "P": data.phosphorus,
            "K": data.potassium,
            "temperature": data.temperature,
            "humidity": data.humidity,
            "ph": data.ph,
            "rainfall": data.rainfall
        }
        
        from ml import model_loader
        res = model_loader.predict("crop_recommendation_model", input_data)
        
        if "error" in res:
            print(f"ML Prediction failed: {res['error']}. Falling back to rule-based.")
            result = fallback_prediction(data)
        else:
            # The model outputs a number since it was label encoded. 
            # We map it back to crop strings statically.
            crop_labels = ['apple', 'banana', 'blackgram', 'chickpea', 'coconut', 'coffee', 'cotton', 'grapes', 'jute', 'kidneybeans', 'lentil', 'maize', 'mango', 'mothbeans', 'mungbean', 'muskmelon', 'orange', 'papaya', 'pigeonpeas', 'pomegranate', 'rice', 'watermelon']
            pred_idx = int(res["prediction"][0])
            pred_label = crop_labels[pred_idx] if 0 <= pred_idx < len(crop_labels) else "Unknown"

            result = CropPredictResponse(
                recommended_crop=pred_label.capitalize(),
                seed_variety="Standard",
                expected_yield=5.0
            )
    except Exception as e:
        print(f"Prediction Error: {e}. Falling back to rule-based.")
        result = fallback_prediction(data)
    
    # Save to history tracking in Firestore
    crud.save_history({
        "user_input": data.dict(),
        "prediction_result": result.dict(),
        "type": "crop_prediction"
    })
    
    return result

def fallback_prediction(data: CropPredictRequest) -> CropPredictResponse:
    # Rule-based logic has been removed to ensure the system is genuinely AI-driven.
    # If this is hit, it means the ML model failed to load or infer.
    print("CRITICAL: ML Model Inference Failed. No fallback logic available.")
    return CropPredictResponse(
        recommended_crop="Prediction Unavailable",
        seed_variety="N/A",
        expected_yield=0.0
    )
