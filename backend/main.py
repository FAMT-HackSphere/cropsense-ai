from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routes import crop_routes, fertilizer_routes, rotation_routes, seed_routes, economic_routes
import model_loader

app = FastAPI(
    title="CropSense AI API",
    description="Backend API for machine learning powered agricultural recommendations",
    version="2.0.0"
)

# Step 10 & 7: Enable CORS for Flutter Connectivity
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], # Allow all for development, restrict for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Step 5 & 7: Connect All Routes
app.include_router(crop_routes.router, prefix="/predict", tags=["Crop Prediction"])
app.include_router(fertilizer_routes.router, prefix="/predict", tags=["Fertilizer Recommendation"])
app.include_router(rotation_routes.router, prefix="/predict", tags=["Crop Rotation"])
app.include_router(seed_routes.router, prefix="/predict", tags=["Seed Variety"])
app.include_router(economic_routes.router, prefix="/predict", tags=["Economic Analysis"])

# Step 8: Add Health Check Endpoint
@app.get("/health")
async def health_check():
    models = model_loader._MODELS
    core_models = [
        "crop_recommendation_model",
        "fertilizer_model",
        "crop_rotation_model",
        "seed_variety_model",
        "economic_model"
    ]
    
    loaded_core = [m for m in core_models if m in models]
    
    return {
        "status": "ok",
        "models_loaded": len(loaded_core) == len(core_models),
        "model_count": len(loaded_core),
        "total_artifacts_loaded": len(models)
    }

@app.get("/")
async def root():
    return {"message": "CropSense AI ML Backend is active"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
